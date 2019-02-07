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
    
    public partial class CostBlockHistory
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public CostBlockHistory()
        {
            this.Hardware_AFR = new HashSet<Hardware_AFR>();
            this.Hardware_AvailabilityFee = new HashSet<Hardware_AvailabilityFee>();
            this.Hardware_FieldServiceCost = new HashSet<Hardware_FieldServiceCost>();
            this.Hardware_HddRetention = new HashSet<Hardware_HddRetention>();
            this.Hardware_InstallBase = new HashSet<Hardware_InstallBase>();
            this.Hardware_LogisticsCosts = new HashSet<Hardware_LogisticsCosts>();
            this.Hardware_MarkupOtherCosts = new HashSet<Hardware_MarkupOtherCosts>();
            this.Hardware_MarkupStandardWaranty = new HashSet<Hardware_MarkupStandardWaranty>();
            this.Hardware_MaterialCostOow = new HashSet<Hardware_MaterialCostOow>();
            this.Hardware_MaterialCostOowEmeia = new HashSet<Hardware_MaterialCostOowEmeia>();
            this.Hardware_MaterialCostWarranty = new HashSet<Hardware_MaterialCostWarranty>();
            this.Hardware_ProActive = new HashSet<Hardware_ProActive>();
            this.Hardware_ProlongationMarkup = new HashSet<Hardware_ProlongationMarkup>();
            this.Hardware_Reinsurance = new HashSet<Hardware_Reinsurance>();
            this.Hardware_RoleCodeHourlyRates = new HashSet<Hardware_RoleCodeHourlyRates>();
            this.Hardware_ServiceSupportCost = new HashSet<Hardware_ServiceSupportCost>();
            this.SoftwareSolution_ProActiveSw = new HashSet<SoftwareSolution_ProActiveSw>();
            this.SoftwareSolution_SwSpMaintenance = new HashSet<SoftwareSolution_SwSpMaintenance>();
        }
    
        public long Id { get; set; }
        public Nullable<System.DateTime> ApproveRejectDate { get; set; }
        public Nullable<long> ApproveRejectUserId { get; set; }
        public System.DateTime EditDate { get; set; }
        public int EditItemCount { get; set; }
        public Nullable<long> EditUserId { get; set; }
        public int EditorType { get; set; }
        public bool HasQualityGateErrors { get; set; }
        public bool IsDifferentValues { get; set; }
        public string QualityGateErrorExplanation { get; set; }
        public string RejectMessage { get; set; }
        public int State { get; set; }
        public string Context_ApplicationId { get; set; }
        public string Context_CostBlockId { get; set; }
        public string Context_CostElementId { get; set; }
        public string Context_InputLevelId { get; set; }
        public Nullable<long> Context_RegionInputId { get; set; }
    
        public virtual User User { get; set; }
        public virtual User User1 { get; set; }
        public virtual Availability1 Availability1 { get; set; }
        public virtual CentralContractGroup CentralContractGroup { get; set; }
        public virtual ClusterPla ClusterPla { get; set; }
        public virtual ClusterRegion ClusterRegion { get; set; }
        public virtual Country Country { get; set; }
        public virtual DurationAvailability DurationAvailability { get; set; }
        public virtual EmeiaCountry EmeiaCountry { get; set; }
        public virtual NonEmeiaCountry NonEmeiaCountry { get; set; }
        public virtual Pla Pla { get; set; }
        public virtual ReactionTimeAvailability ReactionTimeAvailability { get; set; }
        public virtual ReactionTimeTypeAvailability ReactionTimeTypeAvailability { get; set; }
        public virtual ReactionTimeType ReactionTimeType { get; set; }
        public virtual RoleCode RoleCode { get; set; }
        public virtual ServiceLocation1 ServiceLocation1 { get; set; }
        public virtual Sfab Sfab { get; set; }
        public virtual Sog Sog { get; set; }
        public virtual SwDigit SwDigit { get; set; }
        public virtual Wg Wg { get; set; }
        public virtual Year1 Year1 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_AFR> Hardware_AFR { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_AvailabilityFee> Hardware_AvailabilityFee { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_FieldServiceCost> Hardware_FieldServiceCost { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_HddRetention> Hardware_HddRetention { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_InstallBase> Hardware_InstallBase { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_LogisticsCosts> Hardware_LogisticsCosts { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_MarkupOtherCosts> Hardware_MarkupOtherCosts { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_MarkupStandardWaranty> Hardware_MarkupStandardWaranty { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_MaterialCostOow> Hardware_MaterialCostOow { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_MaterialCostOowEmeia> Hardware_MaterialCostOowEmeia { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_MaterialCostWarranty> Hardware_MaterialCostWarranty { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_ProActive> Hardware_ProActive { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_ProlongationMarkup> Hardware_ProlongationMarkup { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_Reinsurance> Hardware_Reinsurance { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_RoleCodeHourlyRates> Hardware_RoleCodeHourlyRates { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Hardware_ServiceSupportCost> Hardware_ServiceSupportCost { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SoftwareSolution_ProActiveSw> SoftwareSolution_ProActiveSw { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SoftwareSolution_SwSpMaintenance> SoftwareSolution_SwSpMaintenance { get; set; }
    }
}
