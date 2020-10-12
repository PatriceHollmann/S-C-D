﻿using Gdc.Scd.Core.Entities;
using Gdc.Scd.Import.Por;
using Gdc.Scd.Import.Por.Core.DataAccessLayer;
using Gdc.Scd.Tests.Integration.Import.Por.Testings;
using Gdc.Scd.Tests.Util;
using NUnit.Framework;
using System.Collections.Generic;

namespace Gdc.Scd.Tests.Integration.Import.Por
{
    public class PorServiceTest : PorService
    {
        private FakeLogger fakeLogger;

        private FakeCostBlockUpdateService fakeCostBlockUpdateService;
        private FrieseClient friese;

        [SetUp]
        public void Setup()
        {
            fakeLogger = new FakeLogger();
            fakeCostBlockUpdateService = new FakeCostBlockUpdateService();
            this.Logger = fakeLogger;
            this.CostBlockUpdateService = fakeCostBlockUpdateService;
        }

        [TestCase]
        public void UpdateCostBlocksByPlaTest()
        {
            this.fakeCostBlockUpdateService.OnUpdateByPla = () =>
            {
                Assert.IsTrue(fakeLogger.IsInfo);
                Assert.AreEqual("STEP -1: Updating cost block by pla started...", fakeLogger.Message);
            };

            this.UpdateCostBlocksByPla(-1, new List<Wg>(0));
            Assert.IsTrue(fakeLogger.IsInfo);
            Assert.AreEqual("Cost block by pla updated.", fakeLogger.Message);
        }

        [TestCase]
        public void UpdateCostBlocksByPlaShouldLogErrorTest()
        {
            fakeCostBlockUpdateService.error = new System.Exception("Error here!");
            this.UpdateCostBlocksByPla(-1, null);
            Assert.IsTrue(fakeLogger.IsError);
            Assert.AreEqual("POR Import completed unsuccessfully. Please find details below.", fakeLogger.Message);
        }

        [TestCase]
        public void UpdateCostBlocksBySogTest()
        {
            this.fakeCostBlockUpdateService.OnUpdateByPla = () =>
            {
                Assert.IsTrue(fakeLogger.IsInfo);
                Assert.AreEqual("STEP -999: Updating software cost block by sog started...", fakeLogger.Message);
            };

            this.UpdateCostBlocksBySog(-999, new List<SwDigit>(0));
            Assert.IsTrue(fakeLogger.IsInfo);
            Assert.AreEqual("Software cost block by sog updated.", fakeLogger.Message);
        }

        [TestCase]
        public void UpdateCostBlocksBySogShouldLogErrorTest()
        {
            fakeCostBlockUpdateService.error = new System.Exception("Error here!");
            this.UpdateCostBlocksBySog(-1, new List<SwDigit>(0));
            Assert.IsTrue(fakeLogger.IsError);
            Assert.AreEqual("POR Import completed unsuccessfully. Please find details below.", fakeLogger.Message);
        }
        [TestCase]
        public void ActivateSwDigit()
        {
            //new ImportPorJob().Output();
           // var scd2_SW_Overview = friese.GetSw();
            List<SCD2_SW_Overview> scd2_SW_Overview=new List<SCD2_SW_Overview>();
            var testSCD2_SW_Overview = new SCD2_SW_Overview
            {
                WG = "E0B",
                WG_Definition = "ETERNUS SF with AMF",
                PLA = "X86 / IA SERVER",
                Software_Lizenz_Digit = "OR",
                Software_Lizenz_Beschreibung = "ETSF8 MA for FC-Switch",
                Service_Code = "FSP:G-SW16K60PRV0H",
                Service_Description = "7840 upg lic,WAN traffic rate 10Gbps.",
                Service_Code_Requester = "Wolfgang Dörr",
                Software_Lizenz = "N'D:LEXTSUG1-01-M-L",
                Software_Lizenz_Benennung = "VMW VSAN 7 STD DT 100CCU w/o SP-5yr",
                Service_Code_Status = "50",
                Service_Short_Description = "SP 5y TS Sub & Upgr,9x5,4h Rm Rt ",
                Proactive = "",
                SCD_Relevant = "x",
                ID = 7000,
                SOG_Code = "E0B",
                SOG = "ETERNUS SF with AMF",
                ServiceFabGrp = "FS8236",
                SCD_ServiceType = "Software Service"
            };
            scd2_SW_Overview.Add(testSCD2_SW_Overview);
            List<SwDigit> added= this.UploadSoftwareDigits(scd2_SW_Overview, FormatDataHelper.FillSwInfo(scd2_SW_Overview), 1).added;
            this.UpdateCostBlocksBySog(5, added);
        }
        [TestCase]
        public void DeactivateSwDigit()
        {
            new ImportPorJob().Output();
            var scd2_SW_Overview = friese.GetSw();
            this.UploadSoftwareDigits(scd2_SW_Overview, FormatDataHelper.FillSwInfo(scd2_SW_Overview), 1);
            List<SwDigit> added = this.UploadSoftwareDigits(scd2_SW_Overview, FormatDataHelper.FillSwInfo(scd2_SW_Overview), 1).added;
            this.UpdateCostBlocksBySog(5, added);
        }
        //todo you are here
    }
}
