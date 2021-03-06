﻿using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;
using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gdc.Scd.Core.Entities
{
    [Table("InstallBase", Schema = MetaConstants.HardwareSchema)]
    public class InstallBase : ICostBlockEntity, IModifiable
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }

        [Column("Wg")]
        public long? WgId { get; set; }

        public Wg Wg { get; set; }

        [Column("Country")]
        public long? CountryId { get; set; }

        public Country Country { get; set; }

        public double? InstalledBaseCountry { get; set; }

        public double? InstalledBaseCountry_Approved { get; set; }

        public double? InstalledBase1stLevel { get; set; }

        public DateTime CreatedDateTime { get; set; }

        public DateTime? DeactivatedDateTime { get; set; }

        public DateTime ModifiedDateTime { get; set; }
    }
}
