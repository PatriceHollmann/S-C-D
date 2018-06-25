﻿using System.Collections.Generic;
using System.Threading.Tasks;
using Gdc.Scd.Core.Entities;

namespace Gdc.Scd.DataAccessLayer.Interfaces
{
    public interface ICostEditorRepository
    {
        Task<IEnumerable<EditItem>> GetEditItemsByLevel(string levelColumn, EditItemInfo editItemInfo, IDictionary<string, IEnumerable<object>> filter = null);

        Task<int> UpdateValuesByLevel(IEnumerable<EditItem> editItems, EditItemInfo editItemInfo, string levelColumnName);
    }
}
