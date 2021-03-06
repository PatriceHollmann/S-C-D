ALTER function [Archive].[GetSwDigit]()
returns @tbl table (
      Id bigint not null primary key
    , Name nvarchar(255)
    , Description nvarchar(255)
    , Sog nvarchar(255)
    , Sfab nvarchar(255)
    , Pla nvarchar(255)
    , ClusterPla nvarchar(255)
)
begin

    insert into @tbl
    select  dig.Id
          , dig.Name
          , dig.Description

          , sog.Name as Sog
          , sfab.Name as Sfab
          , pla.Name as Pla
          , cpla.Name as ClusterPla
    from InputAtoms.SwDigit dig
    left join InputAtoms.Sog sog on sog.Id = dig.SogId and sog.Deactivated = 0
    left join InputAtoms.Sfab sfab on sfab.Id = sog.SFabId and sfab.Deactivated = 0
    left join InputAtoms.Pla pla on pla.Id = sfab.PlaId 
    left join InputAtoms.ClusterPla cpla on cpla.Id = pla.ClusterPlaId

    where dig.Deactivated = 0

    return;

end
go

ALTER function [Archive].[GetWg](@software bit)
returns @tbl table (
      Id bigint not null primary key
    , Name nvarchar(255)
    , Description nvarchar(255)
    , Pla nvarchar(255)
    , ClusterPla nvarchar(255)
    , Sog nvarchar(255)
)
begin

    insert into @tbl
    select  wg.Id
          , wg.Name as Wg
          , wg.Description
          , pla.Name as Pla
          , cpla.Name as ClusterPla
          , sog.Name as Sog
    from InputAtoms.Wg wg 
    left join InputAtoms.Pla pla on pla.Id = wg.PlaId
    left join InputAtoms.ClusterPla cpla on cpla.Id = pla.ClusterPlaId
    left join InputAtoms.Sog sog on sog.id = wg.SogId
    where wg.Deactivated = 0
          and (@software is null or wg.IsSoftware = @software)

    return;

end
go

ALTER procedure [Archive].[spGetAfr]
AS
begin
    with AfrCte as (
        select  afr.Wg
              , sum(case when y.IsProlongation = 0 and y.Value = 1 then afr.AFR_Approved end) as AFR1
              , sum(case when y.IsProlongation = 0 and y.Value = 2 then afr.AFR_Approved end) as AFR2
              , sum(case when y.IsProlongation = 0 and y.Value = 3 then afr.AFR_Approved end) as AFR3
              , sum(case when y.IsProlongation = 0 and y.Value = 4 then afr.AFR_Approved end) as AFR4
              , sum(case when y.IsProlongation = 0 and y.Value = 5 then afr.AFR_Approved end) as AFR5
              , sum(case when y.IsProlongation = 1 and y.Value = 1 then afr.AFR_Approved end) as AFRP1
        from Hardware.AFR afr
        join Dependencies.Year y on y.Id = afr.Year 
        where afr.Deactivated = 0
        group by afr.Wg
    )
    select  wg.Name as Wg
          , wg.Description 
          , wg.Sog
          , wg.ClusterPla
          , wg.Pla
          , afr.AFR1
          , afr.AFR2
          , afr.AFR3
          , afr.AFR4
          , afr.AFR5
          , afr.AFRP1
    from AfrCte afr
    join Archive.GetWg(null) wg on wg.id = afr.Wg
    order by wg.Name;
end
go

ALTER procedure [Archive].[spGetAvailabilityFee]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , fee.AverageContractDuration_Approved          as AverageContractDuration
          , fee.InstalledBaseHighAvailability_Approved    as InstalledBaseHighAvailability
          , fee.StockValueFj_Approved                     as StockValueFj
          , fee.StockValueMv_Approved                     as StockValueMv
          , fee.TotalLogisticsInfrastructureCost_Approved as TotalLogisticsInfrastructureCost 
          , fee.MaxQty_Approved                           as MaxQty
          , fee.JapanBuy_Approved                         as JapanBuy
          , fee.CostPerKit_Approved                       as CostPerKit
          , fee.CostPerKitJapanBuy_Approved               as CostPerKitJapanBuy

    from Hardware.AvailabilityFee fee
    join Archive.GetCountries() c on c.id = fee.Country
    join Archive.GetWg(0) wg on wg.id = fee.Wg

    where fee.Deactivated = 0

    order by c.Name, wg.Name
end
go

ALTER procedure [Archive].[spGetHddRetention]
AS
    begin
    with HddCte as (
        select    h.Wg

                , sum(case when y.IsProlongation = 0 and y.Value = 1 then h.HddFr_Approved end) as Fr1
                , sum(case when y.IsProlongation = 0 and y.Value = 2 then h.HddFr_Approved end) as Fr2
                , sum(case when y.IsProlongation = 0 and y.Value = 3 then h.HddFr_Approved end) as Fr3
                , sum(case when y.IsProlongation = 0 and y.Value = 4 then h.HddFr_Approved end) as Fr4
                , sum(case when y.IsProlongation = 0 and y.Value = 5 then h.HddFr_Approved end) as Fr5
                , sum(case when y.IsProlongation = 1 and y.Value = 1 then h.HddFr_Approved end) as FrP1

                , sum(case when y.IsProlongation = 0 and y.Value = 1 then h.HddMaterialCost_Approved end) as Mc1
                , sum(case when y.IsProlongation = 0 and y.Value = 2 then h.HddMaterialCost_Approved end) as Mc2
                , sum(case when y.IsProlongation = 0 and y.Value = 3 then h.HddMaterialCost_Approved end) as Mc3
                , sum(case when y.IsProlongation = 0 and y.Value = 4 then h.HddMaterialCost_Approved end) as Mc4
                , sum(case when y.IsProlongation = 0 and y.Value = 5 then h.HddMaterialCost_Approved end) as Mc5
                , sum(case when y.IsProlongation = 1 and y.Value = 1 then h.HddMaterialCost_Approved end) as McP1

        from Hardware.HddRetention h
        join Dependencies.Year y on y.Id = h.Year
        where h.Deactivated = 0

        group by h.Wg
    )
    select  wg.Name as Wg
          , wg.Description 
          , wg.Sog
          , wg.ClusterPla
          , wg.Pla

          , h.Fr1
          , h.Fr2
          , h.Fr3
          , h.Fr4
          , h.Fr5
          , h.FrP1

          , h.Mc1
          , h.Mc2
          , h.Mc3
          , h.Mc4
          , h.Mc5
          , h.McP1

          , mc.TransferPrice
          , mc.ListPrice
          , mc.DealerDiscount
          , mc.DealerPrice

          , u.Name as ChangeUser
          , u.Email as ChangeUserEmail

    from HddCte h
    join Archive.GetWg(0) wg on wg.id = h.Wg
    left join Hardware.HddRetentionManualCost mc on mc.WgId = h.Wg
    left join dbo.[User] u on u.Id = mc.ChangeUserId
    order by wg.Name
end
go

ALTER procedure [Archive].[spGetInstallBase]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , ib.InstalledBaseCountry_Approved as InstalledBaseCountry

    from Hardware.InstallBase ib
    join Archive.GetCountries() c on c.id = ib.Country
    join Archive.GetWg(null) wg on wg.id = ib.Wg

    where ib.Deactivated = 0

    order by c.Name, wg.Name
end
go

ALTER procedure [Archive].[spGetLogisticsCosts]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , ccg.Name                             as ContractGroup
          , ccg.Code                             as ContractGroupCode

          , rtt.ReactionTime
          , rtt.ReactionType

          , lc.StandardHandling_Approved         as StandardHandling
          , lc.HighAvailabilityHandling_Approved as HighAvailabilityHandling
          , lc.StandardDelivery_Approved         as StandardDelivery
          , lc.ExpressDelivery_Approved          as ExpressDelivery
          , lc.TaxiCourierDelivery_Approved      as TaxiCourierDelivery
          , lc.ReturnDeliveryFactory_Approved    as ReturnDeliveryFactory

    from Hardware.LogisticsCosts lc
    join Archive.GetCountries() c on c.id = lc.Country
    join Archive.GetWg(null) wg on wg.id = lc.Wg
    join InputAtoms.CentralContractGroup ccg on ccg.Id = lc.CentralContractGroup

    join Archive.GetReactionTimeType() rtt on rtt.Id = lc.ReactionTimeType

    where lc.Deactivated = 0
    order by c.Name, wg.Name
end
go

ALTER procedure [Archive].[spGetMarkupOtherCosts]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , ccg.Name                             as ContractGroup
          , ccg.Code                             as ContractGroupCode

          , tta.Availability
          , tta.ReactionTime
          , tta.ReactionType

          , moc.MarkupFactor_Approved  as MarkupFactor
          , moc.Markup_Approved        as Markup

          , moc.ProlongationMarkupFactor_Approved as ProlongationMarkupFactor
          , moc.ProlongationMarkup_Approved as ProlongationMarkup

    from Hardware.MarkupOtherCosts moc
    join Archive.GetCountries() c on c.id = moc.Country
    join Archive.GetWg(null) wg on wg.id = moc.Wg
    join InputAtoms.CentralContractGroup ccg on ccg.Id = moc.CentralContractGroup
    join Archive.GetReactionTimeTypeAvailability() tta on tta.Id = moc.ReactionTimeTypeAvailability

    where moc.Deactivated = 0
    order by c.Name, wg.Name
end
go

ALTER procedure [Archive].[spGetMarkupStandardWaranty]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , ccg.Name                             as ContractGroup
          , ccg.Code                             as ContractGroupCode

          , msw.MarkupFactorStandardWarranty_Approved  as MarkupFactorStandardWarranty 
          , msw.MarkupStandardWarranty_Approved        as MarkupStandardWarranty       

    from Hardware.MarkupStandardWaranty msw
    join Archive.GetCountries() c on c.id = msw.Country
    join Archive.GetWg(null) wg on wg.id = msw.Wg
    join InputAtoms.CentralContractGroup ccg on ccg.Id = msw.CentralContractGroup

    where msw.Deactivated = 0
    order by c.Name, wg.Name
end
go

ALTER procedure [Archive].[spGetMaterialCostWarranty]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , mcw.MaterialCostOow_Approved as MaterialCostOow
          , mcw.MaterialCostIw_Approved  as MaterialCostIw


    from Hardware.MaterialCostWarranty mcw
    join Archive.GetCountries() c on c.id = mcw.NonEmeiaCountry
    join Archive.GetWg(null) wg on wg.id = mcw.Wg

    where mcw.Deactivated = 0

    order by c.Name, wg.Name
end
go

ALTER procedure [Archive].[spGetMaterialCostWarrantyEmeia]
AS
begin
    select  wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , mcw.MaterialCostOow_Approved as MaterialCostOow
          , mcw.MaterialCostIw_Approved  as MaterialCostIw


    from Hardware.MaterialCostWarrantyEmeia mcw
    join Archive.GetWg(null) wg on wg.id = mcw.Wg

    where mcw.Deactivated = 0

    order by wg.Name
end
go

ALTER procedure [Archive].[spGetProActive]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , ccg.Name                             as ContractGroup
          , ccg.Code                             as ContractGroupCode

          , pro.LocalRemoteAccessSetupPreparationEffort_Approved as LocalRemoteAccessSetupPreparationEffort
          , pro.LocalRegularUpdateReadyEffort_Approved           as LocalRegularUpdateReadyEffort
          , pro.LocalPreparationShcEffort_Approved               as LocalPreparationShcEffort
          , pro.CentralExecutionShcReportCost_Approved           as CentralExecutionShcReportCost
          , pro.LocalRemoteShcCustomerBriefingEffort_Approved    as LocalRemoteShcCustomerBriefingEffort
          , pro.LocalOnSiteShcCustomerBriefingEffort_Approved    as LocalOnSiteShcCustomerBriefingEffort
          , pro.TravellingTime_Approved                          as TravellingTime
          , pro.OnSiteHourlyRate_Approved                        as OnSiteHourlyRate

    from Hardware.ProActive pro
    join Archive.GetCountries() c on c.id = pro.Country
    join Archive.GetWg(null) wg on wg.id = pro.Wg
    join InputAtoms.CentralContractGroup ccg on ccg.Id = pro.CentralContractGroup

    where pro.Deactivated = 0
    order by c.Name, wg.Name
end
go

ALTER procedure [Archive].[spGetProActiveSw]
AS
begin
    select   c.Name as Country
           , c.Region
           , c.ClusterRegion

           , dig.Name as Digit
           , dig.Description as DigitDescription
           , dig.ClusterPla
           , dig.Pla
           , dig.Sfab
           , dig.Sog

           , pro.LocalRemoteAccessSetupPreparationEffort_Approved as LocalRemoteAccessSetupPreparationEffort
           , pro.LocalRegularUpdateReadyEffort_Approved           as LocalRegularUpdateReadyEffort
           , pro.LocalPreparationShcEffort_Approved               as LocalPreparationShcEffort
           , pro.CentralExecutionShcReportCost_Approved           as CentralExecutionShcReportCost
           , pro.LocalRemoteShcCustomerBriefingEffort_Approved    as LocalRemoteShcCustomerBriefingEffort
           , pro.LocalOnSiteShcCustomerBriefingEffort_Approved    as LocalOnSiteShcCustomerBriefingEffort
           , pro.TravellingTime_Approved                          as TravellingTime
           , pro.OnSiteHourlyRate_Approved                        as OnSiteHourlyRate

    from SoftwareSolution.ProActiveSw pro
    join Archive.GetCountries() c on c.Id = pro.Country
    join Archive.GetSwDigit() dig on dig.Id = pro.SwDigit

    where pro.Deactivated = 0

    order by c.Name, dig.Name
end
go

ALTER procedure [Archive].[spGetReinsurance]
AS
begin
    select  wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , dur.Name as Duration
          , rta.Availability
          , rta.ReactionTime

          , cur.Name as Currency
          , er.Value as ExchangeRate

          , r.ReinsuranceFlatfee_Approved      as ReinsuranceFlatfee
          , r.ReinsuranceUpliftFactor_Approved as ReinsuranceUpliftFactor

    from Hardware.Reinsurance r
    join Archive.GetWg(null) wg on wg.id = r.Wg
    join Dependencies.Duration dur on dur.Id = r.Duration
    join Archive.GetReactionTimeAvailability() rta on rta.Id = r.ReactionTimeAvailability

    left join [References].Currency cur on cur.Id = r.CurrencyReinsurance_Approved
    left join [References].ExchangeRate er on er.CurrencyId = r.CurrencyReinsurance_Approved

    where r.Deactivated = 0
    order by wg.Name, dur.Name
end
go

ALTER procedure [Archive].[spGetRoleCodeHourlyRates]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , rc.Name as RoleCode

          , hr.OnsiteHourlyRates_Approved as OnsiteHourlyRates

    from Hardware.RoleCodeHourlyRates hr
    join Archive.GetCountries() c on c.id = hr.Country
    left join InputAtoms.RoleCode rc on rc.Id = hr.RoleCode and rc.Deactivated = 0

    where hr.Deactivated = 0

    order by c.Name, rc.Name
end
go

ALTER procedure [Archive].[spGetServiceSupportCost]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion
          , c.Currency

          , cpla.Name as ClusterPla

          , ssc.[1stLevelSupportCostsCountry_Approved]       as [1stLevelSupportCostsCountry]
          , ssc.[2ndLevelSupportCostsClusterRegion_Approved] as [2ndLevelSupportCostsClusterRegion]
          , ssc.[2ndLevelSupportCostsLocal_Approved]         as [2ndLevelSupportCostsLocal]

    from Hardware.ServiceSupportCost ssc
    join Archive.GetCountries() c on c.id = ssc.Country
    join InputAtoms.ClusterPla cpla on cpla.Id = ssc.ClusterPla

    where ssc.Deactivated = 0

    order by c.Name, cpla.Name
end
go

ALTER procedure [Archive].[spGetSwSpMaintenance]
AS
begin
    select   dig.Name as Digit
           , dig.Description
           , dig.ClusterPla
           , dig.Pla
           , dig.Sfab
           , dig.Sog

           , da.Duration
           , da.Availability

           , m.[2ndLevelSupportCosts_Approved]                   as [2ndLevelSupportCosts]
           , m.InstalledBaseSog_Approved                         as InstalledBaseSog
           , cur.Name                                            as CurrencyReinsurance
           , m.ReinsuranceFlatfee_Approved                       as ReinsuranceFlatfee
           , m.RecommendedSwSpMaintenanceListPrice_Approved      as RecommendedSwSpMaintenanceListPrice
           , m.MarkupForProductMarginSwLicenseListPrice_Approved as MarkupForProductMarginSwLicenseListPrice
           , m.ShareSwSpMaintenanceListPrice_Approved            as ShareSwSpMaintenanceListPrice
           , m.DiscountDealerPrice_Approved                      as DiscountDealerPrice

    from SoftwareSolution.SwSpMaintenance m
    join Archive.GetSwDigit() dig on dig.Id = m.SwDigit
    join Archive.GetDurationAvailability() da on da.Id = m.DurationAvailability
    left join [References].Currency cur on cur.Id = m.CurrencyReinsurance_Approved

    where m.Deactivated = 0

    order by dig.Name, da.Duration
end
go

ALTER procedure [Archive].[spGetTaxAndDuties]
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , tax.TaxAndDuties_Approved as Tax

    from Hardware.TaxAndDuties tax
    join Archive.GetCountries() c on c.id = tax.Country

    where tax.Deactivated = 0

    order by c.Name
end
go

alter procedure Archive.spGetFieldServiceCost
AS
begin
    select  c.Name as Country
          , c.Region
          , c.ClusterRegion

          , wg.Name as Wg
          , wg.Description as WgDescription
          , wg.Pla
          , wg.Sog

          , ccg.Name                             as ContractGroup
          , ccg.Code                             as ContractGroupCode

          , loc.Name as ServiceLocation

          , rtt.ReactionTime
          , rtt.ReactionType

          , fsc.RepairTime_Approved           as RepairTime
          , fsc.TravelTime_Approved           as TravelTime
          , fsc.LabourCost_Approved           as LabourCost
          , fsc.TravelCost_Approved           as TravelCost
          , fsc.PerformanceRate_Approved      as PerformanceRate
          , fsc.TimeAndMaterialShare_Approved as TimeAndMaterialShare

    from Hardware.FieldServiceCost fsc
    join Archive.GetReactionTimeType() rtt on rtt.Id = fsc.ReactionTimeType
    join Archive.GetCountries() c on c.Id = fsc.Country
    join Archive.GetWg(null) wg on wg.id = fsc.Wg
    join Dependencies.ServiceLocation loc on loc.Id = fsc.ServiceLocation
    join InputAtoms.CentralContractGroup ccg on ccg.Id = fsc.CentralContractGroup

    where fsc.Deactivated = 0

    order by c.Name, wg.Name
end
go