﻿namespace Gdc.Scd.Core.Entities
{
    public class CostEditorContext : CostElementIdentifier
    {
        public long? RegionInputId { get; set; }

        public string InputLevelId { get; set; }

        public long[] CostElementFilterIds { get; set; }

        public long[] InputLevelFilterIds { get; set; }
    }
}
