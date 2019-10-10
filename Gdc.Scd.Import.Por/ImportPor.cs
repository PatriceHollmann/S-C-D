﻿using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Import.Por.Core.DataAccessLayer;
using Gdc.Scd.Import.Por.Core.Dto;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.Import.Por
{
    public class ImportPor
    {
        private ILogger log;

        private PorService PorService;

        public ImportPor(PorService por, ILogger log)
        {
            this.PorService = por;
            this.log = log;
        }

        public virtual void Run()
        {
            //CONFIGURATION
            log.Info("Reading configuration...");
            var softwareServiceTypes = Config.SoftwareSolutionTypes;
            var proactiveServiceTypes = Config.ProActiveServices;
            var standardWarrantiesServiceTypes = Config.StandardWarrantyTypes;
            var hardwareServiceTypes = Config.HwServiceTypes;
            var allowedServiceTypes = Config.AllServiceTypes;
            var hddServiceTypes = Config.HddServiceType;
            var solutionIdentifier = Config.SolutionIdentifier;

            log.Info("Reading configuration is completed.");


            //Start Process
            log.Info(ImportConstantMessages.START_PROCESS);

            log.Info(ImportConstantMessages.FETCH_INFO_START, nameof(Sog));
            var porSogs = PorService.SogImporter.ImportData()
                .ToList();

            log.Info(ImportConstantMessages.FETCH_INFO_ENDS, nameof(Sog), porSogs.Count);

            log.Info(ImportConstantMessages.FETCH_INFO_START, nameof(Wg));
            var porWGs = PorService.WgImporter.ImportData()
                .ToList();
            log.Info(ImportConstantMessages.FETCH_INFO_ENDS, nameof(Wg), porWGs.Count);

            var plas = PorService.PlaService.GetAll().ToList();
            var step = 1;

            //STEP 1: UPLOADING SOGs
            PorService.UploadSogs(plas, step, porSogs, softwareServiceTypes, solutionIdentifier);
            step++;

            //STEP 2: UPLOAD WGs
            var sogs = PorService.SogDomainService.GetAllActive().ToList();
            PorService.UploadWgs(plas, step, sogs, porWGs, softwareServiceTypes);
            step++;

            //STEP 3: UPLOAD SOFTWARE DIGITS 
            log.Info(ImportConstantMessages.FETCH_INFO_START, "Software Info");
            var porSoftware = PorService.SoftwareImporter.ImportData()
                .Where(sw => sw.Service_Code_Status == "50" && sw.SCD_Relevant == "x")
                .ToList();
            log.Info(ImportConstantMessages.FETCH_INFO_ENDS, "Software Info", porSoftware.Count);


            var swInfo = FormatDataHelper.FillSwInfo(porSoftware);
            var rebuildRelationships = PorService.UploadSoftwareDigits(porSoftware, sogs, swInfo, step);
            step++;

            //STEP 4: UPLOAD SOFTWARE LICENCE
            var swLicensesInfo = swInfo.SwLicenses.Select(sw => sw.Value).ToList();
            rebuildRelationships = rebuildRelationships && PorService.UploadSoftwareLicense(swLicensesInfo, step);
            step++;

            //STEP 5: REBUILD RELATIONSHIPS BETWEEN SOFTWARE LICENSES AND DIGITS
            var digits = PorService.DigitService.GetAllActive().ToList();
            if (rebuildRelationships)
            {
                PorService.RebuildSoftwareInfo(digits, porSoftware, step);
                step++;
            }


            //STEP 6: UPLOAD FSP CODES AND TRANSLATIONS
            log.Info(ImportConstantMessages.FETCH_INFO_START, "FSP codes Translation");

            //VStatus is ignored for STDWs 
            var fspcodes = PorService.FspCodesImporter.ImportData()
                                           .Where(fsp => (fsp.VStatus == "50" &&
                                                         allowedServiceTypes.Contains(fsp.SCD_ServiceType)) ||
                                                         (standardWarrantiesServiceTypes.Contains(fsp.SCD_ServiceType)
                                                         && (fsp.Service_Code.Substring(11, 4).ToUpper().Equals("STDW") ||
                                                             fsp.Service_Code.Substring(11, 4).ToUpper().Equals("SMDW"))))
                                           .ToList();

            log.Info(ImportConstantMessages.FETCH_INFO_ENDS, "FSP codes Translation", fspcodes.Count);


            var proActiveValues = PorService.ProactiveService.GetAll().ToList();


            var countries = FormatDataHelper.FillCountryDictionary(PorService.CountryService.GetAll().ToList(),
                PorService.CountryGroupService.GetAll().ToList());

            var sla = PorService.FillSlasDictionaries();

            var proactiveDictionary = FormatDataHelper.FillSlaDictionary(proActiveValues);


            var otherHardwareCodes = new List<SCD2_v_SAR_new_codes>();
            var stdwCodes = new List<SCD2_v_SAR_new_codes>();
            var proActiveCodes = new List<SCD2_v_SAR_new_codes>();
            var softwareCodes = new List<SCD2_v_SAR_new_codes>();
            var hddRetentionCodes = new List<SCD2_v_SAR_new_codes>();

            foreach (var code in fspcodes)
            {
                if (hardwareServiceTypes.Contains(code.SCD_ServiceType))
                    otherHardwareCodes.Add(code);

                else if (proactiveServiceTypes.Contains(code.SCD_ServiceType))
                    proActiveCodes.Add(code);

                else if (standardWarrantiesServiceTypes.Contains(code.SCD_ServiceType))
                {
                    stdwCodes.Add(code);
                }

                else if (softwareServiceTypes.Contains(code.SCD_ServiceType))
                    softwareCodes.Add(code);

                else if (hddServiceTypes.Contains(code.SCD_ServiceType))
                    hddRetentionCodes.Add(code);
            }

            log.Info(ImportConstantMessages.FETCH_INFO_START, "Standard Warranties");
            var lutCodes = PorService.LutCodesImporter.ImportData().ToList();
            log.Info(ImportConstantMessages.FETCH_INFO_ENDS, "Standard Warranties", lutCodes.Count);

            var wgs = PorService.WgDomainService.GetAllActive().Where(wg => wg.WgType == Scd.Core.Enums.WgType.Por).ToList();
            var hwModel = new HwFspCodeDto
            {
                HardwareCodes = otherHardwareCodes,
                ProactiveCodes = proActiveCodes,
                StandardWarranties = stdwCodes,
                HddRetentionCodes = hddRetentionCodes,
                LutCodes = lutCodes,
                CreationDate = DateTime.Now,
                HwSla = new HwSlaDto
                {
                    Countries = countries,
                    Proactive = proactiveDictionary,
                    Sogs = sogs,
                    Wgs = wgs
                },
                Sla = sla,
                OtherHardwareServiceTypes = hardwareServiceTypes,
                ProactiveServiceTypes = proactiveServiceTypes,
                StandardWarrantiesServiceTypes = standardWarrantiesServiceTypes
            };

            //UPLOAD HARDWARE
            PorService.UploadHwFspCodes(hwModel, step);
            step++;


            //STEP 7: PROACTIVE DIGITS UPLOAD
            log.Info(ImportConstantMessages.FETCH_INFO_START, "Software ProActive");
            var swProActive = PorService.SwProActiveImporter.ImportData().ToList();
            log.Info(ImportConstantMessages.FETCH_INFO_ENDS, "Software ProActive", swProActive.Count);


            var proActiveDigitModel = new SwProActiveDto
            {
                Proactive = proactiveDictionary,
                SwDigits = digits,
                ProActiveInfo = swProActive,
                CreatedDateTime = DateTime.Now
            };

            PorService.UploadSwProactiveInfo(proActiveDigitModel, step);
            step++;

            //STEP 8: UPLOAD SOFTWARE
            var proActiveDigits = PorService.ProActiveDigitService.GetAll().ToList();
            var license = PorService.LicenseService.GetAll().ToList();

            var swModel = new SwFspCodeDto
            {
                Sla = sla,
                Digits = digits,
                SoftwareInfo = porSoftware,
                SoftwareCodes = softwareCodes,
                Sogs = sogs,
                SoftwareServiceTypes = softwareServiceTypes,
                CreatedDateTime = DateTime.Now,
                ProActiveDigits = proActiveDigits,
                License = license
            };

            PorService.UploadSwFspCodes(swModel, step);
            step++;

            //STEP 9: UPLOAD COST BLOCKS
            PorService.UpdateCostBlocks(step, PorService.UpdateQueryOptions);
            step++;

            //STEP 10: UPDATE 2ndLevelSupportCosts
            PorService.Update2ndLevelSupportCosts(step);

            log.Info(ImportConstantMessages.END_PROCESS);
        }
    }
}
