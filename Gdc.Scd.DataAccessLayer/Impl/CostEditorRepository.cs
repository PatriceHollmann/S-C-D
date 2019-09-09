﻿using System.Collections.Generic;
using System.Threading.Tasks;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Entities;
using Gdc.Scd.DataAccessLayer.Helpers;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Impl;

namespace Gdc.Scd.DataAccessLayer.Impl
{
    public class CostEditorRepository : ICostEditorRepository
    {
        private readonly IRepositorySet repositorySet;

        private readonly ICostBlockQueryBuilder costBlockQueryBuilder;

        private readonly DomainEnitiesMeta domainEnitiesMeta;

        public CostEditorRepository(
            IRepositorySet repositorySet, 
            ICostBlockQueryBuilder costBlockQueryBuilder, 
            DomainEnitiesMeta domainEnitiesMeta)
        {
            this.repositorySet = repositorySet;
            this.costBlockQueryBuilder = costBlockQueryBuilder;
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
            var queryData = new CostBlockSelectQueryData
            {
                CostBlock = costBlockMeta,
                CostElementInfos = new[] 
                {
                    new CostBlockSelectCostElementInfo { CostElementId = context.CostElementId }
                },
                GroupedFields = new[] { context.InputLevelId },
                IsGroupedFieldsNameSelected = true,
                Filter = filter
            };

            var query =
                this.costBlockQueryBuilder.BuildSelectQuery(queryData)
                                          .OrderBy(new OrderByInfo
                                          {
                                              Direction = SortDirection.Asc,
                                              SqlBuilder = new ColumnSqlBuilder($"{context.InputLevelId}_{nameField.ReferenceFaceField}")
                                          });

            return await this.repositorySet.ReadBySqlAsync(query, reader =>
            {
                var valueCount = reader.GetInt32(3);

                return new EditItem
                {
                    Id = reader.GetInt64(0),
                    Name = reader.GetString(1),
                    Value = valueCount == 1 ? reader.GetValue(2) : null,
                    ValueCount = valueCount,
                    IsApproved = reader.GetInt32(4) == 1
                };
            });
        }
    }
}
