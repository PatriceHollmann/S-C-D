﻿using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.Core.Meta.Entities
{
    public class DomainMeta
    {
        public IEnumerable<CostBlockMeta>  CostBlocks { get; set; }

        public IEnumerable<InputLevelMeta> InputLevels { get; set; }

        public IEnumerable<ApplicationMeta> Applications { get; set; }

        public IEnumerable<ScopeMeta> Scopes { get; set; }

        public CostBlockMeta GetCostBlock(string id)
        {
            return this.CostBlocks.FirstOrDefault(costBlock => costBlock.Id == id);
        }

        public InputLevelMeta GetPreviousInputLevel(string inputLevelId)
        {
            InputLevelMeta previousInputLevel = null;

            foreach (var inputLevel in this.InputLevels)
            {
                if (inputLevel.Id == inputLevelId)
                {
                    break;
                }

                previousInputLevel = inputLevel;
            }

            return previousInputLevel;
        }
    }
}
