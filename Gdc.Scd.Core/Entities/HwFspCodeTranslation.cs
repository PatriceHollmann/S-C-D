﻿using Gdc.Scd.Core.Meta.Constants;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gdc.Scd.Core.Entities
{
    [Table(MetaConstants.HwFspCodeTranslation, Schema = MetaConstants.FspCodeTranslationSchema)]
    public class HwFspCodeTranslation : FspCodeTranslation
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public override long Id
        {
            get => base.Id;
            set => base.Id = value;
        }

        public Country Country { get; set; }
        public long? CountryId { get; set; }

        public Wg Wg { get; set; }
        public long WgId { get; set; }

        public bool? IsStandardWarranty { get; set; }
        public string LUT { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public string Sla { get; private set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public string SlaHash { get; private set; }
    }
}
