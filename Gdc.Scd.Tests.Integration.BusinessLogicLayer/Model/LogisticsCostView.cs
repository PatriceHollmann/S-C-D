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
    using System.Collections.Generic;
    
    public partial class LogisticsCostView
    {
        public long Country { get; set; }
        public long Wg { get; set; }
        public Nullable<long> ReactionType { get; set; }
        public Nullable<long> ReactionTime { get; set; }
        public Nullable<double> StandardHandling { get; set; }
        public Nullable<double> StandardHandling_Approved { get; set; }
        public Nullable<double> HighAvailabilityHandling { get; set; }
        public Nullable<double> HighAvailabilityHandling_Approved { get; set; }
        public Nullable<double> StandardDelivery { get; set; }
        public Nullable<double> StandardDelivery_Approved { get; set; }
        public Nullable<double> ExpressDelivery { get; set; }
        public Nullable<double> ExpressDelivery_Approved { get; set; }
        public Nullable<double> TaxiCourierDelivery { get; set; }
        public Nullable<double> TaxiCourierDelivery_Approved { get; set; }
        public Nullable<double> ReturnDeliveryFactory { get; set; }
        public Nullable<double> ReturnDeliveryFactory_Approved { get; set; }
    }
}