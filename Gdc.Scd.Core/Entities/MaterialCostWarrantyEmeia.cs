﻿using System;
using System.ComponentModel.DataAnnotations.Schema;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;

namespace Gdc.Scd.Core.Entities
{
    [Table("MaterialCostWarrantyEmeia", Schema = MetaConstants.HardwareSchema)]
    public class MaterialCostWarrantyEmeia : ICostBlockEntity, IModifiable
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        public double? MaterialCostOow { get; set; }

        public double? MaterialCostOow_Approved { get; set; }

        public double? MaterialCostIw { get; set; }

        public double? MaterialCostIw_Approved { get; set; }

        [Column("Wg")]
        public long? WgId { get; set; }

        public Wg Wg { get; set; }

        public DateTime CreatedDateTime { get; set; }

        public DateTime? DeactivatedDateTime { get; set; }

        public DateTime ModifiedDateTime { get; set; }
    }
}
