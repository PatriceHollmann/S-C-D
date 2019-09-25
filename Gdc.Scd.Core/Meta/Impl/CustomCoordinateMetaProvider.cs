﻿using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.Core.Meta.Helpers;
using Gdc.Scd.Core.Meta.Interfaces;
using System.Collections.Generic;
using System.Linq;

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
            var companyMeta = new NamedEntityMeta(MetaConstants.CompanyInputLevelName, MetaConstants.InputLevelSchema);
            var plaMeta = new NamedEntityMeta(MetaConstants.PlaInputLevelName, MetaConstants.InputLevelSchema);
            var centralContractGroupMeta = new NamedEntityMeta(MetaConstants.CentralContractGroupInputLevel, MetaConstants.InputLevelSchema);
            var sfabMeta = new SFabEntityMeta(plaMeta);
            var sogMeta = new BaseWgSogEntityMeta(MetaConstants.SogInputLevel, MetaConstants.InputLevelSchema, plaMeta, sfabMeta);
            var swDigitMeta = new SwDigitEnityMeta(sogMeta);
            var clusterRegionMeta = new ClusterRegionEntityMeta();
            var currencyMeta = new NamedEntityMeta(MetaConstants.CurrencyTable, MetaConstants.ReferencesSchema);
            var countryMeta = new CountryEntityMeta(MetaConstants.CountryInputLevelName, MetaConstants.InputLevelSchema, clusterRegionMeta, currencyMeta);
            var nonEmeiaCountryMeta = new CountryEntityMeta(MetaConstants.NonEmeiaCountryInputLevelName, MetaConstants.InputLevelSchema, clusterRegionMeta, currencyMeta)
            {
                StoreType = StoreType.View,
                RealMeta = countryMeta
            };
            var roleCode = new DeactivatableEntityMeta(MetaConstants.RoleCodeInputLevel, MetaConstants.InputLevelSchema);
            var wgMeta = new WgEnityMeta(plaMeta, sfabMeta, sogMeta, centralContractGroupMeta, roleCode, companyMeta);

            var customMetas = new[]
            {
                swDigitMeta,
                sogMeta,
                sfabMeta,
                companyMeta,
                plaMeta,
                centralContractGroupMeta,
                wgMeta,
                clusterRegionMeta,
                currencyMeta,
                countryMeta,
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
