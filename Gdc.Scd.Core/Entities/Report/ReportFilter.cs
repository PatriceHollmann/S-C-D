﻿using Gdc.Scd.Core.Meta.Constants;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gdc.Scd.Core.Entities.Report
{
    [Table("ReportFilter", Schema = MetaConstants.ReportSchema)]
    public class ReportFilter : NamedId
    {
        public Report Report { get; set; }

        [Required]
        public string Text { get; set; }

        [Required]
        public string Type { get; set; }

        public string Value { get; set; }
    }
}