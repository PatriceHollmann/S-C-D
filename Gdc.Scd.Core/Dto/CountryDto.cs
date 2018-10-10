﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gdc.Scd.Core.Dto
{
    public class CountryDto
    {
        public string CountryName { get; set; }
        public string CountryGroup { get; set; }
        public string LUTCode { get; set; }
        public string CountryDigit { get; set; }
        public string QualityGroup { get; set; }
        public bool CanStoreListAndDealerPrices { get; set; }
        public bool CanOverrideTransferCostAndPrice { get; set; }
        public string IsMaster { get; set; }
        public string ISO3Code { get; set; }
        public long CountryId { get; set; }
    }
}
