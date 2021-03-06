﻿using Gdc.Scd.Core.Interfaces;
using System.ComponentModel.DataAnnotations;

namespace Gdc.Scd.Core.Entities.Portfolio
{
    public class Portfolio : IIdentifiable
    {
        public long Id { get; set; }

        [Required]
        public Wg Wg { get; set; }

        [Required]
        public Availability Availability { get; set; }

        [Required]
        public Duration Duration { get; set; }

        [Required]
        public ReactionType ReactionType { get; set; }

        [Required]
        public ReactionTime ReactionTime { get; set; }

        [Required]
        public ServiceLocation ServiceLocation { get; set; }

        [Required]
        public ProActiveSla ProActiveSla { get; set; }
    }
}
