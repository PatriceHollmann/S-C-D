//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Gdc.Scd.Tests.Integration.BusinessLogicLayer.Model
{
    using System;
    
    public partial class LogisticCostCalcCountry_Result
    {
        public long Id { get; set; }
        public string Region { get; set; }
        public string Country { get; set; }
        public string Wg { get; set; }
        public string ServiceLevel { get; set; }
        public string ReactionTime { get; set; }
        public string ReactionType { get; set; }
        public string Duration { get; set; }
        public string Availability { get; set; }
        public Nullable<double> ServiceTC { get; set; }
        public Nullable<double> Handling { get; set; }
        public Nullable<double> TaxAndDutiesW { get; set; }
        public Nullable<double> TaxAndDutiesOow { get; set; }
        public Nullable<double> LogisticW { get; set; }
        public Nullable<int> LogisticOow { get; set; }
        public Nullable<double> Fee { get; set; }
    }
}
