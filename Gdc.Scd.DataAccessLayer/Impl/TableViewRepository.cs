﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Entities;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers;

namespace Gdc.Scd.DataAccessLayer.Impl
{
    public class TableViewRepository : ITableViewRepository
    {
        private const char AliasSeparator = '.';

        private readonly IRepositorySet repositorySet;

        private readonly ISqlRepository sqlRepository;

        public TableViewRepository(IRepositorySet repositorySet, ISqlRepository sqlRepository)
        {
            this.repositorySet = repositorySet;
            this.sqlRepository = sqlRepository;
        }

        public async Task<DataInfo<TableViewRecord>> GetRecords(
            TableViewCostBlockInfo[] costBlockInfos, 
            QueryInfo queryInfo, 
            IDictionary<ColumnInfo, IEnumerable<object>> filter = null)
        {
            var coordinateFieldInfos = this.GetCoordinateFieldInfos(costBlockInfos);
            var columnInfo = this.BuildTableViewColumnInfo(costBlockInfos, coordinateFieldInfos);
            var columns = columnInfo.IdColumns.Concat(columnInfo.DataColumns).ToArray();

            if (queryInfo.Sort == null)
            {
                queryInfo.Sort = new SortInfo
                {
                    Direction = SortDirection.Asc,
                    Property = columns[0].Alias
                };
            }

            var recordsQuery = 
                this.BuildGetRecordsQuery(costBlockInfos, coordinateFieldInfos, filter, columns)
                    .ByQueryInfo(queryInfo);

            var records = await this.repositorySet.ReadBySql(recordsQuery, reader =>
            {
                var record = new TableViewRecord();

                foreach (var column in columnInfo.IdColumns)
                {
                    record.Ids.Add(column.Alias, (long)reader[column.Alias]);
                }

                foreach (var column in columnInfo.DataColumns)
                {
                    record.Data.Add(column.Alias, reader[column.Alias]);
                }

                return record;
            });

            var firstColumn = columns[0];
            var countColumn = SqlFunctions.Count(firstColumn.Name, tableName: firstColumn.TableName);
            var countQuery = this.BuildGetRecordsQuery(costBlockInfos, coordinateFieldInfos, filter, countColumn);

            var count = (await this.repositorySet.ReadBySql(countQuery, reader => reader.GetInt32(0))).First();

            return new DataInfo<TableViewRecord>
            {
                Items = records,
                Total = count
            };
        }

        public async Task UpdateRecords(TableViewCostBlockInfo[] costBlockInfos, IEnumerable<TableViewRecord> records)
        {
            var queries = new List<SqlHelper>();
            var fieldDictionary = costBlockInfos.ToDictionary(
                info => info.Meta.Name, 
                info => new
                {
                    QueryInfo = info,
                    FieldsHashSet = new HashSet<string>(info.CostElementIds)
                });

            foreach (var record in records)
            {
                var idInfos =
                    record.Ids.Select(keyValue => new { Column = this.ParseColumnAlias(keyValue.Key), Id = keyValue.Value })
                              .ToDictionary(idInfo => idInfo.Column.TableName);

                var groupedData =
                    record.Data.Select(keyValue => new { Column = this.ParseColumnAlias(keyValue.Key), Value = keyValue.Value })
                               .GroupBy(dataInfo => dataInfo.Column.TableName);

                foreach (var data in groupedData)
                {
                    if (fieldDictionary.TryGetValue(data.Key, out var info))
                    {
                        foreach (var dataInfo in data)
                        {
                            if (!info.FieldsHashSet.Contains(dataInfo.Column.Name))
                            {
                                throw new Exception($"Invalid column {dataInfo.Column.Name} from table {dataInfo.Column.TableName}");
                            }
                        }
                    }
                    else
                    {
                        throw new Exception($"Invalid table {data.Key}");
                    }

                    var updateColumns = data.Select(dataInfo => new ValueUpdateColumnInfo(
                        dataInfo.Column.Name, 
                        dataInfo.Value, 
                        $"{dataInfo.Column.TableName}_{dataInfo.Column.Name}_{queries.Count}"));

                    var idInfo = idInfos[data.Key];

                    var query = 
                        Sql.Update(info.QueryInfo.Meta, updateColumns.ToArray())
                           .Where(SqlOperators.Equals(idInfo.Column.Name, idInfo.Column.Name, idInfo.Id, idInfo.Column.TableName));

                    queries.Add(query);
                }
            }

            await this.repositorySet.ExecuteSqlAsync(Sql.Queries(queries));
        }

        public async Task<IDictionary<string, IEnumerable<NamedId>>> GetFilters(TableViewCostBlockInfo[] costBlockInfos)
        {
            var result = new Dictionary<string, IEnumerable<NamedId>>();
            var coordinateFields = this.GetCoordinateFieldInfos(costBlockInfos).Select(fieldInfo => fieldInfo.CoordinateField);

            foreach (var field in coordinateFields)
            {
                var items = await this.sqlRepository.GetNameIdItems(field.ReferenceMeta, field.ReferenceValueField, field.ReferenceFaceField);

                result.Add(field.Name, items);
            }

            return result;
        }

        public async Task<IDictionary<string, IEnumerable<NamedId>>> GetReferences(TableViewCostBlockInfo[] costBlockInfos)
        {
            var result = new Dictionary<string, IEnumerable<NamedId>>();

            foreach (var costBlockInfo in costBlockInfos)
            {
                foreach (var costElementId in costBlockInfo.CostElementIds)
                {
                    if (costBlockInfo.Meta.CostElementsFields[costElementId] is ReferenceFieldMeta field)
                    {
                        var items = await this.sqlRepository.GetNameIdItems(field.ReferenceMeta, field.ReferenceValueField, field.ReferenceFaceField);
                        var key = this.BuildColumnAlias(costBlockInfo.Meta, field);

                        result.Add(key, items);
                    }
                }
            }

            return result;
        }

        private GroupBySqlHelper BuildGetRecordsQuery(
            TableViewCostBlockInfo[] costBlockInfos, 
            IEnumerable<CoordinateFieldInfo> coordinateFieldInfos,
            IDictionary<ColumnInfo, IEnumerable<object>> filter,
            params BaseColumnInfo[] columns)
        {
            var firstCostBlockInfo = costBlockInfos[0];
            var joinQuery = Sql.Select(columns).From(firstCostBlockInfo.Meta);
            var joinedCostBlocks = new List<TableViewCostBlockInfo> { firstCostBlockInfo };

            for (var index = 1; index < costBlockInfos.Length; index++)
            {
                var costBlockInfo = costBlockInfos[index];
                var conditions = new List<ConditionHelper>();

                foreach (var coordinateField in costBlockInfo.Meta.CoordinateFields)
                {
                    var conditionInfo = joinedCostBlocks.FirstOrDefault(
                        joinedCostBlock => joinedCostBlock.Meta.ContainsCoordinateField(coordinateField.Name));

                    if (conditionInfo != null)
                    {
                        conditions.Add(SqlOperators.Equals(
                            new ColumnInfo(coordinateField.Name, conditionInfo.Meta.Name),
                            new ColumnInfo(coordinateField.Name, costBlockInfo.Meta.Name)));
                    }
                }

                joinQuery = joinQuery.Join(costBlockInfo.Meta, ConditionHelper.And(conditions));

                joinedCostBlocks.Add(costBlockInfo);
            }

            var joinInfos = coordinateFieldInfos.Select(info => new JoinInfo(info.Meta, info.CoordinateField.Name));

            return joinQuery.Join(joinInfos).Where(filter);
        }

        private string BuildColumnAlias(BaseEntityMeta meta, FieldMeta field)
        {
            return $"{meta.Name}{AliasSeparator}{field.Name}";
        }

        private ColumnInfo ParseColumnAlias(string columnAlias)
        {
            var values = columnAlias.Split(AliasSeparator);

            return new ColumnInfo(values[1], values[0], columnAlias);
        }

        private TableViewColumnInfo BuildTableViewColumnInfo(IEnumerable<TableViewCostBlockInfo> costBlockInfos, IEnumerable<CoordinateFieldInfo> coordinateFieldInfos)
        {
            var coordinateColumns = coordinateFieldInfos.Select(
                info => new ColumnInfo(info.CoordinateField.ReferenceFaceField, info.CoordinateField.ReferenceMeta.Name, info.CoordinateField.Name));

            var costElementColumns = new List<ColumnInfo>();
            var idColumns = new List<ColumnInfo>();

            foreach (var info in costBlockInfos)
            {
                costElementColumns.AddRange(
                    info.CostElementIds.Select(info.Meta.GetField)
                                   .Select(field => new ColumnInfo(
                                        field.Name, 
                                        info.Meta.Name, 
                                        this.BuildColumnAlias(info.Meta, field))));

                idColumns.Add(new ColumnInfo(info.Meta.IdField.Name, info.Meta.Name, this.BuildColumnAlias(info.Meta, info.Meta.IdField)));
            }

            return new TableViewColumnInfo
            {
                IdColumns = idColumns.ToArray(),
                DataColumns = coordinateColumns.Concat(costElementColumns).ToArray()
            };
        }

        private IEnumerable<CoordinateFieldInfo> GetCoordinateFieldInfos(IEnumerable<TableViewCostBlockInfo> costBlockInfos)
        {
            var coordinateHashSet = new HashSet<string>();
            var coordinateFieldInfos = new List<CoordinateFieldInfo>();

            foreach (var info in costBlockInfos)
            {
                foreach (var field in info.Meta.CoordinateFields)
                {
                    if (!coordinateHashSet.Contains(field.Name))
                    {
                        coordinateHashSet.Add(field.Name);
                        coordinateFieldInfos.Add(new CoordinateFieldInfo
                        {
                            Meta = info.Meta,
                            CoordinateField = field
                        });
                    }
                }
            }

            return coordinateFieldInfos;
        }

        private class CoordinateFieldInfo
        {
            public CostBlockEntityMeta Meta { get; set; }

            public ReferenceFieldMeta CoordinateField { get; set; }
        }

        private class TableViewColumnInfo
        {
            public ColumnInfo[] IdColumns { get; set; }

            public ColumnInfo[] DataColumns { get; set; }
        }
    }
}
