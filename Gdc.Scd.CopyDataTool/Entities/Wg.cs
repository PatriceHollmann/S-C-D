//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Gdc.Scd.CopyDataTool.Entities
{
    using System;
    using System.Collections.Generic;
    
    public partial class Wg
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Wg()
        {
            this.StandardWarrantyManualCost = new HashSet<StandardWarrantyManualCost>();
            this.LocalPortfolio = new HashSet<LocalPortfolio>();
            this.PrincipalPortfolio = new HashSet<PrincipalPortfolio>();
        }
    
        public long Id { get; set; }
        public string Alignment { get; set; }
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
        public Nullable<long> RoleCodeId { get; set; }
        public string SCD_ServiceType { get; set; }
        public Nullable<long> SFabId { get; set; }
        public Nullable<long> SogId { get; set; }
        public int WgType { get; set; }
        public string ResponsiblePerson { get; set; }
        public Nullable<long> CentralContractGroupId { get; set; }
        public bool PsmRelease { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<StandardWarrantyManualCost> StandardWarrantyManualCost { get; set; }
        public virtual CentralContractGroup CentralContractGroup { get; set; }
        public virtual Pla Pla { get; set; }
        public virtual RoleCode RoleCode { get; set; }
        public virtual Sfab Sfab { get; set; }
        public virtual Sog Sog { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<LocalPortfolio> LocalPortfolio { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<PrincipalPortfolio> PrincipalPortfolio { get; set; }
    }
}
