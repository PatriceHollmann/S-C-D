﻿using Gdc.Scd.Core.Entities;
using Gdc.Scd.Import.Por.Core.DataAccessLayer;
using System;
using System.Collections.Generic;

namespace Gdc.Scd.Import.Por.Core.Interfaces
{
    public interface IPorSwDigitLicenseService
    {
        bool UploadSwDigitAndLicenseRelation(IEnumerable<SwLicense> licenses,
            IEnumerable<SwDigit> digits,
            IEnumerable<SCD2_SW_Overview> swInfo, DateTime created);
    }
}
