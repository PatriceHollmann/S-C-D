﻿using Gdc.Scd.Core.Meta.Interfaces;

namespace Gdc.Scd.Core.Meta.Entities
{
    public class InputLevelMeta : BaseMeta, IStoreTyped
    {
        public StoreType StoreType { get; set; }

        public int LevelNumber { get; set; }
    }
}
