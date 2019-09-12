﻿using System.ComponentModel.DataAnnotations.Schema;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Constants;

namespace Gdc.Scd.Tests.DataAccessLayer.CostBlock.Entities
{
    [Table(nameof(SimpleInputLevel3), Schema = MetaConstants.InputLevelSchema)]
    public class SimpleInputLevel3 : NamedId
    {
    }
}
