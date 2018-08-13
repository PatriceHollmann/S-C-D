﻿using System.Collections.Generic;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Interfaces;

namespace Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers
{
    public class UpdateSqlHelper : SqlHelper, IWhereSqlHelper<SqlHelper>, IFromSqlHelper<UpdateFromSqlHelper>
    {
        private readonly WhereSqlHelper whereHelper;

        private readonly FromSqlHepler fromSqlHelper;

        public UpdateSqlHelper(ISqlBuilder sqlBuilder) 
            : base(sqlBuilder)
        {
            this.whereHelper = new WhereSqlHelper(sqlBuilder);
            this.fromSqlHelper = new FromSqlHepler(sqlBuilder);
        }

        public UpdateFromSqlHelper From(string tabeName, string schemaName = null, string dataBaseName = null, string alias = null)
        {
            return new UpdateFromSqlHelper(this.fromSqlHelper.From(tabeName, schemaName, dataBaseName, alias));
        }

        public UpdateFromSqlHelper From(BaseEntityMeta meta, string alias = null)
        {
            return new UpdateFromSqlHelper(this.fromSqlHelper.From(meta, alias));
        }

        public UpdateFromSqlHelper FromQuery(ISqlBuilder query)
        {
            return new UpdateFromSqlHelper(this.fromSqlHelper.FromQuery(query));
        }

        public UpdateFromSqlHelper FromQuery(SqlHelper sqlHelper)
        {
            return new UpdateFromSqlHelper(this.fromSqlHelper.FromQuery(sqlHelper));
        }

        public SqlHelper Where(ISqlBuilder condition)
        {
            return new SqlHelper(this.whereHelper.Where(condition));
        }

        public SqlHelper Where(ConditionHelper condition)
        {
            return new SqlHelper(this.whereHelper.Where(condition));
        }

        public SqlHelper Where(IDictionary<string, IEnumerable<object>> filter, string tableName = null)
        {
            return new SqlHelper(this.whereHelper.Where(filter, tableName));
        }
    }
}
