
ALTER FUNCTION [Hardware].[GetCalcMember] (
    @approved       bit,
    @cnt            dbo.ListID readonly,
    @wg             dbo.ListID readonly,
    @av             dbo.ListID readonly,
    @dur            dbo.ListID readonly,
    @reactiontime   dbo.ListID readonly,
    @reactiontype   dbo.ListID readonly,
    @loc            dbo.ListID readonly,
    @pro            dbo.ListID readonly,
    @lastid         bigint,
    @limit          int
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT    m.rownum
            , m.Id

            --SLA

            , m.Fsp
            , m.CountryId          
            , std.Country
            , std.CurrencyId
            , std.Currency
            , std.ExchangeRate
            , m.WgId
            , std.Wg
            , std.SogId
            , std.Sog
            , m.DurationId
            , dur.Name             as Duration
            , dur.Value            as Year
            , dur.IsProlongation   as IsProlongation
            , m.AvailabilityId
            , av.Name              as Availability
            , m.ReactionTimeId
            , rtime.Name           as ReactionTime
            , m.ReactionTypeId
            , rtype.Name           as ReactionType
            , m.ServiceLocationId
            , loc.Name             as ServiceLocation
            , m.ProActiveSlaId
            , prosla.ExternalName  as ProActiveSla

            , m.Sla
            , m.SlaHash

            , std.StdWarranty
            , std.StdWarrantyLocation

            --Cost values

            , std.AFR1  
            , std.AFR2  
            , std.AFR3  
            , std.AFR4  
            , std.AFR5  
            , std.AFRP1 

            , std.MatCost1
            , std.MatCost2
            , std.MatCost3
            , std.MatCost4
            , std.MatCost5
            , std.MatCost1P

            , std.MatOow1 
            , std.MatOow2 
            , std.MatOow3 
            , std.MatOow4 
            , std.MatOow5 
            , std.MatOow1p

            , std.MaterialW

            , std.TaxAndDuties1
            , std.TaxAndDuties2
            , std.TaxAndDuties3
            , std.TaxAndDuties4
            , std.TaxAndDuties5
            , std.TaxAndDuties1P

            , std.TaxOow1 
            , std.TaxOow2 
            , std.TaxOow3 
            , std.TaxOow4 
            , std.TaxOow5 
            , std.TaxOow1P
            
            , std.TaxAndDutiesW

            , ISNULL(case when @approved = 0 then r.Cost else r.Cost_approved end, 0) as Reinsurance

            --##### FIELD SERVICE COST #########                                                                                               
            , case when @approved = 0 

                   then (1 - fst.TimeAndMaterialShare_norm) * (fsc.TravelCost + fsc.LabourCost + fst.PerformanceRate) / std.ExchangeRate + 
                            fst.TimeAndMaterialShare_norm * ((fsc.TravelTime + fsc.repairTime) * std.OnsiteHourlyRates + fst.PerformanceRate / std.ExchangeRate) 

                   else (1 - fst.TimeAndMaterialShare_norm_Approved) * (fsc.TravelCost_Approved + fsc.LabourCost_Approved + fst.PerformanceRate_Approved) / std.ExchangeRate + 
                            fst.TimeAndMaterialShare_norm_Approved * ((fsc.TravelTime_Approved + fsc.repairTime_Approved) * std.OnsiteHourlyRates + fst.PerformanceRate_Approved / std.ExchangeRate) 

               end as FieldServicePerYear

            --##### SERVICE SUPPORT COST #########                                                                                               
            , std.ServiceSupportPerYear

            --##### LOGISTICS COST #########                                                                                               
            , case when @approved = 0 
                   then lc.ExpressDelivery          +
                        lc.HighAvailabilityHandling +
                        lc.StandardDelivery         +
                        lc.StandardHandling         +
                        lc.ReturnDeliveryFactory    +
                        lc.TaxiCourierDelivery      
                   else lc.ExpressDelivery_Approved          +
                        lc.HighAvailabilityHandling_Approved +
                        lc.StandardDelivery_Approved         +
                        lc.StandardHandling_Approved         +
                        lc.ReturnDeliveryFactory_Approved    +
                        lc.TaxiCourierDelivery_Approved     
                end / std.ExchangeRate as LogisticPerYear

                                                                                                                       
            , case when afEx.id is not null then std.Fee else 0 end as AvailabilityFee

            , case when @approved = 0 
                    then (case when dur.IsProlongation = 0 then moc.Markup else moc.ProlongationMarkup end)                             
                    else (case when dur.IsProlongation = 0 then moc.Markup_Approved else moc.ProlongationMarkup_Approved end)                      
                end / std.ExchangeRate as MarkupOtherCost                      
            , case when @approved = 0 
                    then (case when dur.IsProlongation = 0 then moc.MarkupFactor_norm else moc.ProlongationMarkupFactor_norm end)                             
                    else (case when dur.IsProlongation = 0 then moc.MarkupFactor_norm_Approved else moc.ProlongationMarkupFactor_norm_Approved end)                      
                end as MarkupFactorOtherCost                

            --####### PROACTIVE COST ###################
            , case when proSla.Name = '0' 
                    then 0 --we don't calc proactive(none)
                    else std.LocalRemoteAccessSetup + dur.Value * (
                                      std.LocalRegularUpdate * proSla.LocalRegularUpdateReadyRepetition                
                                    + std.LocalPreparation * proSla.LocalPreparationShcRepetition                      
                                    + std.LocalRemoteCustomerBriefing * proSla.LocalRemoteShcCustomerBriefingRepetition
                                    + std.LocalOnsiteCustomerBriefing * proSla.LocalOnsiteShcCustomerBriefingRepetition
                                    + std.Travel * proSla.TravellingTimeRepetition                                     
                                    + std.CentralExecutionReport * proSla.CentralExecutionShcReportRepetition          
                                )
                end as ProActive

            , std.LocalServiceStandardWarranty
            , std.LocalServiceStandardWarrantyManual
            , std.Credit1
            , std.Credit2
            , std.Credit3
            , std.Credit4
            , std.Credit5
            , std.Credits

            --########## MANUAL COSTS ################
            , man.ListPrice          / std.ExchangeRate as ListPrice                   
            , man.DealerDiscount                        as DealerDiscount              
            , man.DealerPrice        / std.ExchangeRate as DealerPrice                 
            , case when std.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTC     / std.ExchangeRate) end as ServiceTCManual                   
            , case when std.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTP     / std.ExchangeRate) end as ServiceTPManual                   
            , man.ServiceTP_Released / std.ExchangeRate as ServiceTP_Released                  

            , man.ReleaseDate                           as ReleaseDate
            , u2.Name                                   as ReleaseUserName
            , u2.Email                                  as ReleaseUserEmail

            , man.ChangeDate                            
            , u.Name                                    as ChangeUserName
            , u.Email                                   as ChangeUserEmail

    FROM Hardware.CalcStdw(@approved, @cnt, @wg) std 

    INNER JOIN Portfolio.GetBySlaPaging(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m on std.CountryId = m.CountryId and std.WgId = m.WgId 

    INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

    INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId

    INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

    INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId
   
    INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

    INNER JOIN Dependencies.ProActiveSla prosla on prosla.id = m.ProActiveSlaId

    LEFT JOIN Hardware.ReinsuranceCalc r on r.Wg = m.WgId AND r.Duration = m.DurationId AND r.ReactionTimeAvailability = m.ReactionTime_Avalability

    LEFT JOIN Hardware.FieldServiceCalc fsc ON fsc.Country = m.CountryId AND fsc.Wg = m.WgId AND fsc.ServiceLocation = m.ServiceLocationId
    LEFT JOIN Hardware.FieldServiceTimeCalc fst ON fst.Country = m.CountryId AND fst.Wg = m.WgId AND fst.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lc on lc.Country = m.CountryId AND lc.Wg = m.WgId AND lc.ReactionTimeType = m.ReactionTime_ReactionType and lc.Deactivated = 0

    LEFT JOIN Hardware.MarkupOtherCosts moc on moc.Country = m.CountryId AND moc.Wg = m.WgId AND moc.ReactionTimeTypeAvailability = m.ReactionTime_ReactionType_Avalability and moc.Deactivated = 0

    LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId AND afEx.ReactionTimeId = m.ReactionTimeId AND afEx.ReactionTypeId = m.ReactionTypeId AND afEx.ServiceLocationId = m.ServiceLocationId

    LEFT JOIN Hardware.ManualCost man on man.PortfolioId = m.Id

    LEFT JOIN dbo.[User] u on u.Id = man.ChangeUserId

    LEFT JOIN dbo.[User] u2 on u2.Id = man.ReleaseUserId
)
GO

ALTER FUNCTION [Hardware].[GetCalcMember2] (
    @approved       bit,
    @cnt            dbo.ListID readonly,
    @fsp            nvarchar(255),
    @hasFsp         bit,
    @wg             dbo.ListID readonly,
    @av             dbo.ListID readonly,
    @dur            dbo.ListID readonly,
    @reactiontime   dbo.ListID readonly,
    @reactiontype   dbo.ListID readonly,
    @loc            dbo.ListID readonly,
    @pro            dbo.ListID readonly,
    @lastid         bigint,
    @limit          int
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT    m.rownum
            , m.Id

            --SLA

            , m.Fsp
            , m.CountryId          
            , std.Country
            , std.CurrencyId
            , std.Currency
            , std.ExchangeRate
            , m.WgId
            , std.Wg
            , std.SogId
            , std.Sog
            , m.DurationId
            , dur.Name             as Duration
            , dur.Value            as Year
            , dur.IsProlongation   as IsProlongation
            , m.AvailabilityId
            , av.Name              as Availability
            , m.ReactionTimeId
            , rtime.Name           as ReactionTime
            , m.ReactionTypeId
            , rtype.Name           as ReactionType
            , m.ServiceLocationId
            , loc.Name             as ServiceLocation
            , m.ProActiveSlaId
            , prosla.ExternalName  as ProActiveSla

            , m.Sla
            , m.SlaHash

            , std.StdWarranty
            , std.StdWarrantyLocation

            --Cost values

            , std.AFR1  
            , std.AFR2  
            , std.AFR3  
            , std.AFR4  
            , std.AFR5  
            , std.AFRP1 

            , std.MatCost1
            , std.MatCost2
            , std.MatCost3
            , std.MatCost4
            , std.MatCost5
            , std.MatCost1P

            , std.MatOow1 
            , std.MatOow2 
            , std.MatOow3 
            , std.MatOow4 
            , std.MatOow5 
            , std.MatOow1p

            , std.MaterialW

            , std.TaxAndDuties1
            , std.TaxAndDuties2
            , std.TaxAndDuties3
            , std.TaxAndDuties4
            , std.TaxAndDuties5
            , std.TaxAndDuties1P

            , std.TaxOow1 
            , std.TaxOow2 
            , std.TaxOow3 
            , std.TaxOow4 
            , std.TaxOow5 
            , std.TaxOow1P
            
            , std.TaxAndDutiesW

            , ISNULL(case when @approved = 0 then r.Cost else r.Cost_approved end, 0) as Reinsurance

            --##### FIELD SERVICE COST #########                                                                                               
            , case when @approved = 0 

                   then (1 - fst.TimeAndMaterialShare_norm) * (fsc.TravelCost + fsc.LabourCost + fst.PerformanceRate) / std.ExchangeRate + 
                            fst.TimeAndMaterialShare_norm * ((fsc.TravelTime + fsc.repairTime) * std.OnsiteHourlyRates + fst.PerformanceRate / std.ExchangeRate) 

                   else (1 - fst.TimeAndMaterialShare_norm_Approved) * (fsc.TravelCost_Approved + fsc.LabourCost_Approved + fst.PerformanceRate_Approved) / std.ExchangeRate + 
                            fst.TimeAndMaterialShare_norm_Approved * ((fsc.TravelTime_Approved + fsc.repairTime_Approved) * std.OnsiteHourlyRates + fst.PerformanceRate_Approved / std.ExchangeRate) 

               end as FieldServicePerYear

            --##### SERVICE SUPPORT COST #########                                                                                               
            , std.ServiceSupportPerYear

            --##### LOGISTICS COST #########                                                                                               
            , case when @approved = 0 
                   then lc.ExpressDelivery          +
                        lc.HighAvailabilityHandling +
                        lc.StandardDelivery         +
                        lc.StandardHandling         +
                        lc.ReturnDeliveryFactory    +
                        lc.TaxiCourierDelivery      
                   else lc.ExpressDelivery_Approved          +
                        lc.HighAvailabilityHandling_Approved +
                        lc.StandardDelivery_Approved         +
                        lc.StandardHandling_Approved         +
                        lc.ReturnDeliveryFactory_Approved    +
                        lc.TaxiCourierDelivery_Approved     
                end / std.ExchangeRate as LogisticPerYear

                                                                                                                       
            , case when afEx.id is not null then std.Fee else 0 end as AvailabilityFee

            , case when @approved = 0 
                    then (case when dur.IsProlongation = 0 then moc.Markup else moc.ProlongationMarkup end)                             
                    else (case when dur.IsProlongation = 0 then moc.Markup_Approved else moc.ProlongationMarkup_Approved end)                      
                end / std.ExchangeRate as MarkupOtherCost                      
            , case when @approved = 0 
                    then (case when dur.IsProlongation = 0 then moc.MarkupFactor_norm else moc.ProlongationMarkupFactor_norm end)                             
                    else (case when dur.IsProlongation = 0 then moc.MarkupFactor_norm_Approved else moc.ProlongationMarkupFactor_norm_Approved end)                      
                end as MarkupFactorOtherCost                

            --####### PROACTIVE COST ###################
            , case when proSla.Name = '0' 
                    then 0 --we don't calc proactive(none)
                    else std.LocalRemoteAccessSetup + dur.Value * (
                                      std.LocalRegularUpdate * proSla.LocalRegularUpdateReadyRepetition                
                                    + std.LocalPreparation * proSla.LocalPreparationShcRepetition                      
                                    + std.LocalRemoteCustomerBriefing * proSla.LocalRemoteShcCustomerBriefingRepetition
                                    + std.LocalOnsiteCustomerBriefing * proSla.LocalOnsiteShcCustomerBriefingRepetition
                                    + std.Travel * proSla.TravellingTimeRepetition                                     
                                    + std.CentralExecutionReport * proSla.CentralExecutionShcReportRepetition          
                                )
                end as ProActive

            , std.LocalServiceStandardWarranty
            , std.LocalServiceStandardWarrantyManual
            , std.Credit1
            , std.Credit2
            , std.Credit3
            , std.Credit4
            , std.Credit5
            , std.Credits

            --########## MANUAL COSTS ################
            , man.ListPrice          / std.ExchangeRate as ListPrice                   
            , man.DealerDiscount                        as DealerDiscount              
            , man.DealerPrice        / std.ExchangeRate as DealerPrice                 
            , case when std.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTC     / std.ExchangeRate) end as ServiceTCManual                   
            , case when std.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTP     / std.ExchangeRate) end as ServiceTPManual                   
            , man.ServiceTP_Released / std.ExchangeRate as ServiceTP_Released                  

            , man.ReleaseDate                           as ReleaseDate
            , u2.Name                                   as ReleaseUserName
            , u2.Email                                  as ReleaseUserEmail

            , man.ChangeDate                            
            , u.Name                                    as ChangeUserName
            , u.Email                                   as ChangeUserEmail

    FROM Hardware.CalcStdw(@approved, @cnt, @wg) std 

    INNER JOIN Portfolio.GetBySlaFspPaging(@cnt, @fsp, @hasFsp, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m on std.CountryId = m.CountryId and std.WgId = m.WgId 

    INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

    INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId

    INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

    INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId
   
    INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

    INNER JOIN Dependencies.ProActiveSla prosla on prosla.id = m.ProActiveSlaId

    LEFT JOIN Hardware.ReinsuranceCalc r on r.Wg = m.WgId AND r.Duration = m.DurationId AND r.ReactionTimeAvailability = m.ReactionTime_Avalability

    LEFT JOIN Hardware.FieldServiceCalc fsc ON fsc.Country = m.CountryId AND fsc.Wg = m.WgId AND fsc.ServiceLocation = m.ServiceLocationId
    LEFT JOIN Hardware.FieldServiceTimeCalc fst ON fst.Country = m.CountryId AND fst.Wg = m.WgId AND fst.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lc on lc.Country = m.CountryId AND lc.Wg = m.WgId AND lc.ReactionTimeType = m.ReactionTime_ReactionType and lc.Deactivated = 0

    LEFT JOIN Hardware.MarkupOtherCosts moc on moc.Country = m.CountryId AND moc.Wg = m.WgId AND moc.ReactionTimeTypeAvailability = m.ReactionTime_ReactionType_Avalability and moc.Deactivated = 0

    LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId AND afEx.ReactionTimeId = m.ReactionTimeId AND afEx.ReactionTypeId = m.ReactionTypeId AND afEx.ServiceLocationId = m.ServiceLocationId

    LEFT JOIN Hardware.ManualCost man on man.PortfolioId = m.Id

    LEFT JOIN dbo.[User] u on u.Id = man.ChangeUserId

    LEFT JOIN dbo.[User] u2 on u2.Id = man.ReleaseUserId
)
GO

ALTER function [SODA].[GetHw]()
returns @tbl table(
      Country             nvarchar(64)
    , CountryGroup        nvarchar(64)
    , Fsp                 nvarchar(64)
    , Sog                 nvarchar(64)
    , Wg                  nvarchar(64)
    , TP_Released         float
    , TP_Manual           float
    , ListPrice           float
    , DealerDiscount      float
    , DealerPrice         float
    , ProActive           float
    , ReleaseDate         datetime
    , UserName            nvarchar(64)
    , UserEmail           nvarchar(64)
)
as
begin

    declare @cnt table (
          Id bigint not null INDEX IX1 CLUSTERED
        , Name nvarchar(255)
        , ISO3CountryCode nvarchar(255)
        , CountryGroup nvarchar(255)
        , ExchangeRate float
        , CanOverrideTransferCostAndPrice bit
        , CanStoreListAndDealerPrices     bit
    );
    insert into @cnt
    select  c.Id
        , c.Name as Country
        , c.ISO3CountryCode
        , cg.Name
        , er.Value
        , c.CanOverrideTransferCostAndPrice
        , c.CanStoreListAndDealerPrices
    from InputAtoms.Country c 
    left join InputAtoms.CountryGroup cg on cg.id = c.CountryGroupId
    left join [References].ExchangeRate er on er.CurrencyId = c.CurrencyId;

    declare @wg table (
          Id bigint not null INDEX IX1 CLUSTERED
        , Name nvarchar(8)
        , Sog  nvarchar(8)
    );
    insert into @wg
    select wg.Id, wg.Name, sog.Name
    from InputAtoms.Wg wg
    left join InputAtoms.Sog sog on sog.Id = wg.SogId
    where wg.Deactivated = 0 and wg.WgType = 1;

    insert into @tbl
    select 
              c.Name as Country
            , c.CountryGroup
      
            , fsp.Name as Fsp

            , wg.Sog
            , wg.Name as Wg

            , man.ServiceTP_Released / c.ExchangeRate   as TP_Released
            , case when c.CanOverrideTransferCostAndPrice = 1 then (man.ServiceTP / c.ExchangeRate) end     as TP_Manual                   

            , case when CanStoreListAndDealerPrices = 1 then man.ListPrice          / c.ExchangeRate end    as ListPrice                   
            , case when CanStoreListAndDealerPrices = 1 then man.DealerDiscount                      end    as DealerDiscount              
            , case when CanStoreListAndDealerPrices = 1 then man.DealerPrice        / c.ExchangeRate end    as DealerPrice                 

            --####### PROACTIVE COST ###############################################################################################################################
            , case when proSla.Name = '0' 
                    then 0 --we don't calc proactive(none)
                    else pro.LocalRemoteAccessSetupPreparationEffort_Approved * pro.OnSiteHourlyRate_Approved + dur.Value * (

                                  pro.LocalRegularUpdateReadyEffort_Approved        * proSla.LocalRegularUpdateReadyRepetition        * pro.OnSiteHourlyRate_Approved       
                                + pro.LocalPreparationShcEffort_Approved            * proSla.LocalPreparationShcRepetition            * pro.OnSiteHourlyRate_Approved         
                                + pro.LocalRemoteShcCustomerBriefingEffort_Approved * proSla.LocalRemoteShcCustomerBriefingRepetition * pro.OnSiteHourlyRate_Approved
                                + pro.LocalOnSiteShcCustomerBriefingEffort_Approved * proSla.LocalOnsiteShcCustomerBriefingRepetition * pro.OnSiteHourlyRate_Approved
                                + pro.TravellingTime_Approved                       * proSla.TravellingTimeRepetition                 * pro.OnSiteHourlyRate_Approved                   
                                + pro.CentralExecutionShcReportCost_Approved        * proSla.CentralExecutionShcReportRepetition          

                            ) 
                end as ProActive
            --######################################################################################################################################################
            , man.ReleaseDate                           as ReleaseDate
            , u.Name                                    as UserName
            , u.Email                                   as UserEmail

    from Hardware.ManualCost man
    join Portfolio.LocalPortfolio p on p.Id = man.PortfolioId
    join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = p.SlaHash and p.Sla = p.Sla

    join @cnt c on c.id = p.CountryId
    join @wg wg on wg.id = p.WgId
    join Dependencies.Duration dur on dur.id = p.DurationId
    join Dependencies.ProActiveSla proSla on proSla.id = p.ProactiveSlaId

    left join Hardware.ProActive pro ON pro.Country= p.CountryId and pro.Wg = p.WgId and pro.Deactivated = 0

    left join dbo.[User] u on u.Id = man.ChangeUserId

    where man.ServiceTP_Released is not null;

    return;

end
GO

ALTER PROCEDURE [Report].[spProActive]
(
    @cnt          bigint,
    @wg           bigint,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint,
    @lastid       bigint,
    @limit        int
)
AS
BEGIN

    declare @cntGroup nvarchar(255) = (select Name from InputAtoms.CountryGroup where Id = (select CountryGroupId from InputAtoms.Country where id = @cnt))

    declare @cntTable dbo.ListId; insert into @cntTable(id) values(@cnt);

    declare @wg_SOG_Table dbo.ListId;
    insert into @wg_SOG_Table
    select id
        from InputAtoms.Wg 
        where SogId in (select wg.SogId from InputAtoms.Wg wg where @wg is null or wg.Id = @wg)
        and IsSoftware = 0
        and SogId is not null
        and Deactivated = 0;

    if not exists(select id from @wg_SOG_Table) return;

    declare @avTable dbo.ListId; if @av is not null insert into @avTable(id) values(@av);

    declare @durTable dbo.ListId; if @dur is not null insert into @durTable(id) values(@dur);

    declare @rtimeTable dbo.ListId; if @reactiontime is not null insert into @rtimeTable(id) values(@reactiontime);

    declare @rtypeTable dbo.ListId; if @reactiontype is not null insert into @rtypeTable(id) values(@reactiontype);

    declare @locTable dbo.ListId; if @loc is not null insert into @locTable(id) values(@loc);

    declare @proTable dbo.ListId; if @pro is not null insert into @proTable(id) values(@pro);
    
    with cte as (
        select m.* 
               , case when m.IsProlongation = 1 then 'Prolongation' else CAST(m.Year as varchar(1)) end as ServicePeriod
        from Hardware.GetCostsSlaSog(1, @cntTable, @wg_SOG_Table, @avTable, @durTable, @rtimeTable, @rtypeTable, @locTable, @proTable) m
        where @wg is null or m.WgId = @wg
    )
    , cte2 as (
        select  
                ROW_NUMBER() over(ORDER BY (SELECT 1)) as rownum

                , m.*
                , fsp.Name as Fsp
                , fsp.ServiceDescription as FspDescription

        from cte m
        left join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla and fsp.IsStandardWarranty <> 1
    )
    select    m.Id
            , m.Country
            , @cntGroup as CountryGroup
            , m.Fsp
            , m.Wg

            , m.ServiceLocation
            , m.ReactionTime
            , m.ReactionType
            , m.Availability
            , m.ProActiveSla

            , m.ServicePeriod as Duration

             , m.ServiceTpSog * m.ExchangeRate as ReActive
             , m.ProActiveSog * m.ExchangeRate as ProActive
             , (m.ServiceTpSog + coalesce(m.ProActiveSog, 0)) * m.ExchangeRate as ServiceTP

            , m.Currency

            , sog.Name as Sog
            , sog.Description as SogDescription

            , m.FspDescription
    from cte2 m
    JOIN InputAtoms.Sog sog on Sog.Id = m.SogId

    where (@limit is null) or (m.rownum > @lastid and m.rownum <= @lastid + @limit);

END
go
