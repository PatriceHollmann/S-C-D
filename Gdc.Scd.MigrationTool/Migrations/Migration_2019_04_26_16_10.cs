﻿using Gdc.Scd.MigrationTool.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Gdc.Scd.DataAccessLayer.Interfaces;

namespace Gdc.Scd.MigrationTool.Migrations
{
    public class Migration_2019_04_26_16_10 : IMigrationAction
    {
        private readonly IRepositorySet repositorySet;

        public int Number => 91;

        public string Description => "Fix Release Service TP for prolongation";

        public Migration_2019_04_26_16_10(IRepositorySet repositorySet)
        {
            this.repositorySet = repositorySet;
        }

        public void Execute()
        {
            repositorySet.ExecuteFromFile("2019-04-26-16-10.sql");
        }
    }
}
