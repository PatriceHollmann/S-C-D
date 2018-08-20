﻿using Gdc.Scd.BusinessLogicLayer.Entities;
using Gdc.Scd.BusinessLogicLayer.Interfaces;
using Gdc.Scd.BusinessLogicLayer.Procedures;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Parameters;
using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Text;
using System.Threading.Tasks;
using Gdc.Scd.Core.Entities;
using Gdc.Scd.Core.Dto.AvailabilityFee;
using Gdc.Scd.DataAccessLayer.Procedures;

namespace Gdc.Scd.BusinessLogicLayer.Impl
{
    public class AvailabilityFeeAdminService : IAvailabilityFeeAdminService
    {
        private readonly IRepositorySet _repositorySet;

        private readonly IRepository<AdminAvailabilityFee> _availabilityFeeAdminRepo;

        public AvailabilityFeeAdminService(IRepositorySet repositorySet, 
            IRepository<AdminAvailabilityFee> availabilityFeeAdminRepo)
        {
            _repositorySet = repositorySet;
            _availabilityFeeAdminRepo = availabilityFeeAdminRepo;
        }

        public void ApplyAvailabilityFeeForSelectedCombination(AdminAvailabilityFee model)
        {
            using (var transaction = _repositorySet.GetTransaction())
            {
                try
                {
                    _availabilityFeeAdminRepo.Save(model);
                    _repositorySet.Sync();
                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    transaction.Rollback();

                    throw ex;
                }
            }
        }

        public List<AdminAvailabilityFeeDto> GetAllCombinations(int pageNumber, int limit, out int totalCount)
        {
            return new AvailabilityFeeAdmin(_repositorySet).Execute(pageNumber, limit, out totalCount);
        }

        public void RemoveCombination(long id)
        {
            using (var transaction = _repositorySet.GetTransaction())
            {
                try
                {
                    _availabilityFeeAdminRepo.Delete(id);
                    _repositorySet.Sync();
                    transaction.Commit();
                }
                catch(Exception ex)
                {
                    transaction.Rollback();

                    throw ex;
                }
            }
                  
        }

        public void SaveCombinations(IEnumerable<AdminAvailabilityFeeViewDto> records)
        {
            foreach (var record in records)
            {
                if (record.IsApplicable)
                {
                    if (record.InnerId == 0)
                    {
                        var newObj = new AdminAvailabilityFee()
                        {
                            CountryId = record.CountryId,
                            ReactionTimeId = record.ReactionTimeId,
                            ReactionTypeId = record.ReactionTypeId,
                            ServiceLocationId = record.ServiceLocatorId
                        };

                        this.ApplyAvailabilityFeeForSelectedCombination(newObj);
                    }
                }
                else
                {
                    if (record.InnerId > 0)
                        this.RemoveCombination(record.InnerId);
                }
            }
        }
        
    }
}
