﻿using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using NLog;
using System;
using System.Collections.Generic;
using System.Linq;
using Ninject;
using Gdc.Scd.BusinessLogicLayer.Impl;
using Gdc.Scd.Import.Por.Models;
using Gdc.Scd.Core.Entities.CapabilityMatrix;
using Gdc.Scd.Import.Por.Core.Interfaces;
using Gdc.Scd.Import.Por.Core.DataAccessLayer;
using Gdc.Scd.Import.Por.Core.Impl;
using Gdc.Scd.Import.Por.Core.Dto;

namespace Gdc.Scd.Import.Por
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                //CONFIGURATION
                PorService.Logger.Log(LogLevel.Info, "Reading configuration...");
                var softwareServiceTypes = Config.SoftwareSolutionTypes;
                var proactiveServiceTypes = Config.ProActiveServices;
                var standardWarrantiesServiceTypes = Config.StandardWarrantyTypes;
                var hardwareServiceTypes = Config.HwServiceTypes;
                var allowedServiceTypes = Config.AllServiceTypes;
                PorService.Logger.Log(LogLevel.Info, "Reading configuration is completed.");


                //Start Process
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.START_PROCESS);

                Func<SCD2_ServiceOfferingGroups, bool> sogPredicate = sog => sog.Active_Flag == "1";
                Func<SCD2_WarrantyGroups, bool> wgPredicate = wg => wg.Active_Flag == "1";

                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_START, nameof(Sog));
                var porSogs = PorService.SogImporter.ImportData()
                    .Where(sogPredicate)
                    .ToList();

                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_ENDS, nameof(Sog), porSogs.Count);

                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_START, nameof(Wg));
                var porWGs = PorService.WgImporter.ImportData()
                    .Where(wgPredicate)
                    .ToList();
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_ENDS, nameof(Wg), porWGs.Count);

                var plas = PorService.PlaService.GetAll().ToList();
                int step = 1;

                //STEP 1: UPLOADING SFABs
                PorService.UploadSFabs(porSogs, porWGs, plas, step);
                step++;

                //STEP 2: UPLOADING SOGs
                var sFabs = PorService.SFabDomainService.GetAllActive().ToList();
                PorService.UploadSogs(sFabs, plas, step, porSogs, softwareServiceTypes);
                step++;

                //STEP 3: UPLOAD WGs
                var sogs = PorService.SogDomainService.GetAllActive().ToList();
                PorService.UploadWgs(sFabs, plas, step, sogs, porWGs, softwareServiceTypes);
                step++;

                //STEP 4: UPLOAD SOFTWARE DIGITS 
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_START, "Software Info");
                var porSoftware = PorService.SoftwareImporter.ImportData()
                    .Where(sw => sw.Service_Code_Status == "50" && sw.SCD_Relevant == "x")
                    .ToList();
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_ENDS, "Software Info", porSoftware.Count);

                
                var swInfo = FormatDataHelper.FillSwInfo(porSoftware);
                var rebuildRelationships = PorService.UploadSoftwareDigits(porSoftware, sogs, swInfo, step);
                step++;

                //STEP 5: UPLOAD SOFTWARE LICENCE
                var swLicensesInfo = swInfo.SwLicenses.Select(sw => sw.Value).ToList();
                rebuildRelationships = rebuildRelationships && PorService.UploadSoftwareLicense(swLicensesInfo, step);
                step++;

                //STEP6: REBUILD RELATIONSHIPS BETWEEN SOFTWARE LICENSES AND DIGITS
                var digits = PorService.DigitService.GetAllActive().ToList();
                if (rebuildRelationships)
                {
                    PorService.RebuildSoftwareInfo(digits, porSoftware, step);
                    step++;
                }
                

                //STEP 7: UPLOAD FSP CODES AND TRANSLATIONS
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_START, "FSP codes Translation");

                var fspcodes = PorService.FspCodesImporter.ImportData()
                                               .Where(fsp => fsp.VStatus == "50" &&
                                                             allowedServiceTypes.Contains(fsp.SCD_ServiceType))
                                               .ToList();
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_ENDS, "FSP codes Translation", fspcodes.Count);

                
                var proActiveValues = PorService.ProactiveService.GetAll().ToList();
                var countryValues = PorService.CountryService.GetAll().ToList();


                var countries = FormatDataHelper.FillCountryDictionary(PorService.CountryService.GetAll().ToList(), 
                    PorService.CountryGroupService.GetAll().ToList());

                var sla = FormatDataHelper.FillSlasDictionaries();

                var proactiveDictionary = FormatDataHelper.FillSlaDictionary(proActiveValues);


                List<SCD2_v_SAR_new_codes> otherHardwareCodes = new List<SCD2_v_SAR_new_codes>();
                List<SCD2_v_SAR_new_codes> stdwCodes = new List<SCD2_v_SAR_new_codes>();
                List<SCD2_v_SAR_new_codes> proActiveCodes = new List<SCD2_v_SAR_new_codes>();
                List<SCD2_v_SAR_new_codes> softwareCodes = new List<SCD2_v_SAR_new_codes>();

                foreach (var code in fspcodes)
                {
                    if (hardwareServiceTypes.Contains(code.SCD_ServiceType))
                        otherHardwareCodes.Add(code);

                    else if (proactiveServiceTypes.Contains(code.SCD_ServiceType))
                        proActiveCodes.Add(code);

                    else if (standardWarrantiesServiceTypes.Contains(code.SCD_ServiceType))
                    {
                        if (code.Service_Code.Substring(11, 4).ToUpper() == "STDW")
                            stdwCodes.Add(code);
                    }

                    else if (softwareServiceTypes.Contains(code.SCD_ServiceType))
                        softwareCodes.Add(code);
                }

                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_START, "Standard Warranties");
                var lutCodes = PorService.LutCodesImporter.ImportData().ToList();
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_ENDS, "Standard Warranties", lutCodes.Count);

                var wgs = PorService.WgDomainService.GetAllActive().Where(wg => !wg.IsMultiVendor).ToList();
                var hwModel = new HwFspCodeDto
                {
                    HardwareCodes = otherHardwareCodes,
                    ProactiveCodes = proActiveCodes,
                    StandardWarranties = stdwCodes,
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

                //PROACTIVE DIGITS UPLOAD
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_START, "Software ProActive");
                var swProActive = PorService.SwProActiveImporter.ImportData().ToList();
                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.FETCH_INFO_ENDS, "Software ProActive", swProActive.Count);

                
                var proActiveDigitModel = new SwProActiveDto
                {
                    Proactive = proactiveDictionary,
                    SwDigits = digits,
                    ProActiveInfo = swProActive,
                    CreatedDateTime = DateTime.Now
                };

                PorService.UploadSwProactiveInfo(proActiveDigitModel, step);
                step++;

                //STEP 9: UPLOAD SOFTWARE
                var proActiveDigits = PorService.ProActiveDigitService.GetAll().ToList();

                var swModel = new SwFspCodeDto
                {
                    Sla = sla,
                    Digits = digits,
                    SoftwareInfo = porSoftware,
                    SoftwareCodes = softwareCodes,
                    Sogs = sogs,
                    SoftwareServiceTypes = softwareServiceTypes,
                    CreatedDateTime = DateTime.Now,
                    ProActiveDigits = proActiveDigits
                };

                PorService.UploadSwFspCodes(swModel, step);

                PorService.Logger.Log(LogLevel.Info, ImportConstantMessages.END_PROCESS);
            }

            catch(Exception ex)
            {
                PorService.Logger.Log(LogLevel.Fatal, ex, ImportConstantMessages.UNEXPECTED_ERROR);
                Fujitsu.GDC.ErrorNotification.Logger.Error(ImportConstantMessages.UNEXPECTED_ERROR, ex, null, null);
            }
        }
    }
}
