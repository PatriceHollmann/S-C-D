﻿using Gdc.Scd.Core.Enums;
using Gdc.Scd.Core.Helpers;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Import.Core.Interfaces;
using Ninject;
using NLog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gdc.Scd.Import.Ebis.MCiW
{
    public class MaterialCostService
    {
        public  IConfigHandler ConfigHandler { get; private set; }
        public  IImportManager ImportManager { get; set; }
        public  ILogger<LogLevel> Logger { get; private set; }

        public MaterialCostService()
        {
            NinjectExt.IsConsoleApplication = true;
            IKernel kernel = CreateKernel();
            ConfigHandler = kernel.Get<IConfigHandler>();
            ImportManager = kernel.Get<IImportManager>();
            Logger = kernel.Get<ILogger<LogLevel>>();
        }

        public void UploadMaterialCostInfo()
        {
            Logger.Log(LogLevel.Info, ImportConstants.START_PROCESS);
            Logger.Log(LogLevel.Info, ImportConstants.CONFIG_READ_START);
            var configuration = ConfigHandler.ReadConfiguration(ImportSystems.EBIS_MATERIAL_COST);
            Logger.Log(LogLevel.Info, ImportConstants.CONFIG_READ_END);
            var result = ImportManager.ImportData(configuration);
            if (!result.Skipped)
            {
                Logger.Log(LogLevel.Info, ImportConstants.UPDATING_CONFIGURATION);
                ConfigHandler.UpdateImportResult(configuration, result.ModifiedDateTime);
            }
            Logger.Log(LogLevel.Info, ImportConstants.END_PROCESS);
        }

        private StandardKernel CreateKernel()
        {
            return new StandardKernel(
                new Scd.Core.Module(),
                new Scd.DataAccessLayer.Module(),
                new Scd.BusinessLogicLayer.Module(),
                new Module());
        }
    }
}
