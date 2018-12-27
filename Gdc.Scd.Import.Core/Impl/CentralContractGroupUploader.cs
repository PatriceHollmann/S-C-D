﻿using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.Import.Core.Dto;
using Gdc.Scd.Import.Core.Interfaces;
using NLog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Gdc.Scd.Import.Core.Impl
{
    public class CentralContractGroupUploader : IUploader<CentralContractGroupDto>
    {
        private readonly IRepositorySet _repositorySet;
        private readonly IRepository<CentralContractGroup> _repositoryCentralContractGroup;
        private readonly IRepository<Wg> _repositoryWg;
        private readonly ILogger<LogLevel> _logger;

        public CentralContractGroupUploader(IRepositorySet repositorySet, ILogger<LogLevel> logger)
        {
            if (repositorySet == null)
                throw new ArgumentNullException(nameof(repositorySet));

            if (logger == null)
                throw new ArgumentNullException(nameof(logger));

            this._repositorySet = repositorySet;
            this._repositoryWg = this._repositorySet.GetRepository<Wg>();
            this._repositoryCentralContractGroup = this._repositorySet.GetRepository<CentralContractGroup>();
            this._logger = logger;
        }

        public void Upload(IEnumerable<CentralContractGroupDto> items, DateTime modifiedDateTime,
            List<UpdateQueryOption> updateOption = null)
        {
            UploadCentralContractGroup(items, modifiedDateTime);
            UpdateWgs(items, modifiedDateTime, updateOption);
        }

        private void UploadCentralContractGroup(IEnumerable<CentralContractGroupDto> items, DateTime modifiedDateTime)
        {
            var centralContractGroups = _repositoryCentralContractGroup.GetAll().ToList();

            var newCentralContractGroups = new Dictionary<string, CentralContractGroup>();

            foreach (var item in items)
            {
                var centralContractGroup = centralContractGroups.FirstOrDefault(ccg => ccg.Name.Equals(item.CentralContractGroupName,
                    StringComparison.OrdinalIgnoreCase));

                //Central Contract Group does not exist in database -> add it
                if (centralContractGroup == null)
                {
                    _logger.Log(LogLevel.Debug, ImportConstants.ADD_NEW_CCG, item.CentralContractGroupName);

                    CollectionHelper.AddEntry<CentralContractGroup>(newCentralContractGroups, new CentralContractGroup
                    {
                        Name = item.CentralContractGroupName,
                        Description = item.CentralContractGroupDescription
                    }, _logger);
                }

                else
                {
                    if (!centralContractGroup.Description.Equals(item.CentralContractGroupDescription, 
                        StringComparison.OrdinalIgnoreCase))
                    {
                        centralContractGroup.Description = item.CentralContractGroupDescription;
                        CollectionHelper.AddEntry<CentralContractGroup>(newCentralContractGroups, centralContractGroup, _logger);
                    }
                }
            }

            if (newCentralContractGroups.Any())
            {
                _repositoryCentralContractGroup.Save(newCentralContractGroups.Values);
                _repositorySet.Sync();
            }

            _logger.Log(LogLevel.Info, ImportConstants.UPLOAD_CCG_END, newCentralContractGroups.Count);
        }

        private void UpdateWgs(IEnumerable<CentralContractGroupDto> items, DateTime modifiedDateTime,
            List<UpdateQueryOption> updateOption)
        {
            _logger.Log(LogLevel.Info, ImportConstants.UPDATING_WGS);
            var wgs = _repositoryWg.GetAll().ToList();
            var centralContractGroups = _repositoryCentralContractGroup.GetAll().ToList();

            var uploadedCcg = items.Select(i => i.CentralContractGroupName).Distinct(StringComparer.OrdinalIgnoreCase).ToList();
            var updatedWgs = new Dictionary<string, Wg>();

            foreach (var item in items)
            {
                var dbCcg = centralContractGroups.FirstOrDefault(ccg =>
                            ccg.Name.Equals(item.CentralContractGroupName, StringComparison.OrdinalIgnoreCase));

                if (dbCcg != null)
                {
                    var wg = wgs.FirstOrDefault(w =>
                            w.Name.Equals(item.WgName, StringComparison.OrdinalIgnoreCase));

                    if (wg == null)
                    {
                        _logger.Log(LogLevel.Warn, ImportConstants.UNKNOWN_WARRANTY, item.WgName);
                        continue;
                    }

                    if (wg.CentralContractGroupId != dbCcg.Id)
                    {
                        updateOption.Add(
                                new UpdateQueryOption(
                                    new Dictionary<string, long>
                                    {
                                        [MetaConstants.WgInputLevelName] = wg.Id,
                                        [MetaConstants.CentralContractGroupInputLevel] = wg.CentralContractGroupId.Value
                                    },
                                    new Dictionary<string, long>
                                    {
                                        [MetaConstants.WgInputLevelName] = wg.Id,
                                        [MetaConstants.CentralContractGroupInputLevel] = dbCcg.Id
                                    }));
                        wg.CentralContractGroupId = dbCcg.Id;
                    }

                    CollectionHelper.AddEntry<Wg>(updatedWgs, wg, _logger);
                }
            }

            if (updatedWgs.Any())
            {
                _repositoryWg.Save(updatedWgs.Values);
                _repositorySet.Sync();
            }

            _logger.Log(LogLevel.Info, ImportConstants.UPDATING_WGS);
        }
    }
}
