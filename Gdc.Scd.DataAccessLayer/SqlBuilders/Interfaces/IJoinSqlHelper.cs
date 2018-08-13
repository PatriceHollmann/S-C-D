﻿using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers;

namespace Gdc.Scd.DataAccessLayer.SqlBuilders.Interfaces
{
    public interface IJoinSqlHelper<out TResult>
    {
        TResult Join(ISqlBuilder table, ISqlBuilder condition, JoinType type = JoinType.Inner);

        TResult Join(ISqlBuilder table, ConditionHelper condition, JoinType type = JoinType.Inner);

        TResult Join(string schemaName, string tableName, ConditionHelper condition, JoinType type = JoinType.Inner, string alias = null);

        TResult Join(string tableName, ConditionHelper condition, JoinType type = JoinType.Inner, string alias = null);

        TResult Join(BaseEntityMeta meta, string referenceFieldName, string aliasMetaTable = null);

        TResult Join(BaseEntityMeta meta, ConditionHelper condition, JoinType type = JoinType.Inner, string aliasMetaTable = null);
    }
}
