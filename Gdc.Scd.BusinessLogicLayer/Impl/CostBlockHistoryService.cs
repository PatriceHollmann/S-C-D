﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Gdc.Scd.BusinessLogicLayer.Entities;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Dto;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Entities.Approval;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Interfaces;

namespace Gdc.Scd.BusinessLogicLayer.Impl
{
    public class CostBlockHistoryService : ReadingDomainService<CostBlockHistory>, ICostBlockHistoryService
    {
        private readonly IUserService userService;

        private readonly ICostBlockValueHistoryRepository costBlockValueHistoryRepository;

        private readonly DomainMeta domainMeta;

        private readonly DomainEnitiesMeta domainEnitiesMeta;

        private readonly ICostBlockFilterBuilder costBlockFilterBuilder;

        public CostBlockHistoryService(
            IRepositorySet repositorySet,
            IUserService userService,
            ICostBlockValueHistoryRepository costBlockValueHistoryRepository,
            ICostBlockFilterBuilder costBlockFilterBuilder,
            DomainMeta domainMeta,
            DomainEnitiesMeta domainEnitiesMeta)
            : base(repositorySet)
        {
            this.userService = userService;
            this.costBlockValueHistoryRepository = costBlockValueHistoryRepository;
            this.domainMeta = domainMeta;
            this.domainEnitiesMeta = domainEnitiesMeta;
            this.costBlockFilterBuilder = costBlockFilterBuilder;
        }

        public IQueryable<CostBlockHistory> GetByFilter(BundleFilter filter)
        {
            return this.FilterHistories(this.GetAll(), filter);
        }

        public IQueryable<CostBlockHistory> GetByFilter(CostBlockHistoryState state)
        {
            return this.GetAll().Where(history => history.State == state);
        }

        public IQueryable<CostBlockHistory> GetByFilter(BundleFilter filter, CostBlockHistoryState state)
        {
            return this.FilterHistories(this.GetByFilter(state), filter);
        }

        public async Task<DataInfo<HistoryItemDto>> GetHistory(CostElementContext historyContext, IDictionary<string, long[]> filter, QueryInfo queryInfo = null)
        {
            return await this.costBlockValueHistoryRepository.GetHistory(historyContext, filter, queryInfo);
        }

        public async Task Save(CostElementContext context, IEnumerable<EditItem> editItems, ApprovalOption approvalOption, IDictionary<string, long[]> filter, EditorType editorType)
        {
            if (approvalOption.HasQualityGateErrors && string.IsNullOrWhiteSpace(approvalOption.QualityGateErrorExplanation))
            {
                throw new Exception("QualityGateErrorExplanation must be");
            }

            var editItemArray = editItems.ToArray();
            var isDifferentValues = 
                editItemArray.Length > 0 && 
                editItemArray.All(item => item.Value == editItemArray[0].Value);

            var history = new CostBlockHistory
            {
                EditDate = DateTime.UtcNow,
                EditUser = this.userService.GetCurrentUser(),
                Context = context,
                EditItemCount = editItemArray.Length,
                IsDifferentValues = isDifferentValues, 
                HasQualityGateErrors = approvalOption.HasQualityGateErrors,
                QualityGateErrorExplanation = approvalOption.QualityGateErrorExplanation,
                EditorType = editorType
            };

            this.Save(history, approvalOption);

            var relatedItems = new Dictionary<string, long[]>(filter)
            {
                [context.InputLevelId] = editItems.Select(item => item.Id).ToArray()
            };

            await this.costBlockValueHistoryRepository.Save(history, editItemArray, relatedItems);
        }

        public void Save(CostBlockHistory history, ApprovalOption approvalOption)
        {
            if (approvalOption.HasQualityGateErrors && string.IsNullOrWhiteSpace(approvalOption.QualityGateErrorExplanation))
            {
                throw new Exception("QualityGateErrorExplanation must be");
            }

            history.State = approvalOption.IsApproving ? CostBlockHistoryState.Approving : CostBlockHistoryState.Saved;

            this.repositorySet.GetRepository<CostBlockHistory>().Save(history);
            this.repositorySet.Sync();
        }

        public CostBlockHistory SaveAsApproved(long historyId)
        {
            var history = this.Get(historyId);

            this.SetState(history, CostBlockHistoryState.Approved);

            this.repository.Save(history);
            this.repositorySet.Sync();

            return history;
        }

        public CostBlockHistory SaveAsRejected(long historyId, string rejectedMessage)
        {
            var history = this.Get(historyId);

            this.SetState(history, CostBlockHistoryState.Rejected);

            this.repository.Save(history);
            this.repositorySet.Sync();

            return history;
        }

        private void SetState(CostBlockHistory history, CostBlockHistoryState state)
        {
            history.ApproveRejectDate = DateTime.UtcNow;
            history.ApproveRejectUser = this.userService.GetCurrentUser();
            history.State = state;
        }

        private IQueryable<CostBlockHistory> FilterHistories(IQueryable<CostBlockHistory> query, BundleFilter filter)
        {
            if (filter != null)
            {
                if (filter.DateTimeFrom.HasValue)
                {
                    query = query.Where(history => filter.DateTimeFrom.Value <= history.EditDate);
                }

                if (filter.DateTimeTo.HasValue)
                {
                    query = query.Where(history => history.EditDate <= filter.DateTimeTo);
                }

                if (filter.ApplicationIds != null && filter.ApplicationIds.Length > 0)
                {
                    query = query.Where(history => filter.ApplicationIds.Contains(history.Context.ApplicationId));
                }

                if (filter.CostBlockIds != null && filter.CostBlockIds.Length > 0)
                {
                    query = query.Where(history => filter.CostBlockIds.Contains(history.Context.CostBlockId));
                }

                if (filter.CostElementIds != null && filter.CostElementIds.Length > 0)
                {
                    query = query.Where(history => filter.CostElementIds.Contains(history.Context.CostElementId));
                }

                if (filter.UserIds != null && filter.UserIds.Length > 0)
                {
                    query = query.Where(history => filter.UserIds.Contains(history.EditUser.Id));
                }
            }

            return query;
        }
    }
}
