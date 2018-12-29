﻿using System;
using System.Collections.Generic;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Constants;

namespace Gdc.Scd.Core.Meta.Entities
{
    public class WgEnityMeta : BaseWgSogEntityMeta
    {
        public ReferenceFieldMeta SogField { get; }
        public ReferenceFieldMeta CentralContractGroupField { get; }

        public SimpleFieldMeta WgTypeField { get; }

        public WgEnityMeta(NamedEntityMeta plaMeta, NamedEntityMeta sfabMeta, NamedEntityMeta sogMeta, 
            NamedEntityMeta centralContractGroupMeta) 
            : base(MetaConstants.WgInputLevelName, MetaConstants.InputLevelSchema, plaMeta, sfabMeta)
        {
            this.SogField = ReferenceFieldMeta.Build(nameof(Wg.SogId), sogMeta);
            this.WgTypeField = new SimpleFieldMeta(nameof(Wg.WgType), TypeCode.Int32);
            this.CentralContractGroupField = ReferenceFieldMeta.Build(nameof(Wg.CentralContractGroupId), centralContractGroupMeta);
        }

        public override IEnumerable<FieldMeta> AllFields
        {
            get
            {
                yield return this.SogField;
                yield return this.CentralContractGroupField;
                yield return this.WgTypeField;

                foreach (var field in base.AllFields)
                {
                    yield return field;
                }
            }
        }
    }
}
