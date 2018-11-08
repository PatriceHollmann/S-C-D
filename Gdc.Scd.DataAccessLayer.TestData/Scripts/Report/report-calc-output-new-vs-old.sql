﻿IF OBJECT_ID('Report.CalcOutputNewVsOld') IS NOT NULL
  DROP FUNCTION Report.CalcOutputNewVsOld;
go 

CREATE FUNCTION Report.CalcOutputNewVsOld
(
    @cnt bigint,
    @wg bigint,
    @av bigint,
    @dur bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc bigint
)
RETURNS TABLE 
AS
RETURN (
    with cte as (
        SELECT m.Id

            --FSP
                , fsp.Name Fsp
                , fsp.ServiceDescription as FspDescription
          
                , wg.SogDescription as SogDescription
                , wg.Description as WgDescription
                , wg.Name as Wg
                , wg.Sog

            --SLA
                , c.Name as Country
                , dur.Name as Duration
                , dur.Value as Year
                , dur.IsProlongation
                , av.Name as Availability
                , rtime.Name as ReactionTime
                , loc.Name as ServiceLocation

                , afr.AFR1 
                , afr.AFR2 
                , afr.AFR3 
                , afr.AFR4 
                , afr.AFR5 
                , afr.AFRP1

                , mcw.MaterialCostWarranty          * tax.TaxAndDuties          as TaxAndDutiesW

                , fsc.LabourCost            
                , fsc.TravelCost            
                , fsc.TimeAndMaterialShare  
                , fsc.PerformanceRate       
                , fsc.TravelTime            
                , fsc.RepairTime            
                , fsc.OnsiteHourlyRates     

                , Hardware.CalcSrvSupportCost(ssc.[1stLevelSupportCosts], ssc.[2ndLevelSupportCosts], ib.InstalledBaseCountry, ib.InstalledBaseCountryPla) as ServiceSupportPerYear

                , lc.StandardHandling + lc.HighAvailabilityHandling + lc.StandardDelivery + lc.ExpressDelivery + lc.TaxiCourierDelivery + lc.ReturnDeliveryFactory as LogisticPerYear

                , case 
                        when afEx.id is null then af.Fee
                        else 0
                end as AvailabilityFee

                , msw.MarkupFactorStandardWarranty 
                , msw.MarkupStandardWarranty       

        FROM Report.GetMatrixBySlaCountry(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc) m

        INNER JOIN InputAtoms.Country c on c.id = m.CountryId

        INNER JOIN InputAtoms.WgSogView wg on wg.id = m.WgId

        INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

        INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId

        INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

        INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

        LEFT JOIN Atom.AfrYear afr on afr.Wg = m.WgId

        LEFT JOIN Atom.InstallBase ib on ib.Wg = m.WgId AND ib.Country = m.CountryId

        LEFT JOIN Hardware.ServiceSupportCostView ssc on ssc.Country = m.CountryId and ssc.Wg = m.WgId

        LEFT JOIN Atom.TaxAndDutiesView tax on tax.Country = m.CountryId

        LEFT JOIN Atom.MaterialCostWarranty mcw on mcw.Wg = m.WgId AND mcw.ClusterRegion = c.ClusterRegionId

        LEFT JOIN Hardware.FieldServiceCostView fsc ON fsc.Wg = m.WgId AND fsc.Country = m.CountryId AND fsc.ServiceLocation = m.ServiceLocationId AND fsc.ReactionTypeId = m.ReactionTypeId AND fsc.ReactionTimeId = m.ReactionTimeId

        LEFT JOIN Hardware.LogisticsCostView lc on lc.Country = m.CountryId AND lc.Wg = m.WgId AND lc.ReactionTime = m.ReactionTimeId AND lc.ReactionType = m.ReactionTypeId

        LEFT JOIN Atom.MarkupStandardWarantyView msw on msw.Wg = m.WgId AND msw.Country = m.CountryId AND msw.ReactionTimeId = m.ReactionTimeId AND msw.ReactionTypeId = m.ReactionTypeId AND msw.AvailabilityId = m.AvailabilityId

        LEFT JOIN Hardware.AvailabilityFeeCalcView af on af.Country = m.CountryId AND af.Wg = m.WgId

        LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId AND afEx.ReactionTimeId = m.ReactionTimeId AND afEx.ReactionTypeId = m.ReactionTypeId AND afEx.ServiceLocationId = m.ServiceLocationId

        LEFT JOIN Fsp.HwFspCodeTranslation fsp on fsp.CountryId = m.CountryId
                                            and fsp.WgId = m.WgId
                                            and fsp.AvailabilityId = m.AvailabilityId
                                            and fsp.DurationId = m.DurationId
                                            and fsp.ReactionTimeId = m.ReactionTimeId
                                            and fsp.ReactionTypeId = m.ReactionTypeId
                                            and fsp.ServiceLocationId = m.ServiceLocationId
    )
    , CostCte as (
        select    m.*

                , m.LogisticPerYear * m.AFR1 as Logistic1
                , m.LogisticPerYear * m.AFR2 as Logistic2
                , m.LogisticPerYear * m.AFR3 as Logistic3
                , m.LogisticPerYear * m.AFR4 as Logistic4
                , m.LogisticPerYear * m.AFR5 as Logistic5
                , m.LogisticPerYear * m.AFRP1 as Logistic1P

        from cte m
    )
    , CostCte2 as (
        select    m.*

                , Hardware.CalcLocSrvStandardWarranty(m.LabourCost, m.TravelCost, m.ServiceSupportPerYear, m.Logistic1, m.TaxAndDutiesW, m.AFR1, m.AvailabilityFee, m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty) as LocalServiceStandardWarranty1
                , Hardware.CalcLocSrvStandardWarranty(m.LabourCost, m.TravelCost, m.ServiceSupportPerYear, m.Logistic2, m.TaxAndDutiesW, m.AFR2, m.AvailabilityFee, m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty) as LocalServiceStandardWarranty2
                , Hardware.CalcLocSrvStandardWarranty(m.LabourCost, m.TravelCost, m.ServiceSupportPerYear, m.Logistic3, m.TaxAndDutiesW, m.AFR3, m.AvailabilityFee, m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty) as LocalServiceStandardWarranty3
                , Hardware.CalcLocSrvStandardWarranty(m.LabourCost, m.TravelCost, m.ServiceSupportPerYear, m.Logistic4, m.TaxAndDutiesW, m.AFR4, m.AvailabilityFee, m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty) as LocalServiceStandardWarranty4
                , Hardware.CalcLocSrvStandardWarranty(m.LabourCost, m.TravelCost, m.ServiceSupportPerYear, m.Logistic5, m.TaxAndDutiesW, m.AFR5, m.AvailabilityFee, m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty) as LocalServiceStandardWarranty5
                , Hardware.CalcLocSrvStandardWarranty(m.LabourCost, m.TravelCost, m.ServiceSupportPerYear, m.Logistic1P, m.TaxAndDutiesW, m.AFRP1, m.AvailabilityFee, m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty) as LocalServiceStandardWarranty1P

        from CostCte m
    )
    , CostCte3 as (
        select 
              m.Id
            , m.Country
            , m.SogDescription as SogDescription
            , m.Fsp
            , m.Wg
            , m.Sog
            , m.WgDescription
            , m.ServiceLocation
            , m.ReactionTime
         
            , (m.Duration + ' ' + m.ServiceLocation) as ServiceProduct
         
            , Hardware.CalcByDur(m.Year, m.IsProlongation, m.LocalServiceStandardWarranty1, m.LocalServiceStandardWarranty2, m.LocalServiceStandardWarranty3, m.LocalServiceStandardWarranty4, m.LocalServiceStandardWarranty5, m.LocalServiceStandardWarranty1P) as StandardWarranty
        from CostCte2 m
    )
    select    m.Id
            , m.Country 
            , m.SogDescription
            , m.Fsp
            , m.WgDescription
            , m.ServiceLocation
            , m.ReactionTime
            , m.Wg
         
            , m.ServiceProduct
            
            , m.StandardWarranty
            , null as StandardWarrantyOld

            , m.Sog

            , (100 * (m.StandardWarranty - null) / m.StandardWarranty) as Bw

    from CostCte3 m
)
GO

declare @reportId bigint = (select Id from Report.Report where upper(Name) = 'CALCOUTPUT-NEW-VS-OLD');
declare @index int = 0;

delete from Report.ReportColumn where ReportId = @reportId;

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Country', 'Country Name', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'SogDescription', 'Portfolio Alignment', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Fsp', 'Product_No', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'WgDescription', 'Warranty Group Name', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ServiceLocation', 'Service Level', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ReactionTime', 'Reaction Time', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Wg', 'Warranty Group', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ServiceProduct', 'Service Product', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 4, 'StandardWarranty', 'NEW - Service standard warranty', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 4, 'StandardWarrantyOld', 'OLD - Service standard warranty', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 5, 'Bw', 'b/w %', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 5, 'Sog', 'SOG', 1, 1);

set @index = 0;
delete from Report.ReportFilter where ReportId = @reportId;
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 7, 'cnt', 'Country Name');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 4, 'wg', 'Warranty Group');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 8, 'av', 'Availability');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 9, 'dur', 'Service period');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 10, 'reactiontime', 'Reaction time');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 11, 'reactiontype', 'Reaction type');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, 12, 'loc', 'Service location');

GO