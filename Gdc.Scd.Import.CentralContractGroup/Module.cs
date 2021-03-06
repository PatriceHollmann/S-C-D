﻿using Gdc.Scd.BusinessLogicLayer.Helpers;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Import.Core.DataAccess;
using Gdc.Scd.Import.Core.Dto;
using Gdc.Scd.Import.Core.Impl;
using Gdc.Scd.Import.Core.Interfaces;
using Gdc.Scd.Spooler.Core;
using NLog;
using System.Configuration;

namespace Gdc.Scd.Import.CentralContractGroup
{
    public class Module : BaseJobModule<Module>
    {
        public override void Load()
        {
            Bind<ImportRepository<Wg>>().ToSelf().InSingletonScope();
            Bind<ILogger<LogLevel>, Gdc.Scd.Core.Interfaces.ILogger>().To<Core.Impl.Logger>().InSingletonScope();
            Bind<IDataAccessManager>().To<SqlManager>()
                .InSingletonScope()
                .WithConstructorArgument("connectionString", 
                ConfigurationManager.ConnectionStrings["Partner_New"].ConnectionString);
            Bind<IDataImporter<CentralContractGroupDto>>().To<CentralContractGroupImporter>().InSingletonScope();
            Bind<IImportManager>().To<DbImportManager<CentralContractGroupDto>>().InSingletonScope();
            Bind(typeof(IUploader<>)).To(typeof(CentralContractGroupUploader)).InSingletonScope();

            Bind<Scd.Core.Interfaces.IPrincipalProvider>().To<ConsolePrincipleProvider>().InSingletonScope();

            Bind<CentralContractGroupService>().ToSelf();
        }
    }
}
