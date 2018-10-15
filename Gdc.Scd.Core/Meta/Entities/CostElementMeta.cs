﻿using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.Core.Meta.Entities
{
    public class CostElementMeta : BaseDomainMeta
    {
        public DependencyMeta Dependency { get; set; }

        public string Description { get; set; }

        public MetaCollection<InputLevelMeta> InputLevels { get; set; }

        public InputLevelMeta RegionInput { get; set; }

        public InputType InputType { get; set; }

        public IDictionary<string, string> TypeOptions { get; set; }

        public TableViewOption TableViewOption { get; set; }

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

        public IEnumerable<InputLevelMeta> FilterInputLevels(string maxInputLevelId)
        {
            foreach (var inputLevel in this.InputLevels.OrderBy(x => x.LevelNumber))
            {
                yield return inputLevel;

                if (inputLevel.Id == maxInputLevelId)
                {
                    break;
                }
            }
        }
    }
}
