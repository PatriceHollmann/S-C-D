if OBJECT_ID('Archive.spGetMarkupStandardWaranty') is not null
    drop procedure Archive.spGetMarkupStandardWaranty;
go

create procedure [Archive].[spGetMarkupStandardWaranty]
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