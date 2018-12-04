CREATE VIEW [Hardware].[HddRetByDurationView] WITH SCHEMABINDING as 
     select wg.Id as WgID,
            d.Id as DurID, 

            (select sum(h.HddMaterialCost * h.HddFr / 100)
                from Hardware.HddRetention h
                JOIN Dependencies.Year y on y.Id = h.Year
                where h.Wg = wg.Id
                       and y.IsProlongation = d.IsProlongation
                       and y.Value <= d.Value) as HddRet,

            (select sum(h.HddMaterialCost_Approved * h.HddFr_Approved / 100)
                from Hardware.HddRetention h
                JOIN Dependencies.Year y on y.Id = h.Year
                where h.Wg = wg.Id
                       and y.IsProlongation = d.IsProlongation
                       and y.Value <= d.Value) as HddRet_Approved

     from Dependencies.Duration d,
          InputAtoms.Wg wg
go
/****** Object:  UserDefinedFunction [Report].[HddRetentionCentral]    Script Date: 30.10.2018 15:45:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Report].[HddRetention]
(
)
RETURNS TABLE 
AS
RETURN (
    select wg.Name as Wg
         , wg.Description as WgDescription
         , coalesce(hddRet.TP , 0) as TP
         , coalesce(hddRet.DealerPrice , 0)  as DealerPrice
         , coalesce(hddRet.ListPrice , 0)  as ListPrice
    from Hardware.HddRetByDurationView hdd
    join InputAtoms.WgSogView wg on wg.Id = hdd.WgID
    join Dependencies.Duration dur on dur.Id = hdd.DurID
	cross apply [Report].[HddRetentionCentral](hdd.WgID, hdd.DurID) hddRet
    where hdd.DurID = 1
)