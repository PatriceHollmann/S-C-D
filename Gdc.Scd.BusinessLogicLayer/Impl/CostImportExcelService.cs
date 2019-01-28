﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using ClosedXML.Excel;
using Gdc.Scd.BusinessLogicLayer.Entities;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Interfaces;

namespace Gdc.Scd.BusinessLogicLayer.Impl
{
    public class CostImportExcelService : ICostImportExcelService
    {
        private readonly ICostBlockService costBlockService;

        private readonly IDomainService<Wg> wgService;

        private readonly ISqlRepository sqlRepository;

        private readonly DomainEnitiesMeta metas;

        public CostImportExcelService(
            ICostBlockService costBlockService,
            IDomainService<Wg> wgService,
            ISqlRepository sqlRepository,
            DomainEnitiesMeta metas)
        {
            this.costBlockService = costBlockService;
            this.wgService = wgService;
            this.sqlRepository = sqlRepository;
            this.metas = metas;
        }

        public async Task<ExcelImportResult> Import(
            ICostElementIdentifier costElementId, 
            Stream excelStream, 
            ApprovalOption approvalOption, 
            long? dependencyItemId = null,
            long? regionId = null)
        {
            var result = new ExcelImportResult
            {
                Errors = new List<string>()
            };

            try
            {
                var workbook = new XLWorkbook(excelStream);
                var worksheetInfo = 
                    workbook.Worksheets.Select(worksheet => new
                                        {
                                            Worksheet = worksheet,
                                            RowCount = worksheet.RowsUsed().Count()
                                        })
                                       .FirstOrDefault(info => info.RowCount > 0);

                if (worksheetInfo == null)
                {
                    result.Errors.Add("Excel file is empty");
                }
                else
                {
                    var wgRawValues = new Dictionary<string, string>();

                    for (var rowIndex = 1; rowIndex <= worksheetInfo.RowCount; rowIndex++)
                    {
                        var wgName = worksheetInfo.Worksheet.Cell(rowIndex, 1).GetValue<string>();

                        if (!string.IsNullOrWhiteSpace(wgName))
                        {
                            var wgValue = worksheetInfo.Worksheet.Cell(rowIndex, 2).GetValue<string>();

                            if (!string.IsNullOrWhiteSpace(wgValue))
                            {
                                wgRawValues[wgName] = wgValue;
                            }
                        }
                    }
                   
                    var editInfoResult = await this.BuildEditInfos(costElementId, dependencyItemId, regionId, wgRawValues);

                    if (editInfoResult.EditInfo.ValueInfos.Any())
                    {
                        result.Errors.AddRange(editInfoResult.Errors);

                        var qualityGateResultSet = await this.costBlockService.Update(new[] { editInfoResult.EditInfo }, approvalOption, EditorType.CostImport);
                        var qualityGateResultSetItem = qualityGateResultSet.Items.FirstOrDefault();

                        if (qualityGateResultSetItem != null)
                        {
                            result.QualityGateResult = qualityGateResultSetItem.QualityGateResult;
                        }
                    }
                    else
                    {
                        result.Errors.Add($"Worksheet '{worksheetInfo.Worksheet.Name}' has not warranty groups");
                    }
                }
            }
            catch(Exception ex)
            {
                result.Errors.Add($"Import error. {ex.Message}");
            }

            if (result.QualityGateResult == null)
            {
                result.QualityGateResult = new QualityGateResult();
            }

            return result;
        }

        private async Task<(EditInfo EditInfo, IEnumerable<string> Errors)> BuildEditInfos(
            ICostElementIdentifier costElementId,
            long? dependencyItemId,
            long? regionId,
            IDictionary<string, string> wgRawValues)
        {
            var errors = new List<string>();
            var wgs =
                this.wgService.GetAll()
                              .Where(wg => wgRawValues.Keys.Contains(wg.Name))
                              .ToDictionary(wg => wg.Name);

            var costBlockMeta = this.metas.GetCostBlockEntityMeta(costElementId);
            var converter = await this.BuildConverter(costBlockMeta, costElementId.CostElementId);
            var valueInfos = new List<ValuesInfo>();
            var dependencyFilter = this.BuildFilter(costBlockMeta, costElementId, dependencyItemId, regionId);
            var costElementField = costBlockMeta.CostElementsFields[costElementId.CostElementId];

            foreach (var wgValue in wgRawValues)
            {
                try
                {
                    if (wgs.TryGetValue(wgValue.Key, out var wg))
                    {
                        valueInfos.Add(new ValuesInfo
                        {
                            CoordinateFilter = new Dictionary<string, long[]>(dependencyFilter)
                            {
                                [MetaConstants.WgInputLevelName] = new[] { wg.Id }
                            },
                            Values = new Dictionary<string, object>
                            {
                                [costElementId.CostElementId] = converter(wgValue.Value)
                            }
                        });
                    }
                    else
                    {
                        errors.Add($"Warranty group '{wgValue.Key}' not found");
                    }
                }
                catch(Exception ex)
                {
                    errors.Add($"Import error - warranty group '{wgValue.Key}', value '{wgValue.Value}'. {ex.Message}");
                }
            }

            var editInfo = new EditInfo
            {
                Meta = costBlockMeta,
                ValueInfos = valueInfos
            };

            return (editInfo, errors);
        }

        private async Task<Func<string, object>> BuildConverter(CostBlockEntityMeta meta, string costElementId)
        {
            Func<string, object> converter;

            switch (meta.CostElementsFields[costElementId])
            {
                case SimpleFieldMeta simpleField:
                    switch(simpleField.Type)
                    {
                        case TypeCode.Boolean:
                            converter = rawValue =>
                            {
                                bool result;

                                var rawValueUpper = rawValue.ToUpper();

                                if (rawValueUpper == "0" || rawValueUpper == "FALSE")
                                {
                                    result = false;
                                }
                                else if (rawValueUpper == "1" || rawValueUpper == "TRUE")
                                {
                                    result = true;
                                }
                                else
                                {
                                    throw new Exception($"Unable to convert value from '{rawValue}' to boolean");
                                }

                                return result;
                            };
                            break;

                        default:
                            converter = rawValue => Convert.ChangeType(rawValue, simpleField.Type);
                            break;
                    }
                    break;

                case ReferenceFieldMeta referenceField:
                    var referenceItems = 
                        await this.sqlRepository.GetNameIdItems(
                            referenceField.ReferenceMeta, 
                            referenceField.ReferenceValueField, 
                            referenceField.ReferenceFaceField);

                    var referenceItemsDict = referenceItems.ToDictionary(item => item.Name.ToUpper(), item => item.Id);

                    converter = rawValue =>
                    {
                        if (!referenceItemsDict.TryGetValue(rawValue.ToUpper(), out var id))
                        {
                            throw new Exception($"'{rawValue}' not found in {referenceField.Name}");
                        }

                        return id;
                    };
                    break;

                default:
                    throw new NotSupportedException("Cost element field type not supported");
            }

            return converter;
        }

        private IDictionary<string, long[]> BuildFilter(
            CostBlockEntityMeta costBlockMeta,
            ICostElementIdentifier costElementId,
            long? dependencyItemId,
            long? regionId)
        {
            var filter = new Dictionary<string, long[]>();
            var costElement = costBlockMeta.DomainMeta.CostElements[costElementId.CostElementId];

            if (dependencyItemId.HasValue)
            {
                if (costElement.Dependency == null)
                {
                    throw new Exception($"Cost element '{costElementId.CostElementId}' has not dependency, but parameter 'dependencyItemId' has value");
                }
                else
                {
                    filter.Add(costElement.Dependency.Id, new [] { dependencyItemId.Value });
                }
            }

            if (regionId.HasValue)
            {
                if (costElement.RegionInput == null)
                {
                    throw new Exception($"Cost element '{costElementId.CostElementId}' has not region, but parameter 'regionId' has value");
                }
                else
                {
                    filter.Add(costElement.RegionInput.Id, new[] { regionId.Value });
                }
            }

            return filter;
        }
    }
}
