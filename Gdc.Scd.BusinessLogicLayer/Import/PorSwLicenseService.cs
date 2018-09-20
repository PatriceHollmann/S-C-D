﻿using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.DataAccessLayer.External.Por;
using Gdc.Scd.DataAccessLayer.Interfaces;
using NLog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gdc.Scd.BusinessLogicLayer.Import
{
    public class PorSwLicenseService : ImportPorService<SwLicense>, IPorSwLicenseService
    {
        private ILogger<LogLevel> _logger;

        public PorSwLicenseService(IRepositorySet repositorySet,
            IEqualityComparer<SwLicense> comparer,
            ILogger<LogLevel> logger)
            : base(repositorySet, comparer)
        {
            if (logger == null)
                throw new ArgumentNullException(nameof(logger));

            _logger = logger;
        }

        public bool Deactivate(IEnumerable<SCD_SW_Overview> swInfo, DateTime modifiedDateTime)
        {
            var result = true;

            try
            {
                _logger.Log(LogLevel.Info, PorImportLoggingMessage.DEACTIVATE_STEP_BEGIN, nameof(SwLicense));

                var porItems = swInfo.Select(sw => sw.Software_Lizenz.ToLower()).ToList();

                //select all that is not coming from POR and was not already deactivated in SCD
                var itemsToDeacivate = this.GetAll()
                                          .Where(s => !porItems.Contains(s.Name.ToLower())
                                                    && !s.DeactivatedDateTime.HasValue).ToList();

                var deactivated = this.Deactivate(itemsToDeacivate, modifiedDateTime);

                if (deactivated)
                {
                    foreach (var deactivateItem in itemsToDeacivate)
                    {
                        _logger.Log(LogLevel.Info, PorImportLoggingMessage.DEACTIVATED_ENTITY,
                            nameof(SwDigit), deactivateItem.Name);
                    }
                }

                _logger.Log(LogLevel.Info, PorImportLoggingMessage.DEACTIVATE_STEP_END, itemsToDeacivate.Count);
            }

            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex, PorImportLoggingMessage.UNEXPECTED_ERROR);
                result = false;
            }

            return result;
        }

        public bool UploadSwLicense(IEnumerable<SCD_SW_Overview> swInfo, 
            IEnumerable<SwDigit> digits, DateTime modifiedDateTime)
        {
            var result = true;

            try
            {
                _logger.Log(LogLevel.Info, PorImportLoggingMessage.ADD_STEP_BEGIN, nameof(SwLicense));

                var updatedSwLicenses = new List<SwLicense>();

                foreach (var swLicense in swInfo)
                {
                    
                    var digit = digits.FirstOrDefault(d => d.Name.Equals(swLicense.Software_Lizenz_Digit, 
                        StringComparison.OrdinalIgnoreCase));

                    if (digit == null)
                    {
                        _logger.Log(LogLevel.Warn,
                            PorImportLoggingMessage.UNKNOW_DIGIT, 
                            $"{nameof(SwLicense)} {swLicense.Software_Lizenz}", 
                            swLicense.Software_Lizenz_Digit);
                        continue;
                    }

                    updatedSwLicenses.Add(new SwLicense
                    {
                        Name = swLicense.Software_Lizenz,
                        SoftwareLicenseDescription = swLicense.Software_Lizenz_Beschreibung,
                        SoftwareLicenseName = swLicense.Software_Lizenz_Benennung,
                        SwDigitId = digit.Id
                    });
                }

                var added = this.AddOrActivate(updatedSwLicenses, modifiedDateTime);

                foreach (var addedEntity in added)
                {
                    _logger.Log(LogLevel.Info, PorImportLoggingMessage.ADDED_OR_UPDATED_ENTITY,
                        nameof(SwLicense), addedEntity.Name);
                }

                _logger.Log(LogLevel.Info, PorImportLoggingMessage.ADD_STEP_END, added.Count);
            }

            catch (Exception ex)
            {
                _logger.Log(LogLevel.Error, ex, PorImportLoggingMessage.UNEXPECTED_ERROR);
                result = false;
            }

            return result;
        }
    }
}
