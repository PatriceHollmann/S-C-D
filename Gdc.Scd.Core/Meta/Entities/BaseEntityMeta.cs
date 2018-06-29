﻿using System;
using System.Collections.Generic;
using System.Text;
using Gdc.Scd.Core.Meta.Interfaces;

namespace Gdc.Scd.Core.Meta.Entities
{
    public abstract class BaseEntityMeta : IMetaIdentifialble
    {
        public string Name { get; private set; }

        public string Schema { get; private set; }

        public string FullName => BuildFullName(this.Name, this.Schema);

        public abstract IEnumerable<FieldMeta> AllFields { get; }

        string IMetaIdentifialble.Id => this.FullName;

        public BaseEntityMeta(string name, string shema = null)
        {
            this.Name = name;
            this.Schema = shema;
        }

        public static string BuildFullName(string name, string schema = null)
        {
            return schema == null ? name : $"{schema}_{name}";
        }
    }
}
