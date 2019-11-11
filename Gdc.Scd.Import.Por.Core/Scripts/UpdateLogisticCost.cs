﻿// ------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version: 15.0.0.0
//  
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
// ------------------------------------------------------------------------------
namespace Gdc.Scd.Import.Por.Core.Scripts
{
    using System;
    
    /// <summary>
    /// Class to produce the template output
    /// </summary>
    
    #line 1 "C:\Dev\SCD\Gdc.Scd.Import.Por.Core\Scripts\UpdateLogisticCost.tt"
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("Microsoft.VisualStudio.TextTemplating", "15.0.0.0")]
    public partial class UpdateLogisticCost : BaseUpdateCost
    {
#line hidden
        /// <summary>
        /// Create the template output
        /// </summary>
        public override string TransformText()
        {
            this.Write("\r\ndeclare @wg dbo.ListID;\r\ninsert into @wg(id) select id from InputAtoms.Wg where" +
                    " Deactivated = 0 and UPPER(name) in (");
            
            #line 4 "C:\Dev\SCD\Gdc.Scd.Import.Por.Core\Scripts\UpdateLogisticCost.tt"
 PrintNames(); 
            
            #line default
            #line hidden
            this.Write(@")

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp;
IF OBJECT_ID('tempdb..#tmpMin') IS NOT NULL DROP TABLE #tmpMin;

select c.* into #tmp
from Hardware.LogisticsCosts c
where c.Deactivated = 0 and not exists(select * from @wg where Id = c.Wg);

create index ix_tmp_Country_SLA on #tmp(Country, ");
            
            #line 13 "C:\Dev\SCD\Gdc.Scd.Import.Por.Core\Scripts\UpdateLogisticCost.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(this.field));
            
            #line default
            #line hidden
            this.Write(", ReactionTimeType);\r\n\r\nselect    t.Country\r\n        , t.");
            
            #line 16 "C:\Dev\SCD\Gdc.Scd.Import.Por.Core\Scripts\UpdateLogisticCost.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(this.field));
            
            #line default
            #line hidden
            this.Write("\r\n        , t.ReactionTimeType\r\n\r\n        , case when min(StandardHandling) = max" +
                    "(StandardHandling) then min(StandardHandling) else null end as StandardHandling\r" +
                    "\n        , case when min(HighAvailabilityHandling) = max(HighAvailabilityHandlin" +
                    "g) then min(HighAvailabilityHandling) else null end as HighAvailabilityHandling\r" +
                    "\n        , case when min(StandardDelivery) = max(StandardDelivery) then min(Stan" +
                    "dardDelivery) else null end as StandardDelivery\r\n        , case when min(Express" +
                    "Delivery) = max(ExpressDelivery) then min(ExpressDelivery) else null end as Expr" +
                    "essDelivery\r\n        , case when min(TaxiCourierDelivery) = max(TaxiCourierDeliv" +
                    "ery) then min(TaxiCourierDelivery) else null end as TaxiCourierDelivery\r\n       " +
                    " , case when min(ReturnDeliveryFactory) = max(ReturnDeliveryFactory) then min(Re" +
                    "turnDeliveryFactory) else null end as ReturnDeliveryFactory\r\n\r\n        , case wh" +
                    "en min(StandardHandling_Approved) = max(StandardHandling_Approved) then min(Stan" +
                    "dardHandling_Approved) else null end as StandardHandling_Approved\r\n        , cas" +
                    "e when min(HighAvailabilityHandling_Approved) = max(HighAvailabilityHandling_App" +
                    "roved) then min(HighAvailabilityHandling_Approved) else null end as HighAvailabi" +
                    "lityHandling_Approved\r\n        , case when min(StandardDelivery_Approved) = max(" +
                    "StandardDelivery_Approved) then min(StandardDelivery_Approved) else null end as " +
                    "StandardDelivery_Approved\r\n        , case when min(ExpressDelivery_Approved) = m" +
                    "ax(ExpressDelivery_Approved) then min(ExpressDelivery_Approved) else null end as" +
                    " ExpressDelivery_Approved\r\n        , case when min(TaxiCourierDelivery_Approved)" +
                    " = max(TaxiCourierDelivery_Approved) then min(TaxiCourierDelivery_Approved) else" +
                    " null end as TaxiCourierDelivery_Approved\r\n        , case when min(ReturnDeliver" +
                    "yFactory_Approved) = max(ReturnDeliveryFactory_Approved) then min(ReturnDelivery" +
                    "Factory_Approved) else null end as ReturnDeliveryFactory_Approved\r\n\r\ninto #tmpMi" +
                    "n\r\nfrom #tmp t\r\ngroup by t.Country, t.");
            
            #line 35 "C:\Dev\SCD\Gdc.Scd.Import.Por.Core\Scripts\UpdateLogisticCost.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(this.field));
            
            #line default
            #line hidden
            this.Write(", t.ReactionTimeType\r\n\r\ncreate index ix_tmpmin_Country_SLA on #tmp(Country, ");
            
            #line 37 "C:\Dev\SCD\Gdc.Scd.Import.Por.Core\Scripts\UpdateLogisticCost.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(this.field));
            
            #line default
            #line hidden
            this.Write(@", ReactionTimeType);

update c set
      StandardHandling = coalesce(t.StandardHandling, c.StandardHandling) 
    , HighAvailabilityHandling = coalesce(t.HighAvailabilityHandling, c.HighAvailabilityHandling) 
    , StandardDelivery = coalesce(t.StandardDelivery, c.StandardDelivery) 
    , ExpressDelivery = coalesce(t.ExpressDelivery, c.ExpressDelivery) 
    , TaxiCourierDelivery = coalesce(t.TaxiCourierDelivery, c.TaxiCourierDelivery) 
    , ReturnDeliveryFactory = coalesce(t.ReturnDeliveryFactory, c.ReturnDeliveryFactory) 

    , StandardHandling_Approved = coalesce(t.StandardHandling_Approved, c.StandardHandling_Approved) 
    , HighAvailabilityHandling_Approved = coalesce(t.HighAvailabilityHandling_Approved, c.HighAvailabilityHandling_Approved) 
    , StandardDelivery_Approved = coalesce(t.StandardDelivery_Approved, c.StandardDelivery_Approved) 
    , ExpressDelivery_Approved = coalesce(t.ExpressDelivery_Approved, c.ExpressDelivery_Approved) 
    , TaxiCourierDelivery_Approved = coalesce(t.TaxiCourierDelivery_Approved, c.TaxiCourierDelivery_Approved) 
    , ReturnDeliveryFactory_Approved = coalesce(t.ReturnDeliveryFactory_Approved, c.ReturnDeliveryFactory_Approved) 

from Hardware.LogisticsCosts c
inner join #tmpMin t on t.Country = c.Country and t.");
            
            #line 55 "C:\Dev\SCD\Gdc.Scd.Import.Por.Core\Scripts\UpdateLogisticCost.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(this.field));
            
            #line default
            #line hidden
            this.Write(" = c.");
            
            #line 55 "C:\Dev\SCD\Gdc.Scd.Import.Por.Core\Scripts\UpdateLogisticCost.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(this.field));
            
            #line default
            #line hidden
            this.Write(" and t.ReactionTimeType = c.ReactionTimeType\r\nwhere c.Deactivated = 0 and exists(" +
                    "select * from @wg where Id = c.Wg);\r\n\r\nIF OBJECT_ID(\'tempdb..#tmp\') IS NOT NULL " +
                    "DROP TABLE #tmp\r\nIF OBJECT_ID(\'tempdb..#tmpMin\') IS NOT NULL DROP TABLE #tmpMin;" +
                    "\r\n");
            return this.GenerationEnvironment.ToString();
        }
    }
    
    #line default
    #line hidden
}
