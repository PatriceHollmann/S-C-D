﻿using Gdc.Scd.Core.Meta.Constants;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gdc.Scd.Core.Entities
{
    [Table(MetaConstants.CountryInputLevelName, Schema = MetaConstants.InputLevelSchema)]
    public class Country : NamedId
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public override long Id
        {
            get => base.Id;
            set => base.Id = value;
        }

        public bool CanOverrideListAndDealerPrices { get; set; }

        public bool ShowDealerPrice { get; set; }

        public bool CanOverrideTransferCostAndPrice { get; set; }

        public ClusterRegion ClusterRegion { get; set; }

        public long ClusterRegionId { get; set; }

        [Required]
        public Currency Currency { get; set; }
    }
}
