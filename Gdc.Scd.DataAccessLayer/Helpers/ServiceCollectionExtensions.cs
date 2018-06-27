﻿using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.DataAccessLayer.Impl;
using Microsoft.Extensions.DependencyInjection;

namespace Gdc.Scd.DataAccessLayer.Helpers
{
    public static class ServiceCollectionExtensions
    {
        public static void AddEntityFrameworkRepository<TRepository, TEntity>(this IServiceCollection services)
            where TRepository : EntityFrameworkRepository<TEntity>
            where TEntity : class, IIdentifiable, new()
        {
            services.AddSingleton<EntityFrameworkRepository<TEntity>, TRepository>();
        }

        public static void RegisterEntity<T>(this IServiceCollection services) where T : class, IIdentifiable
        {
            EntityFrameworkRepositorySet.RegisteredEntities.Add(typeof(T));
        }
    }
}
