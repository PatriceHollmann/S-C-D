﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Impl.MetaBuilders;
using Ninject;

namespace Gdc.Scd.DataAccessLayer.Impl
{
    public class DatabaseCreationHandler : IConfigureApplicationHandler
    {
        private readonly DomainEnitiesMeta meta;

        private readonly IKernel serviceProvider;

        private readonly EntityFrameworkRepositorySet repositorySet;

        private readonly ICostBlockRepository costBlockRepository;

        public DatabaseCreationHandler(
            DomainEnitiesMeta meta, 
            IKernel serviceProvider, 
            EntityFrameworkRepositorySet repositorySet, 
            ICostBlockRepository costBlockRepository)
        {
            this.meta = meta;
            this.serviceProvider = serviceProvider;
            this.repositorySet = repositorySet;
            this.costBlockRepository = costBlockRepository;
        }

        public void Handle()
        {
            if (this.repositorySet.Database.EnsureCreated())
            {
                var entities = repositorySet.GetRegisteredEntities();
                var entityInfos = this.GetEnityInfos(entities).ToArray();
                var tableCommands = this.GetCreateTableCommands(entityInfos);
                var constraintCommands = this.GetCreateConstraintCommands(entityInfos);
                var addDefaultCommands = this.GetAddDefaultCommands();
                var commands = this.GetCreateSchemaCommands(entityInfos).Concat(tableCommands).Concat(constraintCommands).Concat(addDefaultCommands);

                foreach (var command in commands)
                {
                    this.repositorySet.ExecuteSql(command);
                }

                this.costBlockRepository.CreatRegionIndexes();

                foreach (var configDatabaseHandler in this.serviceProvider.GetAll<IConfigureDatabaseHandler>())
                {
                    configDatabaseHandler.Handle();
                }
            }
        }

        private IEnumerable<string> GetCreateSchemaCommands(IEnumerable<(string Schema, string Table)> registeredEntityInfos)
        {
            var registeredSchemas = registeredEntityInfos.Select(entityInfo => entityInfo.Schema).Distinct();
            var registeredSchemaSet = new HashSet<string>(registeredSchemas);
            var schemas =
                this.meta.AllMetas.Select(meta => meta.Schema)
                                  .Distinct()
                                  .Where(schema => !registeredSchemaSet.Contains(schema));

            foreach (var schema in schemas)
            {
                var schamaBuilder = new CreateSchemMetaSqlBuilder { Schema = schema };

                yield return schamaBuilder.Build(null);
            }
        }

        private IEnumerable<string> GetCreateTableCommands(IEnumerable<(string Schema, string Table)> registeredEntityInfos)
        {
            var entityMetas = this.GetNotRegisteredMetas(registeredEntityInfos);
            var customHandlers = this.serviceProvider.GetAll<ICustomConfigureTableHandler>();

            foreach (var entityMeta in entityMetas)
            {
                if (entityMeta.AllFields.Any() && entityMeta.StoreType == StoreType.Table)
                {
                    var tableBuilder = new CreateTableMetaSqlBuilder(this.serviceProvider)
                    {
                        Meta = entityMeta
                    };

                    yield return tableBuilder.Build(null);
                }

                foreach (var customHandler in customHandlers)
                {
                    foreach (var sqlBuilder in customHandler.GetSqlBuilders(entityMeta))
                    {
                        yield return sqlBuilder.Build(null);
                    }
                }
            }          
        }

        private IEnumerable<string> GetAddDefaultCommands()
        {
            var entities = repositorySet.GetRegisteredEntities();

            foreach (var entity in entities)
            {
                if (typeof(IDeactivatable).IsAssignableFrom(entity))
                {
                    var tableAttr = GetTableAttribute(entity);

                    yield return Sql.AddDefault(tableAttr.Name, nameof(IDeactivatable.CreatedDateTime), this.GetDefaultExpresstion(), tableAttr.Schema).ToQueryData().Sql;
                    
                }

                if (typeof(IModifiable).IsAssignableFrom(entity))
                {
                    var tableAttr = GetTableAttribute(entity);

                    yield return Sql.AddDefault(tableAttr.Name, nameof(IModifiable.ModifiedDateTime), this.GetDefaultExpresstion(), tableAttr.Schema).ToQueryData().Sql;
                }
            }

            TableAttribute GetTableAttribute(Type entity)
            {
                return entity.GetCustomAttributes(false).Select(attr => attr as TableAttribute).FirstOrDefault(attr => attr != null);
            }
        }

        private string GetDefaultExpresstion()
        {
            return "GETUTCDATE()";
        }

        private IEnumerable<(string Schema, string Table)> GetEnityInfos(IEnumerable<Type> registeredEntities)
        {
            foreach (var entityType in registeredEntities)
            {
                string table;
                string schema = null;

                var tableAttr =
                    entityType.GetCustomAttributes(false)
                              .Select(attr => attr as TableAttribute)
                              .FirstOrDefault(attr => attr != null);

                if (tableAttr == null)
                {
                    table = entityType.Name;
                }
                else
                {
                    table = tableAttr.Name;
                    schema = tableAttr.Schema;
                }

                yield return (schema, table);
            }
        }

        private IEnumerable<string> GetCreateConstraintCommands(IEnumerable<(string Schema, string Table)> registeredEntityInfos)
        {
            return
                this.GetNotRegisteredMetas(registeredEntityInfos)
                    .SelectMany(meta => meta.AllFields.Select(field => new { Meta = meta, Field = field }))
                    .OrderByDescending(fieldInfo => fieldInfo.Field is IdFieldMeta)
                    .Select(fieldInfo => new CreateColumnConstraintMetaSqlBuilder
                    {
                        Meta = fieldInfo.Meta,
                        Field = fieldInfo.Field.Name
                    })
                    .Select(builder => builder.Build(null))
                    .Where(sql => !string.IsNullOrEmpty(sql));
        }

        private IEnumerable<BaseEntityMeta> GetNotRegisteredMetas(IEnumerable<(string Schema, string Table)> registeredEntityInfos)
        {
            return this.meta.AllMetas.Where(
                entityMeta => registeredEntityInfos.All(
                    entityInfo => entityInfo.Schema != entityMeta.Schema || entityInfo.Table != entityMeta.Name));
        }
    }
}
