﻿using System.ComponentModel.DataAnnotations.Schema;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Constants;

namespace Gdc.Scd.Tests.Common.CostBlock.Entities
{
    [Table(nameof(RelatedInputLevel3), Schema = MetaConstants.InputLevelSchema)]
    public class RelatedInputLevel3 : NamedId
    {
        public long RelatedInputLevel2Id { get; set; }
    }
}
