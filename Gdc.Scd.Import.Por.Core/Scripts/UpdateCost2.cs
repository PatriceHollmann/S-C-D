﻿using Gdc.Scd.Core.Entities;

namespace Gdc.Scd.Import.Por.Core.Scripts
{
    public partial class UpdateCost
    {
        protected NamedId[] items;

        protected string[] deps;

        protected string[] updateFields;

        protected string table;

        public UpdateCost(NamedId[] items)
        {
            if (items == null || items.Length == 0)
            {
                throw new System.ArgumentException("empty items");
            }
            this.items = items;
        }

        public UpdateCost WithUpdateFields(string[] fields)
        {
            this.updateFields = fields;
            return this;
        }

        public UpdateCost WithTable(string tbl)
        {
            this.table = tbl;
            return this;
        }

        public UpdateCost WithDeps(string[] deps)
        {
            this.deps = deps;
            return this;
        }

        public string Build()
        {
            GenerationEnvironment.Clear();
            return TransformText();
        }

        protected void WriteNames()
        {
            for (var i = 0; i < items.Length; i++)
            {
                if (i > 0)
                {
                    Write(", ");
                }
                Write("'");
                Write(items[i].Name.ToUpper());
                Write("'");
            }
        }

        protected void WriteDeps()
        {
            for (var i = 0; i < deps.Length; i++)
            {
                if (i > 0)
                {
                    Write(", ");
                }
                Write("[");
                Write(deps[i]);
                Write("]");
            }
        }

        protected void WriteJoinByDeps()
        {
            for (var i = 0; i < deps.Length; i++)
            {
                if (i > 0)
                {
                    Write(" and ");
                }
                Write("t.["); Write(deps[i]); Write("] = c.["); Write(deps[i]); Write("]");
            }
        }

        protected void WriteSelectFields()
        {
            const string whitespace = "      , ";
            for (var i = 0; i < updateFields.Length; i++)
            {
                if (i > 0)
                {
                    Write(whitespace);
                }
                WriteSelectField(updateFields[i]);
                WriteLine(string.Empty);
                Write(whitespace);
                WriteSelectField(updateFields[i] + "_Approved");
                WriteLine(string.Empty);
            }
        }

        protected void WriteSelectField(string f)
        {
            Write("case when min(["); Write(f); Write("]) = max(["); Write(f); Write("]) then min(["); Write(f); Write("]) else null end as ["); Write(f); Write("]");
        }

        protected void WriteSetFields()
        {
            const string whitespace = "      , ";
            for (var i = 0; i < updateFields.Length; i++)
            {
                if (i > 0)
                {
                    Write(whitespace);
                }
                WriteSetField(updateFields[i]);
                WriteLine(string.Empty);
                Write(whitespace);
                WriteSetField(updateFields[i] + "_Approved");
                WriteLine(string.Empty);
            }
        }

        protected void WriteSetField(string f)
        {
            Write("["); Write(f); Write("] = coalesce(t.["); Write(f); Write("], c.["); Write(f); Write("])");
        }
    }
}
