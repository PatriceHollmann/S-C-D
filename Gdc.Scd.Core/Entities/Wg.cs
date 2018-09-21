﻿using System;
using System.ComponentModel.DataAnnotations.Schema;
using Gdc.Scd.Core.Attributes;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;

namespace Gdc.Scd.Core.Entities
{
    [Table(MetaConstants.WgInputLevelName, Schema = MetaConstants.InputLevelSchema)]
    public class Wg : BaseWgSog, IDeactivatable
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public override long Id
        {
            get => base.Id;
            set => base.Id = value;
        }

        [MustCompare]
        public long? SogId { get; set; }
        public Sog Sog { get; set; }

        public long? RoleCodeId { get; set; }

        public RoleCode RoleCode { get; set; }

        public bool IsMultiVendor { get; set; }

        public DateTime CreatedDateTime { get; set; }
        public DateTime? DeactivatedDateTime { get; set; }
        public DateTime ModifiedDateTime { get; set; }
    }
}