﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using Gdc.Scd.Core.Attributes;
using Gdc.Scd.Core.Interfaces;
using Gdc.Scd.Core.Meta.Constants;

namespace Gdc.Scd.Core.Entities
{
    [Table("SwLicense", Schema = MetaConstants.InputLevelSchema)]
    public class SwLicense : NamedId, IModifiable
    {
        [MustCompare(true, IsIgnoreCase = true)]
        public string Description { get; set; }

        public DateTime CreatedDateTime { get; set; }

        public DateTime? DeactivatedDateTime { get; set; }

        public DateTime ModifiedDateTime { get; set; }

        public ICollection<SwDigitLicense> SwDigitLicenses { get; set; }
    }
}
