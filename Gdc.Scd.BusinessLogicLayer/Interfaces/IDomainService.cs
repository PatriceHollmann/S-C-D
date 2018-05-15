﻿using System;
using System.Linq;
using Gdc.Scd.Core.Interfaces;

namespace Gdc.Scd.BusinessLogicLayer.Interfaces
{
    public interface IDomainService<T> where T : IIdentifiable
    {
        T Get(Guid id);

        IQueryable<T> GetAll();

        void Save(T item);

        void Delete(Guid id);
    }
}
