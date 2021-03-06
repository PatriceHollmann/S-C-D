﻿using System.Text;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;

namespace Gdc.Scd.DataAccessLayer.SqlBuilders.Impl
{
    public class ColumnSqlBuilder : NameSqlBuilder
    {
        public string Table { get; set; }

        public ColumnSqlBuilder()
        {
        }

        public ColumnSqlBuilder(string column, string table = null)
        {
            this.Name = column;
            this.Table = table;
        }

        public ColumnSqlBuilder(ColumnInfo columnInfo)
            : this(columnInfo.Name, columnInfo.TableName)
        {
        }

        public override string Build(SqlBuilderContext context)
        {
            var stringBuilder = new StringBuilder();

            if (!string.IsNullOrWhiteSpace(this.Table))
            {
                stringBuilder.Append(this.GetSqlName(this.Table));
                stringBuilder.Append(".");
            }

            var columnName = this.Name == null ? "*" : this.GetSqlName(this.Name);

            stringBuilder.Append(columnName);

            return stringBuilder.ToString();
        }
    }
}
