﻿using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.DataAccessLayer.Impl;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Microsoft.Extensions.DependencyInjection;

namespace Gdc.Scd.DataAccessLayer
{
    public class Module : IModule
    {
        public void Init(IServiceCollection services)
        {
            services.AddScoped(typeof(EntityFrameworkRepository<>), typeof(EntityFrameworkRepository<>));
            services.AddScoped<IRepositorySet, EntityFrameworkRepositorySet>();
            services.AddScoped<ISqlRepository, SqlRepository>();
            services.AddScoped<ICostEditorRepository, CostEditorRepository>();
        }
    }
}
