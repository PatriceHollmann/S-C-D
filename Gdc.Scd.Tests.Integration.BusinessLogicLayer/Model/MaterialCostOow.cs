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
    
    public partial class MaterialCostOow
    {
        public long Id { get; set; }
        public long Wg { get; set; }
        public long ClusterRegion { get; set; }
        public Nullable<double> MaterialCostOow1 { get; set; }
        public Nullable<double> MaterialCostOow_Approved { get; set; }
        public System.DateTime CreatedDateTime { get; set; }
        public Nullable<System.DateTime> DeactivatedDateTime { get; set; }
    
        public virtual ClusterRegion ClusterRegion1 { get; set; }
        public virtual Wg Wg1 { get; set; }
    }
}