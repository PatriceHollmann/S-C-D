﻿namespace Gdc.Scd.BusinessLogicLayer.Dto.Calculation
{
    public class HwCostManualDto
    {
        public long Id { get; set; }

        public double? ServiceTC { get; set; }

        public double? ReActiveTP { get; set; }

        public double? ListPrice { get; set; }

        public double? DealerDiscount { get; set; }

        public double? ServiceTP_Released { get; set; }
    }
}
