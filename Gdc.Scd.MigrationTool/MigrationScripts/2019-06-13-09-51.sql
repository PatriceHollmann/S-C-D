ALTER FUNCTION [SoftwareSolution].[GetCosts] (
     @approved bit,
    @digit dbo.ListID readonly,
    @av dbo.ListID readonly,
    @year dbo.ListID readonly,
    @lastid bigint,
    @limit int
)
RETURNS TABLE 
AS
RETURN 
(
    with GermanyServiceCte as (
        SELECT top(1)
                  case when @approved = 0 then ssc.[1stLevelSupportCostsCountry] else ssc.[1stLevelSupportCostsCountry_Approved] end / er.Value as [1stLevelSupportCosts]
                , case when @approved = 0 then ssc.TotalIb else TotalIb_Approved end as TotalIb

        FROM Hardware.ServiceSupportCost ssc
        JOIN InputAtoms.Country c on c.Id = ssc.Country and c.ISO3CountryCode = 'DEU' --install base by Germany!
        LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId
    )
    , SwSpMaintenanceCte0 as (
            SELECT  ssm.rownum
                    , ssm.Id
                    , ssm.SwDigit
                    , ssm.Sog
                    , ssm.Pla
                    , ssm.Sfab
                    , ssm.Availability
                    , ssm.Year
                    , y.Value as YearValue
                    , y.IsProlongation

                    , ssm.[2ndLevelSupportCosts]
                    , ssm.InstalledBaseSog
                    , ssm.TotalInstalledBaseSog
           
                    , case when ssm.ReinsuranceFlatfee is null 
                            then ssm.ShareSwSpMaintenanceListPrice / 100 * ssm.RecommendedSwSpMaintenanceListPrice 
                            else ssm.ReinsuranceFlatfee / er.Value
                       end as Reinsurance

                    , ssm.ShareSwSpMaintenanceListPrice / 100                      as ShareSwSpMaintenance

                    , ssm.RecommendedSwSpMaintenanceListPrice                      as MaintenanceListPrice

                    , ssm.MarkupForProductMarginSwLicenseListPrice / 100           as MarkupForProductMargin

                    , ssm.DiscountDealerPrice / 100                                as DiscountDealerPrice

            FROM SoftwareSolution.GetSwSpMaintenancePaging(@approved, @digit, @av, @year, @lastid, @limit) ssm
            INNER JOIN Dependencies.Year y on y.Id = ssm.Year
            LEFT JOIN [References].ExchangeRate er on er.CurrencyId = ssm.CurrencyReinsurance    
    )
    , SwSpMaintenanceCte as (
        select    m.*
                , ssc.[1stLevelSupportCosts]
                , ssc.TotalIb

                , SoftwareSolution.CalcSrvSupportCost(ssc.[1stLevelSupportCosts], m.[2ndLevelSupportCosts], ssc.TotalIb, m.InstalledBaseSog) as ServiceSupportPerYear

        from SwSpMaintenanceCte0 m, GermanyServiceCte ssc 
    )
    , SwSpMaintenanceCte2 as (
        select m.*

                , m.ServiceSupportPerYear * m.YearValue as ServiceSupport

                , SoftwareSolution.CalcTransferPrice(m.Reinsurance, m.ServiceSupportPerYear * m.YearValue) as TransferPrice

            from SwSpMaintenanceCte m
    )
    , SwSpMaintenanceCte3 as (
        select m.rownum
                , m.Id
                , m.SwDigit
                , m.Sog
                , m.Pla
                , m.Sfab
                , m.Availability
                , m.Year
                , m.[1stLevelSupportCosts]
                , m.[2ndLevelSupportCosts]
                , m.InstalledBaseSog
                , m.TotalIb as InstalledBaseCountry
                , m.TotalInstalledBaseSog
                , m.Reinsurance
                , m.ShareSwSpMaintenance
                , m.DiscountDealerPrice
                , m.ServiceSupport
                , m.TransferPrice

            , case when m.MaintenanceListPrice is null 
                        then SoftwareSolution.CalcMaintenanceListPrice(m.TransferPrice, m.MarkupForProductMargin)
                        else m.MaintenanceListPrice
                end as MaintenanceListPrice

        from SwSpMaintenanceCte2 m
    )
    select m.*
            , SoftwareSolution.CalcDealerPrice(m.MaintenanceListPrice, m.DiscountDealerPrice) as DealerPrice 
    from SwSpMaintenanceCte3 m
)

go

IF OBJECT_ID('Report.SwParamOverview') IS NOT NULL
  DROP FUNCTION Report.SwParamOverview;
go 

CREATE FUNCTION [Report].[SwParamOverview]
(
    @cnt bigint,
    @sog bigint,
    @digit dbo.ListID readonly,
    @av dbo.ListID readonly,
    @year dbo.ListID readonly
)
RETURNS TABLE 
AS
RETURN (
    with GermanyServiceCte as (
        SELECT top(1)
                  ssc.[1stLevelSupportCostsCountry_Approved] / er.Value as [1stLevelSupportCosts]
                , ssc.TotalIb_Approved as TotalIb

        FROM Hardware.ServiceSupportCost ssc
        JOIN InputAtoms.Country c on c.Id = ssc.Country and c.ISO3CountryCode = 'DEU' --install base by Germany!
        LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId
    )
    , ProCte as (
        select   pro.Country
               , pro.SwDigit
               , pro.LocalRemoteAccessSetupPreparationEffort_Approved as LocalRemoteAccessSetupPreparationEffort
               , pro.LocalRegularUpdateReadyEffort_Approved as LocalRegularUpdateReadyEffort
               , pro.LocalPreparationShcEffort_Approved as LocalPreparationShcEffort
               , pro.CentralExecutionShcReportCost_Approved as CentralExecutionShcReportCost
               , pro.LocalRemoteShcCustomerBriefingEffort_Approved as LocalRemoteShcCustomerBriefingEffort
               , pro.LocalOnSiteShcCustomerBriefingEffort_Approved as LocalOnSiteShcCustomerBriefingEffort
               , pro.TravellingTime_Approved as TravellingTime
               , pro.OnSiteHourlyRate_Approved as OnSiteHourlyRate

        from SoftwareSolution.ProActiveSw pro
        where    pro.Country = @cnt 
             and pro.DeactivatedDateTime is null
    )
    , cte as (
        select   c.Name as Country
               , sog.Description as SogDescription
               , sog.Name as Sog
               , dig.Name as Digit
               , l.Name as SwProduct
               , dig.Description as DigitDescription

               , av.Name as Availability
               , case when dur.IsProlongation = 0 then CAST(dur.Value as nvarchar(16)) else 'prolongation' end as Duration

               , fsp.Name as Fsp
               , fsp.ShortDescription FspDescription

               , (select [1stLevelSupportCosts] from GermanyServiceCte) as [1stLevelSupportCosts]
               , m.[2ndLevelSupportCosts_Approved] as [2ndLevelSupportCosts]
       
               , (select TotalIb from GermanyServiceCte) as TotalIb
               , m.InstalledBaseSog as IbDigit

               , cur.Name as CurrencyReinsurance
               , m.ReinsuranceFlatfee_Approved as ReinsuranceFlatfee

               , m.ShareSwSpMaintenanceListPrice_Approved as ShareSwSpMaintenanceListPrice
               , m.RecommendedSwSpMaintenanceListPrice_Approved as RecommendedSwSpMaintenanceListPrice
               , m.DiscountDealerPrice_Approved as DiscountDealerPrice
               , m.MarkupForProductMarginSwLicenseListPrice_Approved as MarkupForProductMarginSwLicenseListPrice

               , pro.LocalRemoteAccessSetupPreparationEffort
               , pro.LocalRegularUpdateReadyEffort
               , pro.LocalPreparationShcEffort
               , pro.CentralExecutionShcReportCost
               , pro.LocalRemoteShcCustomerBriefingEffort
               , pro.LocalOnSiteShcCustomerBriefingEffort
               , pro.TravellingTime
               , pro.OnSiteHourlyRate

        from SoftwareSolution.SwSpMaintenance m
        join ProCte pro on pro.SwDigit = m.SwDigit

        join InputAtoms.Pla pla on pla.Id = m.Pla

        join InputAtoms.Country c on c.id = pro.Country
        join InputAtoms.Sog sog on sog.Id = m.Sog
        join InputAtoms.SwDigit dig on dig.id = m.SwDigit
        join Dependencies.Duration_Availability da on da.id = m.DurationAvailability
        join Dependencies.Availability av on av.id = da.AvailabilityId
        join Dependencies.Duration dur on dur.id = da.YearId

        left join Fsp.SwFspCodeTranslation fsp on fsp.SwDigitId = m.SwDigit and fsp.AvailabilityId = av.Id and fsp.DurationId = dur.Id 

        left join [References].Currency cur on cur.id = m.CurrencyReinsurance_Approved
        left join InputAtoms.SwLicense l on fsp.SwLicenseId = l.Id

        WHERE   (@sog is null or m.Sog = @sog)
            AND (not exists(select 1 from @digit) or exists(select 1 from @digit where id = m.SwDigit     ))
            AND (not exists(select 1 from @av   ) or exists(select 1 from @av    where id = m.Availability))
            AND (not exists(select 1 from @year ) or exists(select 1 from @year  where id = dur.Id        ))
            AND m.DeactivatedDateTime is null
    )
    select *
           , case when TotalIb > 0 then [1stLevelSupportCosts] / TotalIb end as [1stLevelSupportCosts_Calc]
           , case when IbDigit > 0 then [2ndLevelSupportCosts] / IbDigit end as [2ndLevelSupportCosts_Calc]
    from cte
)
GO

declare @reportId bigint = (select Id from Report.Report where upper(Name) = 'SW-PARAM-OVERVIEW');

declare @index int = 0;

delete from Report.ReportColumn where ReportId = @reportId;


set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'SogDescription', 'SOG Name', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Sog', 'SOG', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Digit', 'Digit', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'SwProduct', 'SW Product Order no.', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'DigitDescription', 'SW Product Order no. description', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Availability', 'Availability', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Duration', 'Duration', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'Fsp', 'G_MATNR', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'FspDescription', 'G_MAKTX', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), '1stLevelSupportCosts', '1st level support costs', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), '2ndLevelSupportCosts', '2nd level support costs', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'TotalIb', 'Installed base country', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'IbDigit', 'Installed base Digit', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), '1stLevelSupportCosts_Calc', 'Calculated 1st level support costs', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), '2ndLevelSupportCosts_Calc', 'Calculated 2nd level support costs', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'CurrencyReinsurance', 'Currency Reinsurance', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'ReinsuranceFlatfee', 'Reinsurance flatfee', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('percent'), 'ShareSwSpMaintenanceListPrice', 'Share Reinsurance of SW/SP Maintenance List Price', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'RecommendedSwSpMaintenanceListPrice', 'SW/SP Maintenance List Price', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('percent'), 'DiscountDealerPrice', 'Discount to Dealer price in %', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('percent'), 'MarkupForProductMarginSwLicenseListPrice', 'Markup for Product Margin of SW License List Price (%)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'LocalRemoteAccessSetupPreparationEffort', 'Local Remote-Access setup preparation effort', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'LocalRegularUpdateReadyEffort', 'Local regular update ready for service effort', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'LocalPreparationShcEffort', 'Local preparation SHC effort', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'CentralExecutionShcReportCost', 'Central execution SHC & report cost', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'LocalRemoteShcCustomerBriefingEffort', 'Local remote SHC customer briefing effort', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'LocalOnSiteShcCustomerBriefingEffort', 'Local on-site SHC customer briefing effort', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('text'), 'TravellingTime', 'Travelling Time (MTTT)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('euro'), 'OnSiteHourlyRate', 'On-Site Hourly Rate', 1, 1);

set @index = 0;

delete from Report.ReportFilter where ReportId = @reportId;

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('country', 0), 'cnt', 'Country');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('swdigitsog', 0), 'sog', 'SOG');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('swdigit', 1), 'digit', 'SW digit');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('availability', 1), 'av', 'Availability');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, Report.GetReportFilterTypeByName('year', 1), 'year', 'Year');

GO

USE [SCD_2]
GO

ALTER function [Archive].[GetSwDigit]()
returns @tbl table (
      Id bigint not null primary key
    , Name nvarchar(255)
    , Description nvarchar(255)
    , Sog nvarchar(255)
    , Sfab nvarchar(255)
    , Pla nvarchar(255)
    , ClusterPla nvarchar(255)
)
begin

    insert into @tbl
    select    dig.Id
            , dig.Name
            , dig.Description

            , sog.Name as Sog
            , sfab.Name as Sfab
            , pla.Name as Pla
            , cpla.Name as ClusterPla
    from InputAtoms.SwDigit dig
    left join InputAtoms.Sog sog on sog.Id = dig.SogId and sog.DeactivatedDateTime is null
    left join InputAtoms.Sfab sfab on sfab.Id = sog.SFabId and sfab.DeactivatedDateTime is null
    left join InputAtoms.Pla pla on pla.Id = sfab.PlaId
    left join InputAtoms.ClusterPla cpla on cpla.Id = pla.ClusterPlaId

    where dig.DeactivatedDateTime is null

    return;

end
GO

ALTER procedure [Archive].[spGetSwSpMaintenance]
AS
begin
    select   dig.Name as Digit
           , dig.Description
           , dig.ClusterPla
           , dig.Pla
           , dig.Sfab
           , dig.Sog

           , da.Duration
           , da.Availability

           , m.[2ndLevelSupportCosts_Approved]                   as [2ndLevelSupportCosts]
           , m.InstalledBaseSog_Approved                         as InstalledBaseSog
           , cur.Name                                            as CurrencyReinsurance
           , m.ReinsuranceFlatfee_Approved                       as ReinsuranceFlatfee
           , m.RecommendedSwSpMaintenanceListPrice_Approved      as RecommendedSwSpMaintenanceListPrice
           , m.MarkupForProductMarginSwLicenseListPrice_Approved as MarkupForProductMarginSwLicenseListPrice
           , m.ShareSwSpMaintenanceListPrice_Approved            as ShareSwSpMaintenanceListPrice
           , m.DiscountDealerPrice_Approved                      as DiscountDealerPrice

    from SoftwareSolution.SwSpMaintenance m
    join Archive.GetSwDigit() dig on dig.Id = m.SwDigit
    join Archive.GetDurationAvailability() da on da.Id = m.DurationAvailability
    left join [References].Currency cur on cur.Id = m.CurrencyReinsurance_Approved

    where m.DeactivatedDateTime is null

    order by dig.Name, da.Duration
end
GO

alter FUNCTION [Report].[SolutionPackPriceList]
(
    @digit bigint
)
RETURNS @tbl TABLE (
      License nvarchar(max) NULL
    , SogDescription nvarchar(max) NULL
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
    select    lic.Name as License
            , sog.Description as SogDescription
            , sog.Name as Sog

            , av.Name as Availability
            , y.Name  as Year

            , fsp.Name as Fsp
            , fsp.ServiceDescription as SpDescription
            , null as Sp

            , sw.TransferPrice as TP
            , sw.DealerPrice as DealerPrice
            , sw.MaintenanceListPrice as ListPrice

    from cte sw
    join InputAtoms.SwDigit dig on dig.Id = sw.SwDigit
    join InputAtoms.Sog sog on sog.id = sw.Sog and sog.IsSoftware = 1 and sog.IsSolution = 1
    join Dependencies.Availability av on av.id = sw.Availability
    join Dependencies.Year y on y.Id = sw.Year

    join Fsp.SwFspCodeTranslation fsp on fsp.SwDigitId = sw.SwDigit
                                          and fsp.AvailabilityId = sw.Availability
                                          and fsp.DurationId = sw.Year

    left join InputAtoms.SwDigitLicense dl on dl.SwDigitId = dig.Id
    left join InputAtoms.SwLicense lic on lic.Id = dl.SwLicenseId

    return
end
GO

alter FUNCTION Report.SolutionPackPriceListDetail
(
   @digit bigint
)
RETURNS @tbl TABLE (
      SogDescription nvarchar(max) NULL
    , License nvarchar(max) NULL
    , Fsp nvarchar(max) NULL
    , Sog nvarchar(max) NULL

    , Availability nvarchar(255) NULL
    , Year nvarchar(255) NULL

    , SpDescription nvarchar(max) NULL
    , Sp nvarchar(max) NULL
      
    , ServiceSupport float NULL
      
    , Reinsurance float NULL
      
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
            , lic.Name as License
            , fsp.Name as Fsp
            , sog.Name as Sog

            , av.Name as Availability
            , y.Name  as Year

            , fsp.ServiceDescription as SpDescription
            , sog.Description as Sp

            , sw.ServiceSupport
            
            , sw.Reinsurance as Reinsurance

            , sw.TransferPrice as TP
            , sw.DealerPrice as DealerPrice
            , sw.MaintenanceListPrice as ListPrice

    from cte sw
    join InputAtoms.SwDigit dig on dig.Id = sw.SwDigit
    join InputAtoms.Sog sog on sog.id = sw.Sog and sog.IsSoftware = 1 and sog.IsSolution = 1

    join Dependencies.Availability av on av.id = sw.Availability
    join Dependencies.Year y on y.Id = sw.Year

    join Fsp.SwFspCodeTranslation fsp on fsp.SwDigitId = sw.SwDigit
                                          and fsp.AvailabilityId = sw.Availability
                                          and fsp.DurationId = sw.Year

    left join InputAtoms.SwDigitLicense dl on dl.SwDigitId = dig.Id
    left join InputAtoms.SwLicense lic on lic.Id = dl.SwLicenseId;

    return
end
GO

IF OBJECT_ID('Report.HwCalcResult') IS NOT NULL
  DROP FUNCTION Report.HwCalcResult;
go 

CREATE FUNCTION Report.HwCalcResult
(
    @approved bit,
    @local bit,
    @country         dbo.ListID readonly,
    @wg              dbo.ListID readonly,
    @availability    dbo.ListID readonly,
    @duration        dbo.ListID readonly,
    @reactiontime    dbo.ListID readonly,
    @reactiontype    dbo.ListID readonly,
    @servicelocation dbo.ListID readonly,
    @proactive       dbo.ListID readonly
)
RETURNS TABLE 
AS
RETURN (
    select    Country
            , case when @local = 1 then c.Name else 'EUR' end as Currency

            , sog.Name as SOG
            , Wg
            , Availability
            , Duration
            , ReactionTime
            , ReactionType
            , ServiceLocation
            , ProActiveSla

            , StdWarranty
            , StdWarrantyLocation

            --Cost

            , case when @local = 1 then AvailabilityFee * costs.ExchangeRate else AvailabilityFee end as AvailabilityFee 
            , case when @local = 1 then TaxAndDutiesW * costs.ExchangeRate else TaxAndDutiesW end as TaxAndDutiesW
            , case when @local = 1 then TaxAndDutiesOow * costs.ExchangeRate else TaxAndDutiesOow end as TaxAndDutiesOow
            , case when @local = 1 then Reinsurance * costs.ExchangeRate else Reinsurance end as Reinsurance
            , case when @local = 1 then ProActive * costs.ExchangeRate else ProActive end as ProActive
            , case when @local = 1 then ServiceSupportCost * costs.ExchangeRate else ServiceSupportCost end as ServiceSupportCost
                                                          
            , case when @local = 1 then MaterialW * costs.ExchangeRate else MaterialW end as MaterialW
            , case when @local = 1 then MaterialOow * costs.ExchangeRate else MaterialOow end as MaterialOow
            , case when @local = 1 then FieldServiceCost * costs.ExchangeRate else FieldServiceCost end as FieldServiceCost
            , case when @local = 1 then Logistic * costs.ExchangeRate else Logistic end as Logistic
            , case when @local = 1 then OtherDirect * costs.ExchangeRate else OtherDirect end as OtherDirect
            , coalesce(LocalServiceStandardWarrantyManual, LocalServiceStandardWarranty) * iif(@local = 1, costs.ExchangeRate, 1) as LocalServiceStandardWarranty
            , case when @local = 1 then Credits * costs.ExchangeRate else Credits end as Credits
            , case when @local = 1 then ServiceTC * costs.ExchangeRate else ServiceTC end as ServiceTC
            , case when @local = 1 then ServiceTP * costs.ExchangeRate else ServiceTP end as ServiceTP
                                                          
            , case when @local = 1 then ServiceTCManual * costs.ExchangeRate else ServiceTCManual end as ServiceTCManual
            , case when @local = 1 then ServiceTPManual * costs.ExchangeRate else ServiceTPManual end as ServiceTPManual
                                                          
            , case when @local = 1 then ServiceTP_Released * costs.ExchangeRate else ServiceTP_Released end as ServiceTP_Released

            , case when @local = 1 then ListPrice * costs.ExchangeRate else ListPrice end as ListPrice
            , case when @local = 1 then DealerPrice * costs.ExchangeRate else DealerPrice end as DealerPrice
            , DealerDiscount                               as DealerDiscount
                                                           
            , ChangeUserName + '[' + ChangeUserEmail + ']' as ChangeUser
            , ReleaseDate
            , ChangeDate

    from Hardware.GetCosts(@approved, @country, @wg, @availability, @duration, @reactiontime, @reactiontype, @servicelocation, @proactive, -1, -1) costs
    join [References].Currency c on c.Id = costs.CurrencyId
    join InputAtoms.Wg wg on wg.id = costs.WgId
    LEFT JOIN InputAtoms.Sog sog on sog.Id = wg.SogId
)

GO

declare @reportId bigint = (select Id from Report.Report where upper(Name) = 'HW-CALC-RESULT');
declare @index int = 0;

delete from Report.ReportColumn where ReportId = @reportId;

declare @money bigint;
select @money = id from Report.ReportColumnType where upper(name) = 'MONEY';

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Country', 'Country', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'SOG', 'SOG', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Wg', 'WG(Asset)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Availability', 'Availability', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'Duration', 'Duration', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ReactionType', 'Reaction type', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ReactionTime', 'Reaction time', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ServiceLocation', 'Service location', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ProActiveSla', 'ProActive SLA', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'StdWarranty', 'Standard warranty duration', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'StdWarrantyLocation', 'Standard Warranty Service Location', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'FieldServiceCost', 'Field service cost', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'ServiceSupportCost', 'Service support cost', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'Logistic', 'Logistic cost', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'AvailabilityFee', 'Availability fee', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'Reinsurance', 'Reinsurance', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'TaxAndDutiesW', 'Tax & Duties iW period', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'TaxAndDutiesOow', 'Tax & Duties OOW period', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'MaterialW', 'Material cost iW period', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'MaterialOow', 'Material cost OOW period', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'ProActive', 'ProActive', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'ServiceTC', 'Service TC(calc)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'ServiceTCManual', 'Service TC(manual)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'ServiceTP', 'Service TP(calc)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'ServiceTPManual', 'Service TP(manual)', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'ServiceTP_Released', 'Service TP(released)', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'ListPrice', 'List price', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 5, 'DealerDiscount', 'Dealer discount in %', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'DealerPrice', 'Dealer price', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, 1, 'ChangeUser', 'Change user', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('datetime'), 'ReleaseDate', 'Release date', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, Report.GetReportColumnTypeByName('datetime'), 'ChangeDate', 'Change date', 1, 1);

set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'OtherDirect', 'Other direct cost', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'LocalServiceStandardWarranty', 'Local service standard warranty', 1, 1);
set @index = @index + 1;
insert into Report.ReportColumn(ReportId, [Index], TypeId, Name, Text, AllowNull, Flex) values(@reportId, @index, @money, 'Credits', 'Credits', 1, 1);

------------------------------------
set @index = 0;
delete from Report.ReportFilter where ReportId = @reportId;
declare @filterTypeId bigint = 0

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'boolean'), 'approved', 'Approved');
set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'boolean'), 'local', 'Local currency');

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'country' and MultiSelect=1), 'country', 'Country');

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'wg' and MultiSelect=1), 'wg', 'Asset(WG)');

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'availability' and MultiSelect=1), 'availability', 'Availability');

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'duration' and MultiSelect=1), 'duration', 'Duration');

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'reactiontime' and MultiSelect=1), 'reactiontime', 'Reaction time');

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'reactiontype' and MultiSelect=1), 'reactiontype', 'Reaction type');

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'servicelocation' and MultiSelect=1), 'servicelocation', 'Service location');

set @index = @index + 1;
insert into Report.ReportFilter(ReportId, [Index], TypeId, Name, Text) values(@reportId, @index, (select Id from Report.ReportFilterType where Name = 'proactive' and MultiSelect=1), 'proactive', 'ProActive');


go
