﻿using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gdc.Scd.Core.Entities.ProjectCalculator
{
    [Table("Project", Schema = MetaConstants.ProjectCalculatorSchema)]
    public class Project : IIdentifiable
    {
        public long Id { get; set; }

        public Wg Wg { get; set; }

        public long WgId { get; set; }
        
        public Country Country { get; set; }

        public long CountryId { get; set; }

        public AvailabilityProjCalc Availability { get; set; }

        public ReactionTimeProjCalc ReactionTime { get; set; }

        public ReactionType ReactionType { get; set; }

        public long ReactionTypeId { get; set; }

        public ServiceLocation ServiceLocation { get; set; }

        public long ServiceLocationId { get; set; }

        public DurationProjCalc Duration { get; set; }

        public bool IsCalculated { get; set; }

        public List<AfrProjCalc> Afrs { get; set; }

        public double? OnsiteHourlyRates { get; set; }

        public FieldServiceCostProjCalc FieldServiceCost { get; set; }

        public ReinsuranceProjCalc Reinsurance { get; set; }

        public MarkupOtherCostsProjCalc MarkupOtherCosts { get; set; }

        public LogisticsCostsProjCalc LogisticsCosts { get; set; }

        public AvailabilityFeeProjCalc AvailabilityFee { get; set; }
    }
}
