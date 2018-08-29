﻿using System.ComponentModel.DataAnnotations.Schema;
using Gdc.Scd.Core.Meta.Constants;

namespace Gdc.Scd.Core.Entities
{
    [Table(MetaConstants.WgInputLevelName, Schema = MetaConstants.InputLevelSchema)]
    public class Wg : NamedId
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public override long Id
        {
            get => base.Id;
            set => base.Id = value;
        }

        public long? RoleCodeId { get; set; }

        public RoleCode RoleCode { get; set; }

        public bool IsMultiVendor { get; set; }
    }
}