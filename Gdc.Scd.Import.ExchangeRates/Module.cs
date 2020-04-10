﻿using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Import.Core.Dto;
using Gdc.Scd.Import.Core.Impl;
using Gdc.Scd.Import.Core.Interfaces;
using Gdc.Scd.Spooler.Core;
using NLog;

namespace Gdc.Scd.Import.ExchangeRatesJob
{
    public class Module : BaseJobModule<Module>
    {
        public override void Load()
        {
            Bind<ILogger<LogLevel>, Gdc.Scd.Core.Interfaces.ILogger>().To<Core.Impl.Logger>().InSingletonScope();

            Bind<IDownloader>().To<FileDownloader>().InSingletonScope();
            Bind(typeof(IParser<>)).To(typeof(Parser<>)).InSingletonScope();
            Bind(typeof(IUploader<>)).To(typeof(ExRatesUploader)).InSingletonScope();
            Bind<IImportManager>().To<FileImportManager<ExchangeRateDto>>().InSingletonScope();
            Bind<IConfigHandler>().To<DataBaseConfigHandler>().InSingletonScope();

            Bind<ExchangeRateService>().ToSelf();
        }
    }
}
