USE SCD_2;
GO

ALTER procedure [Archive].[spGetAvailabilityFee]
AS
begin
    select    c.Name as Country
            , c.Region
            , c.ClusterRegion

            , wg.Name as Wg
            , wg.Description as WgDescription
            , wg.Pla
            , wg.Sog

            , fee2.AverageContractDuration_Approved          as AverageContractDuration
            , fee2.InstalledBaseHighAvailability_Approved    as InstalledBaseHighAvailability
            , fee2.StockValueFj_Approved                     as StockValueFj
            , fee2.StockValueMv_Approved                     as StockValueMv
            , fee2.TotalLogisticsInfrastructureCost_Approved as TotalLogisticsInfrastructureCost 
            , fee.MaxQty_Approved                           as MaxQty
            , fee2.JapanBuy_Approved                         as JapanBuy
            , fee.CostPerKit_Approved                       as CostPerKit
            , fee.CostPerKitJapanBuy_Approved               as CostPerKitJapanBuy

    from Hardware.AvailabilityFeeWg fee

    join Archive.GetWg(0) wg on wg.id = fee.Wg

    join Hardware.AvailabilityFeeCountryWg fee2 on fee2.Wg = wg.Id

    join Archive.GetCountries() c on c.id = fee2.Country

    order by c.Name, wg.Name
end
GO

ALTER FUNCTION [Report].[FlatFeeReport]
(
    @cnt bigint,
    @wg bigint
)
RETURNS TABLE 
AS
RETURN (
    select    c.Name as Country
            , c.CountryGroup
            , wg.Name as Wg
            , wg.Description as WgDescription
        
            , c.Currency
            , calc.Fee_Approved * er.Value / 12 as Fee
        
            , fee2.InstalledBaseHighAvailability_Approved as IB
            , fee.CostPerKit as CostPerKit
            , fee.CostPerKitJapanBuy as CostPerKitJapanBuy
            , fee.MaxQty as MaxQty
            , fee2.JapanBuy_Approved as JapanBuy

    from Hardware.AvailabilityFeeWg fee
    join InputAtoms.Wg wg on wg.id = fee.Wg
    
    join Hardware.AvailabilityFeeCountryWg fee2 on fee2.Wg = wg.Id and fee2.DeactivatedDateTime is null
    left join Hardware.AvailabilityFeeCalc calc on calc.Wg = fee.Wg and calc.Country = fee2.Country 
    
    join InputAtoms.CountryView c on c.Id = fee2.Country
    
    left join [References].ExchangeRate er on er.CurrencyId = c.CurrencyId

    where     fee.DeactivatedDateTime is null
          and (@cnt is null or fee2.Country = @cnt)
          and (@wg is null or fee.Wg = @wg)

)
go