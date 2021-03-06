﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.Core.Meta.Interfaces;

namespace Gdc.Scd.Core.Meta.Impl
{
    public class DomainMetaSevice : IDomainMetaSevice
    {
        private const string NoneValue = "_none_";

        private const string IdAttributeName = "Id";

        private const string CaptionAttributeName = "Caption";

        private const string TypeAttributeName = "Type";

        private const string DefaultNodeName = "Default";

        private const string CostBlockListNodeName = "Blocks";

        private const string CostBlockNodeName = "Block";

        private const string ApplicationListNodeName = "Applications";

        private const string ApplicationNodeName = "Application";

        private const string TableListNodeName = "Tables";

        private const string TableNodeName = "Table";

        private const string TableNameAttributeName = "Name";

        private const string TableShemaAttributeName = "Shema";

        private const string CostElementListNodeName = "Elements";

        private const string CostElementNodeName = "Element";

        private const string CostElementDescriptionNodeName = "Description";

        private const string CostElementTableIdAttributeNodeName = "TableId";
        private const string InputLevelListNodeName = "InputLevels";

        private const string InputLevelNodeName = "InputLevel";

        private const string InputLevelHideAttributeName = "Hide";

        private const string RegionInputListNodeName = "RegionInputs";

        private const string RegionInputNodeName = "RegionInput";

        private const string DependencyListNodeName = "Dependencies";

        private const string DependencyNodeName = "Dependency";

        private const string IncludeDisabledDependcyItemsAttributeName = "IncludeDisabledDependcyItems";

        private const string InputTypeAttributeName = "InputOption";

        private const string FilterAttributeName = "HideFilter";

        private const string CountryReadOnlyColumnAttributeName = "CountryReadOnlyColumn";

        private const string TypeOptionNodeName = "TypeOption";

        private const string QualityGateNodeName = "QualityGate";

        private const string CountryGroupCoeffNodeName = "CountryGroupCoeff";

        private const string PeriodCoeffNodeName = "PeriodCoeff";

        private const string TableViewNodeName = "TableView";

        private const string CostEditorNodeName = "CostEditor";

        private const string RoleListNodeName = "Roles";

        private const string RoleNodeName = "Role";

        private const string DisableTriggersAttributeName = "DisableTriggers";

        private readonly Regex idRegex = new Regex(@"^[a-zA-Z0-9_]+$", RegexOptions.Compiled);

        public DomainMeta Get()
        {
            var assembly = Assembly.GetExecutingAssembly();
            var stream = assembly.GetManifestResourceStream($"{assembly.GetName().Name}.DomainConfig.xml");

            return this.Get(stream);
        }

        public DomainMeta Get(Stream stream)
        {
            var doc = XDocument.Load(stream);
            var domainMeta = this.BuilDomainMeta(doc.Root);

            foreach (var costBlock in domainMeta.CostBlocks)
            {
                foreach (var costElement in costBlock.CostElements)
                {
                    if (costElement.TableViewRoles != null && !costElement.InputLevels.Where(x => x.Id == MetaConstants.WgInputLevelName).Any())
                    {
                        throw new Exception($"Cost element {costElement.Id} must have '{MetaConstants.WgInputLevelName}' Input Level.");
                    }
                }
            }

            return domainMeta;
        }

        private DomainMeta BuilDomainMeta(XElement configNode)
        {
            var costBlocksNode = configNode.Element(CostBlockListNodeName);
            if (costBlocksNode == null)
            {
                throw new Exception("Cost blocks node not found");
            }

            var domainDefination = this.BuildDomainDefination(configNode);
            var costBlocks =
                costBlocksNode.Elements(CostBlockNodeName)
                              .Select(costBlockNode => this.BuildCostBlockMeta(costBlockNode, domainDefination));

            return new DomainMeta
            {
                CostBlocks = new MetaCollection<CostBlockMeta>(costBlocks),
                Applications = new MetaCollection<ApplicationMeta>(domainDefination.Applications.Items),
                Dependencies = new MetaCollection<DependencyMeta>(domainDefination.Dependencies.Items),
                InputLevels = new MetaCollection<InputLevelMeta>(domainDefination.InputLevels.Items),
                RegionInputs = new MetaCollection<InputLevelMeta>(domainDefination.RegionInputs.Items)
            };
        }

        private CostBlockMeta BuildCostBlockMeta(XElement node, DomainDefination defination)
        {
            var costBlockMeta = this.BuildMeta<CostBlockMeta>(node);

            var disableTriggersAttr = node.Attribute(DisableTriggersAttributeName);
            if (disableTriggersAttr != null)
            {
                costBlockMeta.DisableTriggers = bool.Parse(disableTriggersAttr.Value);
            }

            var costElementListNode = node.Element(CostElementListNodeName);
            if (costElementListNode == null)
            {
                throw new Exception("Cost elements node not found");
            }

            var qualityGateNode = node.Element(QualityGateNodeName);
            var qualityGate = qualityGateNode == null
                ? defination.QualityGate
                : this.BuildQualityGate(qualityGateNode);

            var costElements =
                costElementListNode.Elements(CostElementNodeName)
                                   .Select(costElement => this.BuildCostElementMeta(costElement, defination, qualityGate));

            costBlockMeta.CostElements = new MetaCollection<CostElementMeta>(costElements);

            costBlockMeta.ApplicationIds =
                this.BuildItemCollectionByDomainInfo(node.Element(ApplicationListNodeName), ApplicationNodeName, defination.Applications)
                    .Select(application => application.Id)
                    .ToArray();

            if (costBlockMeta.ApplicationIds.Length > 1 &&
                costBlockMeta.CostElements.Any(costElement => costElement.Table != null))
            {
                throw new NotSupportedException($"Multiple applications not supported for cost elemnts with table definition");
            }

            return costBlockMeta;
        }

        private CostElementMeta BuildCostElementMeta(XElement node, DomainDefination defination, QualityGate qualityGate)
        {
            var nameAttr = node.Attribute(IdAttributeName);
            if (nameAttr == null)
            {
                throw new Exception("Cost element name attribute not found");
            }

            var costElementMeta = this.BuildMeta<CostElementMeta>(node);

            costElementMeta.Description = this.BuildCostElementDescription(node);
            costElementMeta.QualityGate = qualityGate;

            costElementMeta.InputLevelMetaInfos =
                this.BuildInputLevelMetaInfos(node.Element(InputLevelListNodeName), defination.InputLevels);

            costElementMeta.RegionInput = this.BuildItemByDomainInfo(node, RegionInputNodeName, defination.RegionInputs);
            costElementMeta.Dependency = this.BuildItemByDomainInfo(node, DependencyNodeName, defination.Dependencies);

            var inputTypeAttribute = node.Attribute(InputTypeAttributeName);
            if (inputTypeAttribute != null)
            {
                Enum.TryParse(inputTypeAttribute.Value, out InputType type);
                costElementMeta.InputType = type;
            }

            var typeNode = node.Element(TypeOptionNodeName);
            if (typeNode != null)
            {
                costElementMeta.TypeOptions = 
                    typeNode.Attributes()
                            .ToDictionary(attr => attr.Name.ToString(), attr => attr.Value.ToString());

                if (costElementMeta.IsCountryCurrencyCost && 
                    costElementMeta.RegionInput != null && 
                    costElementMeta.RegionInput.Id != MetaConstants.CountryInputLevelName)
                {
                    throw new Exception($"Cost element {costElementMeta.Id} with 'CountryCurrencyCost' type option must have '{MetaConstants.CountryInputLevelName}' region input.");
                }
            }

            costElementMeta.TableViewRoles = this.BuildRoles(node, TableViewNodeName);
            costElementMeta.CostEditorRoles = this.BuildRoles(node, CostEditorNodeName);

            var includeDisabledDependcyItemsAttribute = node.Attribute(IncludeDisabledDependcyItemsAttributeName);
            if (includeDisabledDependcyItemsAttribute != null)
            {
                costElementMeta.IncludeDisabledDependcyItems = bool.Parse(includeDisabledDependcyItemsAttribute.Value);
            }

            var countryReadOnlyColumnAttribute = node.Attribute(CountryReadOnlyColumnAttributeName);
            if (countryReadOnlyColumnAttribute != null)
            {
                costElementMeta.CountryReadOnlyColumn = countryReadOnlyColumnAttribute.Value;
            }

            var tableIdAttribute = node.Attribute(CostElementTableIdAttributeNodeName);
            if (tableIdAttribute != null)
            {
                costElementMeta.Table = defination.Tables[tableIdAttribute.Value];

                if (costElementMeta.Table == null)
                {
                    throw new Exception($"Table id '{tableIdAttribute.Value}' not found");
                }
            }

            return costElementMeta;
        }

        private HashSet<string> BuildRoles(XElement node, string nodeName)
        {
            HashSet<string> result = null;

            var attribute = node.Element(nodeName);
            if (attribute != null)
            {
                var roles =
                    attribute.Elements(RoleListNodeName)
                                      .Elements(RoleNodeName)
                                      .Select(roleNode => roleNode.Value);

                result = new HashSet<string>(roles);
            }

            return result;
        }

        private MetaCollection<InputLevelMetaInfo<InputLevelMeta>> BuildInputLevelMetaInfos(XElement node, DomainInfo<InputLevelMeta> domainInfo)
        {
            var inputLevelInfos = new MetaCollection<InputLevelMetaInfo<InputLevelMeta>>();

            if (node != null)
            {
                foreach (var inputLevelNode in node.Elements(InputLevelNodeName))
                {
                    var hideAttribute = inputLevelNode.Attribute(InputLevelHideAttributeName);

                    inputLevelInfos.Add(new InputLevelMetaInfo<InputLevelMeta>
                    {
                        InputLevel = domainInfo.Items[inputLevelNode.Value],
                        Hide = hideAttribute == null ? false : bool.Parse(hideAttribute.Value)
                    });
                }
            }

            if (inputLevelInfos.Count == 0)
            {
                inputLevelInfos.AddRange(
                    domainInfo.DefaultItems.Select(inpuLevel => new InputLevelMetaInfo<InputLevelMeta>
                    {
                        InputLevel = inpuLevel
                    }));
            }

            return inputLevelInfos;
        }

        private MetaCollection<T> BuildItemCollectionByDomainInfo<T>(XElement node, string nodeItemName, DomainInfo<T> domainInfo) where T : BaseMeta
        {
            List<T> items = null;

            if (node != null)
            {
                items =
                    node.Elements(nodeItemName)
                        .Select(innerNode => domainInfo.Items[innerNode.Value])
                        .ToList();
            }

            return
                items == null || items.Count == 0
                    ? new MetaCollection<T>(domainInfo.DefaultItems)
                    : new MetaCollection<T>(items);
        }

        private T BuildItemByDomainInfo<T>(XElement node, string attributeName, DomainInfo<T> domainInfo) where T : BaseMeta
        {
            T result = null;

            var idAttribute = node.Attribute(attributeName);
            if (idAttribute == null)
            {
                result = domainInfo.DefaultItems.FirstOrDefault();
            }
            else
            {
                var id = idAttribute.Value;

                result =
                    id == NoneValue
                        ? null
                        : domainInfo.Items[id];
            }

            return result;
        }

        private string BuildCostElementDescription(XElement costElementNode)
        {
            string description = null;

            var descriptionNode = costElementNode.Element(CostElementDescriptionNodeName);
            if (descriptionNode != null)
            {
                description = descriptionNode.Value;
            }

            return description;
        }

        private string GetId(XElement node, string idAttributeName = IdAttributeName)
        {
            var idAttr = node.Attribute(IdAttributeName);
            if (idAttr == null)
            {
                throw new Exception($"{IdAttributeName} attribute not found");
            }

            if (string.IsNullOrWhiteSpace(idAttr.Value) || !this.idRegex.IsMatch(idAttr.Value))
            {
                throw new Exception($"Invalid BaseDomainMeta id '{idAttr.Value}'");
            }

            return idAttr.Value;
        }

        private T BuildMeta<T>(XElement node) where T : BaseMeta, new()
        {
            var id = this.GetId(node);
            var captionAttr = node.Attribute(CaptionAttributeName);
            
            return new T
            {
                Id = id,
                Caption = captionAttr == null ? id : captionAttr.Value
            };
        }

        private DomainDefination BuildDomainDefination(XElement node)
        {
            var inputLevels = BuildInputLevelDomainInfo(node.Element(InputLevelListNodeName));

            var qualityGateNode = node.Element(QualityGateNodeName);
            if (qualityGateNode != null)
            {
                qualityGateNode = qualityGateNode.Element(DefaultNodeName);
            }

            return new DomainDefination
            {
                InputLevels = inputLevels,
                RegionInputs = BuildDomainInfoByItems(node.Element(RegionInputListNodeName), InputLevelNodeName, inputLevels.Items),
                Dependencies = BuildStoreTypedDomainInfo<DependencyMeta>(node.Element(DependencyListNodeName), DependencyNodeName),
                Applications = BuildDomainInfo<ApplicationMeta>(node.Element(ApplicationListNodeName), ApplicationNodeName),
                QualityGate = this.BuildQualityGate(qualityGateNode), 
                Tables = BuildTableMetas()
            };

            DomainInfo<InputLevelMeta> BuildInputLevelDomainInfo(XElement inputLevelNode)
            {
                var inputLevelMetas = BuildStoreTypedFilterableDomainInfo<InputLevelMeta>(inputLevelNode, InputLevelNodeName);

                var index = 0;

                foreach (var inputLevel in inputLevelMetas.Items)
                {
                    inputLevel.LevelNumber = index++;
                }

                return inputLevelMetas;

                DomainInfo<T> BuildStoreTypedFilterableDomainInfo<T>(XElement listNode, string itemNodeName)
                    where T : BaseMeta, IStoreTyped, IFilterable, new()
                {
                    var items = listNode.Elements(itemNodeName).Select(BuildStoreTypedFilterable);

                    return BuildDomainInfoByItems(listNode, itemNodeName, items);

                    T BuildStoreTypedFilterable(XElement nodeItem)
                    {
                        var element = BuildStoreTypedMeta<T>(nodeItem);

                        var filterAttr = nodeItem.Attribute(FilterAttributeName);
                        element.HideFilter = false;
                        if (filterAttr != null)
                        {
                            if (bool.TryParse(filterAttr.Value, out bool filterValue))
                                element.HideFilter = filterValue;
                        }

                        return element;
                    }
                }
            }

            DomainInfo<T> BuildDomainInfoByItems<T>(XElement listNode, string itemNodeName, IEnumerable<T> items) where T : BaseMeta, new()
            {
                var domainInfo = new DomainInfo<T>();

                domainInfo.Items.AddRange(items);

                var defaultNode = listNode.Element(DefaultNodeName);
                if (defaultNode != null)
                {
                    var defaultItems =
                        defaultNode.Elements(itemNodeName)
                                   .Select(nodeItem => domainInfo.Items[nodeItem.Value]);

                    domainInfo.DefaultItems.AddRange(defaultItems);
                }

                return domainInfo;
            }

            DomainInfo<T> BuildDomainInfo<T>(XElement listNode, string itemNodeName) where T : BaseMeta, new()
            {
                var items = listNode.Elements(itemNodeName).Select(this.BuildMeta<T>);

                return BuildDomainInfoByItems(listNode, itemNodeName, items);
            }

            DomainInfo<T> BuildStoreTypedDomainInfo<T>(XElement listNode, string itemNodeName) where T : BaseMeta, IStoreTyped, new()
            {
                var items = listNode.Elements(itemNodeName).Select(BuildStoreTypedMeta<T>);

                return BuildDomainInfoByItems(listNode, itemNodeName, items);
            }

            T BuildStoreTypedMeta<T>(XElement nodeItem) where T : BaseMeta, IStoreTyped, new()
            {
                var meta = this.BuildMeta<T>(nodeItem);

                var typeAttr = nodeItem.Attribute(TypeAttributeName);
                if (typeAttr != null)
                {
                    meta.StoreType = StoreType.View;
                }

                return meta;
            }

            MetaCollection<TableMeta> BuildTableMetas()
            {
                var result = new MetaCollection<TableMeta>();

                var tablesNode = node.Element(TableListNodeName);
                if (tablesNode != null)
                {
                    result.AddRange(tablesNode.Elements(TableNodeName).Select(BuildTableMeta));
                }

                return result;

                TableMeta BuildTableMeta(XElement tableMetaNode)
                {
                    var shemaAttribute = tableMetaNode.Attribute(TableShemaAttributeName);

                    return new TableMeta
                    {
                        Id = this.GetId(tableMetaNode),
                        Schema = shemaAttribute == null ? MetaConstants.DefaultSchema : shemaAttribute.Value,
                        Name = this.GetId(tableMetaNode, TableNameAttributeName)
                    };
                }
            }
        }

        private QualityGate BuildQualityGate(XElement node)
        {
            var qualityGate = new QualityGate();

            if (node != null)
            {
                var regionCoeffNode = node.Element(CountryGroupCoeffNodeName);
                if (regionCoeffNode != null &&
                    double.TryParse(regionCoeffNode.Value, out var regionCoeff))
                {
                    qualityGate.CountryGroupCoeff = regionCoeff;
                }

                var periodCoeffNode = node.Element(PeriodCoeffNodeName);
                if (periodCoeffNode != null &&
                    double.TryParse(periodCoeffNode.Value, out var periodCoeff))
                {
                    qualityGate.PeriodCoeff = periodCoeff;
                }
            }

            return qualityGate;
        }

        private class DomainInfo<T> where T : IMetaIdentifialble
        {
            public MetaCollection<T> Items { get; } = new MetaCollection<T>();

            public MetaCollection<T> DefaultItems { get; } = new MetaCollection<T>();
        }

        private class DomainDefination
        {
            public DomainInfo<InputLevelMeta> InputLevels { get; set; }

            public DomainInfo<InputLevelMeta> RegionInputs { get; set; }

            public DomainInfo<DependencyMeta> Dependencies { get; set; }

            public DomainInfo<ApplicationMeta> Applications { get; set; }

            public QualityGate QualityGate { get; set; }

            public MetaCollection<TableMeta> Tables { get; set; }
        }
    }
}
