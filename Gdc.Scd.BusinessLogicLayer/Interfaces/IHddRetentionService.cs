﻿using Gdc.Scd.BusinessLogicLayer.Dto.Calculation;
using Gdc.Scd.Core.Entities;
using System.Threading.Tasks;

namespace Gdc.Scd.BusinessLogicLayer.Interfaces
{
    public interface IHddRetentionService
    {
        Task<(HddRetentionDto[] items, int total)> GetCost(bool approved, object filter, int start, int limit);

        void SaveCost(User user, HddRetentionDto[] items);
    }
}
