﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.Core.Meta.Interfaces;
using Microsoft.Extensions.Configuration;

namespace Gdc.Scd.Core.Meta.Impl
{
    public class DomainMetaSevice : IDomainMetaSevice
    {
        private const string NameAttributeName = "Name";

        private const string CostAtomListNodeName = "Atoms";

        private const string CostAtomNodeName = "Atom";

        private const string CostBlockListNodeName = "Blocks";

        private const string CostBlockNodeName = "Block";

        private const string CostBlockApplicationListNodeName = "Applications";

        private const string CostBlockApplicationNodeName = "Application";

        private const string CostBlockApplicationSeparator = ",";

        private const string CostElementListNodeName = "Elements";

        private const string CostElementNodeName = "Element";

        private const string CostElementScopeAttributeName = "Domain";

        private const string CostElementDependencyNodeName = "Dependency";

        private const string CostElementDescriptionNodeName = "Description";

        private const string DomainMetaConfigKey = "DomainMetaFile";

        private readonly IConfiguration configuration;

        private readonly string[] forbiddenIdSymbols = new[] { " ", "(", ")" };

        public DomainMetaSevice(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public DomainMeta Get()
        {
            var fileName = this.configuration[DomainMetaConfigKey];
            var doc = XDocument.Load(fileName);

            return this.BuilDomainMeta(doc.Root);
        }

        private DomainMeta BuilDomainMeta(XElement configNode)
        {
            var costBlocksNode = configNode.Element(CostBlockListNodeName);
            if (costBlocksNode == null)
            {
                throw new Exception("Cost blocks node not found");
            }

            var costAtoms = costBlocksNode.Elements(CostAtomListNodeName).Select(this.BuildCostItemMeta<CostAtomMeta>);
            var costBlocks = costBlocksNode.Elements(CostBlockNodeName).Select(this.BuildCostBlockMeta);

            return new DomainMeta
            {
                CostAtoms = new MetaCollection<CostAtomMeta>(costAtoms),
                CostBlocks = new MetaCollection<CostBlockMeta>(costBlocks),
                Applications = new MetaCollection<ApplicationMeta>(this.BuildApplicationsMetas()),
            };
        }

        private T BuildCostItemMeta<T>(XElement node) where T : CostAtomMeta, new()
        {
            var nameAttr = node.Attribute(NameAttributeName);
            if (nameAttr == null)
            {
                throw new Exception("Cost block or cost atom name attribute not found");
            }

            var costItem = new T
            {
                Id = this.BuildId(nameAttr.Value),
                Name = nameAttr.Value,
            };

            var costElementListNode = node.Element(CostElementListNodeName);
            if (costElementListNode == null)
            {
                throw new Exception("Cost elements node not found");
            }

            var costElements = costElementListNode.Elements(CostElementNodeName).Select(this.BuildCostElementMeta);

            costItem.CostElements = new MetaCollection<CostElementMeta>(costElements);

            return costItem;
        }

        private CostBlockMeta BuildCostBlockMeta(XElement node)
        {
            var costBlockMeta = this.BuildCostItemMeta<CostBlockMeta>(node);

            var applicationAttr = node.Attribute(CostBlockApplicationNodeName);
            if (applicationAttr == null)
            {
                throw new Exception("Cost block application attribute not found");
            }

            costBlockMeta.ApplicationIds = 
                applicationAttr.Value.Split(CostBlockApplicationSeparator)
                                     .Select(application => application.Trim())
                                     .ToList();

            return costBlockMeta;
        }

        private CostElementMeta BuildCostElementMeta(XElement node)
        {
            var nameAttr = node.Attribute(NameAttributeName);
            if (nameAttr == null)
            {
                throw new Exception("Cost element name attribute not found");
            }

            var costElementMeta = new CostElementMeta
            {
                Id = this.BuildId(nameAttr.Value),
                Name = nameAttr.Value,
            };

            var scopeAttr = node.Attribute(CostElementScopeAttributeName);
            if (scopeAttr == null)
            {
                throw new Exception("Cost element scope attribute not found");
            }

            costElementMeta.Dependency = this.BuildCostElementDependency(node);
            costElementMeta.Description = this.BuildCostElementDescription(node);

            return costElementMeta;
        }

        private DependencyMeta BuildCostElementDependency(XElement costElementNode)
        {
            DependencyMeta dependency = null;

            var dependencyNode = costElementNode.Element(CostElementDependencyNodeName);
            if (dependencyNode != null)
            {
                var nameAttr = dependencyNode.Attribute(NameAttributeName);
                if (nameAttr == null)
                {
                    throw new Exception("Dependency name attribute not found");
                }

                dependency = new DependencyMeta
                {
                    Id = this.BuildId(nameAttr.Value),
                    Name = nameAttr.Value
                };
            }

            return dependency;
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

        private IEnumerable<InputLevelMeta> BuildInputLevelMetas()
        {
            return new[]
            {
                new InputLevelMeta{ Id = MetaConstants.CountryLevelId, Name = "Country" },
                new InputLevelMeta{ Id = MetaConstants.PlaLevelId, Name = "PLA" },
                new InputLevelMeta{ Id = MetaConstants.WgLevelId, Name = "WG" },
            };
        }

        private IEnumerable<ApplicationMeta> BuildApplicationsMetas()
        {
            return new[]
            {
                new ApplicationMeta { Id = "Hardware", Name = "Hardware" },
                new ApplicationMeta { Id = "Software", Name = "Software & Solution" }
            };
        }

        private IEnumerable<ScopeMeta> BuildScopeMetas()
        {
            return new[]
            {
                new ScopeMeta { Id = "Local", Name = "Local" },
                new ScopeMeta { Id = "Central", Name = "Central" }
            };
        }

        private string BuildId(string name)
        {
            foreach(var symbol in this.forbiddenIdSymbols)
            {
                name = name.Replace(symbol, string.Empty);
            }

            return name;
        }
    }
}
