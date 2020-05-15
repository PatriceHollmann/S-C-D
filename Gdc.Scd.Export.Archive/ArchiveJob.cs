﻿using System;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Export.Archive;
using Gdc.Scd.Spooler.Core.Entities;
using Gdc.Scd.Spooler.Core.Interfaces;
using Ninject;

namespace Gdc.Scd.Export.ArchiveJob
{
    public class ArchiveJob : IJob
    {
        public const string JobName = "ArchiveJob";
        protected ArchiveService srv;

        protected ILogger logger;

        public ArchiveJob()
        {
            Init();
        }

        IOperationResult IJob.Output()
        {
            return this.Output();
        }

        public OperationResult<bool> Output()
        {
            try
            {
                srv.Run();
                return Result(true);
            }
            catch (Exception e)
            {
                logger.Fatal(e, ArchiveConstants.UNEXPECTED_ERROR);
                Notify(ArchiveConstants.UNEXPECTED_ERROR, e);
                return Result(false);
            }
        }

        public string WhoAmI()
        {
            return JobName;
        }

        /// <summary>
        /// for testing only
        /// </summary>
        protected virtual void Init()
        {
            var kernel = Module.CreateKernel();
            //
            logger = kernel.Get<ILogger>();
            srv = new ArchiveService(kernel.Get<IArchiveRepository>(), logger);
        }

        /// <summary>
        /// for testing only
        /// </summary>
        protected virtual void Notify(string msg, Exception e)
        {
            Fujitsu.GDC.ErrorNotification.Logger.Error(msg, e, null, null);
        }

        public static OperationResult<bool> Result(bool ok)
        {
            return new OperationResult<bool> { IsSuccess = ok, Result = true };
        }
    }
}
