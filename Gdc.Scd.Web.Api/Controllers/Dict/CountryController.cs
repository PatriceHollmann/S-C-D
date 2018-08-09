﻿using Gdc.Scd.BusinessLogicLayer.Entities;
using Gdc.Scd.BusinessLogicLayer.Interfaces;

namespace Gdc.Scd.Web.Api.Controllers.Dict
{
    public class CountryController : BaseDomainController<Country>
    {
        public CountryController(IDomainService<Country> domainService) : 
            base(domainService) { }
    }
}
