﻿IF OBJECT_ID('Report.FlatFeeReport') IS NOT NULL
  DROP FUNCTION Report.FlatFeeReport;
go 

CREATE FUNCTION Report.FlatFeeReport
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
        
            , calc.Fee_Approved * er.Value as Fee
        
            , fee.InstalledBaseHighAvailability_Approved as IB
            , fee.CostPerKit as CostPerKit
            , fee.CostPerKitJapanBuy as CostPerKitJapanBuy
            , fee.MaxQty as MaxQty
            , fee.JapanBuy_Approved as JapanBuy

    from Hardware.AvailabilityFee fee
    join InputAtoms.CountryView c on c.Id = fee.Country
    join InputAtoms.Wg wg on wg.id = fee.Wg
    left join Hardware.AvailabilityFeeCalc calc on calc.Wg = fee.Wg and calc.Country = fee.Country
    left join [References].ExchangeRate er on er.CurrencyId = c.CurrencyId

    where (@cnt is null or fee.Country = @cnt)
        and (@wg is null or fee.Wg = @wg)
)

GO

declare @reportId bigint = (select Id from Report.Report where upper(Name) = 'FLAT-FEE-REPORTS');
declare @index int = 0;

delete from Report.ReportColumn where ReportId = @reportId;
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'CountryGroup', 'Country Group', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Country', 'Country Name', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Wg', 'Warranty Group', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'WgDescription', 'WG Description', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 2, 'Fee', 'FSL Flatfee monthly (country currency)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'IB', 'Installed base high availability', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 4, 'CostPerKit', 'Cost per KIT (EUR)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 4, 'CostPerKitJapanBuy', 'Cost per KIT Japan-Buy (EUR)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'MaxQty', 'MaxQty', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 3, 'JapanBuy', 'Japan buy', 1, 1);

set @index = 0;
delete from Report.ReportFilter where ReportId = @reportId;

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 7, 'cnt', 'Country Name');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where Name = 'wgall'), 'wg', 'Warranty Group');

GO