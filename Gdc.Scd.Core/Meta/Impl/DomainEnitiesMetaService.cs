﻿using System;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.Core.Meta.Interfaces;

namespace Gdc.Scd.Core.Meta.Impl
{
    public class DomainEnitiesMetaService : IDomainEnitiesMetaService
    {
        public DomainEnitiesMeta Get(DomainMeta domainMeta)
        {
            var domainEnitiesMeta = new DomainEnitiesMeta();

            foreach (var costBlockMeta in domainMeta.CostBlocks)
            {
                foreach (var applicationId in costBlockMeta.ApplicationIds)
                {
                    var costBlockEntity = new CostBlockEntityMeta(costBlockMeta.Id, applicationId);

                    foreach (var inputLevelMeta in costBlockMeta.GetInputLevels())
                    {
                        this.BuildByInputLevel(inputLevelMeta, costBlockEntity, domainEnitiesMeta);
                    }

                    foreach (var costElementMeta in costBlockMeta.CostElements)
                    {
                        costBlockEntity.CostElementsFields.Add(new SimpleFieldMeta(costElementMeta.Id, TypeCode.Double));

                        if (costElementMeta.Dependency != null && costBlockEntity.DependencyFields[costElementMeta.Dependency.Id] == null)
                        {
                            this.BuildByDependency(costElementMeta, costBlockEntity, domainEnitiesMeta);
                        }

                        if (costElementMeta.RegionInput != null && costBlockEntity.InputLevelFields[costElementMeta.RegionInput.Id] == null)
                        {
                            this.BuildByInputLevel(costElementMeta.RegionInput, costBlockEntity, domainEnitiesMeta);
                        }
                    }

                    domainEnitiesMeta.CostBlocks.Add(costBlockEntity);
                }
            }

            return domainEnitiesMeta;
        }

        private void BuildByCostBlocks(DomainEnitiesMeta domainEnitiesMeta, DomainMeta domainMeta)
        {
            foreach (var costBlockMeta in domainMeta.CostBlocks)
            {
                foreach (var applicationId in costBlockMeta.ApplicationIds)
                {
                    var costBlockEntity = new CostBlockEntityMeta(costBlockMeta.Id, applicationId);

                    foreach (var costElementMeta in costBlockMeta.CostElements)
                    {
                        costBlockEntity.CostElementsFields.Add(new SimpleFieldMeta(costElementMeta.Id, TypeCode.Double));

                        this.BuildByDependency(costElementMeta, costBlockEntity, domainEnitiesMeta);

                        foreach (var inputLevelMeta in costElementMeta.InputLevels)
                        {
                            this.BuildByInputLevel(inputLevelMeta, costBlockEntity, domainEnitiesMeta);
                        }
                    }

                    domainEnitiesMeta.CostBlocks.Add(costBlockEntity);
                }
            }
        }

        private void BuildByDependency(CostElementMeta costElementMeta, CostBlockEntityMeta costBlockEntity, DomainEnitiesMeta domainEnitiesMeta)
        {
            if (costElementMeta.Dependency != null && costBlockEntity.DependencyFields[costElementMeta.Dependency.Id] == null)
            {
                var dependencyNameField = new SimpleFieldMeta(MetaConstants.NameFieldKey, TypeCode.String);
                var dependencyEntity = new NamedEntityMeta(costElementMeta.Dependency.Id, dependencyNameField, MetaConstants.DependencySchema)
                {
                    Type = costElementMeta.Dependency.Type
                };

                if (domainEnitiesMeta.Dependencies[dependencyEntity.FullName] == null)
                {
                    domainEnitiesMeta.Dependencies.Add(dependencyEntity);
                }

                costBlockEntity.DependencyFields.Add(
                    ReferenceFieldMeta.Build(costElementMeta.Dependency.Id, dependencyEntity));
            }
        }

        private void BuildByInputLevel(InputLevelMeta inputLevelMeta, CostBlockEntityMeta costBlockEntity, DomainEnitiesMeta domainEnitiesMeta)
        {
            var inputLevelNameField = new SimpleFieldMeta(MetaConstants.NameFieldKey, TypeCode.String);
            var inputLevelEntity = new NamedEntityMeta(inputLevelMeta.Id, inputLevelNameField, MetaConstants.InputLevelSchema)
            {
                Type = inputLevelMeta.Type
            };

            if (domainEnitiesMeta.InputLevels[inputLevelEntity.FullName] == null)
            {
                domainEnitiesMeta.InputLevels.Add(inputLevelEntity);
            }

            costBlockEntity.InputLevelFields.Add(
                ReferenceFieldMeta.Build(inputLevelMeta.Id, inputLevelEntity));
        }
    }
}
