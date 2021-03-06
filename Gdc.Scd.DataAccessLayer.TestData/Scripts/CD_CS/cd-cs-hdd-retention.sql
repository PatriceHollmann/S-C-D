IF OBJECT_ID('Report.HddRetention') IS NOT NULL
  DROP FUNCTION Report.HddRetention;
go 

CREATE FUNCTION [Report].[HddRetention]
(
	@cnt nvarchar(200)
)
RETURNS TABLE 
AS
RETURN (
    select h.Wg
         , h.WgDescription
         , coalesce(h.TransferPrice * er.Value, 0) as TP
         , coalesce(h.DealerPrice * er.Value, 0)  as DealerPrice
         , coalesce(h.ListPrice * er.Value, 0)  as ListPrice
    from Report.HddRetentionCentral(null) h
	left join InputAtoms.Country cnt on UPPER(Name)= UPPER(@cnt)
	left join [References].Currency cur on cur.Id = cnt.CurrencyId
	left join [References].ExchangeRate er on er.CurrencyId = cnt.CurrencyId
)