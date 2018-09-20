﻿using Gdc.Scd.Core.Attributes;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gdc.Scd.Core.Entities
{
    [Table("FspCodeTranslation", Schema = MetaConstants.PorSchema)]
    public class FspCodeTranslation : NamedId, IDeactivatable
    {

        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public override long Id
        {
            get => base.Id;
            set => base.Id = value;
        }

        [MustCompare(true, IsIgnoreCase = true)]
        public string ServiceDescription { get; set; }

        [MustCompare(true, IsIgnoreCase = true)]
        public string ServiceType { get; set; }

        [MustCompare(true, IsIgnoreCase = true)]
        public string SCD_ServiceType { get; set; }

        [MustCompare(true, IsIgnoreCase = true)]
        public string Status { get; set; }

        [MustCompare(true, IsIgnoreCase = true)]
        public string SecondSLA { get; set; }

        public DateTime CreatedDateTime { get; set; }
        public DateTime? DeactivatedDateTime { get; set; }
        public DateTime ModifiedDateTime { get; set; }

        public ServiceLocation ServiceLocation { get; set; }
        public long? ServiceLocationId { get; set; }

        public ReactionTime ReactionTime { get; set; }
        public long? ReactionTimeId { get; set; }

        public ReactionType ReactionType { get; set; }
        public long? ReactionTypeId { get; set; }

        public Availability Availability { get; set; }
        public long? AvailabilityId { get; set; }

        public Duration Duration { get; set; }
        public long? DurationId { get; set; }

        public Country Country { get; set; }
        public long? CountryId { get; set; }

        public Sog Sog { get; set; }
        public long? SogId { get; set; }

        public Wg Wg { get; set; }
        public long? WgId { get; set; }
    }
}
