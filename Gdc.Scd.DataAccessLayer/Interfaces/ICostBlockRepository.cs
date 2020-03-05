﻿using System.Collections.Generic;
using System.Threading.Tasks;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Meta.Entities;
using Gdc.Scd.DataAccessLayer.Entities;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Helpers;

namespace Gdc.Scd.DataAccessLayer.Interfaces
{
    public interface ICostBlockRepository
    {
        Task<int> Update(IEnumerable<EditInfo> editInfos);

        Task<int> UpdateByCoordinatesAsync(CostBlockEntityMeta meta, IEnumerable<UpdateQueryOption> updateOptions = null);

        void UpdateByCoordinates(CostBlockEntityMeta meta, IEnumerable<UpdateQueryOption> updateOptions = null);

        void CreatRegionIndexes();

        SqlHelper BuildUpdateByCoordinatesQuery(CostBlockEntityMeta meta, IEnumerable<UpdateQueryOption> updateOptions = null);
    }
}
