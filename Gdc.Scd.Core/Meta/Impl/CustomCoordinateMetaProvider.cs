﻿using System.Collections.Generic;
using System.Linq;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.Core.Meta.Helpers;
using Gdc.Scd.Core.Meta.Interfaces;

namespace Gdc.Scd.Core.Meta.Impl
{
    public class CustomCoordinateMetaProvider : ICoordinateEntityMetaProvider
    {
        private readonly IRegisteredEntitiesProvider registeredEntitiesProvider;

        public CustomCoordinateMetaProvider(IRegisteredEntitiesProvider registeredEntitiesProvider)
        {
            this.registeredEntitiesProvider = registeredEntitiesProvider;
        }

        public IEnumerable<NamedEntityMeta> GetCoordinateEntityMetas()
        {
            var plaMeta = new NamedEntityMeta(MetaConstants.PlaInputLevelName, MetaConstants.InputLevelSchema);
            var centralContractGroupMeta = new NamedEntityMeta(MetaConstants.CentralContractGroupInputLevel, MetaConstants.InputLevelSchema);
            var sfabMeta = new SFabEntityMeta(plaMeta);
            var sogMeta = new BaseWgSogEntityMeta(MetaConstants.SogInputLevel, MetaConstants.InputLevelSchema, plaMeta, sfabMeta);
            var swDigitMeta = new SwDigitEnityMeta(sogMeta);
            var clusterRegionMeta = new ClusterRegionEntityMeta();
            var countryMeta = new CountryEntityMeta(MetaConstants.CountryInputLevelName, MetaConstants.InputLevelSchema, clusterRegionMeta);
            var emeiaCountryMeta = new CountryEntityMeta(MetaConstants.EmeiaCountryInputLevelName, MetaConstants.InputLevelSchema, clusterRegionMeta)
            {
                StoreType = StoreType.View,
                RealMeta = countryMeta
            };
            var nonEmeiaCountryMeta = new CountryEntityMeta(MetaConstants.NonEmeiaCountryInputLevelName, MetaConstants.InputLevelSchema, clusterRegionMeta)
            {
                StoreType = StoreType.View,
                RealMeta = countryMeta
            };
            var roleCode = new NamedEntityMeta(MetaConstants.RoleCodeInputLevel, MetaConstants.InputLevelSchema);
            var wgMeta = new WgEnityMeta(plaMeta, sfabMeta, sogMeta, centralContractGroupMeta, roleCode);

            var customMetas = new[]
            {
                swDigitMeta,
                sogMeta,
                sfabMeta,
                plaMeta,
                centralContractGroupMeta,
                wgMeta,
                clusterRegionMeta,
                countryMeta,
                emeiaCountryMeta,
                nonEmeiaCountryMeta,
                roleCode
            };

            var result = customMetas.ToDictionary(meta => BaseEntityMeta.BuildFullName(meta.Name, meta.Schema));

            var deactivatableType = typeof(IDeactivatable);
            var entities = registeredEntitiesProvider.GetRegisteredEntities().Where(type => deactivatableType.IsAssignableFrom(type));

            foreach (var entityType in entities)
            {
                var entityInfo = MetaHelper.GetEntityInfo(entityType);
                var fullName = BaseEntityMeta.BuildFullName(entityInfo.Name, entityInfo.Schema);

                if (!result.ContainsKey(fullName))
                {
                    result[fullName] = new DeactivatableEntityMeta(entityInfo.Name, entityInfo.Schema);
                }
            }

            return result.Values;
        }
    }
}
