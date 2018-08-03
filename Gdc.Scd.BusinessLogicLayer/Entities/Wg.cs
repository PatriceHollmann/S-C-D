﻿using System.ComponentModel.DataAnnotations.Schema;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Constants;

namespace Gdc.Scd.BusinessLogicLayer.Entities
{
    [Table("Wg", Schema = MetaConstants.InputLevelSchema)]
    public class Wg : NamedId
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public override long Id
        {
            get => base.Id;
            set => base.Id = value;
        }

        public RoleCode RoleCode { get; set; }
    }
}