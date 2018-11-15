﻿using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Gdc.Scd.BusinessLogicLayer.Entities;
using Gdc.Scd.Core.Dto;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Entities.TableView;
using Gdc.Scd.Web.BusinessLogicLayer.Entities;

namespace Gdc.Scd.BusinessLogicLayer.Interfaces
{
    public interface ICostBlockHistoryService
    {
        IQueryable<CostBlockHistory> GetHistories();

        IQueryable<CostBlockHistory> GetHistories(CostBlockHistoryFilter filter);

        IQueryable<CostBlockHistory> GetHistories(CostBlockHistoryState state);

        IQueryable<CostBlockHistory> GetHistories(CostBlockHistoryFilter filter, CostBlockHistoryState state);

        Task<IEnumerable<Bundle>> GetApprovalBundles(CostBlockHistoryFilter filter, CostBlockHistoryState state);

        Task<IEnumerable<HistoryItem>> GetHistoryItems(CostEditorContext context, long editItemId, QueryInfo queryInfo = null);

        Task<IEnumerable<HistoryItem>> GetHistoryItems(CostElementIdentifier costElementId, IDictionary<string, long> coordinates, QueryInfo queryInfo = null);

        Task Save(CostEditorContext context, IEnumerable<EditItem> editItems, ApprovalOption approvalOption, IDictionary<string, long[]> filter);

        Task Save(IEnumerable<EditInfo> editInfos, ApprovalOption approvalOption);

        Task<IEnumerable<BundleDetailGroup>> GetApproveBundleDetails(
            CostBlockHistory history, 
            long? historyValueId = null, 
            IDictionary<string, IEnumerable<object>> costBlockFilter = null);

        Task<IEnumerable<BundleDetailGroup>> GetApproveBundleDetails(
            long costBlockHistoryId, 
            long? historyValueId = null, 
            IDictionary<string, IEnumerable<object>> costBlockFilter = null);

        Task Approve(long historyId);

        Task<QualityGateResultDto> SendForApproval(long historyId, string qualityGateErrorExplanation = null);

        void Reject(long historyId, string message = null);
    }
}
