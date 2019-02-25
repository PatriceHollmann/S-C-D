IF OBJECT_ID('Report.spLocapGlobalSupport') IS NOT NULL
  DROP PROCEDURE Report.spLocapGlobalSupport;
go 

CREATE PROCEDURE [Report].[spLocapGlobalSupport]
(
    @cnt     dbo.ListID readonly,
    @wg      dbo.ListID readonly,
    @av      dbo.ListID readonly,
    @dur     dbo.ListID readonly,
    @rtime   dbo.ListID readonly,
    @rtype   dbo.ListID readonly,
    @loc     dbo.ListID readonly,
    @pro     dbo.ListID readonly,
    @lastid  bigint,
    @limit   int,
    @total   int output
)
AS
BEGIN

    if @limit > 0 select @total = count(id) from Portfolio.GetBySlaFsp(@cnt, @wg, @av, @dur, @rtime, @rtype, @loc, @pro);

    declare @sla Portfolio.Sla;
    insert into @sla select * from Portfolio.GetBySlaFspPaging(@cnt, @wg, @av, @dur, @rtime, @rtype, @loc, @pro, @lastid, @limit) m

    select    c.Country
            , cnt.ISO3CountryCode
            , c.Fsp
            , c.FspDescription

            , sog.Description as SogDescription
            , sog.Name        as Sog

            , c.ServiceLocation
            , c.ReactionTime + ' ' + c.ReactionType + ' time, ' + c.Availability as ReactionTime
            , c.Year as ServicePeriod
            , LOWER(c.Duration) + ' ' + c.ServiceLocation as ServiceProduct

            , c.LocalServiceStandardWarranty
            , coalesce(ServiceTPManual, ServiceTP) ServiceTP
            , c.DealerPrice
            , c.ListPrice

    from Hardware.GetCostsSla(1, @sla) c
    inner join InputAtoms.Country cnt on cnt.id = c.CountryId
    inner join InputAtoms.WgSogView sog on sog.Id = c.WgId

END
GO

declare @reportId bigint = (select Id from Report.Report where upper(Name) = ('Locap-Global-Support'));
declare @index int = 0;

delete from Report.ReportColumn where ReportId = @reportId;
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'Fsp', 'Product_No', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'WgDescription', 'Warranty Group Name', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'ServiceLevel', 'Service Level', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'ReactionTime', 'Reaction Time', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'ServicePeriod', 'Service Period', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'Wg', 'WG', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'euro'), 'LocalServiceStandardWarranty', 'Standard Warranty costs', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'euro'), 'ServiceTC', 'Service TC', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'euro'), 'ServiceTP_Released', 'Service TP (Released)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'Country', 'Country Name', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'ServiceType', 'Service type', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'PlausiCheck', 'Plausi Check', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'PortfolioType', 'Portfolio Type', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'ReleaseCreated', 'Release created', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, (select id from Report.ReportColumnType where name = 'text'), 'Sog', 'SOG', 1, 1);

set @index = 0;
delete from Report.ReportFilter where ReportId = @reportId;


set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where MultiSelect = 1 and name ='country'         ), 'cnt', 'Country Name');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where MultiSelect = 1 and name ='wg'              ), 'wg', 'Warranty Group');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where MultiSelect = 1 and name ='availability'    ), 'av', 'Availability');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where MultiSelect = 1 and name ='duration'        ), 'dur', 'Service period');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where MultiSelect = 1 and name ='reactiontime'    ), 'rtime', 'Reaction time');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where MultiSelect = 1 and name ='reactiontype'    ), 'rtype', 'Reaction type');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where MultiSelect = 1 and name ='servicelocation' ), 'loc', 'Service location');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select id from Report.ReportFilterType where MultiSelect = 1 and name ='proactive'       ), 'pro', 'ProActive');

GO

