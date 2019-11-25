﻿using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.MigrationTool.Interfaces;

namespace Gdc.Scd.MigrationTool.Migrations
{
    public class Migration_2019_02_15_2 : IMigrationAction
    {
        private readonly IRepositorySet repositorySet;

        public int Number => 12;

        public string Description => "Display Master Countries on Admin Availability Fee.";

        public Migration_2019_02_15_2(IRepositorySet repositorySet)
        {
            this.repositorySet = repositorySet;
        }

        public void Execute()
        {
            repositorySet.ExecuteFromFile("2019-02-15.sql");
        }
    }
}