﻿IF OBJECT_ID('Report.PoStandardWarrantyMaterial') IS NOT NULL
  DROP FUNCTION Report.PoStandardWarrantyMaterial;
go 

CREATE FUNCTION Report.PoStandardWarrantyMaterial
(
    @cnt bigint,
    @wg bigint,
    @av bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc bigint
)
RETURNS TABLE 
AS
RETURN (
    with cte as (
        select 
                m.Id
              , c.CountryGroup
              , c.LUTCode
              , wg.Name as Wg
              , wg.Description as WgDescription
              , pla.Name as Pla
              , dur.Value as Year
              , dur.IsProlongation
              , (dur.Name + ' ' + loc.Name) as ServiceLevel
              , rtime.Name as ReactionTime
              , rtype.Name as ReactionType
              , av.Name    as Availability

              , mc.MaterialCostWarranty_Approved as MaterialCostWarranty

              , afr.AFR1_Approved as AFR1
              , afr.AFR2_Approved as AFR2
              , afr.AFR3_Approved as AFR3
              , afr.AFR4_Approved as AFR4
              , afr.AFR5_Approved as AFR5

              , null as SparesAvailability

        from Report.GetMatrixBySlaCountry(@cnt, @wg, @av, null, @reactiontime, @reactiontype, @loc) m

        JOIN InputAtoms.CountryView c on c.Id = m.CountryId

        JOIN InputAtoms.WgSogView wg on wg.id = m.WgId

        JOIN Dependencies.Duration dur on dur.id = m.DurationId and dur.IsProlongation = 0

        JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

        JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

        JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId

        JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

        LEFT JOIN Atom.AfrYear afr on afr.Wg = m.WgId

        LEFT JOIN Atom.MaterialCostWarranty mc on mc.Wg = wg.Id

        LEFT JOIN InputAtoms.Pla pla on pla.id = wg.PlaId
    )
    , cte2 as (
        select    
              m.*

            , m.MaterialCostWarranty * m.AFR1 as mat1
            , m.MaterialCostWarranty * m.AFR2 as mat2
            , m.MaterialCostWarranty * m.AFR3 as mat3
            , m.MaterialCostWarranty * m.AFR4 as mat4
            , m.MaterialCostWarranty * m.AFR5 as mat5
        from cte m
    )
    select    m.Id
            , m.CountryGroup
            , m.LUTCode
            , m.Wg
            , m.WgDescription
            , m.Pla
            , m.ServiceLevel
            , m.ReactionTime
            , m.ReactionType
            , m.Availability

            , Hardware.CalcByDur(m.Year, m.IsProlongation, m.mat1, m.mat2, m.mat3, m.mat4, m.mat5, 0) as MaterialW

            , m.MaterialCostWarranty

            , m.AFR1
            , m.AFR2
            , m.AFR3
            , m.AFR4
            , m.AFR5

            , m.SparesAvailability
    from cte2 m
)
GO

declare @reportId bigint = (select Id from Report.Report where upper(Name) = 'PO-STANDARD-WARRANTY-MATERIAL');
declare @index int = 0;

delete from Report.ReportColumn where ReportId = @reportId;

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'CountryGroup', 'Country Group', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'LUTCode', 'CountryCode LUT', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Wg', 'Warranty Group', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'WgDescription', 'Warranty Group Name', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Pla', 'Pla', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ServiceLevel', 'Service Level', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ReactionTime', 'Reaction time', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ReactionType', 'Reaction type', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Availability', 'Availability', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 4, 'MaterialW', 'Material Price', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 4, 'MaterialCostWarranty', 'Material Cost', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'AFR1', 'FR1', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'AFR2', 'FR2', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'AFR3', 'FR3', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'AFR4', 'FR4', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'AFR5', 'FR5', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'SparesAvailability', 'Spares availability (year)', 1, 1);

------------------------------------
set @index = 0;
delete from Report.ReportFilter where ReportId = @reportId;
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 7, 'cnt', 'Country Name');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 4, 'wg', 'Warranty Group');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 8, 'av', 'Availability');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 10, 'reactiontime', 'Reaction time');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 11, 'reactiontype', 'Reaction type');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 12, 'loc', 'Service location');