﻿using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.DataAccessLayer.Helpers;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;

namespace Gdc.Scd.Web.Server.Controllers.Dict
{
    public class CountryController : ApiController
    {
        private readonly IDomainService<Country> domainService;

        public CountryController(IDomainService<Country> domainService)
        {
            this.domainService = domainService;
        }

        [HttpGet]
        public Task<CountryDto2[]> GetAll()
        {
            return domainService.GetAll()
                                  .Where(x => x.IsMaster)
                                  .Select(x => new CountryDto2
                                  {
                                      Id = x.Id,
                                      Name = x.Name,
                                      CanOverrideTransferCostAndPrice = x.CanOverrideTransferCostAndPrice,
                                      CanStoreListAndDealerPrices = x.CanStoreListAndDealerPrices,
                                      IsMaster = x.IsMaster,
                                  })
                                  .GetAsync();
        }

        [HttpGet]
        public Task<string[]> Iso()
        {
            return domainService.GetAll()
                                .Select(x => x.ISO3CountryCode)
                                .Distinct()
                                .GetAsync();
        }

        public class CountryDto2
        {
            public bool CanOverrideTransferCostAndPrice { get; set; }
            public bool CanStoreListAndDealerPrices { get; set; }
            public string Name { get; set; }
            public bool IsMaster { get; set; }
            public long Id { get; set; }
        }
    }
}