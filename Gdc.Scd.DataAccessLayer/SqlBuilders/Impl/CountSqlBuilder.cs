﻿using System.Collections.Generic;
using System.Linq;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Interfaces;

namespace Gdc.Scd.DataAccessLayer.SqlBuilders.Impl
{
    public class CountSqlBuilder : ISqlBuilder
    {
        public bool IsDisctinct { get; set; }

        public string ColumnName { get; set; }

        public string TableName { get; set; }

        public string Build(SqlBuilderContext context)
        {
            var distinct = this.IsDisctinct ? "DISTINCT" : string.Empty;

            string column;

            if (string.IsNullOrEmpty(this.ColumnName))
            {
                column = "*";
            }
            else
            {
                var columnBuilder = new ColumnSqlBuilder { Table = this.TableName, Name = this.ColumnName };

                column = columnBuilder.Build(context);
            }

            return $"COUNT({distinct} {column})";
        }

        public IEnumerable<ISqlBuilder> GetChildrenBuilders()
        {
            return Enumerable.Empty<ISqlBuilder>();
        }
    }
}
