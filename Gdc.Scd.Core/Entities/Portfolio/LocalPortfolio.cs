﻿using Gdc.Scd.Core.Meta.Constants;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gdc.Scd.Core.Entities.Portfolio
{
    [Table("LocalPortfolio", Schema = MetaConstants.PortfolioSchema)]
    public class LocalPortfolio: Portfolio
    {
        [Required]
        public Country Country { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public string Sla { get; private set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public int SlaHash { get; private set; }
    }
}
