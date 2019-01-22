﻿using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Helpers;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Impl;

namespace Gdc.Scd.DataAccessLayer.Impl
{
    public class CostEditorRepository : ICostEditorRepository
    {
        private readonly IRepositorySet repositorySet;

        private readonly DomainEnitiesMeta domainEnitiesMeta;

        public CostEditorRepository(IRepositorySet repositorySet, DomainEnitiesMeta domainEnitiesMeta)
        {
            this.repositorySet = repositorySet;
            this.domainEnitiesMeta = domainEnitiesMeta;
        }

        public async Task<IEnumerable<EditItem>> GetEditItems(CostEditorContext context, IDictionary<string, long[]> filter)
        {
            return await this.GetEditItems(context, filter.Convert());
        }

        public async Task<IEnumerable<EditItem>> GetEditItems(CostEditorContext context, IDictionary<string, IEnumerable<object>> filter = null)
        {
            var costBlockMeta = this.domainEnitiesMeta.GetCostBlockEntityMeta(context);
            var nameField = costBlockMeta.InputLevelFields[context.InputLevelId];

            var nameColumn = new ColumnInfo(nameField.ReferenceFaceField, nameField.ReferenceMeta.Name);
            var nameIdColumn = new ColumnInfo(nameField.ReferenceValueField, nameField.ReferenceMeta.Name);
            var countColumn = SqlFunctions.Count(context.CostElementId, true, costBlockMeta.Name);

            QueryColumnInfo maxValueColumn;

            var valueField = costBlockMeta.CostElementsFields[context.CostElementId];
            var simpleValueField = valueField as SimpleFieldMeta;
            if (simpleValueField != null && simpleValueField.Type == TypeCode.Boolean)
            {
                var valueColumn = new ColumnSqlBuilder { Name = simpleValueField.Name };

                maxValueColumn = SqlFunctions.Max(
                    SqlFunctions.Convert(valueColumn, TypeCode.Int32),
                    costBlockMeta.Name);
            }
            else
            {
                maxValueColumn = SqlFunctions.Max(context.CostElementId, costBlockMeta.Name);
            }

            var query =
                Sql.Select(nameIdColumn, nameColumn, maxValueColumn, countColumn)
                   .From(costBlockMeta)
                   .Join(costBlockMeta, nameField.Name)
                   .WhereNotDeleted(costBlockMeta, filter, costBlockMeta.Name)
                   .GroupBy(nameColumn, nameIdColumn)
                   .OrderBy(new OrderByInfo
                   {
                       Direction = SortDirection.Asc,
                       SqlBuilder = new ColumnSqlBuilder
                       {
                           Table = nameColumn.TableName,
                           Name = nameColumn.Name
                       }
                   });

            return await this.repositorySet.ReadBySql(query, reader =>
            {
                var valueCount = reader.GetInt32(3);

                return new EditItem
                {
                    Id = reader.GetInt64(0),
                    Name = reader.GetString(1),
                    Value = valueCount == 1 ? reader.GetValue(2) : null,
                    ValueCount = valueCount,
                };
            });
        }
    }
}
