ALTER FUNCTION [Hardware].[GetCostsSlaSog](
    @approved bit,
    @cnt dbo.ListID readonly,
    @wg dbo.ListID readonly,
    @av dbo.ListID readonly,
    @dur dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc dbo.ListID readonly,
    @pro dbo.ListID readonly
)
RETURNS TABLE 
AS
RETURN 
(
    with cte as (
        select    
               m.Id

             --SLA

             , m.CountryId
             , m.Country
             , m.CurrencyId
             , m.Currency
             , m.ExchangeRate

             , m.WgId
             , m.Wg
             , wg.Description as WgDescription
             , m.SogId
             , m.Sog

             , m.AvailabilityId
             , m.Availability
             , m.DurationId
             , m.Duration
             , m.Year
             , m.IsProlongation
             , m.ReactionTimeId
             , m.ReactionTime
             , m.ReactionTypeId
             , m.ReactionType
             , m.ServiceLocationId
             , m.ServiceLocation
             , m.ProActiveSlaId
             , m.ProActiveSla
             , m.Sla
             , m.SlaHash

             , m.StdWarranty
             , m.StdWarrantyLocation

             --Cost

             , m.AvailabilityFee
             , m.TaxAndDutiesW
             , m.TaxAndDutiesOow
             , m.Reinsurance
             , m.ProActive
             , m.ServiceSupportCost
             , m.MaterialW
             , m.MaterialOow
             , m.FieldServiceCost
             , m.Logistic
             , m.OtherDirect
             , coalesce(m.LocalServiceStandardWarrantyManual, m.LocalServiceStandardWarranty) as LocalServiceStandardWarranty
             , m.Credits

             , ib.InstalledBaseCountryNorm

             , (sum(m.ServiceTCResult * ib.InstalledBaseCountryNorm)                               over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_x_tc 
             , (sum(case when m.ServiceTCResult <> 0 then ib.InstalledBaseCountryNorm end)          over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_by_tc

             , (sum(m.ServiceTP_Released * ib.InstalledBaseCountryNorm)                      over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_x_tp_Released
             , (sum(case when m.ServiceTP_Released <> 0 then ib.InstalledBaseCountryNorm end) over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_by_tp_Released

             , (sum(m.ServiceTPResult * ib.InstalledBaseCountryNorm)                               over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_x_tp
             , (sum(case when m.ServiceTPResult <> 0 then ib.InstalledBaseCountryNorm end)          over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as sum_ib_by_tp

             , (max(m.ReleaseDate)                                                           over(partition by wg.SogId, m.AvailabilityId, m.DurationId, m.ReactionTimeId, m.ReactionTypeId, m.ServiceLocationId, m.ProActiveSlaId)) as ReleaseDate

             , m.ListPrice
             , m.DealerDiscount
             , m.DealerPrice

        from Hardware.GetCosts(@approved, @cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, null, null) m
        join InputAtoms.Wg wg on wg.id = m.WgId and wg.DeactivatedDateTime is null
        left join Hardware.GetInstallBaseOverSog(@approved, @cnt) ib on ib.Country = m.CountryId and ib.Wg = m.WgId
    )
    select    
            m.Id

            --SLA

            , m.CountryId
            , m.Country
            , m.CurrencyId
            , m.Currency
            , m.ExchangeRate

            , m.WgId
            , m.Wg
            , m.WgDescription
            , m.SogId
            , m.Sog

            , m.AvailabilityId
            , m.Availability
            , m.DurationId
            , m.Duration
            , m.Year
            , m.IsProlongation
            , m.ReactionTimeId
            , m.ReactionTime
            , m.ReactionTypeId
            , m.ReactionType
            , m.ServiceLocationId
            , m.ServiceLocation
            , m.ProActiveSlaId
            , m.ProActiveSla
            , m.Sla
            , m.SlaHash

            , m.StdWarranty
            , m.StdWarrantyLocation

            --Cost

            , m.AvailabilityFee
            , m.TaxAndDutiesW
            , m.TaxAndDutiesOow
            , m.Reinsurance
            , m.ProActive
            , m.ServiceSupportCost
            , m.MaterialW
            , m.MaterialOow
            , m.FieldServiceCost
            , m.Logistic
            , m.OtherDirect
            , m.LocalServiceStandardWarranty
            , m.Credits

            , case when m.sum_ib_x_tc <> 0 and m.sum_ib_by_tc <> 0 then m.sum_ib_x_tc / m.sum_ib_by_tc else 0 end as ServiceTcSog
            , case when m.sum_ib_x_tp <> 0 and m.sum_ib_by_tp <> 0 then m.sum_ib_x_tp / m.sum_ib_by_tp else 0 end as ServiceTpSog
            , case when m.sum_ib_x_tp_Released <> 0 and m.sum_ib_by_tp_Released <> 0 then m.sum_ib_x_tp_Released / m.sum_ib_by_tp_Released 
                   when m.ReleaseDate is not null then 0 end as ServiceTpSog_Released

            , m.ReleaseDate

            , m.ListPrice
            , m.DealerDiscount
            , m.DealerPrice  

    from cte m
)
go

ALTER PROCEDURE [Report].[spLocapGlobalSupport]
(
    @approved bit,
    @cnt      dbo.ListID readonly,
    @sog      bigint,
    @wg       dbo.ListID readonly,
    @av       dbo.ListID readonly,
    @dur      dbo.ListID readonly,
    @rtime    dbo.ListID readonly,
    @rtype    dbo.ListID readonly,
    @loc      dbo.ListID readonly,
    @pro      dbo.ListID readonly,
    @lastid   int,
    @limit    int
)
AS
BEGIN

    if OBJECT_ID('tempdb..#tmp') is not null drop table #tmp;

    --Calc for Emeia countries by SOG

    declare @emeiaCnt dbo.ListID;
    declare @emeiaWg dbo.ListId;

    insert into @emeiaCnt(id)
    select c.Id
    from InputAtoms.Country c 
    join InputAtoms.ClusterRegion cr on cr.id = c.ClusterRegionId
    where exists (select * from @cnt where id = c.Id) and cr.IsEmeia = 1;

    insert into @emeiaWg
    select id
    from InputAtoms.Wg 
    where (@sog is null or SogId = @sog)
    and SogId in (select wg.SogId from InputAtoms.Wg wg  where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = wg.Id)))
    and IsSoftware = 0
    and SogId is not null
    and DeactivatedDateTime is null;

    with cte as (
        select m.* 
                , case when m.IsProlongation = 1 then 'Prolongation' else CAST(m.Year as varchar(1)) end as ServicePeriod
        from Hardware.GetCostsSlaSog(1, @emeiaCnt, @emeiaWg, @av, @dur, @rtime, @rtype, @loc, @pro) m
        where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = m.WgId))
    )
    , cte2 as (
        select    m.*
                , cnt.ISO3CountryCode
                , fsp.Name as Fsp
                , fsp.ServiceDescription as FspDescription

                , sog.SogDescription

        from cte m
        inner join InputAtoms.Country cnt on cnt.id = m.CountryId
        inner join InputAtoms.WgSogView sog on sog.Id = m.WgId
        left join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla
    )
    select    c.Country
            , c.ISO3CountryCode
            , c.Fsp
            , c.FspDescription

            , c.SogDescription
            , c.Sog        
            , c.Wg

            , c.ServiceLocation
            , c.ReactionTime + ' ' + c.ReactionType + ' time, ' + c.Availability as ReactionTime
            , case when c.IsProlongation = 1 then 'Prolongation' else CAST(c.Year as varchar(1)) end as ServicePeriod
            , LOWER(c.Duration) + ' ' + c.ServiceLocation as ServiceProduct

            , c.LocalServiceStandardWarranty
            , case when @approved = 1 then c.ServiceTpSog else c.ServiceTpSog_Released end as ServiceTP
            , c.DealerPrice
            , c.ListPrice
    into #tmp
    from cte2 c

    --Calc for non-Emeia countries by WG

    declare @nonEmeiaCnt dbo.ListID;
    declare @nonEmeiaWg dbo.ListID;

    insert into @nonEmeiaCnt(id)
    select c.Id
    from InputAtoms.Country c 
    join InputAtoms.ClusterRegion cr on cr.id = c.ClusterRegionId
    where exists (select * from @cnt where id = c.Id) and cr.IsEmeia = 0;

    insert into @nonEmeiaWg(id)
    select id
    from InputAtoms.Wg wg 
    where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = wg.Id))
          and (@sog is null or wg.SogId = @sog)
          and IsSoftware = 0
          and DeactivatedDateTime is null;

    insert into #tmp
    select    c.Country
            , cnt.ISO3CountryCode
            , fsp.Name as Fsp
            , fsp.ServiceDescription as FspDescription

            , sog.SogDescription
            , c.Sog        
            , c.Wg

            , c.ServiceLocation
            , c.ReactionTime + ' ' + c.ReactionType + ' time, ' + c.Availability as ReactionTime
            , case when c.IsProlongation = 1 then 'Prolongation' else CAST(c.Year as varchar(1)) end as ServicePeriod
            , LOWER(c.Duration) + ' ' + c.ServiceLocation as ServiceProduct

            , c.LocalServiceStandardWarranty
            , case when @approved = 1 then c.ServiceTP else c.ServiceTP_Released end as ServiceTP
            , c.DealerPrice
            , c.ListPrice
    from Hardware.GetCosts(1, @nonEmeiaCnt, @nonEmeiaWg, @av, @dur, @rtime, @rtype, @loc, @pro, null, null) c
    inner join InputAtoms.Country cnt on cnt.id = c.CountryId
    inner join InputAtoms.WgSogView sog on sog.Id = c.WgId
    left join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = c.SlaHash and fsp.Sla = c.Sla;

    if @limit > 0
        select * from (
            select ROW_NUMBER() over(order by Country,Wg) as rownum, * from #tmp
        ) t
        where rownum > @lastid and rownum <= @lastid + @limit;
    else
        select * from #tmp order by Country,Wg;

END
GO

ALTER PROCEDURE [Report].[spLocap]
(
    @cnt          bigint,
    @wg           dbo.ListID readonly,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint,
    @lastid       bigint,
    @limit        int
)
AS
BEGIN

    declare @cntTable dbo.ListId; insert into @cntTable(id) values(@cnt);

    declare @wg_SOG_Table dbo.ListId;
    insert into @wg_SOG_Table
    select id
        from InputAtoms.Wg 
        where SogId in (
            select wg.SogId from InputAtoms.Wg wg  where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = wg.Id))
        )
        and IsSoftware = 0
        and SogId is not null
        and DeactivatedDateTime is null;

    if not exists(select id from @wg_SOG_Table) return;

    declare @avTable dbo.ListId; if @av is not null insert into @avTable(id) values(@av);

    declare @durTable dbo.ListId; if @dur is not null insert into @durTable(id) values(@dur);

    declare @rtimeTable dbo.ListId; if @reactiontime is not null insert into @rtimeTable(id) values(@reactiontime);

    declare @rtypeTable dbo.ListId; if @reactiontype is not null insert into @rtypeTable(id) values(@reactiontype);

    declare @locTable dbo.ListId; if @loc is not null insert into @locTable(id) values(@loc);

    declare @proTable dbo.ListId; if @pro is not null insert into @proTable(id) values(@pro);

    with cte as (
        select m.* 
               , case when m.IsProlongation = 1 then 'Prolongation' else CAST(m.Year as varchar(1)) end as ServicePeriod
        from Hardware.GetCostsSlaSog(1, @cntTable, @wg_SOG_Table, @avTable, @durTable, @rtimeTable, @rtypeTable, @locTable, @proTable) m
        where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = m.WgId))
    )
    , cte2 as (
        select  
                ROW_NUMBER() over(ORDER BY (SELECT 1)) as rownum

                , m.*
                , fsp.Name as Fsp
                , fsp.ServiceDescription as ServiceLevel

        from cte m
        left join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla
    )
    select    m.Id
            , m.Fsp
            , m.WgDescription
            , m.ServiceLevel

            , m.ReactionTime
            , m.ServicePeriod
            , m.Wg

            , m.StdWarranty
            , m.StdWarrantyLocation

            , m.LocalServiceStandardWarranty * m.ExchangeRate as LocalServiceStandardWarranty
            , m.ServiceTcSog * m.ExchangeRate as ServiceTC
            , m.ServiceTpSog_Released  * m.ExchangeRate as ServiceTP_Released
            , m.ReleaseDate

            , m.Currency
         
            , m.Country
            , m.Availability                       + ', ' +
                  m.ReactionType                   + ', ' +
                  m.ReactionTime                   + ', ' +
                  m.ServicePeriod                  + ', ' +
                  m.ServiceLocation                + ', ' +
                  m.ProActiveSla as ServiceType

            , null as PlausiCheck
            , null as PortfolioType
            , m.Sog

    from cte2 m

    where (@limit is null) or (m.rownum > @lastid and m.rownum <= @lastid + @limit);

END
go

ALTER PROCEDURE [Report].[spLocapApproved]
(
    @cnt          bigint,
    @wg           dbo.ListID readonly,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint,
    @lastid       bigint,
    @limit        int
)
AS
BEGIN

    declare @cntTable dbo.ListId; insert into @cntTable(id) values(@cnt);

    declare @wg_SOG_Table dbo.ListId;
    insert into @wg_SOG_Table
    select id
        from InputAtoms.Wg 
        where SogId in (
            select wg.SogId from InputAtoms.Wg wg  where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = wg.Id))
        )
        and IsSoftware = 0
        and SogId is not null
        and DeactivatedDateTime is null;

    if not exists(select id from @wg_SOG_Table) return;

    declare @avTable dbo.ListId; if @av is not null insert into @avTable(id) values(@av);

    declare @durTable dbo.ListId; if @dur is not null insert into @durTable(id) values(@dur);

    declare @rtimeTable dbo.ListId; if @reactiontime is not null insert into @rtimeTable(id) values(@reactiontime);

    declare @rtypeTable dbo.ListId; if @reactiontype is not null insert into @rtypeTable(id) values(@reactiontype);

    declare @locTable dbo.ListId; if @loc is not null insert into @locTable(id) values(@loc);

    declare @proTable dbo.ListId; if @pro is not null insert into @proTable(id) values(@pro);

    with cte as (
        select m.* 
               , case when m.IsProlongation = 1 then 'Prolongation' else CAST(m.Year as varchar(1)) end as ServicePeriod
        from Hardware.GetCostsSlaSog(1, @cntTable, @wg_SOG_Table, @avTable, @durTable, @rtimeTable, @rtypeTable, @locTable, @proTable) m
        where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = m.WgId))
    )
    , cte2 as (
        select  
                ROW_NUMBER() over(ORDER BY (SELECT 1)) as rownum

                , m.*
                , fsp.Name as Fsp
                , fsp.ServiceDescription as ServiceLevel

        from cte m
        left join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla
    )
    select    m.Id
            , m.Fsp
            , m.WgDescription
            , m.ServiceLevel

            , m.ReactionTime
            , m.ServicePeriod
            , m.Wg

            , m.StdWarranty
            , m.StdWarrantyLocation

            , m.LocalServiceStandardWarranty * m.ExchangeRate as LocalServiceStandardWarranty
            
            , m.ServiceTcSog * m.ExchangeRate as ServiceTC
            , m.ServiceTpSog_Released  * m.ExchangeRate as ServiceTP_Released
            , m.ServiceTpSog * m.ExchangeRate as ServiceTP_Approved
            , m.ReleaseDate

            , m.Currency
         
            , m.Country
            , m.Availability                       + ', ' +
                  m.ReactionType                   + ', ' +
                  m.ReactionTime                   + ', ' +
                  m.ServicePeriod                  + ', ' +
                  m.ServiceLocation                + ', ' +
                  m.ProActiveSla as ServiceType

            , null as PlausiCheck
            , null as PortfolioType
            , m.Sog

    from cte2 m

    where (@limit is null) or (m.rownum > @lastid and m.rownum <= @lastid + @limit);

END
go

ALTER PROCEDURE [Report].[spLocapDetailed]
(
    @cnt          bigint,
    @wg           dbo.ListID readonly,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint,
    @lastid       int,
    @limit        int
)
AS
BEGIN

    declare @cntTable dbo.ListId; insert into @cntTable(id) values(@cnt);

    declare @wg_SOG_Table dbo.ListId;
    insert into @wg_SOG_Table
    select id
        from InputAtoms.Wg 
        where SogId in (
            select wg.SogId from InputAtoms.Wg wg  where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = wg.Id))
        )
        and IsSoftware = 0
        and SogId is not null
        and DeactivatedDateTime is null;

    if not exists(select id from @wg_SOG_Table) return;

    declare @avTable dbo.ListId; if @av is not null insert into @avTable(id) values(@av);

    declare @durTable dbo.ListId; if @dur is not null insert into @durTable(id) values(@dur);

    declare @rtimeTable dbo.ListId; if @reactiontime is not null insert into @rtimeTable(id) values(@reactiontime);

    declare @rtypeTable dbo.ListId; if @reactiontype is not null insert into @rtypeTable(id) values(@reactiontype);

    declare @locTable dbo.ListId; if @loc is not null insert into @locTable(id) values(@loc);

    declare @proTable dbo.ListId; if @pro is not null insert into @proTable(id) values(@pro);

    with cte as (
        select m.* 
               , case when m.IsProlongation = 1 then 'Prolongation' else CAST(m.Year as varchar(1)) end as ServicePeriod
        from Hardware.GetCostsSlaSog(1, @cntTable, @wg_SOG_Table, @avTable, @durTable, @rtimeTable, @rtypeTable, @locTable, @proTable) m
        where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = m.WgId))
    )
    , cte2 as (
        select  
                ROW_NUMBER() over(ORDER BY (SELECT 1)) as rownum

                , m.*
                , fsp.Name as Fsp
                , fsp.ServiceDescription as ServiceLevel

        from cte m
        left join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla
    )
    select     m.Id
             , m.Fsp
             , m.WgDescription
             , m.Wg
             , sog.Description as SogDescription
             , m.ServiceLocation as ServiceLevel
             , m.ReactionTime
             , m.ServicePeriod
             , m.Sog
             , m.ProActiveSla
             , m.Country

             , m.StdWarranty
             , m.StdWarrantyLocation

             , m.ServiceTcSog * m.ExchangeRate as ServiceTC
             , m.ServiceTpSog_Released * m.ExchangeRate as ServiceTP_Released

             , m.ReleaseDate

             , m.FieldServiceCost * m.ExchangeRate as FieldServiceCost
             , m.ServiceSupportCost * m.ExchangeRate as ServiceSupportCost 
             , m.MaterialOow * m.ExchangeRate as MaterialOow
             , m.MaterialW * m.ExchangeRate as MaterialW
             , m.TaxAndDutiesW * m.ExchangeRate as TaxAndDutiesW
             , m.Logistic * m.ExchangeRate as LogisticW
             , m.Logistic * m.ExchangeRate as LogisticOow
             , m.Reinsurance * m.ExchangeRate as Reinsurance
             , m.Reinsurance * m.ExchangeRate as ReinsuranceOow
             , m.OtherDirect * m.ExchangeRate as OtherDirect
             , m.Credits * m.ExchangeRate as Credits
             , m.LocalServiceStandardWarranty * m.ExchangeRate as LocalServiceStandardWarranty
             , m.Currency

             , m.Availability                       + ', ' +
                   m.ReactionType                   + ', ' +
                   m.ReactionTime                   + ', ' +
                   m.ServicePeriod                  + ', ' +
                   m.ServiceLocation                + ', ' +
                   m.ProActiveSla as ServiceType

    from cte2 m
    join InputAtoms.Sog sog on sog.id = m.SogId

    where (@limit is null) or (m.rownum > @lastid and m.rownum <= @lastid + @limit);

END
go

ALTER PROCEDURE [Report].[spLocapDetailedApproved]
(
    @cnt          bigint,
    @wg           dbo.ListID readonly,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint,
    @lastid       int,
    @limit        int
)
AS
BEGIN

    declare @cntTable dbo.ListId; insert into @cntTable(id) values(@cnt);

    declare @wg_SOG_Table dbo.ListId;
    insert into @wg_SOG_Table
    select id
        from InputAtoms.Wg 
        where SogId in (
            select wg.SogId from InputAtoms.Wg wg  where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = wg.Id))
        )
        and IsSoftware = 0
        and SogId is not null
        and DeactivatedDateTime is null;

    if not exists(select id from @wg_SOG_Table) return;

    declare @avTable dbo.ListId; if @av is not null insert into @avTable(id) values(@av);

    declare @durTable dbo.ListId; if @dur is not null insert into @durTable(id) values(@dur);

    declare @rtimeTable dbo.ListId; if @reactiontime is not null insert into @rtimeTable(id) values(@reactiontime);

    declare @rtypeTable dbo.ListId; if @reactiontype is not null insert into @rtypeTable(id) values(@reactiontype);

    declare @locTable dbo.ListId; if @loc is not null insert into @locTable(id) values(@loc);

    declare @proTable dbo.ListId; if @pro is not null insert into @proTable(id) values(@pro);

    with cte as (
        select m.* 
               , case when m.IsProlongation = 1 then 'Prolongation' else CAST(m.Year as varchar(1)) end as ServicePeriod
        from Hardware.GetCostsSlaSog(1, @cntTable, @wg_SOG_Table, @avTable, @durTable, @rtimeTable, @rtypeTable, @locTable, @proTable) m
        where (not exists(select 1 from @wg) or exists(select 1 from @wg where id = m.WgId))
    )
    , cte2 as (
        select  
                ROW_NUMBER() over(ORDER BY (SELECT 1)) as rownum

                , m.*
                , fsp.Name as Fsp
                , fsp.ServiceDescription as ServiceLevel

        from cte m
        left join Fsp.HwFspCodeTranslation fsp on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla
    )
    select     m.Id
             , m.Fsp
             , m.WgDescription
             , m.Wg
             , sog.Description as SogDescription
             , m.ServiceLocation as ServiceLevel
             , m.ReactionTime
             , m.ServicePeriod
             , m.Sog
             , m.ProActiveSla
             , m.Country

             , m.StdWarranty
             , m.StdWarrantyLocation

             , m.ServiceTcSog * m.ExchangeRate as ServiceTC
             , m.ServiceTpSog * m.ExchangeRate as ServiceTP_Approved
             , m.ServiceTpSog_Released * m.ExchangeRate as ServiceTP_Released

             , m.ReleaseDate

             , m.FieldServiceCost * m.ExchangeRate as FieldServiceCost
             , m.ServiceSupportCost * m.ExchangeRate as ServiceSupportCost 
             , m.MaterialOow * m.ExchangeRate as MaterialOow
             , m.MaterialW * m.ExchangeRate as MaterialW
             , m.TaxAndDutiesW * m.ExchangeRate as TaxAndDutiesW
             , m.Logistic * m.ExchangeRate as LogisticW
             , m.Logistic * m.ExchangeRate as LogisticOow
             , m.Reinsurance * m.ExchangeRate as Reinsurance
             , m.Reinsurance * m.ExchangeRate as ReinsuranceOow
             , m.OtherDirect * m.ExchangeRate as OtherDirect
             , m.Credits * m.ExchangeRate as Credits
             , m.LocalServiceStandardWarranty * m.ExchangeRate as LocalServiceStandardWarranty
             , m.Currency

             , m.Availability                       + ', ' +
                   m.ReactionType                   + ', ' +
                   m.ReactionTime                   + ', ' +
                   m.ServicePeriod                  + ', ' +
                   m.ServiceLocation                + ', ' +
                   m.ProActiveSla as ServiceType

    from cte2 m
    join InputAtoms.Sog sog on sog.id = m.SogId

    where (@limit is null) or (m.rownum > @lastid and m.rownum <= @lastid + @limit);

END
go