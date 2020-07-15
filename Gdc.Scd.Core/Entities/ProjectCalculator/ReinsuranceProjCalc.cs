﻿namespace Gdc.Scd.Core.Entities.ProjectCalculator
{
    public class ReinsuranceProjCalc
    {
        public double? Flatfee { get; set; }

        public double? UpliftFactor { get; set; }

        public Currency Currency { get; set; }

        public long? CurrencyId { get; set; }
    }
}