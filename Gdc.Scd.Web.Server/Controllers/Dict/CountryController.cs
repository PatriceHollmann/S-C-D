﻿using Gdc.Scd.BusinessLogicLayer.Dto;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.DataAccessLayer.Helpers;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Http;

namespace Gdc.Scd.Web.Server.Controllers.Dict
{
    public class CountryController : ApiController
    {
        private readonly ICountryUserService userCntSrv;

        private readonly IDomainService<Country> domainService;

        private readonly IUserService userService;

        public CountryController(
                IDomainService<Country> domainService,
                ICountryUserService userCntSrv,  
                IUserService userService
            )
        {
            this.domainService = domainService;
            this.userCntSrv = userCntSrv;
            this.userService = userService;
        }

        [HttpGet]
        public Task<UserCountryDto[]> GetAll()
        {
            return userCntSrv.GetMasterCountries(this.CurrentUser());
        }

        [HttpGet]
        public Task<UserCountryDto[]> Usr()
        {
            return userCntSrv.GetUserMasterCountries(this.CurrentUser());
        }

        [HttpGet]
        public bool IsCountryUser()
        {
            return this.userService.GetCurrentUserCountries().Any();
        }

        [HttpGet]
        public Task<string[]> Iso()
        {
            return domainService.GetAll()
                                .Select(x => x.ISO3CountryCode)
                                .Distinct()
                                .GetAsync();
        }
    }
}
