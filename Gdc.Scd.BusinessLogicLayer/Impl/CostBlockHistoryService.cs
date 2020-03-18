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
using Gdc.Scd.DataAccessLayer.Entities;
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
            var query = this.GetAll();

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

                if (filter.State.HasValue)
                {
                    query = query.Where(history => history.State == filter.State.Value);
                }
            }

            return query;
        }

        public async Task<DataInfo<HistoryItemDto>> GetHistory(CostElementContext historyContext, IDictionary<string, long[]> filter, QueryInfo queryInfo = null)
        {
            return await this.costBlockValueHistoryRepository.GetHistory(historyContext, filter, queryInfo);
        }

        public async Task<CostBlockHistory[]> Save(
            IEnumerable<EditItemContext> editItemContexts,
            ApprovalOption approvalOption,
            EditorType editorType)
        {
            return await this.Save(editItemContexts, approvalOption, editorType, false);
        }

        public async Task<CostBlockHistory[]> SaveAsApproved(
            IEnumerable<EditItemContext> editItemContexts,
            ApprovalOption approvalOption,
            EditorType editorType)
        {
            return await this.Save(editItemContexts, approvalOption, editorType, true);
        }

        public void Save(CostBlockHistory history, ApprovalOption approvalOption)
        {
            if (approvalOption.HasQualityGateErrors && string.IsNullOrWhiteSpace(approvalOption.QualityGateErrorExplanation))
            {
                throw new Exception("QualityGateErrorExplanation must be");
            }

            this.SetStateByApprovalOption(history, approvalOption);

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

        public void SaveAsRejected(CostBlockHistory history, string rejectedMessage)
        {
            history.RejectMessage = rejectedMessage;

            this.SetState(history, CostBlockHistoryState.Rejected);

            this.repository.Save(history);
            this.repositorySet.Sync();
        }

        private void SetStateByApprovalOption(CostBlockHistory history, ApprovalOption approvalOption)
        {
            history.State = approvalOption.IsApproving ? CostBlockHistoryState.Approving : CostBlockHistoryState.Saved;
        }

        private void SetState(CostBlockHistory history, CostBlockHistoryState state)
        {
            history.ApproveRejectDate = DateTime.UtcNow;
            history.ApproveRejectUser = this.userService.GetCurrentUser();
            history.State = state;
        }

        private async Task<CostBlockHistory[]> Save(
           IEnumerable<EditItemContext> editItemContexts,
           ApprovalOption approvalOption,
           EditorType editorType,
           bool isSavingAsApproved)
        {
            if (approvalOption.HasQualityGateErrors && string.IsNullOrWhiteSpace(approvalOption.QualityGateErrorExplanation))
            {
                throw new Exception("QualityGateErrorExplanation must be");
            }

            var histories = new List<CostBlockHistory>();
            var historyContexts = new List<HistoryContext>();
            var historyRepository = this.repositorySet.GetRepository<CostBlockHistory>();

            foreach (var editItemContext in editItemContexts)
            {
                var isDifferentValues =
                    editItemContext.EditItems.Length > 0 &&
                    editItemContext.EditItems.All(item => item.Value == editItemContext.EditItems[0].Value);

                var history = new CostBlockHistory
                {
                    EditDate = DateTime.UtcNow,
                    EditUser = this.userService.GetCurrentUser(),
                    Context = editItemContext.Context,
                    EditItemCount = editItemContext.EditItems.Length,
                    IsDifferentValues = isDifferentValues,
                    HasQualityGateErrors = approvalOption.HasQualityGateErrors,
                    QualityGateErrorExplanation = approvalOption.QualityGateErrorExplanation,
                    EditorType = editorType
                };

                if (isSavingAsApproved)
                {
                    this.SetState(history, CostBlockHistoryState.Approved);
                }

                this.SetStateByApprovalOption(history, approvalOption);
                historyRepository.Save(history);

                var relatedItems = new Dictionary<string, long[]>(editItemContext.Filter)
                {
                    [editItemContext.Context.InputLevelId] = editItemContext.EditItems.Select(item => item.Id).ToArray()
                };

                histories.Add(history);
                historyContexts.Add(new HistoryContext
                {
                    History = history,
                    EditItems = editItemContext.EditItems,
                    RelatedItems = relatedItems
                });
            }

            this.repositorySet.Sync();

            await this.costBlockValueHistoryRepository.Save(historyContexts);

            return histories.ToArray();
        }
    }
}
