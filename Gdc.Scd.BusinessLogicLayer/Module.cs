﻿using Gdc.Scd.BusinessLogicLayer.Impl;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Entities.CapabilityMatrix;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.DataAccessLayer.Helpers;
using Ninject.Modules;
using Ninject.Web.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gdc.Scd.BusinessLogicLayer
{
    public class Module : NinjectModule
    {
        public override void Load()
        {
            Bind(typeof(IDomainService<>)).To(typeof(DomainService<>)).InRequestScope();
            Bind<ICostEditorService>().To<CostEditorService>().InRequestScope();
            Bind<ICapabilityMatrixService>().To<CapabilityMatrixService>().InRequestScope();
            Bind<IUserService>().To<UserService>().InRequestScope();
            Bind<ICostBlockHistoryService>().To<CostBlockHistoryService>().InRequestScope();
            Bind<IAvailabilityFeeAdminService>().To<AvailabilityFeeAdminService>().InRequestScope();
            Bind<IEmailService>().To<EmailService>().InRequestScope();
            Bind<ICostBlockFilterBuilder>().To<CostBlockFilterBuilder>().InRequestScope();
            services.AddScoped<ICostBlockFilterBuilder, CostBlockFilterBuilder>();
            services.AddScoped<IQualityGateSevice, QualityGateSevice>();
            Kernel.RegisterEntity<Country>();
            Kernel.RegisterEntity<Pla>();
            Kernel.RegisterEntity<Wg>();
            Kernel.RegisterEntity<Availability>();
            Kernel.RegisterEntity<Duration>();
            Kernel.RegisterEntity<ReactionType>();
            Kernel.RegisterEntity<ReactionTime>();
            Kernel.RegisterEntity<ReactionTimeType>();
            Kernel.RegisterEntity<ReactionTimeAvalability>();
            Kernel.RegisterEntity<ReactionTimeTypeAvalability>();
            Kernel.RegisterEntity<ServiceLocation>();
            Kernel.RegisterEntity<CapabilityMatrix>();
            Kernel.RegisterEntity<CapabilityMatrixRule>();
            Kernel.RegisterEntity<CapabilityMatrixAllowView>();
            Kernel.RegisterEntity<AdminAvailabilityFee>();
            Kernel.RegisterEntity<CapabilityMatrixCountryAllowView>();
            Kernel.RegisterEntity<RoleCode>();
            Kernel.RegisterEntity<Role>();
            Kernel.RegisterEntity<UserRole>();
            services.RegisterEntity<ClusterRegion>();
            services.RegisterEntity<Country>();
            services.RegisterEntity<CountryGroup>();
            services.RegisterEntity<Pla>();
            services.RegisterEntity<Wg>();
            services.RegisterEntity<Availability>();
            services.RegisterEntity<Year>();
            services.RegisterEntity<Duration>();
            services.RegisterEntity<ReactionType>();
            services.RegisterEntity<ReactionTime>();
            services.RegisterEntity<ReactionTimeType>();
            services.RegisterEntity<ReactionTimeAvalability>();
            services.RegisterEntity<ReactionTimeTypeAvalability>();
            services.RegisterEntity<ServiceLocation>();
            services.RegisterEntity<CapabilityMatrix>();
            services.RegisterEntity<CapabilityMatrixRule>();
            services.RegisterEntity<CapabilityMatrixAllowView>();
            services.RegisterEntity<AdminAvailabilityFee>();
            services.RegisterEntity<CapabilityMatrixCountryAllowView>();
            services.RegisterEntity<RoleCode>();
            services.RegisterEntity<HardwareCalculationResult>();
            services.RegisterEntity<Currency>();
            services.RegisterEntity<ExchangeRate>();
            services.RegisterEntity<YearAvailability>();
            services.RegisterEntity<ClusterPla>();
        }
    }
}
