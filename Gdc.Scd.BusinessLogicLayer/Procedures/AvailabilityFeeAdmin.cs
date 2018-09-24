﻿using Gdc.Scd.BusinessLogicLayer.Dto.AvailabilityFee;
using Gdc.Scd.DataAccessLayer.Interfaces;
using Gdc.Scd.DataAccessLayer.SqlBuilders.Parameters;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;

namespace Gdc.Scd.BusinessLogicLayer.Procedures
{
    public class AvailabilityFeeAdmin
    {
        private const string PROC_NAME = "GetAvailabilityFeeCoverageCombination";

        private readonly IRepositorySet _repositorySet;

        public AvailabilityFeeAdmin(IRepositorySet repositorySet)
        {
            _repositorySet = repositorySet;
        }

        public List<AdminAvailabilityFeeDto> Execute(int pageNumber, int limit, out int totalCount)
        {
            var parameters = Prepare(pageNumber, limit);
            var outParameter = new SqlParameterBuilder().WithName("@totalCount").WithType(DbType.Int32).WithDirection(ParameterDirection.Output).Build();
            return _repositorySet.ExecuteProc<AdminAvailabilityFeeDto, int>(PROC_NAME, outParameter, 
                out totalCount,
                parameters);
        }

        private static DbParameter[] Prepare(int pageNumber, int limit)
        {
            return new DbParameter[] {
                 new SqlParameterBuilder().WithName("@pageSize").WithValue(limit).Build(),
                 new SqlParameterBuilder().WithName("@pageNumber").WithValue(pageNumber).Build()
            };
        }
    }
}
