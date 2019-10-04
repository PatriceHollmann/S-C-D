﻿using Gdc.Scd.Core.Meta.Constants;
using System.ComponentModel.DataAnnotations.Schema;

namespace Gdc.Scd.Core.Entities
{
    [Table(MetaConstants.HwFspCodeTranslation, Schema = MetaConstants.TempSchema)]
    public class TempHwFspCodeTranslation : FspCodeTranslation
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
    }
}
