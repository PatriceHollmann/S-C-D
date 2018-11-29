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
    
    public partial class MatrixRule
    {
        public long Id { get; set; }
        public Nullable<long> AvailabilityId { get; set; }
        public bool CorePortfolio { get; set; }
        public Nullable<long> CountryId { get; set; }
        public Nullable<long> DurationId { get; set; }
        public bool FujitsuGlobalPortfolio { get; set; }
        public bool MasterPortfolio { get; set; }
        public Nullable<long> ReactionTimeId { get; set; }
        public Nullable<long> ReactionTypeId { get; set; }
        public Nullable<long> ServiceLocationId { get; set; }
        public Nullable<long> WgId { get; set; }
    
        public virtual Availability Availability { get; set; }
        public virtual Duration Duration { get; set; }
        public virtual ReactionTime ReactionTime { get; set; }
        public virtual ReactionType ReactionType { get; set; }
        public virtual ServiceLocation ServiceLocation { get; set; }
        public virtual Country Country { get; set; }
        public virtual Wg Wg { get; set; }
    }
}