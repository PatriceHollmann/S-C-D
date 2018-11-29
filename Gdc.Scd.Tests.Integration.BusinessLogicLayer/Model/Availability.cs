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
            this.HwFspCodeTranslations = new HashSet<HwFspCodeTranslation>();
            this.Matrices = new HashSet<Matrix>();
            this.MatrixMasters = new HashSet<MatrixMaster>();
            this.MatrixRules = new HashSet<MatrixRule>();
            this.ReactionTime_Avalability = new HashSet<ReactionTime_Avalability>();
            this.ReactionTime_ReactionType_Avalability = new HashSet<ReactionTime_ReactionType_Avalability>();
            this.SwSpMaintenances = new HashSet<SwSpMaintenance>();
            this.SwFspCodeTranslations = new HashSet<SwFspCodeTranslation>();
            this.Year_Availability = new HashSet<Year_Availability>();
        }
    
        public long Id { get; set; }
        public string ExternalName { get; set; }
        public string Name { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<HwFspCodeTranslation> HwFspCodeTranslations { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Matrix> Matrices { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MatrixMaster> MatrixMasters { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MatrixRule> MatrixRules { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ReactionTime_Avalability> ReactionTime_Avalability { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<ReactionTime_ReactionType_Avalability> ReactionTime_ReactionType_Avalability { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SwSpMaintenance> SwSpMaintenances { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SwFspCodeTranslation> SwFspCodeTranslations { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Year_Availability> Year_Availability { get; set; }
    }
}