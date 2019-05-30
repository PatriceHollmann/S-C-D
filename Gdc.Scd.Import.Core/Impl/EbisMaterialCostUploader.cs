﻿using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Enums;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.Import.Core.Dto;
using Gdc.Scd.Import.Core.Interfaces;
using NLog;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Gdc.Scd.Import.Core.DataAccess;

namespace Gdc.Scd.Import.Core.Impl
{
    public class EbisMaterialCostUploader : IUploader<MaterialCostDto>
    {
        private readonly IRepositorySet _repositorySet;
        private readonly IRepository<Wg> _repositoryWg;
        private readonly IRepository<MaterialCostWarrantyEmeia> _repositoryMaterialCost;
        private readonly ILogger<LogLevel> _logger;

        public EbisMaterialCostUploader(IRepositorySet repositorySet,
            ImportRepository<MaterialCostWarrantyEmeia> mcRepo,
            ILogger<LogLevel> logger)
        {
            if (repositorySet == null)
                throw new ArgumentNullException(nameof(repositorySet));

            if (logger == null)
                throw new ArgumentNullException(nameof(logger));

            this._repositorySet = repositorySet;
            this._repositoryWg = this._repositorySet.GetRepository<Wg>();
            this._repositoryMaterialCost = mcRepo;
            this._logger = logger;
        }

        public IEnumerable<UpdateQueryOption> Upload(IEnumerable<MaterialCostDto> items, DateTime modifiedDateTime)
        {
            var wgs = _repositoryWg.GetAll().Where(wg => wg.WgType == WgType.Por && !wg.IsSoftware).ToList();

            var materialCosts = _repositoryMaterialCost.GetAll().ToList();
            var batchList = new List<MaterialCostWarrantyEmeia>();

            //upload only values with Year Dependency 5
            var actualYearMaterialCost = items.Where(i => i.Year.HasValue && i.Year == Config.ActualYear);
            foreach (var item in items)
            {
                if (String.IsNullOrEmpty(item.Wg) || item.Wg.Equals("-"))
                    continue;
                var wg = wgs.FirstOrDefault(w => w.Name.Equals(item.Wg, StringComparison.OrdinalIgnoreCase));
                if (wg == null)
                {
                    _logger.Log(LogLevel.Warn, ImportConstants.UNKNOWN_WARRANTY, item.Wg);
                    continue;
                }
                

                var materialCostDb = materialCosts.FirstOrDefault(mc => mc.WgId == wg.Id && !mc.DeactivatedDateTime.HasValue);
                if (materialCostDb == null)
                {
                    materialCostDb = new MaterialCostWarrantyEmeia();
                    materialCostDb.WgId = wg.Id;
                }
                materialCostDb.MaterialCostIw = item.MaterialCost;
                materialCostDb.MaterialCostIw_Approved = item.MaterialCost;
                batchList.Add(materialCostDb);
            }

            if (batchList.Any())
            {
                _repositoryMaterialCost.DisableTrigger();
                _repositoryMaterialCost.Save(batchList);
                _repositoryMaterialCost.EnableTrigger();
            }

            _logger.Log(LogLevel.Info, ImportConstants.UPLOAD_END, batchList.Count);
            return new List<UpdateQueryOption>();
        }
    }
}
