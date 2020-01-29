﻿using Gdc.Scd.Core.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.Core.Meta.Entities
{
    public class CostBlockEntityMeta : BaseCostBlockEntityMeta
    {
        public CostBlockValueHistoryEntityMeta HistoryMeta { get; set; }

        public IDictionary<FieldMeta, FieldMeta> CostElementsApprovedFields { get; } = new Dictionary<FieldMeta, FieldMeta>();

        public CreatedDateTimeFieldMeta CreatedDateField { get; } = new CreatedDateTimeFieldMeta();

        public SimpleFieldMeta DeletedDateField { get; } = new SimpleFieldMeta(nameof(IDeactivatable.DeactivatedDateTime), TypeCode.DateTime) { IsNullOption = true };

        public SimpleFieldMeta LastCoordinateModificationDateField { get; } = new SimpleFieldMeta("LastCoordinateModification", TypeCode.DateTime) { IsNullOption = true };

        public ReferenceFieldMeta PreviousVersionField { get; }

        public CostBlockMeta DomainMeta { get; }

        public override IEnumerable<FieldMeta> AllFields
        {
            get
            {
                var fields = base.AllFields.Concat(this.CostElementsApprovedFields.Values);

                foreach (var field in fields)
                {
                    yield return field;
                }

                yield return this.CreatedDateField;
                yield return this.DeletedDateField;
                yield return this.LastCoordinateModificationDateField;
                yield return this.PreviousVersionField;
            }
        }

        public CostBlockEntityMeta(CostBlockMeta meta, string name, string shema = null)
            : base(name, shema)
        {
            this.DomainMeta = meta;
            this.PreviousVersionField = new ReferenceFieldMeta("PreviousVersion", this, this.IdField.Name)
            {
                IsNullOption = true
            };
        }

        public FieldMeta GetApprovedCostElement(string costElementId)
        {
            var costElementField = this.CostElementsFields[costElementId];

            this.CostElementsApprovedFields.TryGetValue(costElementField, out var approvedCostElement);

            return approvedCostElement;
        }

        public IEnumerable<ReferenceFieldMeta> GetDomainInputLevelFields(string costElementId)
        {
            return this.GetDomainInputLevelFields(this.DomainMeta.CostElements[costElementId]);
        }

        public ReferenceFieldMeta GetDomainDependencyField(string costElementId)
        {
            ReferenceFieldMeta dependencyField = null;

            var costElement = this.DomainMeta.CostElements[costElementId];
            if (costElement.Dependency != null)
            {
                dependencyField = this.DependencyFields[costElement.Dependency.Id];
            }

            return dependencyField;
        }

        public IEnumerable<ReferenceFieldMeta> GetDomainCoordinateFields(string costElementId)
        {
            var costElement = this.DomainMeta.CostElements[costElementId];
            
            foreach (var inputLevelField in this.GetDomainInputLevelFields(costElement))
            {
                yield return inputLevelField;
            }

            if (costElement.Dependency != null)
            {
                yield return this.DependencyFields[costElement.Dependency.Id];
            }
        }

        public ReferenceFieldMeta GetDomainCoordinateField(string costElementId, string fieldName)
        {
            return
                this.GetDomainCoordinateFields(costElementId)
                    .FirstOrDefault(field => field.Name == fieldName);
        }

        private IEnumerable<ReferenceFieldMeta> GetDomainInputLevelFields(CostElementMeta costElement)
        {
            foreach(var field in costElement.InputLevels.Select(inputLevel => this.InputLevelFields[inputLevel.Id]))
            {
                yield return field;
            }

            if (costElement.RegionInput != null && !costElement.HasInputLevel(costElement.RegionInput.Id))
            {
                yield return this.InputLevelFields[costElement.RegionInput.Id];
            }
        }
    }
}
