﻿using System.Collections.Generic;

namespace Gdc.Scd.Core.Entities
{
    public class BundleDetail : BaseBundleDetail
    {
        public IDictionary<string, NamedId> InputLevels { get; set; }

        public IDictionary<string, NamedId> Dependencies { get; set; }
    }
}
