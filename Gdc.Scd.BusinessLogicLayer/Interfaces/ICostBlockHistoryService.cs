﻿using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Gdc.Scd.BusinessLogicLayer.Entities;
using Gdc.Scd.Core.Dto;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Entities.Approval;

namespace Gdc.Scd.BusinessLogicLayer.Interfaces
{
    public interface ICostBlockHistoryService : IReadingDomainService<CostBlockHistory>
    {
        IQueryable<CostBlockHistory> GetByFilter(BundleFilter filter);

        Task<DataInfo<HistoryItemDto>> GetHistory(CostElementContext historyContext, IDictionary<string, long[]> filter, QueryInfo queryInfo = null);

        Task<CostBlockHistory> Save(CostElementContext context, IEnumerable<EditItem> editItems, ApprovalOption approvalOption, IDictionary<string, long[]> filter, EditorType editorType);

        void Save(CostBlockHistory history, ApprovalOption approvalOption);

        CostBlockHistory SaveAsApproved(long historyId);

        Task<CostBlockHistory> SaveAsApproved(
            CostElementContext context,
            IEnumerable<EditItem> editItems,
            ApprovalOption approvalOption,
            IDictionary<string, long[]> filter,
            EditorType editorType);

        void SaveAsRejected(CostBlockHistory history, string rejectedMessage);
    }
}
