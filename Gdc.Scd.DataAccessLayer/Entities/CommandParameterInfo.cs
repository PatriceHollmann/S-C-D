﻿using System.Data;

namespace Gdc.Scd.DataAccessLayer.Entities
{
    public class CommandParameterInfo
    {
        public string Name { get; set; }

        public object Value { get; set; }

        public DbType? Type { get; set; }

        public CommandParameterInfo()
        {
        }

        public CommandParameterInfo(string name, object value)
        {
            this.Name = name;
            this.Value = value;
        }
    }
}
