﻿using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers;
using Gdc.Scd.MigrationTool.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gdc.Scd.MigrationTool.Migrations
{
	public class Migration_2019_02_11_2 : IMigrationAction
	{
		private readonly IRepositorySet repositorySet;

		public int Number => 4;

		public string Description => "Multiselect filters for portfolio and calc results";

		public Migration_2019_02_11_2(IRepositorySet repositorySet)
		{
			this.repositorySet = repositorySet;
		}

		public void Execute()
		{
            var queries = new List<SqlHelper>();
            queries.AddRange(SqlFormatter.BuildFromFile(@"MigrationScripts\2019-02-11-2.sql"));
            foreach (var query in queries)
                this.repositorySet.ExecuteSql(query);
		}
	}
}
