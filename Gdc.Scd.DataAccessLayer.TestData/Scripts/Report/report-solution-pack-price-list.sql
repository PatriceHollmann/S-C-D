﻿IF OBJECT_ID('Report.SolutionPackPriceList') IS NOT NULL
  DROP FUNCTION Report.SolutionPackPriceList;
go 

CREATE FUNCTION [Report].[SolutionPackPriceList]
(
    @digit bigint
)
RETURNS @tbl TABLE (
      SogDescription nvarchar(max) NULL
    , Sog nvarchar(max) NULL

    , Availability nvarchar(255) NULL
    , Year nvarchar(255) NULL
      
    , Fsp nvarchar(max) NULL
    , SpDescription nvarchar(max) NULL
    , Sp nvarchar(max) NULL
      
    , TP float NULL
    , DealerPrice float NULL
    , ListPrice float NULL
)
as
begin
    declare @digitList dbo.ListId; 
    if @digit is not null insert into @digitList(id) values(@digit);

    declare @emptyAv dbo.ListId;
    declare @emptyYear dbo.ListId;

    with cte as (
        select    sw.*
        from SoftwareSolution.GetCosts(1, @digitList, @emptyAv, @emptyYear, -1, -1) sw
        where sw.SwDigit not in (select DigitId from SoftwareSolution.ProActiveDigits)
    )
    insert into @tbl
    select    sog.Description as SogDescription
            , sog.Name as Sog

            , av.Name as Availability
            , y.Name  as Year

            , fsp.Name as Fsp
            , fsp.ServiceDescription as SpDescription
            , fsp.ShortDescription as Sp

            , sw.TransferPrice as TP
            , sw.DealerPrice as DealerPrice
            , sw.MaintenanceListPrice as ListPrice

    from cte sw
    join InputAtoms.SwDigit dig on dig.Id = sw.SwDigit
    join InputAtoms.Sog sog on sog.id = sw.Sog and sog.IsSoftware = 1 and sog.IsSolution = 1
    join Dependencies.Availability av on av.id = sw.Availability
    join Dependencies.Year y on y.Id = sw.Year

    join Fsp.SwFspCodeTranslation fsp on fsp.Id = sw.FspId 

    return
end
go

declare @reportId bigint = (select Id from Report.Report where upper(Name) = 'SOLUTIONPACK-PRICE-LIST');
declare @index int = 0;

delete from Report.ReportColumn where ReportId = @reportId;

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'SogDescription', 'Infrastructure Solution', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Sog', 'Service Offering Group', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Availability', 'Availability', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Year', 'Year', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Fsp', 'SolutionPack Product no.', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'SpDescription', 'SolutionPack Service Description', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Sp', 'SolutionPack Service Short Description', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'TP', 'Transfer Price', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'DealerPrice', 'Dealer Price (Central Reference)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'ListPrice', 'List Price (Central Reference)', 1, 1);

set @index = 0;

delete from Report.ReportFilter where ReportId = @reportId;

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('swdigit', 0), 'digit', 'SW digit');

GO