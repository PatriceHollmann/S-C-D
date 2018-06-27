﻿using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Gdc.Scd.BusinessLogicLayer.Entities;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.Core.Meta.Interfaces;
using Gdc.Scd.Web.Api.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Gdc.Scd.Web.Api.Controllers
{
    [Produces("application/json")]
    public class CostEditorController : Controller
    {
        private readonly ICostEditorService costEditorService;

        private readonly IDomainMetaSevice domainMetaSevice;

        private readonly IDomainService<Country> countryService;

        private readonly DomainMeta meta;

        public CostEditorController(
            ICostEditorService costEditorService, 
            IDomainMetaSevice domainMetaSevice,
            IDomainService<Country> countryService,
            DomainMeta meta)
        {
            this.costEditorService = costEditorService;
            this.domainMetaSevice = domainMetaSevice;
            this.countryService = countryService;
            this.meta = meta;
        }

        [HttpGet]
        public CostEditorDto GetCostEditorData()
        {
            return new CostEditorDto
            {
                Meta = this.meta,
                Countries = this.countryService.GetAll().ToArray()
            };
        }

        [HttpGet]
        public async Task<IEnumerable<NamedId>> GetCostElementFilterItems(CostEditorContext context)
        {
            return await this.costEditorService.GetCostElementFilterItems(context);
        }

        [HttpGet]
        public async Task<IEnumerable<NamedId>> GetInputLevelFilterItems(CostEditorContext context)
        {
            return await this.costEditorService.GetInputLevelFilterItems(context);
        }

        [HttpGet]
        public async Task<IEnumerable<EditItem>> GetEditItems(CostEditorContext context)
        {
            return await this.costEditorService.GetEditItems(context);
        }

        [HttpPost]
        public async Task<IActionResult> UpdateValues([FromBody]IEnumerable<EditItem> editItems, [FromQuery]CostEditorContext context)
        {
            await this.costEditorService.UpdateValues(editItems, context);

            return this.Ok();
        }
    }
}
