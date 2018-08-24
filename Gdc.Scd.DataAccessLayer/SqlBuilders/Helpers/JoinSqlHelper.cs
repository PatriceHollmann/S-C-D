﻿using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Impl;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Interfaces;

namespace Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers
{
    public class JoinSqlHelper : SqlHelper, IJoinSqlHelper<ISqlBuilder>
    {
        public JoinSqlHelper(ISqlBuilder sqlBuilder) 
            : base(sqlBuilder)
        {
        }

        public ISqlBuilder Join(ISqlBuilder table, ISqlBuilder condition, JoinType type = JoinType.Inner)
        {
            return new JoinSqlBuilder
            {
                Query = this.ToSqlBuilder(),
                Table = table,
                Condition = condition,
                Type = type
            };
        }

        public ISqlBuilder Join(ISqlBuilder table, ConditionHelper condition, JoinType type = JoinType.Inner)
        {
            return this.Join(table, condition?.ToSqlBuilder(), type);
        }

        public ISqlBuilder Join(string schemaName, string tableName, ConditionHelper condition, JoinType type = JoinType.Inner, string alias = null)
        {
            var table = new TableSqlBuilder
            {
                Schema = schemaName,
                Name = tableName,
            };

            ISqlBuilder sqlBuilder;

            if (alias == null)
            {
                sqlBuilder = table;
            }
            else
            {
                sqlBuilder = new AliasSqlBuilder
                {
                    Alias = alias,
                    Query = table
                };
            }

            return this.Join(sqlBuilder, condition, type);
        }

        public ISqlBuilder Join(string tableName, ConditionHelper condition, JoinType type = JoinType.Inner, string alias = null)
        {
            return this.Join(null, tableName, condition, type, alias);
        }

        public ISqlBuilder Join(BaseEntityMeta meta, string referenceFieldName, string aliasMetaTable = null)
        {
            var referenceField = (ReferenceFieldMeta)meta.GetField(referenceFieldName);

            return this.Join(
                    referenceField.ReferenceMeta.Schema,
                    referenceField.ReferenceMeta.Name,
                    SqlOperators.Equals(
                        new ColumnInfo(referenceField.Name, meta.Name),
                        new ColumnInfo(referenceField.ReferenceValueField, aliasMetaTable ?? referenceField.ReferenceMeta.Name)),
                    alias: aliasMetaTable);
        }

        public ISqlBuilder Join(BaseEntityMeta meta, ConditionHelper condition, JoinType type = JoinType.Inner, string aliasMetaTable = null)
        {
            return this.Join(meta.Schema, meta.Name, condition, type, aliasMetaTable);
        }
    }
}
