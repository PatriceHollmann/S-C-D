USE [SCD_2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [Report].[CalcParameterHw]
(
    @cnt bigint,
    @wg bigint,
    @av bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc bigint,
    @pro bigint
)
RETURNS TABLE 
AS
RETURN (
    with CostCte as (
            select 
                m.Id
              , c.Name as Country
              , wg.Description as WgDescription
              , wg.Name as Wg
              , wg.SogDescription
              , wg.SCD_ServiceType
              , pro.ExternalName as Sla
              , loc.Name as ServiceLocation
              , rtime.Name as ReactionTime
              , rtype.Name as ReactionType
              , av.Name as Availability
              , c.Currency

             --FSP
              , fsp.Name Fsp
              , fsp.ServiceDescription as FspDescription

              --cost blocks

              , fsc.LabourCost_Approved as LabourCost
              , fsc.TravelCost_Approved as TravelCost
              , fsc.PerformanceRate_Approved as PerformanceRate
              , fsc.TravelTime_Approved as TravelTime
              , fsc.RepairTime_Approved as RepairTime
              , fsc.OnsiteHourlyRates_Approved as OnsiteHourlyRate

              , lc.StandardHandling_Approved as StandardHandling

              , lc.StandardHandling_Approved + 
                lc.HighAvailabilityHandling_Approved + 
                lc.StandardDelivery_Approved + 
                lc.ExpressDelivery_Approved + 
                lc.TaxiCourierDelivery_Approved + 
                lc.ReturnDeliveryFactory_Approved as LogisticPerYear

              , case when afEx.id is not null then af.Fee_Approved else 0 end as AvailabilityFee
      
              , tax.TaxAndDuties_Approved as TaxAndDutiesW

              , moc.Markup_Approved       as MarkupOtherCost
              , moc.MarkupFactor_Approved as MarkupFactorOtherCost

              , msw.MarkupFactorStandardWarranty_Approved as MarkupFactorStandardWarranty
              , msw.MarkupStandardWarranty_Approved       as MarkupStandardWarranty
      
              , afr.AFR1_Approved  as AFR1
              , afr.AFR2_Approved  as AFR2
              , afr.AFR3_Approved  as AFR3
              , afr.AFR4_Approved  as AFR4
              , afr.AFR5_Approved  as AFR5
              , afr.AFRP1_Approved as AFRP1

              , Hardware.CalcFieldServiceCost(
                            fsc.TimeAndMaterialShare_Approved, 
                            fsc.TravelCost_Approved, 
                            fsc.LabourCost_Approved, 
                            fsc.PerformanceRate_Approved, 
                            fsc.TravelTime_Approved, 
                            fsc.RepairTime_Approved, 
                            fsc.OnsiteHourlyRates_Approved, 
                            1
                        ) as FieldServicePerYear

              , ssc.[1stLevelSupportCosts_Approved]           as [1stLevelSupportCosts]
              , ssc.[2ndLevelSupportCosts_Approved]           as [2ndLevelSupportCosts]
           
              , r.ReinsuranceFlatfee1_Approved                as ReinsuranceFlatfee1
              , r.ReinsuranceFlatfee2_Approved                as ReinsuranceFlatfee2
              , r.ReinsuranceFlatfee3_Approved                as ReinsuranceFlatfee3
              , r.ReinsuranceFlatfee4_Approved                as ReinsuranceFlatfee4
              , r.ReinsuranceFlatfee5_Approved                as ReinsuranceFlatfee5
              , r.ReinsuranceFlatfeeP1_Approved               as ReinsuranceFlatfeeP1
              , r.ReinsuranceUpliftFactor_4h_24x7_Approved    as ReinsuranceUpliftFactor_4h_24x7
              , r.ReinsuranceUpliftFactor_4h_9x5_Approved     as ReinsuranceUpliftFactor_4h_9x5
              , r.ReinsuranceUpliftFactor_NBD_9x5_Approved    as ReinsuranceUpliftFactor_NBD_9x5

              , mcw.MaterialCostWarranty_Approved as MaterialCostWarranty
              , mco.MaterialCostOow_Approved as MaterialCostOow

              , dur.Value as Duration
              , dur.IsProlongation

        from Portfolio.GetBySla(@cnt, @wg, @av, null, @reactiontime, @reactiontype, @loc, @pro) m

        INNER JOIN InputAtoms.CountryView c on c.Id = m.CountryId

        INNER JOIN InputAtoms.WgSogView wg on wg.id = m.WgId

        INNER JOIN InputAtoms.WgView wg2 on wg2.Id = m.WgId

        INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId and dur.IsProlongation = 0

        INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

        INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

        INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId

        INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

        INNER JOIN Dependencies.ProActiveSla pro on pro.Id = m.ProActiveSlaId

        LEFT JOIN Hardware.AfrYear afr on afr.Wg = m.WgId

        --cost blocks
        LEFT JOIN Hardware.FieldServiceCostView fsc ON fsc.Wg = m.WgId 
                                                AND fsc.Country = m.CountryId 
                                                AND fsc.ServiceLocation = m.ServiceLocationId
                                                AND fsc.ReactionTypeId = m.ReactionTypeId
                                                AND fsc.ReactionTimeId = m.ReactionTimeId

        LEFT JOIN Hardware.LogisticsCostView lc on lc.Country = m.CountryId 
                                            AND lc.Wg = m.WgId
                                            AND lc.ReactionTime = m.ReactionTimeId
                                            AND lc.ReactionType = m.ReactionTypeId

        LEFT JOIN Hardware.TaxAndDutiesView tax on tax.Country = m.CountryId

        LEFT JOIN Hardware.MaterialCostWarranty mcw on mcw.Wg = m.WgId AND mcw.ClusterRegion = c.ClusterRegionId

        LEFT JOIN Hardware.MaterialCostOowCalc mco on mco.Wg = m.WgId AND mco.Country = m.CountryId

        LEFT JOIN Hardware.ServiceSupportCostView ssc on ssc.Country = m.CountryId and ssc.ClusterPla = wg2.ClusterPla

        LEFT JOIN Hardware.ReinsuranceYear r on r.Wg = m.WgId

        LEFT JOIN Hardware.MarkupOtherCostsView moc on moc.Wg = m.WgId 
                                                   AND moc.Country = m.CountryId 
                                                   AND moc.ReactionTimeId = m.ReactionTimeId 
                                                   AND moc.ReactionTypeId = m.ReactionTypeId 
                                                   AND moc.AvailabilityId = m.AvailabilityId

        LEFT JOIN Hardware.MarkupStandardWarantyView msw on msw.Wg = m.WgId 
                                                        AND msw.Country = m.CountryId 
                                                        AND msw.ReactionTimeId = m.ReactionTimeId 
                                                        AND msw.ReactionTypeId = m.ReactionTypeId 
                                                        AND msw.AvailabilityId = m.AvailabilityId

        LEFT JOIN Hardware.AvailabilityFeeCalc af on af.Country = m.CountryId AND af.Wg = m.WgId

        LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId 
                                            AND afEx.ReactionTimeId = m.ReactionTimeId 
                                            AND afEx.ReactionTypeId = m.ReactionTypeId 
                                            AND afEx.ServiceLocationId = m.ServiceLocationId

        LEFT JOIN Fsp.HwFspCodeTranslation fsp  on fsp.SlaHash = m.SlaHash 
                                               and fsp.CountryId = m.CountryId
                                               and fsp.WgId = m.WgId
                                               and fsp.AvailabilityId = m.AvailabilityId
                                               and fsp.DurationId= m.DurationId
                                               and fsp.ReactionTimeId = m.ReactionTimeId
                                               and fsp.ReactionTypeId = m.ReactionTypeId
                                               and fsp.ServiceLocationId = m.ServiceLocationId
                                               and fsp.ProactiveSlaId = m.ProActiveSlaId
    )
    select    
                m.Id
              , m.Country
              , m.WgDescription
              , m.Wg
              , m.SogDescription
              , m.SCD_ServiceType
              , m.Sla
              , m.ServiceLocation
              , m.ReactionTime
              , m.ReactionType
              , m.Availability
              , m.Currency

             --FSP
              , m.Fsp
              , m.FspDescription

              --cost blocks

              , m.LabourCost
              , m.TravelCost
              , m.PerformanceRate
              , m.TravelTime
              , m.RepairTime
              , m.OnsiteHourlyRate

              , m.StandardHandling

              , m.AvailabilityFee
      
              , m.TaxAndDutiesW

              , m.MarkupOtherCost
              , m.MarkupFactorOtherCost

              , m.MarkupFactorStandardWarranty
              , m.MarkupStandardWarranty
      
              , m.AFR1   * 100 as AFR1
              , m.AFR2   * 100 as AFR2
              , m.AFR3   * 100 as AFR3
              , m.AFR4   * 100 as AFR4
              , m.AFR5   * 100 as AFR5
              , m.AFRP1  * 100 as AFRP1

              , m.[1stLevelSupportCosts]
              , m.[2ndLevelSupportCosts]
           
              , m.ReinsuranceFlatfee1
              , m.ReinsuranceFlatfee2
              , m.ReinsuranceFlatfee3
              , m.ReinsuranceFlatfee4
              , m.ReinsuranceFlatfee5
              , m.ReinsuranceFlatfeeP1
              , m.ReinsuranceUpliftFactor_4h_24x7
              , m.ReinsuranceUpliftFactor_4h_9x5
              , m.ReinsuranceUpliftFactor_NBD_9x5

              , m.MaterialCostWarranty
              , m.MaterialCostOow

              , m.Duration

             , m.FieldServicePerYear * m.AFR1 as FieldServiceCost1
             , m.FieldServicePerYear * m.AFR2 as FieldServiceCost2
             , m.FieldServicePerYear * m.AFR3 as FieldServiceCost3
             , m.FieldServicePerYear * m.AFR4 as FieldServiceCost4
             , m.FieldServicePerYear * m.AFR5 as FieldServiceCost5
            
             , Hardware.CalcByDur(
                       m.Duration
                     , m.IsProlongation 
                     , m.LogisticPerYear * m.AFR1 
                     , m.LogisticPerYear * m.AFR2 
                     , m.LogisticPerYear * m.AFR3 
                     , m.LogisticPerYear * m.AFR4 
                     , m.LogisticPerYear * m.AFR5 
                     , m.LogisticPerYear * m.AFRP1
                 ) as LogisticTransportcost

    from CostCte m
)
GO

ALTER FUNCTION [Report].[CalcParameterHwNotApproved]
(
    @cnt bigint,
    @wg bigint,
    @av bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc bigint,
    @pro bigint
)
RETURNS TABLE 
AS
RETURN (
    with CostCte as (
            select 
                m.Id
              , c.Name as Country
              , wg.Description as WgDescription
              , wg.Name as Wg
              , wg.SogDescription
              , wg.SCD_ServiceType
              , pro.ExternalName as Sla
              , loc.Name as ServiceLocation
              , rtime.Name as ReactionTime
              , rtype.Name as ReactionType
              , av.Name as Availability
              , c.Currency

             --FSP
              , fsp.Name Fsp
              , fsp.ServiceDescription as FspDescription

              --cost blocks

              , fsc.LabourCost as LabourCost
              , fsc.TravelCost as TravelCost
              , fsc.PerformanceRate as PerformanceRate
              , fsc.TravelTime as TravelTime
              , fsc.RepairTime as RepairTime
              , fsc.OnsiteHourlyRates as OnsiteHourlyRate

              , lc.StandardHandling as StandardHandling

              , lc.StandardHandling + 
                lc.HighAvailabilityHandling + 
                lc.StandardDelivery + 
                lc.ExpressDelivery + 
                lc.TaxiCourierDelivery + 
                lc.ReturnDeliveryFactory as LogisticPerYear

              , case when afEx.id is not null then af.Fee else 0 end as AvailabilityFee
      
              , tax.TaxAndDuties as TaxAndDutiesW

              , moc.Markup       as MarkupOtherCost
              , moc.MarkupFactor as MarkupFactorOtherCost

              , msw.MarkupFactorStandardWarranty as MarkupFactorStandardWarranty
              , msw.MarkupStandardWarranty       as MarkupStandardWarranty
      
              , afr.AFR1  as AFR1
              , afr.AFR2  as AFR2
              , afr.AFR3  as AFR3
              , afr.AFR4  as AFR4
              , afr.AFR5  as AFR5
              , afr.AFRP1 as AFRP1

              , Hardware.CalcFieldServiceCost(
                            fsc.TimeAndMaterialShare, 
                            fsc.TravelCost, 
                            fsc.LabourCost, 
                            fsc.PerformanceRate, 
                            fsc.TravelTime, 
                            fsc.RepairTime, 
                            fsc.OnsiteHourlyRates, 
                            1
                        ) as FieldServicePerYear

              , ssc.[1stLevelSupportCosts]           as [1stLevelSupportCosts]
              , ssc.[2ndLevelSupportCosts]           as [2ndLevelSupportCosts]
           
              , r.ReinsuranceFlatfee1                as ReinsuranceFlatfee1
              , r.ReinsuranceFlatfee2                as ReinsuranceFlatfee2
              , r.ReinsuranceFlatfee3                as ReinsuranceFlatfee3
              , r.ReinsuranceFlatfee4                as ReinsuranceFlatfee4
              , r.ReinsuranceFlatfee5                as ReinsuranceFlatfee5
              , r.ReinsuranceFlatfeeP1               as ReinsuranceFlatfeeP1
              , r.ReinsuranceUpliftFactor_4h_24x7    as ReinsuranceUpliftFactor_4h_24x7
              , r.ReinsuranceUpliftFactor_4h_9x5     as ReinsuranceUpliftFactor_4h_9x5
              , r.ReinsuranceUpliftFactor_NBD_9x5    as ReinsuranceUpliftFactor_NBD_9x5

              , mcw.MaterialCostWarranty as MaterialCostWarranty
              , mco.MaterialCostOow as MaterialCostOow

              , dur.Value as Duration
              , dur.IsProlongation

        from Portfolio.GetBySla(@cnt, @wg, @av, null, @reactiontime, @reactiontype, @loc, @pro) m

        INNER JOIN InputAtoms.CountryView c on c.Id = m.CountryId

        INNER JOIN InputAtoms.WgSogView wg on wg.id = m.WgId

        INNER JOIN InputAtoms.WgView wg2 on wg2.Id = m.WgId

        INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId and dur.IsProlongation = 0

        INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

        INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

        INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId

        INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

        INNER JOIN Dependencies.ProActiveSla pro on pro.Id = m.ProActiveSlaId

        LEFT JOIN Hardware.AfrYear afr on afr.Wg = m.WgId

        --cost blocks
        LEFT JOIN Hardware.FieldServiceCostView fsc ON fsc.Wg = m.WgId 
                                                AND fsc.Country = m.CountryId 
                                                AND fsc.ServiceLocation = m.ServiceLocationId
                                                AND fsc.ReactionTypeId = m.ReactionTypeId
                                                AND fsc.ReactionTimeId = m.ReactionTimeId

        LEFT JOIN Hardware.LogisticsCostView lc on lc.Country = m.CountryId 
                                            AND lc.Wg = m.WgId
                                            AND lc.ReactionTime = m.ReactionTimeId
                                            AND lc.ReactionType = m.ReactionTypeId

        LEFT JOIN Hardware.TaxAndDutiesView tax on tax.Country = m.CountryId

        LEFT JOIN Hardware.MaterialCostWarranty mcw on mcw.Wg = m.WgId AND mcw.ClusterRegion = c.ClusterRegionId

        LEFT JOIN Hardware.MaterialCostOowCalc mco on mco.Wg = m.WgId AND mco.Country = m.CountryId

        LEFT JOIN Hardware.ServiceSupportCostView ssc on ssc.Country = m.CountryId and ssc.ClusterPla = wg2.ClusterPla

        LEFT JOIN Hardware.ReinsuranceYear r on r.Wg = m.WgId

        LEFT JOIN Hardware.MarkupOtherCostsView moc on moc.Wg = m.WgId 
                                                   AND moc.Country = m.CountryId 
                                                   AND moc.ReactionTimeId = m.ReactionTimeId 
                                                   AND moc.ReactionTypeId = m.ReactionTypeId 
                                                   AND moc.AvailabilityId = m.AvailabilityId

        LEFT JOIN Hardware.MarkupStandardWarantyView msw on msw.Wg = m.WgId 
                                                        AND msw.Country = m.CountryId 
                                                        AND msw.ReactionTimeId = m.ReactionTimeId 
                                                        AND msw.ReactionTypeId = m.ReactionTypeId 
                                                        AND msw.AvailabilityId = m.AvailabilityId

        LEFT JOIN Hardware.AvailabilityFeeCalc af on af.Country = m.CountryId AND af.Wg = m.WgId

        LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId 
                                            AND afEx.ReactionTimeId = m.ReactionTimeId 
                                            AND afEx.ReactionTypeId = m.ReactionTypeId 
                                            AND afEx.ServiceLocationId = m.ServiceLocationId

        LEFT JOIN Fsp.HwFspCodeTranslation fsp  on fsp.SlaHash = m.SlaHash 
                                               and fsp.CountryId = m.CountryId
                                               and fsp.WgId = m.WgId
                                               and fsp.AvailabilityId = m.AvailabilityId
                                               and fsp.DurationId= m.DurationId
                                               and fsp.ReactionTimeId = m.ReactionTimeId
                                               and fsp.ReactionTypeId = m.ReactionTypeId
                                               and fsp.ServiceLocationId = m.ServiceLocationId
                                               and fsp.ProactiveSlaId = m.ProActiveSlaId
    )
    select    
                m.Id
              , m.Country
              , m.WgDescription
              , m.Wg
              , m.SogDescription
              , m.SCD_ServiceType
              , m.Sla
              , m.ServiceLocation
              , m.ReactionTime
              , m.ReactionType
              , m.Availability
              , m.Currency

             --FSP
              , m.Fsp
              , m.FspDescription

              --cost blocks

              , m.LabourCost
              , m.TravelCost
              , m.PerformanceRate
              , m.TravelTime
              , m.RepairTime
              , m.OnsiteHourlyRate

              , m.StandardHandling

              , m.AvailabilityFee
      
              , m.TaxAndDutiesW

              , m.MarkupOtherCost
              , m.MarkupFactorOtherCost

              , m.MarkupFactorStandardWarranty
              , m.MarkupStandardWarranty
      
              , m.AFR1   * 100 as AFR1
              , m.AFR2   * 100 as AFR2
              , m.AFR3   * 100 as AFR3
              , m.AFR4   * 100 as AFR4
              , m.AFR5   * 100 as AFR5
              , m.AFRP1  * 100 as AFRP1

              , m.[1stLevelSupportCosts]
              , m.[2ndLevelSupportCosts]
           
              , m.ReinsuranceFlatfee1
              , m.ReinsuranceFlatfee2
              , m.ReinsuranceFlatfee3
              , m.ReinsuranceFlatfee4
              , m.ReinsuranceFlatfee5
              , m.ReinsuranceFlatfeeP1
              , m.ReinsuranceUpliftFactor_4h_24x7
              , m.ReinsuranceUpliftFactor_4h_9x5
              , m.ReinsuranceUpliftFactor_NBD_9x5

              , m.MaterialCostWarranty
              , m.MaterialCostOow

              , m.Duration

             , m.FieldServicePerYear * m.AFR1 as FieldServiceCost1
             , m.FieldServicePerYear * m.AFR2 as FieldServiceCost2
             , m.FieldServicePerYear * m.AFR3 as FieldServiceCost3
             , m.FieldServicePerYear * m.AFR4 as FieldServiceCost4
             , m.FieldServicePerYear * m.AFR5 as FieldServiceCost5
            
             , Hardware.CalcByDur(
                       m.Duration
                     , m.IsProlongation 
                     , m.LogisticPerYear * m.AFR1 
                     , m.LogisticPerYear * m.AFR2 
                     , m.LogisticPerYear * m.AFR3 
                     , m.LogisticPerYear * m.AFR4 
                     , m.LogisticPerYear * m.AFR5 
                     , m.LogisticPerYear * m.AFRP1
                 ) as LogisticTransportcost

    from CostCte m
)
GO
