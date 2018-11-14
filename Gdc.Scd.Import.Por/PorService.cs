﻿using Gdc.Scd.BusinessLogicLayer.Impl;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Import.Por.Core.DataAccessLayer;
using Gdc.Scd.Import.Por.Core.Dto;
using Gdc.Scd.Import.Por.Core.Impl;
using Gdc.Scd.Import.Por.Core.Interfaces;
using Gdc.Scd.Import.Por.Models;
using Ninject;
using NLog;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.Import.Por
{
    public static class PorService
    {
        public static IDataImporter<SCD2_ServiceOfferingGroups> SogImporter { get; private set; }
        public static ILogger<LogLevel> Logger { get; private set; }
        public static IDataImporter<SCD2_WarrantyGroups> WgImporter { get; private set; }
        public static IDataImporter<SCD2_SW_Overview> SoftwareImporter { get; private set; }
        public static IDataImporter<SCD2_v_SAR_new_codes> FspCodesImporter { get; private set; }
        public static IDataImporter<SCD2_LUT_TSP> LutCodesImporter { get; private set; }
        public static IDataImporter<SCD2_SWR_Level> SwProActiveImporter { get; private set; }
        public static DomainService<Pla> PlaService { get; private set; }
        public static DomainService<ServiceLocation> LocationService { get; private set; }
        public static DomainService<ReactionType> ReactionTypeService { get; private set; }
        public static DomainService<ReactionTime> ReactionTimeService { get; private set; }
        public static DomainService<Availability> AvailabilityService { get; private set; }
        public static DomainService<Duration> DurationService { get; private set; }
        public static DomainService<ProActiveSla> ProactiveService { get; private set; }
        public static DomainService<Country> CountryService { get; private set; }
        public static DomainService<CountryGroup> CountryGroupService { get; private set; }
        public static ImportService<SFab> SFabDomainService { get; private set; }
        public static ImportService<Sog> SogDomainService { get; private set; }
        public static ImportService<Wg> WgDomainService { get; private set; }
        public static ImportService<SwDigit> DigitService { get; private set; }
        public static ImportService<SwLicense> LicenseService { get; private set; }
        public static DomainService<ProActiveDigit> ProActiveDigitService { get; set; }
        public static IPorSogService SogService { get; private set; }
        public static IPorWgService WgService { get; private set; }
        public static IPorSwDigitService SwDigitService { get; private set; }
        public static IPorSwLicenseService SwLicenseService { get; private set; }
        public static IPorSwDigitLicenseService SwLicenseDigitService { get; private set; }
        public static IHwFspCodeTranslationService HardwareService { get; private set; }
        public static ISwFspCodeTranslationService SoftwareService { get; private set; }
        public static IPorSwProActiveService SoftwareProactiveService { get; private set; }
        public static ICostBlockService CostBlockService { get; private set; }

        static PorService()
        {
            IKernel kernel = new StandardKernel(new Module());
            Logger = kernel.Get<ILogger<LogLevel>>();
            SogImporter = kernel.Get<IDataImporter<SCD2_ServiceOfferingGroups>>();
            WgImporter = kernel.Get<IDataImporter<SCD2_WarrantyGroups>>();
            SoftwareImporter = kernel.Get<IDataImporter<SCD2_SW_Overview>>();
            FspCodesImporter = kernel.Get<IDataImporter<SCD2_v_SAR_new_codes>>();
            LutCodesImporter = kernel.Get<IDataImporter<SCD2_LUT_TSP>>();
            PlaService = kernel.Get<DomainService<Pla>>();
            SwProActiveImporter = kernel.Get<IDataImporter<SCD2_SWR_Level>>();

            //SLA ATOMS
            LocationService = kernel.Get<DomainService<ServiceLocation>>();
            ReactionTypeService = kernel.Get<DomainService<ReactionType>>();
            ReactionTimeService = kernel.Get<DomainService<ReactionTime>>();
            AvailabilityService = kernel.Get<DomainService<Availability>>();
            DurationService = kernel.Get<DomainService<Duration>>();
            ProactiveService = kernel.Get<DomainService<ProActiveSla>>();
            CountryService = kernel.Get<DomainService<Country>>();
            CountryGroupService = kernel.Get<DomainService<CountryGroup>>();
            ProActiveDigitService = kernel.Get<DomainService<ProActiveDigit>>();

            SFabDomainService = kernel.Get<ImportService<SFab>>();
            SogDomainService = kernel.Get<ImportService<Sog>>();
            WgDomainService = kernel.Get<ImportService<Wg>>();
            DigitService = kernel.Get<ImportService<SwDigit>>();
            LicenseService = kernel.Get<ImportService<SwLicense>>();
            

            //SERVICES
            SogService = kernel.Get<IPorSogService>();
            WgService = kernel.Get<IPorWgService>();
            SwDigitService = kernel.Get<IPorSwDigitService>();
            SwLicenseService = kernel.Get<IPorSwLicenseService>();
            SwLicenseDigitService = kernel.Get<IPorSwDigitLicenseService>();
            HardwareService = kernel.Get<IHwFspCodeTranslationService>();
            SoftwareService = kernel.Get<ISwFspCodeTranslationService>();
            SoftwareProactiveService = kernel.Get<IPorSwProActiveService>();
            CostBlockService = kernel.Get<ICostBlockService>();
        }


        public static void UploadSogs(List<Pla> plas, int step, 
            List<SCD2_ServiceOfferingGroups> sogs, string[] softwareServiceTypes)
        {
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_START, step, nameof(Sog));
            var success = SogService.UploadSogs(sogs, plas, DateTime.Now, softwareServiceTypes);
            if (success)
                success = SogService.DeactivateSogs(sogs, DateTime.Now);
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_ENDS, step);
        }


        public static void UploadWgs(List<Pla> plas, int step,
            List<Sog> sogs, List<SCD2_WarrantyGroups> wgs, string[] softwareServiceTypes)
        {
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_START, step, nameof(Wg));
            var success = WgService.UploadWgs(wgs, sogs, plas, DateTime.Now, softwareServiceTypes);
            if (success)
                success = WgService.DeactivateWgs(wgs, DateTime.Now);
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_ENDS, step);
        }


        public static bool UploadSoftwareDigits(List<SCD2_SW_Overview> porSoftware, List<Sog> sogs, 
            SwHelperModel swInfo,
            int step)
        {
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_START, step, nameof(SwDigit));
            var success = SwDigitService.UploadSwDigits(swInfo.SwDigits, sogs, DateTime.Now);
            if (success)
            {
                success = SwDigitService.Deactivate(swInfo.SwDigits, DateTime.Now);
            }
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_ENDS, step);
            return success;
        }


        public static bool UploadSoftwareLicense(List<SCD2_SW_Overview> swLicensesInfo, int step)
        {
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_START, step, nameof(SwLicense));
            var success = SwLicenseService.UploadSwLicense(swLicensesInfo, DateTime.Now);
            if (success)
            {
                success = SwLicenseService.Deactivate(swLicensesInfo, DateTime.Now);
            }
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_ENDS, step);
            return success;
        }


        public static void RebuildSoftwareInfo(List<SwDigit> digits, IEnumerable<SCD2_SW_Overview> swInfodigits, int step)
        {
            Logger.Log(LogLevel.Info, ImportConstantMessages.REBUILD_RELATIONSHIPS_START, step, nameof(SwDigit), nameof(SwLicense));
            var licenses = LicenseService.GetAllActive().ToList();
            var success = SwLicenseDigitService.UploadSwDigitAndLicenseRelation(licenses, digits, swInfodigits, DateTime.Now);
            if (!success)
            {
                Logger.Log(LogLevel.Warn, ImportConstantMessages.REBUILD_FAILS, step);
            }
            Logger.Log(LogLevel.Info, ImportConstantMessages.REBUILD_RELATIONSHIPS_END, step);
        }

        public static void UploadHwFspCodes(HwFspCodeDto model, int step)
        {
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_START, step, nameof(HwFspCodeTranslation));

            var success = HardwareService.UploadHardware(model);

            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_ENDS, step);
        }

        public static bool UploadSwProactiveInfo(SwProActiveDto model, int step)
        {
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_START, step, "Software Proactive Info");
            var success = SoftwareProactiveService.UploadSwProactiveInfo(model);
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_ENDS, step);
            return success;
        }

        public static void UploadSwFspCodes(SwFspCodeDto model, int step)
        {
            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_START, step, nameof(SwFspCodeTranslation));

            var success = SoftwareService.UploadSoftware(model);

            Logger.Log(LogLevel.Info, ImportConstantMessages.UPLOAD_ENDS, step);
        }

        public static void UpdateCostBlocks(int step)
        {
            try
            {
                Logger.Log(LogLevel.Info, ImportConstantMessages.UPDATE_COST_BLOCKS_START, step);
                CostBlockService.UpdateByCoordinates();
                Logger.Log(LogLevel.Info, ImportConstantMessages.UPDATE_COST_BLOCKS_END);
            }
            catch(Exception ex)
            {
                Logger.Log(LogLevel.Error, ex, ImportConstantMessages.UNEXPECTED_ERROR);
            }
        }
    }
}
