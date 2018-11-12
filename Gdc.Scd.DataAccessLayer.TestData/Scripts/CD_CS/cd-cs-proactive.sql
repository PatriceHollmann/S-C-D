USE [Scd_2]
GO
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
         , coalesce(hdd.HddRet_Approved , 0) as TP
         , coalesce(0 , 0)  as DealerPrice
         , coalesce(0 , 0)  as ListPrice
    from Hardware.HddRetention hdd
    join InputAtoms.WgSogView wg on wg.Id = hdd.Wg
    where hdd.Year = 1
)