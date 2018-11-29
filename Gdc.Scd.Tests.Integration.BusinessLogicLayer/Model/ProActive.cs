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
    
    public partial class ProActive
    {
        public long Id { get; set; }
        public long Country { get; set; }
        public long Pla { get; set; }
        public long Wg { get; set; }
        public Nullable<double> LocalRemoteAccessSetupPreparationEffort { get; set; }
        public Nullable<double> LocalRegularUpdateReadyEffort { get; set; }
        public Nullable<double> LocalPreparationShcEffort { get; set; }
        public Nullable<double> CentralExecutionShcReportCost { get; set; }
        public Nullable<double> LocalRemoteShcCustomerBriefingEffort { get; set; }
        public Nullable<double> LocalOnSiteShcCustomerBriefingEffort { get; set; }
        public Nullable<double> TravellingTime { get; set; }
        public Nullable<double> OnSiteHourlyRate { get; set; }
        public Nullable<double> LocalRemoteAccessSetupPreparationEffort_Approved { get; set; }
        public Nullable<double> LocalRegularUpdateReadyEffort_Approved { get; set; }
        public Nullable<double> LocalPreparationShcEffort_Approved { get; set; }
        public Nullable<double> CentralExecutionShcReportCost_Approved { get; set; }
        public Nullable<double> LocalRemoteShcCustomerBriefingEffort_Approved { get; set; }
        public Nullable<double> LocalOnSiteShcCustomerBriefingEffort_Approved { get; set; }
        public Nullable<double> TravellingTime_Approved { get; set; }
        public Nullable<double> OnSiteHourlyRate_Approved { get; set; }
        public System.DateTime CreatedDateTime { get; set; }
        public Nullable<System.DateTime> DeactivatedDateTime { get; set; }
    
        public virtual Country Country1 { get; set; }
        public virtual Pla Pla1 { get; set; }
        public virtual Wg Wg1 { get; set; }
    }
}