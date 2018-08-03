﻿using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;

namespace Gdc.Scd.DataAccessLayer.SqlBuilders.Impl
{
    public class IsNullSqlBuilder : BaseSqlBuilder
    {
        public override string Build(SqlBuilderContext context)
        {
            return $"{this.SqlBuilder.Build(context)} IS NULL";
        }
    }
}
