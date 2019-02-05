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
    
    public partial class Wg1
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Wg1()
        {
            this.HwFspCodeTranslations = new HashSet<HwFspCodeTranslation>();
            this.HwHddFspCodeTranslations = new HashSet<HwHddFspCodeTranslation>();
            this.AFRs = new HashSet<AFR>();
            this.AvailabilityFee1 = new HashSet<AvailabilityFee1>();
            this.FieldServiceCosts = new HashSet<FieldServiceCost>();
            this.HddRetentions = new HashSet<HddRetention>();
            this.InstallBases = new HashSet<InstallBase>();
            this.LogisticsCosts = new HashSet<LogisticsCost>();
            this.MarkupOtherCosts = new HashSet<MarkupOtherCost>();
            this.MarkupStandardWaranties = new HashSet<MarkupStandardWaranty>();
            this.MaterialCostOows = new HashSet<MaterialCostOow>();
            this.MaterialCostOowCalcs = new HashSet<MaterialCostOowCalc>();
            this.MaterialCostOowEmeias = new HashSet<MaterialCostOowEmeia>();
            this.MaterialCostWarranties = new HashSet<MaterialCostWarranty>();
            this.ProActives = new HashSet<ProActive>();
            this.ProlongationMarkups = new HashSet<ProlongationMarkup>();
            this.Reinsurances = new HashSet<Reinsurance>();
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
            this.AvailabilityFeeCalcs = new HashSet<AvailabilityFeeCalc>();
            this.HwStandardWarranties = new HashSet<HwStandardWarranty>();
            this.Wgs = new HashSet<Wg>();
            this.LocalPortfolios = new HashSet<LocalPortfolio>();
            this.PrincipalPortfolios = new HashSet<PrincipalPortfolio>();
        }
    
        public long Id { get; set; }
        public string Alignment { get; set; }
        public Nullable<long> CentralContractGroupId { get; set; }
        public System.DateTime CreatedDateTime { get; set; }
        public Nullable<System.DateTime> DeactivatedDateTime { get; set; }
        public string Description { get; set; }
        public bool ExistsInLogisticsDb { get; set; }
        public string FabGrp { get; set; }
        public bool IsDeactivatedInLogistic { get; set; }
        public bool IsSoftware { get; set; }
        public System.DateTime ModifiedDateTime { get; set; }
        public string Name { get; set; }
        public long PlaId { get; set; }
        public string ResponsiblePerson { get; set; }
        public Nullable<long> RoleCodeId { get; set; }
        public string SCD_ServiceType { get; set; }
        public Nullable<long> SFabId { get; set; }
        public Nullable<long> SogId { get; set; }
        public int WgType { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<HwFspCodeTranslation> HwFspCodeTranslations { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<HwHddFspCodeTranslation> HwHddFspCodeTranslations { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<AFR> AFRs { get; set; }
        public virtual AfrYear AfrYear { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<AvailabilityFee1> AvailabilityFee1 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<FieldServiceCost> FieldServiceCosts { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<HddRetention> HddRetentions { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<InstallBase> InstallBases { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<LogisticsCost> LogisticsCosts { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MarkupOtherCost> MarkupOtherCosts { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MarkupStandardWaranty> MarkupStandardWaranties { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MaterialCostOow> MaterialCostOows { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MaterialCostOowCalc> MaterialCostOowCalcs { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MaterialCostOowEmeia> MaterialCostOowEmeias { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MaterialCostWarranty> MaterialCostWarranties { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProActive> ProActives { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ProlongationMarkup> ProlongationMarkups { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Reinsurance> Reinsurances { get; set; }
        public virtual ReinsuranceYear ReinsuranceYear { get; set; }
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
        public virtual CentralContractGroup1 CentralContractGroup1 { get; set; }
        public virtual Pla1 Pla1 { get; set; }
        public virtual RoleCode1 RoleCode1 { get; set; }
        public virtual Sfab1 Sfab1 { get; set; }
        public virtual Sog1 Sog1 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<AvailabilityFeeCalc> AvailabilityFeeCalcs { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<HwStandardWarranty> HwStandardWarranties { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Wg> Wgs { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<LocalPortfolio> LocalPortfolios { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PrincipalPortfolio> PrincipalPortfolios { get; set; }
    }
}
