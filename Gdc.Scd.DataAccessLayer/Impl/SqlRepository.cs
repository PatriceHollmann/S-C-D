﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Gdc.Scd.DataAccessLayer.Entities;
using Microsoft.EntityFrameworkCore;

namespace Gdc.Scd.DataAccessLayer.Impl
{
    public class SqlRepository
    {
        private readonly EntityFrameworkRepositorySet repositorySet;

        public SqlRepository(EntityFrameworkRepositorySet repositorySet)
        {
            this.repositorySet = repositorySet;
        }

        public IEnumerable<string> GetValues(string tableName, string columnName, string schemaName = null)
        {
            var columnInfo = new ColumnInfo { Name = columnName };
            var sql = this.BuildSql(tableName, new[] { columnInfo }, schemaName);

            return this.ReadFromDb(sql, reader => reader.GetString(0));
        }

        private string BuildSql(string tableName, IEnumerable<ColumnInfo> columnInfos, string schemaName = null)
        {
            var columns = string.Join(", ", columnInfos.Select(this.BuilColumnSql));
            var table = this.BuildTableSql(schemaName, tableName);

            return $"SELECT {columns} FROM {table}";
        }

        private string BuilColumnSql(ColumnInfo columnInfo)
        {
            string result;

            if (string.IsNullOrWhiteSpace(columnInfo.Alias))
            {
                result = $"[{columnInfo.Name}]";
            }
            else
            {
                result = $"[{columnInfo.Name}] AS [{columnInfo.Alias}]";
            }

            return result;
        }

        private string BuildTableSql(string schemaName, string tableName)
        {
            string result; 

            if (string.IsNullOrWhiteSpace(schemaName))
            {
                result = $"[{tableName}]";
            }
            else
            {
                result = $"[{schemaName}].[{tableName}]";
            }

            return result;
        }

        private IEnumerable<T> ReadFromDb<T>(string sql, Func<IDataReader, T> mapFunc)
        {
            var connection = repositorySet.Database.GetDbConnection();

            try
            {
                connection.Open();

                using (var command = connection.CreateCommand())
                {
                    command.CommandText = sql;

                    var reader = command.ExecuteReader();

                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            yield return mapFunc(reader);
                        }
                    }
                }
            }
            finally
            {
                connection.Close();
            }
        }
    }
}
