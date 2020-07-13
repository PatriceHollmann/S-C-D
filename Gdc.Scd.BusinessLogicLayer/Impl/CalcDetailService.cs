﻿using Gdc.Scd.BusinessLogicLayer.Procedures;
using Gdc.Scd.Core.Entities.Calculation;
using Gdc.Scd.DataAccessLayer.Interfaces;
using System.Collections.Generic;
using System.Linq;

namespace Gdc.Scd.BusinessLogicLayer.Impl
{
    public class CalcDetailService
    {
        private readonly IRepositorySet _repositorySet;

        public CalcDetailService(IRepositorySet repositorySet)
        {
            _repositorySet = repositorySet;
        }

        public PlausiCost GetHwCostDetails(bool approved, long id, string what)
        {
            var model = new GetHwCostById(_repositorySet).Execute(approved, id);
            var details = new GetHwCostDetailsById(_repositorySet).Execute(approved, id);

            var fieldServiceCost = new PlausiCostBlock { Name = "Field service cost", Value = model.FieldServiceCost, CostElements = AsElements(details, "Field Service Cost") };
            var serviceSupportCost = new PlausiCostBlock { Name = "Service support cost", Value = model.ServiceSupportCost, CostElements = AsElements(details, "Service support cost") };
            var logisticCost = new PlausiCostBlock { Name = "Logistics cost", Value = model.Logistic, CostElements = AsElements(details, "Logistics Cost") };
            var avFee = new PlausiCostBlock { Name = "Availability fee", Value = model.AvailabilityFee, Mandatory = false, CostElements = AsElements(details, "Availability fee") };
            var reinsurance = new PlausiCostBlock { Name = "Reinsurance", Value = model.Reinsurance, Mandatory = false, CostElements = AsElements(details, "Reinsurance") };
            var otherDirectCost = new PlausiCostBlock { Name = "Other", Value = model.OtherDirect };
            var materialCost = new PlausiCostBlock { Name = "Material cost", Value = model.MaterialW + model.MaterialOow, CostElements = AsElements(details, "Material cost") };
            var taxAndDuties = new PlausiCostBlock { Name = "Tax & duties", Value = model.TaxAndDutiesW + model.TaxAndDutiesOow, CostElements = AsElements(details, "Tax & duties") };
            var proactive = new PlausiCostBlock { Name = "ProActive", Value = model.ProActive, Mandatory = false, CostElements = AsElements(details, "ProActive") };

            var blocks = new PlausiCostBlock[]
            {
                fieldServiceCost,
                serviceSupportCost,
                materialCost,
                logisticCost,
                taxAndDuties,
                proactive,
                avFee,
                reinsurance,
                new PlausiCostBlock { Name = "Local STDW", Value = model.LocalServiceStandardWarranty },
                new PlausiCostBlock { Name = "Credits", Value = model.Credits },
                otherDirectCost
            };

            var cost = new PlausiCost
            {
                Fsp = model.Fsp,
                Country = model.Country,
                Currency = model.Currency,
                ExchangeRate = model.ExchangeRate,
                Sog = model.Sog,
                Wg = model.Wg,
                Availability = model.Availability,
                Duration = model.Duration,
                ReactionTime = model.ReactionTime,
                ReactionType = model.ReactionType,
                ServiceLocation = model.ServiceLocation,
                ProActiveSla = model.ProActiveSla,
                StdWarranty = model.StdWarranty,
                StdWarrantyLocation = model.StdWarrantyLocation
            };

            switch (what)
            {
                case "field-service":
                    cost.Name = "Field service cost";
                    cost.Value = model.FieldServiceCost;
                    cost.CostBlocks = new PlausiCostBlock[] { fieldServiceCost };
                    break;

                case "service-support":
                    cost.Name = "Service support cost";
                    cost.Value = model.ServiceSupportCost;
                    cost.CostBlocks = new PlausiCostBlock[] { serviceSupportCost };
                    break;

                case "logistic":
                    cost.Name = "Logistic cost";
                    cost.Value = model.Logistic;
                    cost.CostBlocks = new PlausiCostBlock[] { logisticCost };
                    break;

                case "availability-fee":
                    cost.Name = "Availability fee";
                    cost.Value = model.AvailabilityFee;
                    cost.CostBlocks = new PlausiCostBlock[] { avFee };
                    break;

                case "reinsurance":
                    cost.Name = "Reinsurance";
                    cost.Value = model.Reinsurance;
                    cost.CostBlocks = new PlausiCostBlock[] { reinsurance };
                    break;

                case "other":
                    cost.Name = "Other direct cost";
                    cost.Value = model.OtherDirect;
                    cost.CostBlocks = new PlausiCostBlock[] { otherDirectCost };
                    break;

                case "material":
                    cost.Name = "Material cost iW period";
                    cost.Value = model.MaterialW;
                    cost.CostBlocks = new PlausiCostBlock[] { materialCost };
                    break;

                case "material-oow":
                    cost.Name = "Material cost OOW period";
                    cost.Value = model.MaterialOow;
                    cost.CostBlocks = new PlausiCostBlock[] { materialCost };
                    break;

                case "tax":
                    cost.Name = "Tax & Duties iW period";
                    cost.Value = model.TaxAndDutiesW;
                    cost.CostBlocks = new PlausiCostBlock[] { taxAndDuties };
                    break;

                case "tax-oow":
                    cost.Name = "Tax & Duties OOW period";
                    cost.Value = model.TaxAndDutiesOow;
                    cost.CostBlocks = new PlausiCostBlock[] { taxAndDuties };
                    break;

                case "proactive":
                    cost.Name = "ProActive";
                    cost.Value = model.ProActive;
                    cost.CostBlocks = new PlausiCostBlock[] { proactive };
                    break;

                case "reactive-tc":
                    cost.Name = "ReActive TC";
                    cost.Value = model.ReActiveTC;
                    cost.CostBlocks = blocks;
                    break;

                case "reactive-tp":
                    cost.Name = "ReActive TP";
                    cost.Value = model.ReActiveTP;
                    cost.CostBlocks = blocks;
                    break;

                case "tc":
                    cost.Name = "Service TC";
                    cost.Value = model.ServiceTC;
                    cost.CostBlocks = blocks;
                    break;

                case "tp":
                    cost.Name = "Service TP";
                    cost.Value = model.ServiceTP;
                    cost.CostBlocks = blocks;
                    break;

                default:
                    throw new System.ArgumentException("what");
            }

            return cost;
        }

        public PlausiCost GetStdwDetails(bool approved, long cnt, long wg)
        {
            var model = new GetHwStdwById(_repositorySet).Execute(approved, cnt, wg);
            var details = new GetHwStdwDetailsById(_repositorySet).Execute(approved, cnt, wg);

            var cost = new PlausiCost
            {
                Name = "Standard warranty",
                Fsp = model.StdFsp,
                Country = model.Country,
                Wg = model.Wg,
                Sog = model.Sog,

                Availability = model.Availability,
                Duration = model.Duration,
                ReactionTime = model.ReactionTime,
                ReactionType = model.ReactionType,
                ServiceLocation = model.ServiceLocation,
                ProActiveSla = model.ProActiveSla,

                StdWarranty = model.StdWarranty,
                StdWarrantyLocation = model.StdWarrantyLocation,

                Currency = model.Currency,
                ExchangeRate = model.ExchangeRate,
                Value = model.LocalServiceStandardWarranty
            };

            cost.CostBlocks = new PlausiCostBlock[]
            {
                new PlausiCostBlock { Name = "Field service cost", Value = model.FieldServiceW, CostElements = AsElements(details, "Field Service Cost") },
                new PlausiCostBlock { Name = "Service support cost", Value = model.ServiceSupportW, CostElements = AsElements(details, "Service support cost") },
                new PlausiCostBlock { Name = "Logistics cost", Value = model.LogisticW, CostElements = AsElements(details, "Logistics Cost") },
                new PlausiCostBlock { Name = "Tax & duties", Value = model.TaxAndDutiesW, CostElements = AsElements(details, "Tax & duties") },
                new PlausiCostBlock { Name = "Markup for standard warranty", Value = model.MarkupStandardWarranty, Mandatory = false, CostElements = AsElements(details, "Markup for standard warranty") },
                new PlausiCostBlock { Name = "Availability fee", Value = model.Fee, Mandatory = false, CostElements = AsElements(details, "Availability fee") },
            };

            return cost;
        }

        public PlausiCost GetStdCreditDetails(bool approved, long cnt, long wg)
        {
            var model = new GetHwStdwById(_repositorySet).Execute(approved, cnt, wg);
            var details = new GetHwStdwDetailsById(_repositorySet).Execute(approved, cnt, wg);

            var cost = new PlausiCost
            {
                Name = "Credits",
                Fsp = model.StdFsp,
                Country = model.Country,
                Wg = model.Wg,
                Sog = model.Sog,

                Availability = model.Availability,
                Duration = model.Duration,
                ReactionTime = model.ReactionTime,
                ReactionType = model.ReactionType,
                ServiceLocation = model.ServiceLocation,
                ProActiveSla = model.ProActiveSla,

                StdWarranty = model.StdWarranty,
                StdWarrantyLocation = model.StdWarrantyLocation,

                Currency = model.Currency,
                ExchangeRate = model.ExchangeRate,
                Value = model.Credits
            };

            cost.CostBlocks = new PlausiCostBlock[]
            {
                new PlausiCostBlock { Name = "Field service cost", Value = model.FieldServiceW, CostElements = AsElements(details, "Field Service Cost") },
                new PlausiCostBlock { Name = "Service support cost", Value = model.ServiceSupportW, CostElements = AsElements(details, "Service support cost") },
                new PlausiCostBlock { Name = "Logistics cost", Value = model.LogisticW, CostElements = AsElements(details, "Logistics Cost") },
                new PlausiCostBlock { Name = "Tax & duties", Value = model.TaxAndDutiesW, CostElements = AsElements(details, "Tax & duties") },
                new PlausiCostBlock { Name = "Markup for standard warranty", Value = model.MarkupStandardWarranty, Mandatory = false, CostElements = AsElements(details, "Markup for standard warranty") },
                new PlausiCostBlock { Name = "Availability fee", Value = model.Fee, Mandatory = false, CostElements = AsElements(details, "Availability fee") },
            };

            return cost;
        }

        public PlausiCostSw GetSwCostDetails(bool approved, long id, string what)
        {
            var model = new GetSwCostById(_repositorySet).Execute(approved, id);
            var details = new GetSwCostDetailsById(_repositorySet).Execute(approved, id);

            var cost = new PlausiCostSw
            {
                Fsp = model.Fsp,
                Sog = model.Sog,
                Digit = model.SwDigit,
                Availability = model.Availability,
                Duration = model.Duration,
            };

            var blocks = new PlausiCostBlock[]
            {
                new PlausiCostBlock { Name = "Service support cost", Value = model.ServiceSupport, CostElements = AsElements(details, "Service support cost") },
                new PlausiCostBlock { Name = "SW / SP Maintenance", Value = model.MaintenanceListPrice, CostElements = AsElements(details, "SW / SP Maintenance") }
            };

            switch (what)
            {
                case "service-support":
                    cost.Name = "Service support cost";
                    cost.Value = model.ServiceSupport;
                    cost.CostBlocks = blocks;
                    break;

                case "reinsurance":
                    cost.Name = "Reinsurance";
                    cost.Value = model.Reinsurance;
                    cost.CostBlocks = blocks;
                    break;

                case "transfer":
                    cost.Name = "Transfer price";
                    cost.Value = model.TransferPrice;
                    cost.CostBlocks = blocks;
                    break;

                case "maintenance":
                    cost.Name = "Maintenance list price";
                    cost.Value = model.MaintenanceListPrice;
                    cost.CostBlocks = blocks;
                    break;

                case "dealer":
                    cost.Name = "Dealer reference price";
                    cost.Value = model.DealerPrice;
                    cost.CostBlocks = blocks;
                    break;

                default:
                    throw new System.ArgumentException("what");
            }

            return cost;
        }

        public PlausiCostSw GetSwProactiveCostDetails(bool approved, long id, string fsp)
        {
            var model = new GetSwProactiveCostsById(_repositorySet).Execute(approved, id, fsp);
            var details = new GetSwProactiveCostDetailsById(_repositorySet).Execute(approved, id, fsp);

            var cost = new PlausiCostSw
            {
                Name = "ProActive",
                Fsp = model.Fsp,
                Country = model.Country,
                Digit = model.SwDigit,
                Sog = model.Sog,
                Availability = model.Availability,
                Duration = model.Year,
                Value = model.ProActive
            };

            cost.CostBlocks = new PlausiCostBlock[]
            {
                new PlausiCostBlock { Name = "ProActive", Value = model.ProActive, CostElements = AsElements(details, "ProActive") }
            };

            return cost;
        }

        public PlausiCost GetHddCostDetails(bool approved, long id)
        {
            var repo = this._repositorySet.GetRepository<HddRetentionView>();

            var model = repo.GetAll()
                            .Where(x => x.WgId == id)
                            .Select(x => new
                            {
                                Wg = x.Wg,
                                Sog = x.Sog,
                                HddRetention = approved ? x.HddRet_Approved : x.HddRet,
                            })
                            .First();

            var details = new GetHwHddCostDetailsById(_repositorySet).Execute(approved, id);

            var cost = new PlausiCost
            {
                Name = "Hdd retention",
                Wg = model.Wg,
                Sog = model.Sog,
                Currency = "EUR",
                ExchangeRate = 1.0,
                Value = model.HddRetention
            };

            cost.CostBlocks = new PlausiCostBlock[]
            {
                new PlausiCostBlock { Name = "Hdd retention", Value = model.HddRetention, CostElements = AsElements(details, "Hdd retention") }
            };

            return cost;
        }

        private IEnumerable<PlausiCostElement> AsElements(List<GetHwCostDetailsById.CostDetailDto> details, string costBlock)
        {
            for (var i = 0; i < details.Count; i++)
            {
                var x = details[i];
                if (string.Compare(x.CostBlock, costBlock, true) == 0)
                {
                    yield return new PlausiCostElement
                    {
                        Name = x.CostElement,
                        Dependency = x.Dependency,
                        Value = x.Value,
                        Mandatory = x.Mandatory,
                        Level = x.Level
                    };
                }
            }
        }
    }

    public class PlausiCost
    {
        public string Name { get; internal set; }

        public string Fsp { get; set; }

        public string Country { get; set; }

        public string Currency { get; set; }

        public double? ExchangeRate { get; set; }

        public string Wg { get; set; }

        public string Sog { get; set; }

        public string Availability { get; set; }

        public string Duration { get; set; }

        public string ReactionType { get; set; }

        public string ReactionTime { get; set; }

        public string ServiceLocation { get; set; }

        public string ProActiveSla { get; set; }

        public int StdWarranty { get; set; }

        public string StdWarrantyLocation { get; set; }

        public double? Value { get; set; }

        public PlausiCostBlock[] CostBlocks { get; set; }
    }

    public class PlausiCostSw
    {
        public string Name { get;  set; }

        public string Country { get; set; }

        public string Fsp { get; set; }

        public string Digit { get; set; }

        public string Sog { get; set; }

        public string Availability { get; set; }

        public string Duration { get; set; }

        public double? Value { get; set; }

        public PlausiCostBlock[] CostBlocks { get; set; }
    }


    public class PlausiCostBlock
    {
        public string Name { get; set; }
        public double? Value { get; set; }
        public bool Mandatory { get; set; }
        public IEnumerable<PlausiCostElement> CostElements { get; set; }
        public PlausiCostBlock()
        {
            this.Mandatory = true;
        }
    }

    public class PlausiCostElement
    {
        public string Name { get; set; }
        public string Value { get; set; }
        public string Dependency { get; set; }
        public string Level { get; set; }
        public bool Mandatory { get; set; }
    }
}
