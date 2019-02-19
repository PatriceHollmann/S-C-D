﻿using System.Linq;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Impl;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Interfaces;

namespace Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers
{
    public class OrderBySqlHelper : UnionSqlHelper, IOrderBySqlHelper<UnionSqlHelper>, IQueryInfoSqlHelper
    {
        public OrderBySqlHelper(ISqlBuilder sqlBuilder)
            : base(sqlBuilder)
        {
        }

        public UnionSqlHelper OrderBy(params OrderByInfo[] infos)
        {
            return new UnionSqlHelper(new OrderBySqlBuilder
            {
                Query = this.ToSqlBuilder(),
                OrderByInfos = infos
            });
        }

        public UnionSqlHelper OrderBy(SortDirection direction, params ColumnInfo[] columns)
        {
            var orderByInfos = columns.Select(column => new OrderByInfo
            {
                Direction = direction,
                SqlBuilder = new ColumnSqlBuilder
                {
                    Table = column.TableName,
                    Name = column.Name
                }
            }).ToArray();

            return this.OrderBy(orderByInfos);
        }

        public SqlHelper ByQueryInfo(QueryInfo queryInfo)
        {
            SqlHelper query;

            if (queryInfo == null)
            {
                query = this;
            }
            else if (queryInfo.Skip.HasValue || queryInfo.Take.HasValue)
            {
                const string InnerTableAlias = "t";
                const string RowNumberAlias = "RowNumber";

                var skip = queryInfo.Skip ?? 0;
                var take = queryInfo.Take ?? 0;

                query
                    = Sql.Select()
                         .FromQuery(
                             Sql.Select(new ColumnInfo(null, InnerTableAlias), SqlFunctions.RowNumber(queryInfo.Sort, RowNumberAlias))
                                .FromQuery(this, InnerTableAlias),
                             "t2")
                         .Where(SqlOperators.Between(RowNumberAlias, skip, skip + take));
            }
            else
            {
                query = this.OrderBy(queryInfo.Sort.Direction, new ColumnInfo(queryInfo.Sort.Property));
            }

            return query;
        }
    }
}
