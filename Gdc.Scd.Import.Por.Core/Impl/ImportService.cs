﻿using Gdc.Scd.BusinessLogicLayer.Impl;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.Import.Por.Core.Extensions;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;

namespace Gdc.Scd.Import.Por.Core.Impl
{
    public class ImportService<T> : DomainService<T> where T: NamedId, IDeactivatable, new()
    {
        private const int BATCH_NUMBER = 50;
        private readonly IEqualityComparer<T> _comparer;


        public ImportService(IRepositorySet repositorySet,
            IEqualityComparer<T> comparer)
            : base(repositorySet)
        {
            _comparer = comparer ?? EqualityComparer<T>.Default;
        }

        public bool Deactivate(IEnumerable<T> items, DateTime deactivatedDate)
        {
            bool result = true;

            try
            {
                foreach (T item in items)
                {
                    item.DeactivatedDateTime = deactivatedDate;
                    item.ModifiedDateTime = deactivatedDate;
                }

                this.Save(items);
                this.repositorySet.Sync();
            }
            catch (Exception ex)
            {
                result = false;
                throw ex;
            }
            

            return result;
        }

        public List<T> AddOrActivate(IEnumerable<T> itemsToUpdate, DateTime modifiedDate,
            Expression<Func<T, bool>> predicate = null)
        {
            List<T> batch = new List<T>();
            var dbItems = predicate == null ? this.GetAll().ToList() 
                                            : this.GetAll().Where(predicate).ToList();

            foreach (T item in itemsToUpdate)
            {
                var dbItem = dbItems.FirstOrDefault(i => i.Name.Equals(item.Name, 
                                                            StringComparison.OrdinalIgnoreCase));

                //new item
                if (dbItem == null)
                {
                    item.CreatedDateTime = modifiedDate;
                    item.ModifiedDateTime = modifiedDate;
                    batch.Add(item);
                }

                //item already exists in the database
                else
                {
                    //if something was changed update in the database
                    if (!_comparer.Equals(dbItem, item))
                    {
                        item.CopyModifiedValues<T>(dbItem, modifiedDate);
                        batch.Add(dbItem);
                    }

                    //check if it is active in the databse
                    else
                    {
                        if (dbItem.DeactivatedDateTime.HasValue)
                        {
                            dbItem.DeactivatedDateTime = null;
                            dbItem.ModifiedDateTime = modifiedDate;
                            batch.Add(dbItem);
                        }
                    }
                }
            }

            this.Save(batch);
            return batch;
        }

        public override void Save(IEnumerable<T> items)
        {
            using (var transaction = this.repositorySet.GetTransaction())
            {
                try
                {
                    int count = 0;
                    foreach (var item in items)
                    {
                        count++;
                        this.InnerSave(item);
                        if ( count % BATCH_NUMBER == 0 && count > 0)
                        {
                            this.repositorySet.Sync();
                        }
                    }
                    this.repositorySet.Sync();
                    transaction.Commit();
                }
                catch(Exception ex)
                {
                    transaction.Rollback();
                    throw ex;
                }

            }
        }

        public IQueryable<T> GetAllActive()
        {
            return this.GetAll().Where(entity => !entity.DeactivatedDateTime.HasValue);
        }
    }
}