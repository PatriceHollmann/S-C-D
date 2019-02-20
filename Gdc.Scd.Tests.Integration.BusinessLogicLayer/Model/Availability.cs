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
    
    public partial class Availability
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Availability()
        {
            this.Duration_Availability = new HashSet<Duration_Availability>();
            this.Availability1 = new HashSet<Availability1>();
            this.SoftwareSolution_SwSpMaintenance = new HashSet<SoftwareSolution_SwSpMaintenance>();
            this.HwFspCodeTranslations = new HashSet<HwFspCodeTranslation>();
            this.LocalPortfolios = new HashSet<LocalPortfolio>();
            this.PrincipalPortfolios = new HashSet<PrincipalPortfolio>();
            this.ReactionTime_Avalability = new HashSet<ReactionTime_Avalability>();
            this.ReactionTime_ReactionType_Avalability = new HashSet<ReactionTime_ReactionType_Avalability>();
            this.SwSpMaintenances = new HashSet<SwSpMaintenance>();
            this.SwFspCodeTranslations = new HashSet<SwFspCodeTranslation>();
        }
    
        public long Id { get; set; }
        public string ExternalName { get; set; }
        public string Name { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Duration_Availability> Duration_Availability { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Availability1> Availability1 { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SoftwareSolution_SwSpMaintenance> SoftwareSolution_SwSpMaintenance { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<HwFspCodeTranslation> HwFspCodeTranslations { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<LocalPortfolio> LocalPortfolios { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PrincipalPortfolio> PrincipalPortfolios { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ReactionTime_Avalability> ReactionTime_Avalability { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ReactionTime_ReactionType_Avalability> ReactionTime_ReactionType_Avalability { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SwSpMaintenance> SwSpMaintenances { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SwFspCodeTranslation> SwFspCodeTranslations { get; set; }
    }
}
