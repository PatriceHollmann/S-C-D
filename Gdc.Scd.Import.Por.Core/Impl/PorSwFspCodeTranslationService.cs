﻿using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.Import.Por.Core.Dto;
using Gdc.Scd.Import.Por.Core.Extensions;
using Gdc.Scd.Import.Por.Core.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.Import.Por.Core.Impl
{
    public class PorSwFspCodeTranslationService : PorFspTranslationService<SwFspCodeTranslation>,
                                                  ISwFspCodeTranslationService
    {
        private readonly ILogger _logger;

        public PorSwFspCodeTranslationService(IRepositorySet repositorySet,
            ILogger logger) : base(repositorySet)
        {
            if (logger == null)
                throw new ArgumentNullException(nameof(logger));

            _logger = logger;
        }


        public bool UploadSoftware(SwFspCodeDto model)
        {
            var result = true;
            var updatedFspCodes = new List<SwFspCodeTranslation>();

            using (var transaction = this._repositorySet.GetTransaction())
            {
                try
                {
                    _logger.Info(PorImportLoggingMessage.DELETE_BEGIN, nameof(SwFspCodeTranslation));
                    _repository.DeleteAll();
                    _logger.Info(PorImportLoggingMessage.DELETE_END);

                    foreach (var code in model.SoftwareCodes)
                    {
                        if (String.IsNullOrEmpty(code.SOG))
                        {
                            _logger.Warn(PorImportLoggingMessage.EMPTY_SOG_WG, code.Service_Code);
                            continue;
                        }

                        var sog = model.Sogs.FirstOrDefault(s => s.Name == code.SOG);
                        if (sog == null)
                        {
                            _logger.Warn(PorImportLoggingMessage.UNKNOWN_SOG, code.Service_Code, code.SOG);
                            continue;
                        }

                        var sla = code.MapFspCodeToSla(model.Sla);
                        if (sla == null)
                        {
                            _logger.Warn(PorImportLoggingMessage.UNKNOWN_SLA_TRANSLATION, code.Service_Code);
                            continue;
                        }

                        var swRecords = model.SoftwareInfo.Where(sw => sw.Service_Code.Equals(code.Service_Code)).ToList();
                        var distinctDigits = swRecords.Select(r => r.Software_Lizenz_Digit).Distinct(StringComparer.OrdinalIgnoreCase).ToList();

                        if (distinctDigits.Count != 1)
                        {
                            _logger.Warn(PorImportLoggingMessage.INCORRECT_SOFTWARE_FSPCODE_DIGIT_MAPPING, code.Service_Code, swRecords.Count);
                            continue;
                        }

                        var digit = model.Digits.FirstOrDefault(d => d.Name == distinctDigits[0]);
                        if (digit == null)
                        {
                            _logger.Warn(PorImportLoggingMessage.UNKNOW_DIGIT, code.Service_Code, distinctDigits[0]);
                            continue;
                        }

                        var serviceDescription = swRecords.FirstOrDefault()?.Service_Description;
                        var shortDescription = swRecords.FirstOrDefault()?.Service_Short_Description;

                        _logger.Debug(PorImportLoggingMessage.CHECKING_SW_PROACTIVE, digit.Name);
                        var proActive = model.ProActiveDigits.FirstOrDefault(d => d.DigitId.HasValue && d.DigitId == digit.Id);
                        var proActiveNullValue = model.Sla.Proactive[PorConstants.SlaNullValue];

                        var dbcode = new SwFspCodeTranslation
                        {
                            AvailabilityId = sla.Availability,
                            DurationId = sla.Duration,
                            ReactionTimeId = sla.ReactionTime,
                            ReactionTypeId = sla.ReactionType,
                            ServiceLocationId = sla.ServiceLocation,
                            SogId = sog.Id,
                            Name = code.Service_Code,
                            SCD_ServiceType = code.SCD_ServiceType,
                            SecondSLA = code.SecondSLA,
                            ServiceDescription = serviceDescription,
                            ShortDescription = shortDescription,
                            EKSAPKey = code.EKSchluesselSAP,
                            EKKey = code.EKSchluessel,
                            Status = code.VStatus,
                            SwDigitId = digit.Id,
                            CreatedDateTime = model.CreatedDateTime,
                            ProactiveSlaId = proActive == null ? proActiveNullValue : proActive.ProActiveId
                        };

                        var swRecord = swRecords.FirstOrDefault(rec => !String.IsNullOrEmpty(rec.Software_Lizenz_Benennung)) ??
                                        swRecords.FirstOrDefault();

                        if (swRecord != null)
                        {
                            var swLicense = model.License.FirstOrDefault(x => x.Name == swRecord.Software_Lizenz);
                            dbcode.SwLicenseId = swLicense?.Id;
                        }

                        _logger.Debug(PorImportLoggingMessage.ADDED_OR_UPDATED_ENTITY,
                                            nameof(SwFspCodeTranslation), dbcode.Name);

                        updatedFspCodes.Add(dbcode);
                    }


                    this.Save(updatedFspCodes);
                    transaction.Commit();

                    _logger.Info(PorImportLoggingMessage.ADD_STEP_END, updatedFspCodes.Count);
                }

                catch (Exception ex)
                {
                    _logger.Error(ex, PorImportLoggingMessage.UNEXPECTED_ERROR);
                    result = false;
                }

                return result;
            }
        }
    }
}
