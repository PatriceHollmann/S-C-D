﻿using System;
using System.Collections.Generic;
using System.Linq;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Entities;

namespace Gdc.Scd.BusinessLogicLayer.Impl
{
    public class CostBlockFilterBuilder : ICostBlockFilterBuilder
    {
        private readonly DomainEnitiesMeta meta;

        public CostBlockFilterBuilder(DomainEnitiesMeta meta)
        {
            this.meta = meta;
        }

        public IDictionary<string, long[]> BuildRegionFilter(HistoryContext context, IEnumerable<Country> userCountries = null)
        {
            var filter = new Dictionary<string, long[]>();
            var costBlock = this.meta.GetCostBlockEntityMeta(context);

            if (costBlock.ContainsCoordinateField(MetaConstants.CountryInputLevelName) && userCountries != null)
            {
                var userCountryIds = userCountries.Select(country => country.Id).ToArray();

                if (userCountryIds.Length > 0)
                {
                    filter[MetaConstants.CountryInputLevelName] = userCountryIds;
                }
            }

            if (context.RegionInputId != null)
            {
                var costElement = costBlock.DomainMeta.CostElements[context.CostElementId];

                if (filter.TryGetValue(costElement.RegionInput.Id, out var regionValues))
                {
                    if (regionValues.Any(value => value.Equals(context.RegionInputId)))
                    {
                        filter[costElement.RegionInput.Id] = new long[] { context.RegionInputId.Value };
                    }
                    else
                    {
                        throw new Exception("Country role restriction");
                    }
                }
                else
                {
                    filter[costElement.RegionInput.Id] = new long[] { context.RegionInputId.Value };
                }
            }

            return filter;
        }

        public IDictionary<string, long[]> BuildCoordinateFilter(CostEditorContext context)
        {
            var filter = new Dictionary<string, long[]>();

            if (context.CostElementFilterIds != null)
            {
                var costElement = this.GetCostElement(context);
                var filterValues = context.CostElementFilterIds;
                if (costElement.Dependency != null)
                    filter.Add(costElement.Dependency.Id, filterValues);
            }

            if (context.InputLevelFilterIds != null)
            {
                var costElement = this.GetCostElement(context);
                var previousInputLevel = costElement.GetFilterInputLevel(context.InputLevelId);

                if (previousInputLevel != null &&
                    (costElement.RegionInput == null || costElement.RegionInput.Id != previousInputLevel.Id))
                {
                    var filterValues = context.InputLevelFilterIds;

                    filter.Add(previousInputLevel.Id, filterValues);
                }
            }

            return filter;
        }

        public IDictionary<string, long[]> BuildFilter(CostEditorContext context, IEnumerable<Country> userCountries = null)
        {
            var regionFilter = this.BuildRegionFilter(context, userCountries);
            var coordinateFilter = this.BuildCoordinateFilter(context);

            return regionFilter.Concat(coordinateFilter).ToDictionary(keyValue => keyValue.Key, keyValue => keyValue.Value);
        }

        private CostElementMeta GetCostElement(CostEditorContext context)
        {
            var costBlock = this.meta.GetCostBlockEntityMeta(context);

            return costBlock.DomainMeta.CostElements[context.CostElementId];
        }
    }
}
