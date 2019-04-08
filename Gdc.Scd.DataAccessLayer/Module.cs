﻿using System;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Entities.Calculation;
using Gdc.Scd.Core.Helpers;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.Core.Meta.Interfaces;
using Gdc.Scd.DataAccessLayer.Helpers;
using Gdc.Scd.DataAccessLayer.Impl;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Impl.MetaBuilders;
using Ninject.Activation;
using Ninject.Modules;

namespace Gdc.Scd.DataAccessLayer
{
    public class Module : NinjectModule
    {
        public override void Load()
        {
            Bind(typeof(IRepository<>)).To(typeof(DeactivateDecoratorRepository<>)).When(this.IsDeactivatable).InScdRequestScope();
            Bind(typeof(IRepository<>)).To(typeof(EntityFrameworkRepository<>)).InScdRequestScope();
            Bind<IRepositorySet, IRegisteredEntitiesProvider, EntityFrameworkRepositorySet>().To<EntityFrameworkRepositorySet>().InScdRequestScope();
            Bind<ICostEditorRepository>().To<CostEditorRepository>().InScdRequestScope();
            Bind<ICostBlockValueHistoryRepository>().To<CostBlockValueHistoryRepository>().InScdRequestScope();
            Bind<ISqlRepository>().To<SqlRepository>().InScdRequestScope();
            Bind<IRepository<CostBlockHistory>>().To<CostBlockHistoryRepository>().InScdRequestScope();
            Bind<IWgRepository, IRepository<Wg>>().To<WgRepository>().InScdRequestScope();
            Bind<IRepository<ReactionTimeType>>().To<ReactionTimeTypeRepository>().InScdRequestScope();
            Bind<IRepository<ReactionTimeAvalability>>().To<ReactionTimeAvalabilityRepository>().InScdRequestScope();
            Bind<IRepository<ReactionTimeTypeAvalability>>().To<ReactionTimeTypeAvalabilityRepository>().InScdRequestScope();
            Bind<ICostBlockValueHistoryQueryBuilder>().To<CostBlockValueHistoryQueryBuilder>().InScdRequestScope();
            Bind<IRepository<DurationAvailability>>().To<DurationAvailabilityRepository>().InScdRequestScope();
            Bind<IQualityGateRepository>().To<QualityGateRepository>().InScdRequestScope();
            Bind<IQualityGateQueryBuilder>().To<QualityGateQueryBuilder>().InScdRequestScope();
            Bind<IRepository<Country>>().To<CountryRepository>().InScdRequestScope();
            Bind<ITableViewRepository>().To<TableViewRepository>().InScdRequestScope();
            Bind<IRepository<Role>>().To<RoleRepository>().InScdRequestScope();
            Bind<IUserRepository, IRepository<User>>().To<UserRepository>().InScdRequestScope();
            Bind<ICostBlockRepository>().To<CostBlockRepository>().InScdRequestScope();
            Bind<IApprovalRepository>().To<ApprovalRepository>().InScdRequestScope();
            Bind<IRepository<HardwareManualCost>>().To<HardwareManualCostRepository>().InScdRequestScope();
            Bind<IRepository<HddRetentionManualCost>>().To<HddRetentionManualCostRepository>().InScdRequestScope();
            Bind<ICostBlockFilterBuilder>().To<CostBlockFilterBuilder>().InScdRequestScope();
            Bind<ICostBlockQueryBuilder>().To<CostBlockQueryBuilder>().InScdRequestScope();

            Bind<BaseColumnMetaSqlBuilder<IdFieldMeta>>().To<IdColumnMetaSqlBuilder>().InTransientScope();
            Bind<BaseColumnMetaSqlBuilder<SimpleFieldMeta>>().To<SimpleColumnMetaSqlBuilder>().InTransientScope();
            Bind<BaseColumnMetaSqlBuilder<ReferenceFieldMeta>>().To<ReferenceColumnMetaSqlBuilder>().InTransientScope();
            Bind<BaseColumnMetaSqlBuilder<CreatedDateTimeFieldMeta>>().To<CreatedDateTimeColumnMetaSqlBuilder>().InTransientScope();
            Bind<CreateTableMetaSqlBuilder>().To<CreateTableMetaSqlBuilder>().InTransientScope();
            Bind<DatabaseMetaSqlBuilder>().To<DatabaseMetaSqlBuilder>().InTransientScope();
            Bind<IConfigureApplicationHandler>().To<DatabaseCreationHandler>().InTransientScope();
            Bind<IConfigureDatabaseHandler, ICustomConfigureTableHandler, ICoordinateEntityMetaProvider>().To<ViewConfigureHandler>().InTransientScope();
            Bind<IConfigureDatabaseHandler>().To<CountryViewConfigureHandler>().InTransientScope();

            Kernel.RegisterEntity<CostBlockHistory>(builder => builder.OwnsOne(typeof(CostElementContext), nameof(CostBlockHistory.Context)));
            Kernel.RegisterEntityAsUnique<User>(nameof(User.Login));
            Kernel.RegisterEntity<UserRole>();
            Kernel.RegisterEntityAsUniqueName<Role>();
            Kernel.RegisterEntityAsUniqueName<Permission>();
            Kernel.RegisterEntity<RolePermission>();
        }

        private bool IsDeactivatable(IRequest arg)
        {
            var type = arg.Service.GetGenericArguments();
            var deactivatable = typeof(IDeactivatable);
            return Array.Exists(type, x => deactivatable.IsAssignableFrom(x));
        }
    }
}
