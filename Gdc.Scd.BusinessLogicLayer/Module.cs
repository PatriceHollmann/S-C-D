﻿using Gdc.Scd.BusinessLogicLayer.Impl;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Entities.Calculation;
using Gdc.Scd.Core.Entities.Portfolio;
using Gdc.Scd.Core.Entities.Report;
using Gdc.Scd.DataAccessLayer.Helpers;
using Ninject.Modules;
using Ninject.Web.Common;

namespace Gdc.Scd.BusinessLogicLayer
{
    public class Module : NinjectModule
    {
        public override void Load()
        {
            Bind(typeof(IDomainService<>)).To(typeof(DomainService<>)).InRequestScope();
            Bind<IWgPorService>().To<WgPorDecoratorService>().InRequestScope();
            Bind<ICostEditorService>().To<CostEditorService>().InRequestScope();
            Bind<IPortfolioService>().To<PortfolioService>().InRequestScope();
            Bind<ICalculationService>().To<CalculationService>().InRequestScope();
            Bind<IReportService>().To<ReportService>().InRequestScope();
            Bind<IUserService>().To<UserService>().InRequestScope();
            Bind<ICostBlockHistoryService>().To<CostBlockHistoryService>().InRequestScope();
            Bind<IAvailabilityFeeAdminService>().To<AvailabilityFeeAdminService>().InRequestScope();
            Bind<ICountryAdminService>().To<CountryAdminService>().InRequestScope();
            Bind<ICountryUserService>().To<CountryUserService>().InRequestScope();
            Bind<IEmailService>().To<EmailService>().InRequestScope();
            Bind<IQualityGateSevice>().To<QualityGateSevice>().InRequestScope();
            Bind<IActiveDirectoryService>().To<ActiveDirectoryService>().InRequestScope();
            Bind<ITableViewService>().To<TableViewService>().InRequestScope();
            Bind<IAppService>().To<AppService>().InRequestScope();
            Bind<ICostBlockService>().To<CostBlockService>().InRequestScope();
            Bind<IApprovalService>().To<ApprovalService>().InRequestScope();
            Bind<INotifyChannel>().To<MemoryChannel>().InSingletonScope();
            Bind<ICostElementExcelService>().To<CostElementExcelService>().InRequestScope(); 

            /*----------dictionaries-----------*/
            Kernel.RegisterEntity<ClusterRegion>();
            Kernel.RegisterEntity<Region>();
            Kernel.RegisterEntity<Country>();
            Kernel.RegisterEntity<CountryGroup>();
            Kernel.RegisterEntity<Pla>();
            Kernel.RegisterEntity<CentralContractGroup>();
            Kernel.RegisterEntity<Wg>();
            Kernel.RegisterEntity<Availability>();
            Kernel.RegisterEntity<Year>();
            Kernel.RegisterEntity<Duration>();
            Kernel.RegisterEntity<ReactionType>();
            Kernel.RegisterEntity<ReactionTime>();
            Kernel.RegisterEntity<ReactionTimeType>();
            Kernel.RegisterEntity<ReactionTimeAvalability>();
            Kernel.RegisterEntity<ReactionTimeTypeAvalability>();
            Kernel.RegisterEntity<ServiceLocation>();
            Kernel.RegisterEntity<Currency>();
            Kernel.RegisterEntity<ExchangeRate>();
            Kernel.RegisterEntity<YearAvailability>();
            Kernel.RegisterEntity<ClusterPla>();
            Kernel.RegisterEntity<ProActiveSla>();
            Kernel.RegisterEntity<SwDigit>();
            Kernel.RegisterEntity<Sog>();
            Kernel.RegisterEntity<SFab>();
            Kernel.RegisterEntity<SwLicense>();
            Kernel.RegisterEntity<SwDigitLicense>();
            Kernel.RegisterEntity<HwFspCodeTranslation>();
            Kernel.RegisterEntity<HwHddFspCodeTranslation>();
            Kernel.RegisterEntity<SwFspCodeTranslation>();
            Kernel.RegisterEntity<ImportConfiguration>();
            Kernel.RegisterEntity<ProActiveDigit>();
            /*----------cost block entities---------*/
            Kernel.RegisterEntity<AvailabilityFee>();
            Kernel.RegisterEntity<TaxAndDutiesEntity>();
            Kernel.RegisterEntity<Afr>();
            Kernel.RegisterEntity<InstallBase>();
            Kernel.RegisterEntity<MaterialCostInWarranty>();
            Kernel.RegisterEntity<CdCsConfiguration>();
            /*----------admin---------*/
            Kernel.RegisterEntity<AdminAvailabilityFee>();
            Kernel.RegisterEntity<RoleCode>();

            /*---------domain business logic------------*/
            Kernel.RegisterEntity<LocalPortfolio>();
            Kernel.RegisterEntity<PrincipalPortfolio>();
            Kernel.RegisterEntity<HardwareManualCost>();

            /*---------reports----------*/
            Kernel.RegisterEntity<Report>();
            Kernel.RegisterEntity<ReportColumn>();
            Kernel.RegisterEntity<ReportFilter>();
            Kernel.RegisterEntity<JobsSchedule>();
        }
    }
}
