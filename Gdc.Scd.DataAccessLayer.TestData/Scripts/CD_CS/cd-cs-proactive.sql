IF OBJECT_ID('Report.GetProActiveByCountryAndWg') IS NOT NULL
  DROP FUNCTION Report.GetProActiveByCountryAndWg;
go 

CREATE FUNCTION [Report].[GetProActiveByCountryAndWg]
(
    @cnt nvarchar(max),
    @wgList nvarchar(max)   
)
RETURNS TABLE 
AS
RETURN (
    select wg.Name as Wg,	  
		sla.Name as ProActiveModel, 
		coalesce(pro.Service_Approved * er.Value , 0) as Cost,
		coalesce(pro.Setup_Approved * er.Value, 0) as OneTimeTasks
		from [Hardware].[ProActiveView] pro
		left join InputAtoms.Wg wg on wg.Name in (select Name from Report.SplitString(@wgList))
		left join InputAtoms.Country cnt on cnt.Name = @cnt
		left join Dependencies.ProActiveSla sla on sla.Id = pro.ProActiveSla
		left join [References].ExchangeRate er on er.CurrencyId = cnt.CurrencyId
		where Wg=wg.Id and Country=cnt.Id and sla.Name in (6,7,3,4))