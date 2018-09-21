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
    public class PorSwDigitService : ImportPorService<SwDigit>, IPorSwDigitService
    {
        private ILogger<LogLevel> _logger;

        public PorSwDigitService(IRepositorySet repositorySet, 
            IEqualityComparer<SwDigit> comparer,
            ILogger<LogLevel> logger)
            : base(repositorySet, comparer)
        {
            if (logger == null)
                throw new ArgumentNullException(nameof(logger));

            _logger = logger;
        }

        public bool Deactivate(IDictionary<string, string> swInfo, DateTime modifiedDateTime)
        {
            var result = true;

            try
            {
                _logger.Log(LogLevel.Info, PorImportLoggingMessage.DEACTIVATE_STEP_BEGIN, nameof(SwDigit));

                var porItems = swInfo.Keys.Select(k => k.ToLower()).ToList();

                //select all that is not coming from POR and was not already deactivated in SCD
                var itemsToDeacivate = this.GetAll()
                                          .Where(f => !porItems.Contains(f.Name.ToLower())
                                                    && !f.DeactivatedDateTime.HasValue).ToList();

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

        public bool UploadSwDigits(IDictionary<string, string> swInfo, 
            IEnumerable<Sog> sogs, 
            DateTime modifiedDateTime)
        {
            var result = true;

            try
            {
                _logger.Log(LogLevel.Info, PorImportLoggingMessage.ADD_STEP_BEGIN, nameof(SwDigit));

                var updatedSwDigits = new List<SwDigit>();

                foreach (var swDigit in swInfo)
                {
                    var sog = sogs.FirstOrDefault(p => p.Name.Equals(swDigit.Value, StringComparison.OrdinalIgnoreCase));
                    if (sog == null)
                    {
                        _logger.Log(LogLevel.Warn,
                            PorImportLoggingMessage.UNKNOW_SOG, $"{nameof(SwDigit)} {swDigit.Key}", swDigit.Value);
                        continue;
                    }

                    updatedSwDigits.Add(new SwDigit
                    {
                        Name = swDigit.Key,
                        SogId = sog.Id
                    });
                }

                var added = this.AddOrActivate(updatedSwDigits, modifiedDateTime);

                foreach (var addedEntity in added)
                {
                    _logger.Log(LogLevel.Info, PorImportLoggingMessage.ADDED_OR_UPDATED_ENTITY,
                        nameof(SwDigit), addedEntity.Name);
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
