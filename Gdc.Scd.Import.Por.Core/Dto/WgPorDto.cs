﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Gdc.Scd.Import.Por.Core.DataAccessLayer;
using Gdc.Scd.Import.Por.Core.Impl;

namespace Gdc.Scd.Import.Por.Core.Dto
{
    public struct WgPorDto
    {
        public string Alignment { get; set; }
        public string Description { get; set; }
        public string Name { get; set; }
        public string Pla { get; set; }
        public string Sog { get; set; }
        public string FabGrp { get; set; }
        public string SCD_ServiceType { get; set; }
        public bool IsSoftware { get; set; }
        public bool ActivePorFlag { get; set; }
        public string ServiceTypes { get; set; }

        public WgPorDto(SCD2_WarrantyGroups porWg)
        {
            Alignment = porWg.Alignment;
            Description = porWg.Warranty_Group_Name;
            Name = porWg.Warranty_Group;
            Pla = porWg.Warranty_PLA;
            Sog = porWg.SOG;
            FabGrp = porWg.FabGrp;
            ServiceTypes = porWg.Service_Types;
            SCD_ServiceType = porWg.SCD_ServiceType;
            ActivePorFlag = porWg.Active_Flag == "1";
            IsSoftware = ImportHelper.IsSoftware(porWg.Service_Types,
                porWg.Alignment);
        }
    }
}
