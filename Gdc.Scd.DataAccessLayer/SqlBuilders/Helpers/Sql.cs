﻿using System;
using System.Collections.Generic;
using System.Linq;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Impl;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Interfaces;

namespace Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers
{
    public static class Sql
    {
        public static SqlHelper With(ISqlBuilder query, params WithQuery[] withQueries)
        {
            return new SqlHelper(new WithSqlBuilder
            {
                Query = query,
                WithQueries = withQueries
            });
        }

        public static SqlHelper With(SqlHelper query, params WithQuery[] withQueries)
        {
            return With(query.ToSqlBuilder(), withQueries);
        }

        public static SqlHelper Union(IEnumerable<ISqlBuilder> queries, bool all = false)
        {
            var queriesArray = queries.ToArray();

            if (queriesArray.Length == 0)
            {
                throw new ArgumentException($"{nameof(queries)} don't have items", nameof(queries));
            }

            var query = queriesArray[0];

            for (var index = 1; index < queriesArray.Length; index++)
            {
                query = new UnionSqlBuilder
                {
                    All = all,
                    Query1 = query,
                    Query2 = queriesArray[index]
                };
            }

            return new SqlHelper(query);
        }

        public static SqlHelper Queries(IEnumerable<ISqlBuilder> queries)
        {
            return new SqlHelper(new SeveralQuerySqlBuilder { Queries = queries });
        }

        public static SqlHelper Queries(IEnumerable<SqlHelper> queries)
        {
            return new SqlHelper(new SeveralQuerySqlBuilder
            {
                Queries = queries.Select(query => query.ToSqlBuilder())
            });
        }

        public static SelectSqlHelper Select(params BaseColumnInfo[] columns)
        {
            return Select(false, columns);
        }

        public static SelectSqlHelper Select(params string[] columnNames)
        {
            var columns = GetColumnInfos(columnNames).ToArray();

            return Select(false, columns);
        }

        public static SelectSqlHelper SelectDistinct(params string[] columnNames)
        {
            var columns = GetColumnInfos(columnNames).ToArray();

            return Select(true, columns);
        }

        public static SelectSqlHelper SelectDistinct(params BaseColumnInfo[] columns)
        {
            return Select(true, columns);
        }

        public static UpdateSqlHelper Update(string dataBase, string schema, string table, params BaseUpdateColumnInfo[] columns)
        {
            var queryColumns = new List<QueryUpdateColumnInfo>();

            foreach (var column in columns)
            {
                var queryColumn = column as QueryUpdateColumnInfo;
                if (queryColumn == null)
                {
                    var valueColumn = (ValueUpdateColumnInfo)column;

                    queryColumn = new QueryUpdateColumnInfo(
                        valueColumn.Name,
                        new ParameterSqlBuilder
                        {
                            ParamInfo = new CommandParameterInfo
                            {
                                Name = valueColumn.ParameterName ?? valueColumn.Name,
                                Value = valueColumn.Value
                            }
                        });
                }

                queryColumns.Add(queryColumn);
            }

            var updateBuilder = new UpdateSqlBuilder()
            {
                DataBaseName = dataBase,
                SchemaName = schema,
                TableName = table,
                Columns = queryColumns
            };

            return new UpdateSqlHelper(updateBuilder);
        }

        public static UpdateSqlHelper Update(string schema, string table, params BaseUpdateColumnInfo[] columns)
        {
            return Update(null, schema, table, columns);
        }

        public static UpdateSqlHelper Update(string table, params BaseUpdateColumnInfo[] columns)
        {
            return Update(null, table, columns);
        }

        public static UpdateSqlHelper Update(BaseEntityMeta meta, params BaseUpdateColumnInfo[] columns)
        {
            return Update(null, meta.Schema, meta.Name, columns);
        }

        public static InsertSqlHelper Insert(string schema, string table, params string[] columns)
        {
            return new InsertSqlHelper(new InsertSqlBuilder
            {
                Schema = schema,
                Table = table,
                Columns = columns
            });
        }

        public static InsertSqlHelper Insert(string table, params string[] columns)
        {
            return Insert(null, table, columns);
        }

        public static InsertSqlHelper Insert(BaseEntityMeta entityMeta, params string[] fields)
        {
            return Insert(entityMeta.Schema, entityMeta.Name, fields);
        }

        public static DeleteSqlHelper Delete(string dataBase, string schema, string table)
        {
            var delBuilder = new FromSqlBuilder
            {
                Query = new DeleteSqlBuilder(),
                From = new TableSqlBuilder { DataBase = dataBase, Schema =schema, Name = table }
            };

            return new DeleteSqlHelper(delBuilder);
        }

        public static DeleteSqlHelper Delete(string schema, string table)
        {
            return Delete(null, schema, table);
        }

        public static DeleteSqlHelper Delete(string table)
        {
            return Delete(null, null, table);
        }

        private static SelectSqlHelper Select(bool isDistinct, params BaseColumnInfo[] columns)
        {
            var selectBuilder = new SelectSqlBuilder
            {
                IsDistinct = isDistinct,
                Columns = columns.Select(GetColumnSqlBuilder)
            };

            return new SelectSqlHelper(selectBuilder);
        }

        private static ISqlBuilder GetColumnSqlBuilder(BaseColumnInfo baseColumnInfo)
        {
            ISqlBuilder builder;

            var queryColumnInfo = baseColumnInfo as QueryColumnInfo;
            if (queryColumnInfo == null)
            {
                var columnInfo = (ColumnInfo)baseColumnInfo;

                builder = new ColumnSqlBuilder
                {
                    Name = columnInfo.Name,
                    Table = columnInfo.TableName
                };

                if (!string.IsNullOrWhiteSpace(baseColumnInfo.Alias))
                {
                    builder = new AliasSqlBuilder
                    {
                        Query = builder,
                        Alias = baseColumnInfo.Alias
                    };
                }
            }
            else 
            {
                var bracketsSqlBuilder = new BracketsSqlBuilder
                {
                    Query = queryColumnInfo.Query
                };

                if (string.IsNullOrWhiteSpace(baseColumnInfo.Alias))
                {
                    builder = bracketsSqlBuilder;
                }
                else
                {
                    builder = new AliasSqlBuilder
                    {
                        Alias = baseColumnInfo.Alias,
                        Query = bracketsSqlBuilder
                    };
                }
            }

            return builder;
        }

        private static IEnumerable<ColumnInfo> GetColumnInfos(IEnumerable<string> columnNames)
        {
            return columnNames.Select(name => new ColumnInfo { Name = name });
        }
    }
}
