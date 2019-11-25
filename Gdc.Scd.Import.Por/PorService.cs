﻿using Gdc.Scd.BusinessLogicLayer.Impl;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.Import.Por.Core.DataAccessLayer;
using Gdc.Scd.Import.Por.Core.Dto;
using Gdc.Scd.Import.Por.Core.Impl;
using Gdc.Scd.Import.Por.Core.Interfaces;
using Gdc.Scd.Import.Por.Models;
using Ninject;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.Import.Por
{
    public class PorService
    {
        protected ILogger Logger;

        public virtual DomainService<Pla> PlaService { get; }
        public virtual DomainService<ServiceLocation> LocationService { get; }
        public virtual DomainService<ReactionType> ReactionTypeService { get; }
        public virtual DomainService<ReactionTime> ReactionTimeService { get; }
        public virtual DomainService<Availability> AvailabilityService { get; }
        public virtual DomainService<Duration> DurationService { get; }
        public virtual DomainService<ProActiveSla> ProactiveService { get; }
        public virtual DomainService<Country> CountryService { get; }
        public virtual DomainService<CountryGroup> CountryGroupService { get; }
        public virtual ImportService<Sog> SogDomainService { get; }
        public virtual ImportService<Wg> WgDomainService { get; }
        public virtual ImportService<SwDigit> DigitService { get; }
        public virtual ImportService<SwLicense> LicenseService { get; }
        public virtual DomainService<ProActiveDigit> ProActiveDigitService { get; }
        public virtual DomainService<SwSpMaintenance> SwSpMaintenanceDomainService { get; }
        public virtual IPorSogService SogService { get; }
        public virtual IPorWgService WgService { get; }
        public virtual IPorSwDigitService SwDigitService { get; }
        public virtual IPorSwSpMaintenaceService SwSpMaintenanceService { get; }
        public virtual IPorSwLicenseService SwLicenseService { get; }
        public virtual IPorSwDigitLicenseService SwLicenseDigitService { get; }
        public virtual IHwFspCodeTranslationService<HwFspCodeDto> HardwareService { get; }
        public virtual IHwFspCodeTranslationService<HwHddFspCodeDto> HardwareHddService { get; }
        public virtual ISwFspCodeTranslationService SoftwareService { get; }
        public virtual IPorSwProActiveService SoftwareProactiveService { get; }
        public virtual ICostBlockService CostBlockService { get; }
        public virtual List<UpdateQueryOption> UpdateQueryOptions { get; }

        protected ICostBlockUpdateService CostBlockUpdateService;

        public PorService(IKernel kernel)
        {
            Logger = kernel.Get<ILogger>();
            PlaService = kernel.Get<DomainService<Pla>>();

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
            SwSpMaintenanceDomainService = kernel.Get<DomainService<SwSpMaintenance>>();

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
            HardwareService = kernel.Get<IHwFspCodeTranslationService<HwFspCodeDto>>();
            HardwareHddService = kernel.Get<IHwFspCodeTranslationService<HwHddFspCodeDto>>();
            SoftwareService = kernel.Get<ISwFspCodeTranslationService>();
            SoftwareProactiveService = kernel.Get<IPorSwProActiveService>();
            CostBlockService = kernel.Get<ICostBlockService>();
            CostBlockUpdateService = kernel.Get<ICostBlockUpdateService>();
            SwSpMaintenanceService = kernel.Get<IPorSwSpMaintenaceService>();

            UpdateQueryOptions = new List<UpdateQueryOption>();
        }

        /// <summary>
        /// Test only
        /// </summary>
        protected PorService() { }

        public virtual void UploadSogs(int step, List<SogPorDto> sogs)
        {
            Logger.Info(ImportConstantMessages.UPLOAD_START, step, nameof(Sog));
            var success = SogService.UploadSogs(sogs, GetPla(), DateTime.Now,
                UpdateQueryOptions);
            if (success)
                success = SogService.DeactivateSogs(sogs, DateTime.Now);
            Logger.Info(ImportConstantMessages.UPLOAD_ENDS, step);
        }


        public virtual List<Wg> UploadWgs(int step, List<WgPorDto> wgs)
        {
            Logger.Info(ImportConstantMessages.UPLOAD_START, step, nameof(Wg));
            var (success, added) = WgService.UploadWgs(wgs, GetSog(), GetPla(), DateTime.Now, UpdateQueryOptions);
            if (success)
                success = WgService.DeactivateWgs(wgs, DateTime.Now);
            Logger.Info(ImportConstantMessages.UPLOAD_ENDS, step);
            //
            return added;
        }


        public virtual (bool ok, List<SwDigit> added) UploadSoftwareDigits(List<SCD2_SW_Overview> porSoftware, SwHelperModel swInfo, int step)
        {
            Logger.Info(ImportConstantMessages.UPLOAD_START, step, nameof(SwDigit));
            var (success, added) = SwDigitService.UploadSwDigits(swInfo.SwDigits, GetSog(), DateTime.Now, UpdateQueryOptions);
            if (success)
            {
                success = SwDigitService.Deactivate(swInfo.SwDigits, DateTime.Now);
            }
            Logger.Info(ImportConstantMessages.UPLOAD_ENDS, step);
            return (success, added);
        }


        public virtual bool UploadSoftwareLicense(List<SCD2_SW_Overview> swLicensesInfo, int step)
        {
            Logger.Info(ImportConstantMessages.UPLOAD_START, step, nameof(SwLicense));
            var success = SwLicenseService.UploadSwLicense(swLicensesInfo, DateTime.Now, UpdateQueryOptions);
            if (success)
            {
                success = SwLicenseService.Deactivate(swLicensesInfo, DateTime.Now);
            }
            Logger.Info(ImportConstantMessages.UPLOAD_ENDS, step);
            return success;
        }


        public virtual void RebuildSoftwareInfo(IEnumerable<SCD2_SW_Overview> swInfodigits, int step)
        {
            Logger.Info(ImportConstantMessages.REBUILD_RELATIONSHIPS_START, step, nameof(SwDigit), nameof(SwLicense));
            var licenses = LicenseService.GetAllActive().ToList();
            var success = SwLicenseDigitService.UploadSwDigitAndLicenseRelation(licenses, GetDigits(), swInfodigits, DateTime.Now);
            if (!success)
            {
                Logger.Warn(ImportConstantMessages.REBUILD_FAILS, step);
            }
            Logger.Info(ImportConstantMessages.REBUILD_RELATIONSHIPS_END, step);
        }

        public virtual void UploadHwFspCodes(HwFspCodeDto model, int step)
        {
            Logger.Info(ImportConstantMessages.UPLOAD_START, step, nameof(TempHwFspCodeTranslation));

            var success = HardwareService.UploadHardware(model);

            Logger.Info(ImportConstantMessages.UPLOAD_START, step, nameof(HwHddFspCodeTranslation));

            var hwHddDto = new HwHddFspCodeDto
            {
                HardwareCodes = model.HddRetentionCodes,
                CreationDate = model.CreationDate,
                HwSla = model.HwSla
            };

            var uploadHddSuccess = HardwareHddService.UploadHardware(hwHddDto);
            success = uploadHddSuccess && success;

            Logger.Info(ImportConstantMessages.UPLOAD_ENDS, step);
        }

        public virtual bool UploadSwProactiveInfo(SwProActiveDto model, int step)
        {
            Logger.Info(ImportConstantMessages.UPLOAD_START, step, "Software Proactive Info");
            var success = SoftwareProactiveService.UploadSwProactiveInfo(model);
            Logger.Info(ImportConstantMessages.UPLOAD_ENDS, step);
            return success;
        }

        public virtual void UploadSwFspCodes(SwFspCodeDto model, int step)
        {
            Logger.Info(ImportConstantMessages.UPLOAD_START, step, nameof(SwFspCodeTranslation));

            var success = SoftwareService.UploadSoftware(model);

            Logger.Info(ImportConstantMessages.UPLOAD_ENDS, step);
        }

        public virtual void UpdateCostBlocks(int step, IEnumerable<UpdateQueryOption> updateOptions)
        {
            try
            {
                Logger.Info(ImportConstantMessages.UPDATE_COST_BLOCKS_START, step);
                CostBlockService.UpdateByCoordinates(updateOptions);
                Logger.Info(ImportConstantMessages.UPDATE_COST_BLOCKS_END);
            }
            catch (Exception ex)
            {
                Logger.Error(ex, ImportConstantMessages.UNEXPECTED_ERROR);
            }
        }

        public virtual void Update2ndLevelSupportCosts(int step)
        {
            try
            {
                Logger.Info(ImportConstantMessages.UPDATE_COSTS_START, step);

                SwSpMaintenanceService.Update2ndLevelSupportCosts(DigitService.GetAllActive().ToList(), SwSpMaintenanceDomainService.GetAll().ToList());

                Logger.Info(ImportConstantMessages.UPDATE_COSTS_END);
            }
            catch (Exception ex)
            {
                Logger.Error(ex, ImportConstantMessages.UNEXPECTED_ERROR);
            }
        }

        public virtual void UpdateCostBlocksByPla(int step, List<Wg> newWgs)
        {
            try
            {
                Logger.Info(ImportConstantMessages.UPDATE_COSTS_BY_PLA_START, step);

                CostBlockUpdateService.UpdateByPla(newWgs.ToArray());

                Logger.Info(ImportConstantMessages.UPDATE_COSTS_BY_PLA_END);
            }
            catch (Exception ex)
            {
                Logger.Error(ex, ImportConstantMessages.UNEXPECTED_ERROR);
            }
        }

        public virtual void UpdateCostBlocksBySog(int step, List<SwDigit> newDigits)
        {
            try
            {
                Logger.Info(ImportConstantMessages.UPDATE_SW_COSTS_BY_SOG_START, step);

                CostBlockUpdateService.UpdateBySog(newDigits.ToArray());

                Logger.Info(ImportConstantMessages.UPDATE_SW_COSTS_BY_SOG_END);
            }
            catch (Exception ex)
            {
                Logger.Error(ex, ImportConstantMessages.UNEXPECTED_ERROR);
            }
        }

        private SlaDictsDto _slaDictsDto;
        public virtual SlaDictsDto GetSlasDictionaries()
        {
            if (_slaDictsDto == null)
            {
                var locationServiceValues = this.LocationService.GetAll().ToList();
                var reactionTypeValues = this.ReactionTypeService.GetAll().ToList();
                var reactonTimeValues = this.ReactionTimeService.GetAll().ToList();
                var availabilityValues = this.AvailabilityService.GetAll().ToList();
                var durationValues = this.DurationService.GetAll().ToList();
                var proactiveValues = this.ProactiveService.GetAll().ToList();

                var locationDictionary = FormatDataHelper.FillSlaDictionary(locationServiceValues);
                var reactionTimeDictionary = FormatDataHelper.FillSlaDictionary(reactonTimeValues);
                var reactionTypeDictionary = FormatDataHelper.FillSlaDictionary(reactionTypeValues);
                var availabilityDictionary = FormatDataHelper.FillSlaDictionary(availabilityValues);
                var durationDictionary = FormatDataHelper.FillSlaDictionary(durationValues);
                var proactiveDictionary = FormatDataHelper.FillSlaDictionary(proactiveValues);

                _slaDictsDto = new SlaDictsDto
                {
                    Availability = availabilityDictionary,
                    Duration = durationDictionary,
                    Locations = locationDictionary,
                    ReactionTime = reactionTimeDictionary,
                    ReactionType = reactionTypeDictionary,
                    Proactive = proactiveDictionary
                };
            }
            return _slaDictsDto;
        }

        private List<Pla> _plas;
        public List<Pla> GetPla()
        {
            if (_plas == null)
            {
                _plas = PlaService.GetAll().ToList();
            }
            return _plas;
        }

        private List<Sog> _sogs;
        public List<Sog> GetSog()
        {
            if (_sogs == null)
            {
                _sogs = SogDomainService.GetAllActive().ToList();
            }
            return _sogs;
        }

        private List<SwDigit> _digits;
        public List<SwDigit> GetDigits()
        {
            if (_digits == null)
            {
                _digits = DigitService.GetAllActive().ToList();
            }
            return _digits;
        }
    }
}
