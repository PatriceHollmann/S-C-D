﻿using System.Collections.Generic;
using System.Linq;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Interfaces;

namespace Gdc.Scd.Core.Meta.Entities
{
    public abstract class BaseEntityMeta : IMetaIdentifialble, IStoreTyped
    {
        public string Name { get; private set; }

        public string Schema { get; private set; }

        public string FullName => BuildFullName(this.Name, this.Schema);

        public StoreType StoreType { get; set; }

        public BaseEntityMeta RealMeta { get; set; }

        public IEnumerable<ReferenceFieldMeta> ReferenceFields => this.AllFields.OfType<ReferenceFieldMeta>();

        public abstract IEnumerable<FieldMeta> AllFields { get; }

        string IMetaIdentifialble.Id => this.FullName;

        public BaseEntityMeta(string name, string shema)
        {
            this.Name = name;
            this.Schema = shema;
        }

        public static string BuildFullName(string name, string schema = MetaConstants.DefaultSchema)
        {
            return schema == null ? name : $"{schema}_{name}";
        }

        public FieldMeta GetField(string fieldName)
        {
            return this.AllFields.FirstOrDefault(field => field.Name == fieldName);
        }

        public ReferenceFieldMeta GetFieldByReferenceMeta(BaseEntityMeta referenceMeta)
        {
            return
                this.ReferenceFields.FirstOrDefault(field => field.ReferenceMeta == referenceMeta);
        }
    }
}
