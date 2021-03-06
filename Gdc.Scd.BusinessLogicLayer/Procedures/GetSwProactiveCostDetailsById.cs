﻿using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Parameters;
using System.Collections.Generic;
using System.Data.Common;

namespace Gdc.Scd.BusinessLogicLayer.Procedures
{
    public class GetSwProactiveCostDetailsById
    {
        private const string PROC_NAME = "SoftwareSolution.SpGetProactiveCostDetailsByID";

        private readonly IRepositorySet _repositorySet;

        public GetSwProactiveCostDetailsById(IRepositorySet repositorySet)
        {
            _repositorySet = repositorySet;
        }

        public List<GetHwCostDetailsById.CostDetailDto> Execute(bool approved, long id, string fsp)
        {
            return _repositorySet.ExecuteProc<GetHwCostDetailsById.CostDetailDto>(PROC_NAME, Prepare(approved, id, fsp));
        }

        private static DbParameter[] Prepare(bool approved, long id, string fsp)
        {
            return new DbParameter[] {
                new DbParameterBuilder().WithName("@approved").WithValue(approved).Build(),
                new DbParameterBuilder().WithName("@id").WithValue(id).Build(),
                new DbParameterBuilder().WithName("@fsp").WithValue(fsp).Build()
            };
        }
    }
}
