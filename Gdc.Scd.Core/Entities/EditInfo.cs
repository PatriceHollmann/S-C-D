﻿using System.Collections.Generic;
using Gdc.Scd.Core.Meta.Entities;

namespace Gdc.Scd.Core.Entities
{
    public class EditInfo
    {
        public CostBlockEntityMeta Meta { get; set; }

        public IEnumerable<ValuesInfo> ValueInfos { get; set; }
    }
}
