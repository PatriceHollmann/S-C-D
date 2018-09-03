﻿using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using Gdc.Scd.BusinessLogicLayer.Entities;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Dto;
using Gdc.Scd.Core.Entities;
using Newtonsoft.Json;

namespace Gdc.Scd.Web.Api.Controllers
{
    public class CostBlockHistoryController : Controller
    {
        private readonly ICostBlockHistoryService costBlockHistoryService;

        public CostBlockHistoryController(ICostBlockHistoryService costBlockHistoryService)
        {
            this.costBlockHistoryService = costBlockHistoryService;
        }

        [HttpGet]
        public async Task<IEnumerable<CostBlockHistoryApprovalDto>> GetDtoHistoriesForApproval(CostBlockHistoryFilter filter)
        {
            return await this.costBlockHistoryService.GetDtoHistoriesForApproval(filter);
        }

        [HttpGet]
        public async Task<IEnumerable<CostBlockValueHistory>> GetHistoryValues(long costBlockHistoryId)
        {
           return await this.costBlockHistoryService.GetHistoryValues(costBlockHistoryId);
        }

        [HttpGet]
        public async Task<IEnumerable<Dictionary<string, object>>> GetHistoryValueTable(long costBlockHistoryId)
        {
            var historyValues = await this.costBlockHistoryService.GetHistoryValues(costBlockHistoryId);

            return historyValues.Select(historyValue =>
            {
                var dictionary = new Dictionary<string, object>
                {
                    ["InputLevelId"] = historyValue.InputLevel.Id,
                    ["InputLevelName"] = historyValue.InputLevel.Name,
                    [nameof(CostBlockValueHistory.Value)] = historyValue.Value,
                };

                foreach (var dependency in historyValue.Dependencies)
                {
                    dictionary.Add($"{dependency.Key}Id", dependency.Value.Id);
                    dictionary.Add($"{dependency.Key}Name", dependency.Value.Name);
                }

                return dictionary;
            });
        }

        [HttpGet]
        public async Task<IEnumerable<CostBlockHistoryValueDto>> GetCostBlockHistoryValueDto(
            CostEditorContext context, 
            long editItemId, 
            int? start, 
            int? limit, 
            string sort = null)
        {
            QueryInfo queryInfo = null;

            if (start.HasValue || limit.HasValue || sort != null)
            {
                queryInfo = new QueryInfo
                {
                    Skip = start,
                    Take = limit
                };

                if (sort != null)
                {
                    queryInfo.Sort = JsonConvert.DeserializeObject<SortInfo[]>(sort).FirstOrDefault();
                }
            }

            return await this.costBlockHistoryService.GetCostBlockHistoryValueDto(context, editItemId, queryInfo);
        }

        [HttpPost]
        public async Task<ActionResult> Approve(long historyId)
        {
            await this.costBlockHistoryService.Approve(historyId);

            return new HttpStatusCodeResult(System.Net.HttpStatusCode.OK);
        }

        [HttpPost]
        public ActionResult Reject(long historyId, string message)
        {
            this.costBlockHistoryService.Reject(historyId, message);

            return new HttpStatusCodeResult(System.Net.HttpStatusCode.OK);
        }
    }
}
