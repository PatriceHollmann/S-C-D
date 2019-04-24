﻿IF OBJECT_ID('Report.SwServicePriceListDetail') IS NOT NULL
  DROP FUNCTION Report.SwServicePriceListDetail;
go 

CREATE FUNCTION [Report].[SwServicePriceListDetail]
(
    @sog bigint,
    @digit bigint,
    @av bigint,
    @year bigint
)
RETURNS @tbl TABLE (
      LicenseDescription nvarchar(max) NULL
    , License nvarchar(max) NULL
    , Sog nvarchar(max) NULL
    , Fsp nvarchar(max) NULL
    , ServiceDescription nvarchar(max) NULL
    , ServiceShortDescription nvarchar(max) NULL
      
    , ServiceSupport float NULL
    , Reinsurance float NULL
      
    , TP float NULL
    , DealerPrice float NULL
    , ListPrice float NULL
)
as
begin
    declare @digitList dbo.ListId; 

    if @sog is not null or @digit is not null
    begin

        insert into @digitList(id)
        select Id
        from InputAtoms.SwDigit 
        where     (@sog is null   or SogId = @sog) 
              and (@digit is null or Id = @digit);

        if not exists(select * from @digitList) return;

    end

    declare @avList dbo.ListId; 
    if @av is not null insert into @avList(id) values(@av);

    declare @yearList dbo.ListId; 
    if @year is not null insert into @yearList(id) values(@year);

    insert into @tbl
    select    lic.Description as LicenseDescription
            , lic.Name as License
            , sog.Name as Sog
            , fsp.Name as Fsp

            , fsp.ServiceDescription as ServiceDescription
            , fsp.ShortDescription as ServiceShortDescription

            , sw.ServiceSupport as ServiceSupport
            , sw.Reinsurance as Reinsurance

            , sw.TransferPrice as TP
            , sw.DealerPrice as DealerPrice
            , sw.MaintenanceListPrice as ListPrice

    from SoftwareSolution.GetCosts(1, @digitList, @avList, @yearList, -1, -1) sw
    join InputAtoms.SwDigit dig on dig.Id = sw.SwDigit
    join InputAtoms.Sog sog on sog.id = sw.Sog and sog.IsSoftware = 1 and sog.IsSolution = 0
    join InputAtoms.SwDigitLicense diglic on dig.Id = diglic.SwDigitId
    join InputAtoms.SwLicense lic on lic.Id = diglic.SwLicenseId
									      and lic.Description is not null
    join Fsp.SwFspCodeTranslation fsp on fsp.AvailabilityId = sw.Availability
                                          and fsp.DurationId = sw.Year
                                          and fsp.SwDigitId = sw.SwDigit
										  and fsp.Name is not null

    return;
end
GO

declare @reportId bigint = (select Id from Report.Report where upper(Name) = 'SW-SERVICE-PRICE-LIST-DETAILED');
declare @index int = 0;

delete from Report.ReportColumn where ReportId = @reportId;

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'LicenseDescription', 'Software Product', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'License', 'SW Product Order no.', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Sog', 'Service Offering Group', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Fsp', 'SW Service Product no.', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'ServiceDescription', 'SW Service Description', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'ServiceShortDescription', 'SW Service Short Description', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'ServiceSupport', 'SW Service Support cost', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'Reinsurance', 'Reinsurance', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'TP', 'Transfer Price', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'DealerPrice', 'Dealer Price (Central Reference)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) 
values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'ListPrice', 'List Price (Central Reference)', 1, 1);

set @index = 0;

delete from Report.ReportFilter where ReportId = @reportId;

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('swdigitsog', 0), 'sog', 'SOG');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('swdigit', 0), 'digit', 'SW digit');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('availability', 0), 'av', 'Availability');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('year', 0), 'year', 'Year');

GO

