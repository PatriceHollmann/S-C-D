﻿using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Interfaces;
using System.Collections.Generic;

namespace Gdc.Scd.MigrationTool.Interfaces
{
    public interface IDataMigrator
    {
        void AddColumn(BaseEntityMeta meta, string field);

        void AddCalculatedColumn(string column, string table, string schema, ISqlBuilder calcQuery, bool isPersisted = false);

        void AddCalculatedColumn(string column, BaseEntityMeta meta, ISqlBuilder calcQuery, bool isPersisted = false);

        void AddColumns(BaseEntityMeta meta, IEnumerable<string> fields);

        void AddCostBlock(CostBlockEntityMeta costBlock, bool isAddingData);

        void AddCostBlocks(IEnumerable<CostBlockEntityMeta> costBlocks, bool isAddingData);

        void AddCostElements(IEnumerable<CostElementInfo> costElementInfos);

        void SplitCostBlock(CostBlockEntityMeta source, IEnumerable<CostBlockEntityMeta> targets, DomainEnitiesMeta enitiesMeta);

        void CreateCostBlockView(string shema, string name, IEnumerable<CostBlockEntityMeta> costBlocks, BaseColumnInfo[] additionalColumns = null, string[] ignoreCoordinates = null);

        void DropTable(string tableName, string schema);

        void DropTable(BaseEntityMeta meta);

        void DropCostBlock(CostBlockEntityMeta costBlock);
    }
}