﻿using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.OperationResult;
using Ninject;
using System;

namespace Gdc.Scd.Import.Por
{
    public class ImportPorJob
    {
        protected ILogger log;

        protected ImportPor por;

        public ImportPorJob()
        {
            var kernel = Module.CreateKernel();
            //
            log = kernel.Get<ILogger>();
            por = new ImportPor(new PorService(kernel), log);
        }

        /// <summary>
        /// for testing only
        /// </summary>
        protected ImportPorJob(ImportPor por, ILogger log)
        {
            this.por = por;
            this.log = log;
        }

        public OperationResult<bool> Output()
        {
            try
            {
                por.Run();
                return Result(true);
            }
            catch (Exception ex)
            {
                log.Fatal(ex, ImportConstantMessages.UNEXPECTED_ERROR);
                Notify(ImportConstantMessages.UNEXPECTED_ERROR, ex);
                return Result(false);
            }
        }

        public string WhoAmI()
        {
            return "PorJob";
        }

        protected virtual void Notify(string msg, Exception ex)
        {
            Fujitsu.GDC.ErrorNotification.Logger.Error(msg, ex, null, null);
        }

        public OperationResult<bool> Result(bool ok)
        {
            return new OperationResult<bool> { IsSuccess = ok, Result = true };
        }
    }
}
