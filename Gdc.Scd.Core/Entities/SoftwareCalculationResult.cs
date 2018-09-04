﻿using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gdc.Scd.Core.Entities
{
    [Table(MetaConstants.CalculationTable, Schema = MetaConstants.SoftwareSolutionSchema)]
    public class SoftwareCalculationResult : IIdentifiable
    {
        public long Id { get; set; }

        [Required]
        public Country Country { get; set; }

        [Required]
        public Sog Sog { get; set; }

        [Required]
        public Year Year { get; set; }

        [Required]
        public Availability Availability { get; set; }

        public double? Reinsurance { get; set; }
        public double? Reinsurance_Approved { get; set; }

        public double? ServiceSupport { get; set; }
        public double? ServiceSupport_Approved { get; set; }

        public double? TransferPrice { get; set; }
        public double? TransferPrice_Approved { get; set; }
        public double? TransferPrice_Custom { get; set; }
        public double? TransferPrice_Custom_Approved { get; set; }

        public double? MaintenanceListPrice { get; set; }
        public double? MaintenanceListPrice_Approved { get; set; }
        public double? MaintenanceListPrice_Custom { get; set; }
        public double? MaintenanceListPrice_Custom_Approved { get; set; }

        public double? DealerPrice { get; set; }
        public double? DealerPrice_Approved { get; set; }
        public double? DealerPrice_Custom { get; set; }
        public double? DealerPrice_Custom_Approved { get; set; }
    }
}
