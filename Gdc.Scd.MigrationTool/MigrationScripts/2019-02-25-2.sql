CREATE TYPE [Portfolio].[Sla] AS TABLE(
    [rownum] [int] NOT NULL,
    [Id] [bigint] NOT NULL,
    [CountryId] [bigint] NOT NULL,
    [WgId] [bigint] NOT NULL,
    [AvailabilityId] [bigint] NOT NULL,
    [DurationId] [bigint] NOT NULL,
    [ReactionTimeId] [bigint] NOT NULL,
    [ReactionTypeId] [bigint] NOT NULL,
    [ServiceLocationId] [bigint] NOT NULL,
    [ProActiveSlaId] [bigint] NOT NULL,
    [Sla] [nvarchar](255) NOT NULL,
    [SlaHash] [int] NOT NULL,
    [ReactionTime_Avalability] [bigint] NOT NULL,
    [ReactionTime_ReactionType] [bigint] NOT NULL,
    [ReactionTime_ReactionType_Avalability] [bigint] NOT NULL,
    [Fsp] [nvarchar](255) NULL,
    [FspDescription] [nvarchar](255) NULL
)
GO

IF OBJECT_ID('Hardware.ManualCostView', 'V') IS NOT NULL
  DROP VIEW Hardware.ManualCostView;
go

ALTER PROCEDURE Portfolio.AllowLocalPortfolio
    @cnt bigint,
    @wg dbo.ListID readonly,
    @av dbo.ListID readonly,
    @dur dbo.ListID readonly,
    @rtype dbo.ListID readonly,
    @rtime dbo.ListID readonly,
    @loc dbo.ListID readonly,
    @pro dbo.ListID readonly
AS
BEGIN

    SET NOCOUNT ON;

    declare @isEmptyWG bit    = Portfolio.IsListEmpty(@wg);
    declare @isEmptyAv bit    = Portfolio.IsListEmpty(@av);
    declare @isEmptyDur bit   = Portfolio.IsListEmpty(@dur);
    declare @isEmptyRType bit = Portfolio.IsListEmpty(@rtype);
    declare @isEmptyRTime bit = Portfolio.IsListEmpty(@rtime);
    declare @isEmptyLoc bit   = Portfolio.IsListEmpty(@loc);
    declare @isEmptyPro bit   = Portfolio.IsListEmpty(@pro);

    -- Disable all table constraints
    ALTER TABLE Portfolio.LocalPortfolio NOCHECK CONSTRAINT ALL;

    with ExistSlaCte as (

        --select all existing portfolio

        SELECT Id, WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, ProActiveSlaId
        FROM Portfolio.LocalPortfolio
        WHERE   (CountryId = @cnt)

            AND (@isEmptyWG = 1 or WgId in (select id from @wg))
            AND (@isEmptyAv = 1 or AvailabilityId in (select id from @av))
            AND (@isEmptyDur = 1 or DurationId in (select id from @dur))
            AND (@isEmptyRTime = 1 or ReactionTimeId in (select id from @rtime))
            AND (@isEmptyRType = 1 or ReactionTypeId in (select id from @rtype))
            AND (@isEmptyLoc = 1 or ServiceLocationId in (select id from @loc))
            AND (@isEmptyPro = 1 or ProActiveSlaId in (select id from @pro))
    )
    , PrincipleSlaCte as (

        --find current principle portfolio

        select WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, ProActiveSlaId
        FROM Portfolio.PrincipalPortfolio
        WHERE   (@isEmptyWG = 1 or WgId in (select id from @wg))
            AND (@isEmptyAv = 1 or AvailabilityId in (select id from @av))
            AND (@isEmptyDur = 1 or DurationId in (select id from @dur))
            AND (@isEmptyRTime = 1 or ReactionTimeId in (select id from @rtime))
            AND (@isEmptyRType = 1 or ReactionTypeId in (select id from @rtype))
            AND (@isEmptyLoc = 1 or ServiceLocationId in (select id from @loc))
            AND (@isEmptyPro = 1 or ProActiveSlaId in (select id from @pro))
    )
    INSERT INTO Portfolio.LocalPortfolio (CountryId, WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, ProActiveSlaId, ReactionTime_Avalability, ReactionTime_ReactionType, ReactionTime_ReactionType_Avalability)
    SELECT @cnt, sla.WgId, sla.AvailabilityId, sla.DurationId, sla.ReactionTypeId, sla.ReactionTimeId, sla.ServiceLocationId, sla.ProActiveSlaId, rta.Id, rtt.Id, rtta.Id
    FROM PrincipleSlaCte sla
    JOIN Dependencies.ReactionTime_Avalability rta on rta.AvailabilityId = sla.AvailabilityId and rta.ReactionTimeId = sla.ReactionTimeId
    JOIN Dependencies.ReactionTime_ReactionType rtt on rtt.ReactionTimeId = sla.ReactionTimeId and rtt.ReactionTypeId = sla.ReactionTypeId
    JOIN Dependencies.ReactionTime_ReactionType_Avalability rtta on rtta.AvailabilityId = sla.AvailabilityId and rtta.ReactionTimeId = sla.ReactionTimeId and rtta.ReactionTypeId = sla.ReactionTypeId

    LEFT JOIN ExistSlaCte ex on ex.WgId = sla.WgId
                            and ex.AvailabilityId = sla.AvailabilityId
                            and ex.DurationId = sla.DurationId
                            and ex.ReactionTypeId = sla.ReactionTypeId
                            and ex.ReactionTimeId = sla.ReactionTimeId
                            and ex.ServiceLocationId = sla.ServiceLocationId
                            and ex.ProActiveSlaId = sla.ProActiveSlaId

    where ex.Id is null; --exclude existing portfolio
    
    -- Enable all table constraints
    ALTER TABLE Portfolio.LocalPortfolio CHECK CONSTRAINT ALL;

END
go

--################### PORTFOLIO ##################################
IF OBJECT_ID('[Portfolio].[GetBySla]') IS NOT NULL
  DROP FUNCTION [Portfolio].[GetBySla];
go 

CREATE FUNCTION [Portfolio].[GetBySla](
    @cnt          dbo.ListID readonly,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly
)
RETURNS TABLE 
AS
RETURN 
(
    select m.*
    from Portfolio.LocalPortfolio m
    where   exists(select id from @cnt where id = m.CountryId)

        AND (not exists(select 1 from @wg           ) or exists(select 1 from @wg           where id = m.WgId              ))
        AND (not exists(select 1 from @av           ) or exists(select 1 from @av           where id = m.AvailabilityId    ))
        AND (not exists(select 1 from @dur          ) or exists(select 1 from @dur          where id = m.DurationId        ))
        AND (not exists(select 1 from @reactiontime ) or exists(select 1 from @reactiontime where id = m.ReactionTimeId    ))
        AND (not exists(select 1 from @reactiontype ) or exists(select 1 from @reactiontype where id = m.ReactionTypeId    ))
        AND (not exists(select 1 from @loc          ) or exists(select 1 from @loc          where id = m.ServiceLocationId ))
        AND (not exists(select 1 from @pro          ) or exists(select 1 from @pro          where id = m.ProActiveSlaId    ))
)
GO

IF OBJECT_ID('[Portfolio].[GetBySlaPaging]') IS NOT NULL
  DROP FUNCTION [Portfolio].[GetBySlaPaging];
go 

CREATE FUNCTION [Portfolio].[GetBySlaPaging](
    @cnt          dbo.ListID readonly,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly,
    @lastid       bigint,
    @limit        int
)
RETURNS @tbl TABLE 
            (   
                [rownum] [int] NOT NULL,
                [Id] [bigint] NOT NULL,
                [CountryId] [bigint] NOT NULL,
                [WgId] [bigint] NOT NULL,
                [AvailabilityId] [bigint] NOT NULL,
                [DurationId] [bigint] NOT NULL,
                [ReactionTimeId] [bigint] NOT NULL,
                [ReactionTypeId] [bigint] NOT NULL,
                [ServiceLocationId] [bigint] NOT NULL,
                [ProActiveSlaId] [bigint] NOT NULL,
                [Sla] nvarchar(255) NOT NULL,
                [SlaHash] [int] NOT NULL,
                [ReactionTime_Avalability] [bigint] NOT NULL,
                [ReactionTime_ReactionType] [bigint] NOT NULL,
                [ReactionTime_ReactionType_Avalability] [bigint] NOT NULL,
                [Fsp] nvarchar(255) NULL,
                [FspDescription] nvarchar(255) NULL
            )
AS
BEGIN
    
    if @limit > 0
    begin
        insert into @tbl
        select   rownum
               , Id
               , CountryId
               , WgId
               , AvailabilityId
               , DurationId
               , ReactionTimeId
               , ReactionTypeId
               , ServiceLocationId
               , ProActiveSlaId
               , Sla
               , SlaHash
               , ReactionTime_Avalability
               , ReactionTime_ReactionType
               , ReactionTime_ReactionType_Avalability
               , null
               , null
        from (
                select ROW_NUMBER() over(
                            order by m.CountryId
                                    , m.WgId
                                    , m.AvailabilityId
                                    , m.DurationId
                                    , m.ReactionTimeId
                                    , m.ReactionTypeId
                                    , m.ServiceLocationId
                                    , m.ProActiveSlaId
                        ) as rownum
                        , m.*
                from Portfolio.GetBySla(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m    
        ) t
        where rownum > @lastid and rownum <= @lastid + @limit;
    end
    else
    begin
        insert into @tbl 
        select   -1
               , Id
               , CountryId
               , WgId
               , AvailabilityId
               , DurationId
               , ReactionTimeId
               , ReactionTypeId
               , ServiceLocationId
               , ProActiveSlaId
               , Sla
               , SlaHash
               , ReactionTime_Avalability
               , ReactionTime_ReactionType
               , ReactionTime_ReactionType_Avalability
               , null
               , null
        from Portfolio.GetBySla(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
    end 

    RETURN;
END;
go

IF OBJECT_ID('[Portfolio].[GetBySlaFsp]') IS NOT NULL
  DROP FUNCTION [Portfolio].[GetBySlaFsp];
go 

CREATE FUNCTION [Portfolio].[GetBySlaFsp](
    @cnt          dbo.ListID readonly,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly
)
RETURNS TABLE 
AS
RETURN 
(
    select    m.*
            , fsp.Name               as Fsp
            , fsp.ServiceDescription as FspDescription
    from Portfolio.GetBySla(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
    left JOIN Fsp.HwFspCodeTranslation fsp  on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla 
)
GO

IF OBJECT_ID('[Portfolio].[GetBySlaFspPaging]') IS NOT NULL
  DROP FUNCTION [Portfolio].[GetBySlaFspPaging];
go 

CREATE FUNCTION [Portfolio].[GetBySlaFspPaging](
    @cnt          dbo.ListID readonly,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly,
    @lastid       bigint,
    @limit        int
)
RETURNS @tbl TABLE 
            (   
                [rownum] [int] NOT NULL,
                [Id] [bigint] NOT NULL,
                [CountryId] [bigint] NOT NULL,
                [WgId] [bigint] NOT NULL,
                [AvailabilityId] [bigint] NOT NULL,
                [DurationId] [bigint] NOT NULL,
                [ReactionTimeId] [bigint] NOT NULL,
                [ReactionTypeId] [bigint] NOT NULL,
                [ServiceLocationId] [bigint] NOT NULL,
                [ProActiveSlaId] [bigint] NOT NULL,
                [Sla] nvarchar(255) NOT NULL,
                [SlaHash] [int] NOT NULL,
                [ReactionTime_Avalability] [bigint] NOT NULL,
                [ReactionTime_ReactionType] [bigint] NOT NULL,
                [ReactionTime_ReactionType_Avalability] [bigint] NOT NULL,
                [Fsp] nvarchar(255) NULL,
                [FspDescription] nvarchar(255) NULL
            )
AS
BEGIN
    
    if @limit > 0
    begin
        insert into @tbl
        select rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , Fsp
              , FspDescription
        from (
                select ROW_NUMBER() over(
                            order by m.CountryId
                                    , m.WgId
                                    , m.AvailabilityId
                                    , m.DurationId
                                    , m.ReactionTimeId
                                    , m.ReactionTypeId
                                    , m.ServiceLocationId
                                    , m.ProActiveSlaId
                        ) as rownum
                        , m.*
                from Portfolio.GetBySlaFsp(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m    
        ) t
        where rownum > @lastid and rownum <= @lastid + @limit;
    end
    else
    begin
        insert into @tbl 
        select -1 as rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , m.Fsp
              , m.FspDescription
        from Portfolio.GetBySlaFsp(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
    end 

    RETURN;
END;
go

IF OBJECT_ID('[Portfolio].[GetBySlaSingle]') IS NOT NULL
  DROP FUNCTION [Portfolio].[GetBySlaSingle];
go 

CREATE FUNCTION [Portfolio].[GetBySlaSingle](
    @cnt          bigint,
    @wg           bigint,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint
)
RETURNS TABLE 
AS
RETURN 
(
    select m.*
    from Portfolio.LocalPortfolio m
    where   m.CountryId = @cnt

        AND (@wg           is null or @wg           = m.WgId              )
        AND (@av           is null or @av           = m.AvailabilityId    )
        AND (@dur          is null or @dur          = m.DurationId        )
        AND (@reactiontime is null or @reactiontime = m.ReactionTimeId    )
        AND (@reactiontype is null or @reactiontype = m.ReactionTypeId    )
        AND (@loc          is null or @loc          = m.ServiceLocationId )
        AND (@pro          is null or @pro          = m.ProActiveSlaId    )
)
GO

IF OBJECT_ID('[Portfolio].[GetBySlaSinglePaging]') IS NOT NULL
  DROP FUNCTION [Portfolio].[GetBySlaSinglePaging];
go 

CREATE FUNCTION [Portfolio].[GetBySlaSinglePaging](
    @cnt          bigint,
    @wg           bigint,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint,
    @lastid       bigint,
    @limit        int
)
RETURNS @tbl TABLE 
            (   
                [rownum] [int] NOT NULL,
                [Id] [bigint] NOT NULL,
                [CountryId] [bigint] NOT NULL,
                [WgId] [bigint] NOT NULL,
                [AvailabilityId] [bigint] NOT NULL,
                [DurationId] [bigint] NOT NULL,
                [ReactionTimeId] [bigint] NOT NULL,
                [ReactionTypeId] [bigint] NOT NULL,
                [ServiceLocationId] [bigint] NOT NULL,
                [ProActiveSlaId] [bigint] NOT NULL,
                [Sla] nvarchar(255) NOT NULL,
                [SlaHash] [int] NOT NULL,
                [ReactionTime_Avalability] [bigint] NOT NULL,
                [ReactionTime_ReactionType] [bigint] NOT NULL,
                [ReactionTime_ReactionType_Avalability] [bigint] NOT NULL,
                [Fsp] nvarchar(255) NULL,
                [FspDescription] nvarchar(255) NULL
            )
AS
BEGIN
    
    if @limit > 0
    begin
        insert into @tbl
        select rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , null as Fsp
              , null as FspDescription
        from (
                select ROW_NUMBER() over(
                            order by m.CountryId
                                    , m.WgId
                                    , m.AvailabilityId
                                    , m.DurationId
                                    , m.ReactionTimeId
                                    , m.ReactionTypeId
                                    , m.ServiceLocationId
                                    , m.ProActiveSlaId
                        ) as rownum
                        , m.*
                from Portfolio.GetBySlaSingle(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m    
        ) t
        where rownum > @lastid and rownum <= @lastid + @limit;
    end
    else
    begin
        insert into @tbl 
        select -1 as rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , null as Fsp
              , null as FspDescription
        from Portfolio.GetBySlaSingle(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
    end 

    RETURN;
END;
go

IF OBJECT_ID('[Portfolio].[GetBySlaFspSingle]') IS NOT NULL
  DROP FUNCTION [Portfolio].[GetBySlaFspSingle];
go 

CREATE FUNCTION [Portfolio].[GetBySlaFspSingle](
    @cnt          bigint,
    @wg           bigint,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint
)
RETURNS TABLE 
AS
RETURN 
(
    select    m.*
            , fsp.Name               as Fsp
            , fsp.ServiceDescription as FspDescription
    from Portfolio.GetBySlaSingle(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
    left JOIN Fsp.HwFspCodeTranslation fsp  on fsp.SlaHash = m.SlaHash and fsp.Sla = m.Sla 
)
GO

IF OBJECT_ID('[Portfolio].[GetBySlaFspSinglePaging]') IS NOT NULL
  DROP FUNCTION [Portfolio].[GetBySlaFspSinglePaging];
go 

CREATE FUNCTION [Portfolio].[GetBySlaFspSinglePaging](
    @cnt          bigint,
    @wg           bigint,
    @av           bigint,
    @dur          bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc          bigint,
    @pro          bigint,
    @lastid       bigint,
    @limit        int
)
RETURNS @tbl TABLE 
            (   
                [rownum] [int] NOT NULL,
                [Id] [bigint] NOT NULL,
                [CountryId] [bigint] NOT NULL,
                [WgId] [bigint] NOT NULL,
                [AvailabilityId] [bigint] NOT NULL,
                [DurationId] [bigint] NOT NULL,
                [ReactionTimeId] [bigint] NOT NULL,
                [ReactionTypeId] [bigint] NOT NULL,
                [ServiceLocationId] [bigint] NOT NULL,
                [ProActiveSlaId] [bigint] NOT NULL,
                [Sla] nvarchar(255) NOT NULL,
                [SlaHash] [int] NOT NULL,
                [ReactionTime_Avalability] [bigint] NOT NULL,
                [ReactionTime_ReactionType] [bigint] NOT NULL,
                [ReactionTime_ReactionType_Avalability] [bigint] NOT NULL,
                [Fsp] nvarchar(255) NULL,
                [FspDescription] nvarchar(255) NULL
            )
AS
BEGIN
    
    if @limit > 0
    begin
        insert into @tbl
        select rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , Fsp
              , FspDescription
        from (
                select ROW_NUMBER() over(
                            order by m.CountryId
                                    , m.WgId
                                    , m.AvailabilityId
                                    , m.DurationId
                                    , m.ReactionTimeId
                                    , m.ReactionTypeId
                                    , m.ServiceLocationId
                                    , m.ProActiveSlaId
                        ) as rownum
                        , m.*
                from Portfolio.GetBySlaFspSingle(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m    
        ) t
        where rownum > @lastid and rownum <= @lastid + @limit;
    end
    else
    begin
        insert into @tbl 
        select -1 as rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , m.Fsp
              , m.FspDescription
        from Portfolio.GetBySlaFspSingle(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
    end 

    RETURN;
END;
go

--#####################################################################
IF OBJECT_ID('[Hardware].[GetCalcMember]') IS NOT NULL
  DROP FUNCTION [Hardware].[GetCalcMember];
go 

CREATE FUNCTION [Hardware].[GetCalcMember] (
    @approved       bit,
    @cnt            dbo.ListID readonly,
    @wg             dbo.ListID readonly,
    @av             dbo.ListID readonly,
    @dur            dbo.ListID readonly,
    @reactiontime   dbo.ListID readonly,
    @reactiontype   dbo.ListID readonly,
    @loc            dbo.ListID readonly,
    @pro            dbo.ListID readonly,
    @lastid         bigint,
    @limit          int
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT    m.Id

            --SLA

            , m.CountryId          
            , c.Name               as Country
            , c.CurrencyId
            , er.Value             as ExchangeRate
            , m.WgId
            , wg.Name              as Wg
            , m.DurationId
            , dur.Name             as Duration
            , dur.Value            as Year
            , dur.IsProlongation   as IsProlongation
            , m.AvailabilityId
            , av.Name              as Availability
            , m.ReactionTimeId
            , rtime.Name           as ReactionTime
            , m.ReactionTypeId
            , rtype.Name           as ReactionType
            , m.ServiceLocationId
            , loc.Name             as ServiceLocation
            , m.ProActiveSlaId
            , prosla.ExternalName  as ProActiveSla

            , m.Sla
            , m.SlaHash

            , stdw.DurationValue   as StdWarranty

            --Cost values

            , case when @approved = 0 then afr.AFR1                           else AFR1_Approved                           end as AFR1 
            , case when @approved = 0 then afr.AFR2                           else AFR2_Approved                           end as AFR2 
            , case when @approved = 0 then afr.AFR3                           else afr.AFR3_Approved                       end as AFR3 
            , case when @approved = 0 then afr.AFR4                           else afr.AFR4_Approved                       end as AFR4 
            , case when @approved = 0 then afr.AFR5                           else afr.AFR5_Approved                       end as AFR5 
            , case when @approved = 0 then afr.AFRP1                          else afr.AFRP1_Approved                      end as AFRP1
                                                                              
            , case when @approved = 0 then mcw.MaterialCostWarranty           else mcw.MaterialCostWarranty_Approved       end as MaterialCostWarranty
            , case when @approved = 0 then mco.MaterialCostOow                else mco.MaterialCostOow_Approved            end as MaterialCostOow     
                                                                                                                      
            , case when @approved = 0 then tax.TaxAndDuties_norm              else tax.TaxAndDuties_norm_Approved          end as TaxAndDuties
                                                                                                                      
            , case when @approved = 0 then r.Cost                             else r.Cost_Approved                         end as Reinsurance

            --##### FIELD SERVICE COST STANDARD WARRANTY #########                                                                                               
            , case when @approved = 0 then fscStd.LabourCost                  else fscStd.LabourCost_Approved              end / er.Value as StdLabourCost             
            , case when @approved = 0 then fscStd.TravelCost                  else fscStd.TravelCost_Approved              end / er.Value as StdTravelCost             
            , case when @approved = 0 then fscStd.PerformanceRate             else fscStd.PerformanceRate_Approved         end / er.Value as StdPerformanceRate        

            --##### FIELD SERVICE COST #########                                                                                               
            , case when @approved = 0 then fsc.LabourCost                     else fsc.LabourCost_Approved                 end / er.Value as LabourCost             
            , case when @approved = 0 then fsc.TravelCost                     else fsc.TravelCost_Approved                 end / er.Value as TravelCost             
            , case when @approved = 0 then fsc.PerformanceRate                else fsc.PerformanceRate_Approved            end / er.Value as PerformanceRate        
            , case when @approved = 0 then fsc.TimeAndMaterialShare_norm      else fsc.TimeAndMaterialShare_norm_Approved  end as TimeAndMaterialShare   
            , case when @approved = 0 then fsc.TravelTime                     else fsc.TravelTime_Approved                 end as TravelTime             
            , case when @approved = 0 then fsc.RepairTime                     else fsc.RepairTime_Approved                 end as RepairTime             
            , case when @approved = 0 then hr.OnsiteHourlyRates               else hr.OnsiteHourlyRates_Approved           end as OnsiteHourlyRates      
                       
            --##### SERVICE SUPPORT COST #########                                                                                               
            , case when @approved = 0 then ssc.[1stLevelSupportCostsCountry]  else ssc.[1stLevelSupportCostsCountry_Approved] end / er.Value as [1stLevelSupportCosts] 
            , case when @approved = 0 
                    then (case when ssc.[2ndLevelSupportCostsLocal] > 0 then ssc.[2ndLevelSupportCostsLocal] / er.Value else ssc.[2ndLevelSupportCostsClusterRegion] end)
                    else (case when ssc.[2ndLevelSupportCostsLocal_Approved] > 0 then ssc.[2ndLevelSupportCostsLocal_Approved] / er.Value else ssc.[2ndLevelSupportCostsClusterRegion_Approved] end)
                end as [2ndLevelSupportCosts] 
            , case when @approved = 0 then ssc.TotalIb                        else ssc.TotalIb_Approved                    end as TotalIb 
            , case when @approved = 0
                    then (case when ssc.[2ndLevelSupportCostsLocal] > 0          then ssc.TotalIbClusterPla          else ssc.TotalIbClusterPlaRegion end)
                    else (case when ssc.[2ndLevelSupportCostsLocal_Approved] > 0 then ssc.TotalIbClusterPla_Approved else ssc.TotalIbClusterPlaRegion_Approved end)
                end as TotalIbPla

            --##### LOGISTICS COST STANDARD WARRANTY #########                                                                                               
            , case when @approved = 0 then lcStd.ExpressDelivery              else lcStd.ExpressDelivery_Approved          end / er.Value as StdExpressDelivery         
            , case when @approved = 0 then lcStd.HighAvailabilityHandling     else lcStd.HighAvailabilityHandling_Approved end / er.Value as StdHighAvailabilityHandling
            , case when @approved = 0 then lcStd.StandardDelivery             else lcStd.StandardDelivery_Approved         end / er.Value as StdStandardDelivery        
            , case when @approved = 0 then lcStd.StandardHandling             else lcStd.StandardHandling_Approved         end / er.Value as StdStandardHandling        
            , case when @approved = 0 then lcStd.ReturnDeliveryFactory        else lcStd.ReturnDeliveryFactory_Approved    end / er.Value as StdReturnDeliveryFactory   
            , case when @approved = 0 then lcStd.TaxiCourierDelivery          else lcStd.TaxiCourierDelivery_Approved      end / er.Value as StdTaxiCourierDelivery     

            --##### LOGISTICS COST #########                                                                                               
            , case when @approved = 0 then lc.ExpressDelivery                 else lc.ExpressDelivery_Approved             end / er.Value as ExpressDelivery         
            , case when @approved = 0 then lc.HighAvailabilityHandling        else lc.HighAvailabilityHandling_Approved    end / er.Value as HighAvailabilityHandling
            , case when @approved = 0 then lc.StandardDelivery                else lc.StandardDelivery_Approved            end / er.Value as StandardDelivery        
            , case when @approved = 0 then lc.StandardHandling                else lc.StandardHandling_Approved            end / er.Value as StandardHandling        
            , case when @approved = 0 then lc.ReturnDeliveryFactory           else lc.ReturnDeliveryFactory_Approved       end / er.Value as ReturnDeliveryFactory   
            , case when @approved = 0 then lc.TaxiCourierDelivery             else lc.TaxiCourierDelivery_Approved         end / er.Value as TaxiCourierDelivery     
                                                                                                                       
            , case when afEx.id is not null then (case when @approved = 0 then af.Fee else af.Fee_Approved end)
                    else 0
               end as AvailabilityFee

            , case when @approved = 0 then moc.Markup                              else moc.Markup_Approved                            end as MarkupOtherCost                      
            , case when @approved = 0 then moc.MarkupFactor_norm                   else moc.MarkupFactor_norm_Approved                 end as MarkupFactorOtherCost                
                                                                                                                                     
            , case when @approved = 0 then msw.MarkupStandardWarranty              else msw.MarkupStandardWarranty_Approved            end as MarkupStandardWarranty      
            , case when @approved = 0 then msw.MarkupFactorStandardWarranty_norm   else msw.MarkupFactorStandardWarranty_norm_Approved end as MarkupFactorStandardWarranty

            , case when @approved = 0 then pro.LocalRemoteAccessSetupPreparationEffort * pro.OnSiteHourlyRate
                else pro.LocalRemoteAccessSetupPreparationEffort_Approved * pro.OnSiteHourlyRate_Approved
               end as LocalRemoteAccessSetup

            --####### PROACTIVE COST ###################
            , case when @approved = 0 then pro.LocalRegularUpdateReadyEffort * pro.OnSiteHourlyRate * prosla.LocalRegularUpdateReadyRepetition 
                else pro.LocalRegularUpdateReadyEffort_Approved * pro.OnSiteHourlyRate_Approved * prosla.LocalRegularUpdateReadyRepetition 
               end as LocalRegularUpdate

            , case when @approved = 0 then pro.LocalPreparationShcEffort * pro.OnSiteHourlyRate * prosla.LocalPreparationShcRepetition 
                else pro.LocalPreparationShcEffort_Approved * pro.OnSiteHourlyRate_Approved * prosla.LocalPreparationShcRepetition 
               end as LocalPreparation

            , case when @approved = 0 then pro.LocalRemoteShcCustomerBriefingEffort * pro.OnSiteHourlyRate * prosla.LocalRemoteShcCustomerBriefingRepetition 
                else pro.LocalRemoteShcCustomerBriefingEffort_Approved * pro.OnSiteHourlyRate_Approved * prosla.LocalRemoteShcCustomerBriefingRepetition 
               end as LocalRemoteCustomerBriefing

            , case when @approved = 0 then pro.LocalOnsiteShcCustomerBriefingEffort * pro.OnSiteHourlyRate * prosla.LocalOnsiteShcCustomerBriefingRepetition 
                else pro.LocalOnSiteShcCustomerBriefingEffort_Approved * pro.OnSiteHourlyRate_Approved * prosla.LocalOnsiteShcCustomerBriefingRepetition 
               end as LocalOnsiteCustomerBriefing

            , case when @approved = 0 then pro.TravellingTime * pro.OnSiteHourlyRate * prosla.TravellingTimeRepetition 
                else pro.TravellingTime_Approved * pro.OnSiteHourlyRate_Approved * prosla.TravellingTimeRepetition 
               end as Travel

            , case when @approved = 0 then pro.CentralExecutionShcReportCost * prosla.CentralExecutionShcReportRepetition 
                else pro.CentralExecutionShcReportCost_Approved * prosla.CentralExecutionShcReportRepetition 
               end as CentralExecutionReport

            --########## MANUAL COSTS ################
            , man.ListPrice          / er.Value as ListPrice                   
            , man.DealerDiscount                as DealerDiscount              
            , man.DealerPrice        / er.Value as DealerPrice                 
            , man.ServiceTC          / er.Value as ServiceTCManual                   
            , man.ServiceTP          / er.Value as ServiceTPManual                   
            , man.ServiceTP_Released / er.Value as ServiceTP_Released                  
            , u.Name                            as ChangeUserName
            , u.Email                           as ChangeUserEmail

    FROM Portfolio.GetBySlaPaging(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m

    INNER JOIN InputAtoms.Country c on c.id = m.CountryId

    INNER JOIN InputAtoms.WgView wg on wg.id = m.WgId

    INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

    INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId

    INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

    INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId
   
    INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

    INNER JOIN Dependencies.ProActiveSla prosla on prosla.id = m.ProActiveSlaId

    LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId

    LEFT JOIN Hardware.RoleCodeHourlyRates hr on hr.RoleCode = wg.RoleCodeId and hr.Country = m.CountryId

    LEFT JOIN Fsp.HwStandardWarrantyView stdw on stdw.Wg = m.WgId and stdw.Country = m.CountryId

    LEFT JOIN Hardware.AfrYear afr on afr.Wg = m.WgId

    LEFT JOIN Hardware.ServiceSupportCost ssc on ssc.Country = m.CountryId and ssc.ClusterPla = wg.ClusterPla

    LEFT JOIN Hardware.TaxAndDutiesView tax on tax.Country = m.CountryId

    LEFT JOIN Hardware.MaterialCostWarranty mcw on mcw.Wg = m.WgId AND mcw.ClusterRegion = c.ClusterRegionId

    LEFT JOIN Hardware.MaterialCostOowCalc mco on mco.Wg = m.WgId AND mco.Country = m.CountryId

    LEFT JOIN Hardware.ReinsuranceView r on r.Wg = m.WgId AND r.Duration = m.DurationId AND r.ReactionTimeAvailability = m.ReactionTime_Avalability

    LEFT JOIN Hardware.FieldServiceCost fsc ON fsc.Wg = m.WgId AND fsc.Country = m.CountryId AND fsc.ServiceLocation = m.ServiceLocationId AND fsc.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.FieldServiceCost fscStd ON fscStd.Country = stdw.Country AND fscStd.Wg = stdw.Wg AND fscStd.ServiceLocation = stdw.ServiceLocationId AND fscStd.ReactionTimeType = stdw.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lc on lc.Country = m.CountryId AND lc.Wg = m.WgId AND lc.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lcStd on lcStd.Country = stdw.Country AND lcStd.Wg = stdw.Wg AND lcStd.ReactionTimeType = stdw.ReactionTime_ReactionType

    LEFT JOIN Hardware.MarkupOtherCosts moc on moc.Wg = m.WgId AND moc.Country = m.CountryId AND moc.ReactionTimeTypeAvailability = m.ReactionTime_ReactionType_Avalability

    LEFT JOIN Hardware.MarkupStandardWaranty msw on msw.Wg = m.WgId AND msw.Country = m.CountryId

    LEFT JOIN Hardware.AvailabilityFeeCalc af on af.Country = m.CountryId AND af.Wg = m.WgId

    LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId AND afEx.ReactionTimeId = m.ReactionTimeId AND afEx.ReactionTypeId = m.ReactionTypeId AND afEx.ServiceLocationId = m.ServiceLocationId

    LEFT JOIN Hardware.ProActive pro ON  pro.Country= m.CountryId and pro.Wg= m.WgId

    LEFT JOIN Hardware.ManualCost man on man.PortfolioId = m.Id

    LEFT JOIN dbo.[User] u on u.Id = man.ChangeUserId
)
GO

IF OBJECT_ID('[Hardware].[GetCosts]') IS NOT NULL
    DROP FUNCTION [Hardware].[GetCosts]
GO

IF OBJECT_ID('[Hardware].[GetCostsFull]') IS NOT NULL
    DROP FUNCTION [Hardware].[GetCostsFull]
GO

CREATE FUNCTION [Hardware].[GetCosts](
    @approved bit,
    @cnt dbo.ListID readonly,
    @wg dbo.ListID readonly,
    @av dbo.ListID readonly,
    @dur dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc dbo.ListID readonly,
    @pro dbo.ListID readonly,
    @lastid bigint,
    @limit int
)
RETURNS TABLE 
AS
RETURN 
(
    with CostCte as (
        select    m.*

                , case when m.TaxAndDuties is null then 0 else m.TaxAndDuties end as TaxAndDutiesOrZero

                , case when m.Reinsurance is null then 0 else m.Reinsurance end as ReinsuranceOrZero

                , case when m.AvailabilityFee is null then 0 else m.AvailabilityFee end as AvailabilityFeeOrZero

                , case when m.TotalIb > 0 and m.TotalIbPla > 0 then m.[1stLevelSupportCosts] / m.TotalIb + m.[2ndLevelSupportCosts] / m.TotalIbPla end as ServiceSupportPerYear

                , m.StdLabourCost + m.StdTravelCost + coalesce(m.StdPerformanceRate, 0) as FieldServicePerYearStdw

                , (1 - m.TimeAndMaterialShare) * (m.TravelCost + m.LabourCost + m.PerformanceRate) + m.TimeAndMaterialShare * ((m.TravelTime + m.repairTime) * m.OnsiteHourlyRates + m.PerformanceRate) as FieldServicePerYear

                , m.StdStandardHandling + m.StdHighAvailabilityHandling + m.StdStandardDelivery + m.StdExpressDelivery + m.StdTaxiCourierDelivery + m.StdReturnDeliveryFactory as LogisticPerYearStdw

                , m.StandardHandling + m.HighAvailabilityHandling + m.StandardDelivery + m.ExpressDelivery + m.TaxiCourierDelivery + m.ReturnDeliveryFactory as LogisticPerYear

                , m.LocalRemoteAccessSetup + m.Year * (m.LocalPreparation + m.LocalRegularUpdate + m.LocalRemoteCustomerBriefing + m.LocalOnsiteCustomerBriefing + m.Travel + m.CentralExecutionReport) as ProActive
       
        from Hardware.GetCalcMember(@approved, @cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m
    )
    , CostCte2 as (
        select    m.*

                , case when m.StdWarranty >= 1 then m.MaterialCostWarranty * m.AFR1 else 0 end as mat1
                , case when m.StdWarranty >= 2 then m.MaterialCostWarranty * m.AFR2 else 0 end as mat2
                , case when m.StdWarranty >= 3 then m.MaterialCostWarranty * m.AFR3 else 0 end as mat3
                , case when m.StdWarranty >= 4 then m.MaterialCostWarranty * m.AFR4 else 0 end as mat4
                , case when m.StdWarranty >= 5 then m.MaterialCostWarranty * m.AFR5 else 0 end as mat5
                , 0  as mat1P

                , case when m.StdWarranty >= 1 then 0 else m.MaterialCostOow * m.AFR1 end as matO1
                , case when m.StdWarranty >= 2 then 0 else m.MaterialCostOow * m.AFR2 end as matO2
                , case when m.StdWarranty >= 3 then 0 else m.MaterialCostOow * m.AFR3 end as matO3
                , case when m.StdWarranty >= 4 then 0 else m.MaterialCostOow * m.AFR4 end as matO4
                , case when m.StdWarranty >= 5 then 0 else m.MaterialCostOow * m.AFR5 end as matO5
                , m.MaterialCostOow * m.AFRP1 as matO1P

                , m.FieldServicePerYearStdw * m.AFR1  as FieldServiceCostStdw1
                , m.FieldServicePerYearStdw * m.AFR2  as FieldServiceCostStdw2
                , m.FieldServicePerYearStdw * m.AFR3  as FieldServiceCostStdw3
                , m.FieldServicePerYearStdw * m.AFR4  as FieldServiceCostStdw4
                , m.FieldServicePerYearStdw * m.AFR5  as FieldServiceCostStdw5

                , m.FieldServicePerYear * m.AFR1  as FieldServiceCost1
                , m.FieldServicePerYear * m.AFR2  as FieldServiceCost2
                , m.FieldServicePerYear * m.AFR3  as FieldServiceCost3
                , m.FieldServicePerYear * m.AFR4  as FieldServiceCost4
                , m.FieldServicePerYear * m.AFR5  as FieldServiceCost5
                , m.FieldServicePerYear * m.AFRP1 as FieldServiceCost1P

                , m.LogisticPerYearStdw * m.AFR1  as LogisticStdw1
                , m.LogisticPerYearStdw * m.AFR2  as LogisticStdw2
                , m.LogisticPerYearStdw * m.AFR3  as LogisticStdw3
                , m.LogisticPerYearStdw * m.AFR4  as LogisticStdw4
                , m.LogisticPerYearStdw * m.AFR5  as LogisticStdw5

                , m.LogisticPerYear * m.AFR1  as Logistic1
                , m.LogisticPerYear * m.AFR2  as Logistic2
                , m.LogisticPerYear * m.AFR3  as Logistic3
                , m.LogisticPerYear * m.AFR4  as Logistic4
                , m.LogisticPerYear * m.AFR5  as Logistic5
                , m.LogisticPerYear * m.AFRP1 as Logistic1P

        from CostCte m
    )
    , CostCte2_2 as (
        select    m.*

                , case when m.StdWarranty >= 1 then m.TaxAndDutiesOrZero * m.mat1 else 0 end as tax1
                , case when m.StdWarranty >= 2 then m.TaxAndDutiesOrZero * m.mat2 else 0 end as tax2
                , case when m.StdWarranty >= 3 then m.TaxAndDutiesOrZero * m.mat3 else 0 end as tax3
                , case when m.StdWarranty >= 4 then m.TaxAndDutiesOrZero * m.mat4 else 0 end as tax4
                , case when m.StdWarranty >= 5 then m.TaxAndDutiesOrZero * m.mat5 else 0 end as tax5
                , 0  as tax1P

                , case when m.StdWarranty >= 1 then 0 else m.TaxAndDutiesOrZero * m.matO1 end as taxO1
                , case when m.StdWarranty >= 2 then 0 else m.TaxAndDutiesOrZero * m.matO2 end as taxO2
                , case when m.StdWarranty >= 3 then 0 else m.TaxAndDutiesOrZero * m.matO3 end as taxO3
                , case when m.StdWarranty >= 4 then 0 else m.TaxAndDutiesOrZero * m.matO4 end as taxO4
                , case when m.StdWarranty >= 5 then 0 else m.TaxAndDutiesOrZero * m.matO5 end as taxO5
                , m.TaxAndDutiesOrZero * m.matO1P as taxO1P

                , m.mat1  + m.matO1                     as matCost1
                , m.mat2  + m.matO2                     as matCost2
                , m.mat3  + m.matO3                     as matCost3
                , m.mat4  + m.matO4                     as matCost4
                , m.mat5  + m.matO5                     as matCost5
                , m.mat1P + m.matO1P                    as matCost1P

                , m.TaxAndDutiesOrZero * (m.mat1  + m.matO1)  as TaxAndDuties1
                , m.TaxAndDutiesOrZero * (m.mat2  + m.matO2)  as TaxAndDuties2
                , m.TaxAndDutiesOrZero * (m.mat3  + m.matO3)  as TaxAndDuties3
                , m.TaxAndDutiesOrZero * (m.mat4  + m.matO4)  as TaxAndDuties4
                , m.TaxAndDutiesOrZero * (m.mat5  + m.matO5)  as TaxAndDuties5
                , m.TaxAndDutiesOrZero * (m.mat1P + m.matO1P) as TaxAndDuties1P

        from CostCte2 m
    )
    , CostCte3 as (
        select    
                  m.*

                , Hardware.MarkupOrFixValue(m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1
                , Hardware.MarkupOrFixValue(m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect2
                , Hardware.MarkupOrFixValue(m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect3
                , Hardware.MarkupOrFixValue(m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect4
                , Hardware.MarkupOrFixValue(m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect5
                , Hardware.MarkupOrFixValue(m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1P

                , case when m.StdWarranty >= 1 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw1, m.ServiceSupportPerYear, m.LogisticStdw1, m.tax1, m.AFR1, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty1
                , case when m.StdWarranty >= 2 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw2, m.ServiceSupportPerYear, m.LogisticStdw2, m.tax2, m.AFR2, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty2
                , case when m.StdWarranty >= 3 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw3, m.ServiceSupportPerYear, m.LogisticStdw3, m.tax3, m.AFR3, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty3
                , case when m.StdWarranty >= 4 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw4, m.ServiceSupportPerYear, m.LogisticStdw4, m.tax4, m.AFR4, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty4
                , case when m.StdWarranty >= 5 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw5, m.ServiceSupportPerYear, m.LogisticStdw5, m.tax5, m.AFR5, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty5

        from CostCte2_2 m
    )
    , CostCte4 as (
        select m.*
             , m.mat1 + m.LocalServiceStandardWarranty1 as Credit1
             , m.mat2 + m.LocalServiceStandardWarranty2 as Credit2
             , m.mat3 + m.LocalServiceStandardWarranty3 as Credit3
             , m.mat4 + m.LocalServiceStandardWarranty4 as Credit4
             , m.mat5 + m.LocalServiceStandardWarranty5 as Credit5
        from CostCte3 m
    )
    , CostCte5 as (
        select m.*

             , m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.TaxAndDuties1  + m.ReinsuranceOrZero + m.OtherDirect1  + m.AvailabilityFeeOrZero - m.Credit1  as ServiceTP1
             , m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.TaxAndDuties2  + m.ReinsuranceOrZero + m.OtherDirect2  + m.AvailabilityFeeOrZero - m.Credit2  as ServiceTP2
             , m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.TaxAndDuties3  + m.ReinsuranceOrZero + m.OtherDirect3  + m.AvailabilityFeeOrZero - m.Credit3  as ServiceTP3
             , m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.TaxAndDuties4  + m.ReinsuranceOrZero + m.OtherDirect4  + m.AvailabilityFeeOrZero - m.Credit4  as ServiceTP4
             , m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.TaxAndDuties5  + m.ReinsuranceOrZero + m.OtherDirect5  + m.AvailabilityFeeOrZero - m.Credit5  as ServiceTP5
             , m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.TaxAndDuties1P + m.ReinsuranceOrZero + m.OtherDirect1P + m.AvailabilityFeeOrZero              as ServiceTP1P

        from CostCte4 m
    )
    , CostCte6 as (
        select m.*
                , case when m.ServiceTP1  < m.OtherDirect1  then 0 else m.ServiceTP1  - m.OtherDirect1  end as ServiceTC1
                , case when m.ServiceTP2  < m.OtherDirect2  then 0 else m.ServiceTP2  - m.OtherDirect2  end as ServiceTC2
                , case when m.ServiceTP3  < m.OtherDirect3  then 0 else m.ServiceTP3  - m.OtherDirect3  end as ServiceTC3
                , case when m.ServiceTP4  < m.OtherDirect4  then 0 else m.ServiceTP4  - m.OtherDirect4  end as ServiceTC4
                , case when m.ServiceTP5  < m.OtherDirect5  then 0 else m.ServiceTP5  - m.OtherDirect5  end as ServiceTC5
                , case when m.ServiceTP1P < m.OtherDirect1P then 0 else m.ServiceTP1P - m.OtherDirect1P end as ServiceTC1P
        from CostCte5 m
    )    
    select m.Id

         --SLA

         , m.CountryId
         , m.Country
         , m.CurrencyId
         , m.ExchangeRate
         , m.WgId
         , m.Wg
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

         --Cost

         , m.AvailabilityFee * m.Year as AvailabilityFee
         , m.tax1 + m.tax2 + m.tax3 + m.tax4 + m.tax5 as TaxAndDutiesW
         , m.taxO1 + m.taxO2 + m.taxO3 + m.taxO4 + m.taxO5 as TaxAndDutiesOow
         , m.Reinsurance
         , m.ProActive
         , m.Year * m.ServiceSupportPerYear as ServiceSupportCost

         , m.mat1 + m.mat2 + m.mat3 + m.mat4 + m.mat5 as MaterialW
         , m.matO1 + m.matO2 + m.matO3 + m.matO4 + m.matO5 as MaterialOow

         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.FieldServiceCost1, m.FieldServiceCost2, m.FieldServiceCost3, m.FieldServiceCost4, m.FieldServiceCost5, m.FieldServiceCost1P) as FieldServiceCost
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.Logistic1, m.Logistic2, m.Logistic3, m.Logistic4, m.Logistic5, m.Logistic1P) as Logistic
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.OtherDirect1, m.OtherDirect2, m.OtherDirect3, m.OtherDirect4, m.OtherDirect5, m.OtherDirect1P) as OtherDirect
       
         , m.LocalServiceStandardWarranty1 + m.LocalServiceStandardWarranty2 + m.LocalServiceStandardWarranty3 + m.LocalServiceStandardWarranty4 + m.LocalServiceStandardWarranty5 as LocalServiceStandardWarranty
       
         , m.Credit1 + m.Credit2 + m.Credit3 + m.Credit4 + m.Credit5 as Credits

         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTC1, m.ServiceTC2, m.ServiceTC3, m.ServiceTC4, m.ServiceTC5, m.ServiceTC1P) as ServiceTC
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTP1, m.ServiceTP2, m.ServiceTP3, m.ServiceTP4, m.ServiceTP5, m.ServiceTP1P) as ServiceTP

         , m.ServiceTC1
         , m.ServiceTC2
         , m.ServiceTC3
         , m.ServiceTC4
         , m.ServiceTC5
         , m.ServiceTC1P

         , m.ServiceTP1
         , m.ServiceTP2
         , m.ServiceTP3
         , m.ServiceTP4
         , m.ServiceTP5
         , m.ServiceTP1P

         , m.ListPrice
         , m.DealerDiscount
         , m.DealerPrice
         , m.ServiceTCManual
         , m.ServiceTPManual
         , m.ServiceTP_Released

         , m.ChangeUserName
         , m.ChangeUserEmail

       from CostCte6 m
)
GO

IF OBJECT_ID('[Report].[GetCostsPaging]') IS NOT NULL
    DROP FUNCTION [Report].[GetCostsPaging]
GO

IF OBJECT_ID('[Hardware].[GetCalcMemberSla]') IS NOT NULL
  DROP FUNCTION [Hardware].[GetCalcMemberSla];
go 

CREATE FUNCTION [Hardware].[GetCalcMemberSla] (
    @approved       bit,
    @sla            Portfolio.Sla readonly
)
RETURNS TABLE 
AS
RETURN 
(
    SELECT    m.Id

            --SLA

            , m.CountryId          
            , c.Name               as Country
            , c.CurrencyId
            , er.Value             as ExchangeRate
            , m.WgId
            , wg.Name              as Wg
            , m.DurationId
            , dur.Name             as Duration
            , dur.Value            as Year
            , dur.IsProlongation   as IsProlongation
            , m.AvailabilityId
            , av.Name              as Availability
            , m.ReactionTimeId
            , rtime.Name           as ReactionTime
            , m.ReactionTypeId
            , rtype.Name           as ReactionType
            , m.ServiceLocationId
            , loc.Name             as ServiceLocation
            , m.ProActiveSlaId
            , prosla.ExternalName  as ProActiveSla

            , m.Fsp
            , m.FspDescription

            , m.Sla
            , m.SlaHash

            , stdw.DurationValue   as StdWarranty

            --Cost values

            , case when @approved = 0 then afr.AFR1                           else AFR1_Approved                           end as AFR1 
            , case when @approved = 0 then afr.AFR2                           else AFR2_Approved                           end as AFR2 
            , case when @approved = 0 then afr.AFR3                           else afr.AFR3_Approved                       end as AFR3 
            , case when @approved = 0 then afr.AFR4                           else afr.AFR4_Approved                       end as AFR4 
            , case when @approved = 0 then afr.AFR5                           else afr.AFR5_Approved                       end as AFR5 
            , case when @approved = 0 then afr.AFRP1                          else afr.AFRP1_Approved                      end as AFRP1
                                                                              
            , case when @approved = 0 then mcw.MaterialCostWarranty           else mcw.MaterialCostWarranty_Approved       end as MaterialCostWarranty
            , case when @approved = 0 then mco.MaterialCostOow                else mco.MaterialCostOow_Approved            end as MaterialCostOow     
                                                                                                                      
            , case when @approved = 0 then tax.TaxAndDuties_norm              else tax.TaxAndDuties_norm_Approved          end as TaxAndDuties
                                                                                                                      
            , case when @approved = 0 then r.Cost                             else r.Cost_Approved                         end as Reinsurance

            --##### FIELD SERVICE COST STANDARD WARRANTY #########                                                                                               
            , case when @approved = 0 then fscStd.LabourCost                  else fscStd.LabourCost_Approved              end / er.Value as StdLabourCost             
            , case when @approved = 0 then fscStd.TravelCost                  else fscStd.TravelCost_Approved              end / er.Value as StdTravelCost             
            , case when @approved = 0 then fscStd.PerformanceRate             else fscStd.PerformanceRate_Approved         end / er.Value as StdPerformanceRate        

            --##### FIELD SERVICE COST #########                                                                                               
            , case when @approved = 0 then fsc.LabourCost                     else fsc.LabourCost_Approved                 end / er.Value as LabourCost             
            , case when @approved = 0 then fsc.TravelCost                     else fsc.TravelCost_Approved                 end / er.Value as TravelCost             
            , case when @approved = 0 then fsc.PerformanceRate                else fsc.PerformanceRate_Approved            end / er.Value as PerformanceRate        
            , case when @approved = 0 then fsc.TimeAndMaterialShare_norm      else fsc.TimeAndMaterialShare_norm_Approved  end as TimeAndMaterialShare   
            , case when @approved = 0 then fsc.TravelTime                     else fsc.TravelTime_Approved                 end as TravelTime             
            , case when @approved = 0 then fsc.RepairTime                     else fsc.RepairTime_Approved                 end as RepairTime             
            , case when @approved = 0 then hr.OnsiteHourlyRates               else hr.OnsiteHourlyRates_Approved           end as OnsiteHourlyRates      
                       
            --##### SERVICE SUPPORT COST #########                                                                                               
            , case when @approved = 0 then ssc.[1stLevelSupportCostsCountry]  else ssc.[1stLevelSupportCostsCountry_Approved] end / er.Value as [1stLevelSupportCosts] 
            , case when @approved = 0 
                    then (case when ssc.[2ndLevelSupportCostsLocal] > 0 then ssc.[2ndLevelSupportCostsLocal] / er.Value else ssc.[2ndLevelSupportCostsClusterRegion] end)
                    else (case when ssc.[2ndLevelSupportCostsLocal_Approved] > 0 then ssc.[2ndLevelSupportCostsLocal_Approved] / er.Value else ssc.[2ndLevelSupportCostsClusterRegion_Approved] end)
                end as [2ndLevelSupportCosts] 
            , case when @approved = 0 then ssc.TotalIb                        else ssc.TotalIb_Approved                    end as TotalIb 
            , case when @approved = 0
                    then (case when ssc.[2ndLevelSupportCostsLocal] > 0          then ssc.TotalIbClusterPla          else ssc.TotalIbClusterPlaRegion end)
                    else (case when ssc.[2ndLevelSupportCostsLocal_Approved] > 0 then ssc.TotalIbClusterPla_Approved else ssc.TotalIbClusterPlaRegion_Approved end)
                end as TotalIbPla

            --##### LOGISTICS COST STANDARD WARRANTY #########                                                                                               
            , case when @approved = 0 then lcStd.ExpressDelivery              else lcStd.ExpressDelivery_Approved          end / er.Value as StdExpressDelivery         
            , case when @approved = 0 then lcStd.HighAvailabilityHandling     else lcStd.HighAvailabilityHandling_Approved end / er.Value as StdHighAvailabilityHandling
            , case when @approved = 0 then lcStd.StandardDelivery             else lcStd.StandardDelivery_Approved         end / er.Value as StdStandardDelivery        
            , case when @approved = 0 then lcStd.StandardHandling             else lcStd.StandardHandling_Approved         end / er.Value as StdStandardHandling        
            , case when @approved = 0 then lcStd.ReturnDeliveryFactory        else lcStd.ReturnDeliveryFactory_Approved    end / er.Value as StdReturnDeliveryFactory   
            , case when @approved = 0 then lcStd.TaxiCourierDelivery          else lcStd.TaxiCourierDelivery_Approved      end / er.Value as StdTaxiCourierDelivery     

            --##### LOGISTICS COST #########                                                                                               
            , case when @approved = 0 then lc.ExpressDelivery                 else lc.ExpressDelivery_Approved             end / er.Value as ExpressDelivery         
            , case when @approved = 0 then lc.HighAvailabilityHandling        else lc.HighAvailabilityHandling_Approved    end / er.Value as HighAvailabilityHandling
            , case when @approved = 0 then lc.StandardDelivery                else lc.StandardDelivery_Approved            end / er.Value as StandardDelivery        
            , case when @approved = 0 then lc.StandardHandling                else lc.StandardHandling_Approved            end / er.Value as StandardHandling        
            , case when @approved = 0 then lc.ReturnDeliveryFactory           else lc.ReturnDeliveryFactory_Approved       end / er.Value as ReturnDeliveryFactory   
            , case when @approved = 0 then lc.TaxiCourierDelivery             else lc.TaxiCourierDelivery_Approved         end / er.Value as TaxiCourierDelivery     
                                                                                                                       
            , case when afEx.id is not null then (case when @approved = 0 then af.Fee else af.Fee_Approved end)
                    else 0
               end as AvailabilityFee

            , case when @approved = 0 then moc.Markup                              else moc.Markup_Approved                            end as MarkupOtherCost                      
            , case when @approved = 0 then moc.MarkupFactor_norm                   else moc.MarkupFactor_norm_Approved                 end as MarkupFactorOtherCost                
                                                                                                                                     
            , case when @approved = 0 then msw.MarkupStandardWarranty              else msw.MarkupStandardWarranty_Approved            end as MarkupStandardWarranty      
            , case when @approved = 0 then msw.MarkupFactorStandardWarranty_norm   else msw.MarkupFactorStandardWarranty_norm_Approved end as MarkupFactorStandardWarranty

            , case when @approved = 0 then pro.LocalRemoteAccessSetupPreparationEffort * pro.OnSiteHourlyRate
                else pro.LocalRemoteAccessSetupPreparationEffort_Approved * pro.OnSiteHourlyRate_Approved
               end as LocalRemoteAccessSetup

            --####### PROACTIVE COST ###################
            , case when @approved = 0 then pro.LocalRegularUpdateReadyEffort * pro.OnSiteHourlyRate * prosla.LocalRegularUpdateReadyRepetition 
                else pro.LocalRegularUpdateReadyEffort_Approved * pro.OnSiteHourlyRate_Approved * prosla.LocalRegularUpdateReadyRepetition 
               end as LocalRegularUpdate

            , case when @approved = 0 then pro.LocalPreparationShcEffort * pro.OnSiteHourlyRate * prosla.LocalPreparationShcRepetition 
                else pro.LocalPreparationShcEffort_Approved * pro.OnSiteHourlyRate_Approved * prosla.LocalPreparationShcRepetition 
               end as LocalPreparation

            , case when @approved = 0 then pro.LocalRemoteShcCustomerBriefingEffort * pro.OnSiteHourlyRate * prosla.LocalRemoteShcCustomerBriefingRepetition 
                else pro.LocalRemoteShcCustomerBriefingEffort_Approved * pro.OnSiteHourlyRate_Approved * prosla.LocalRemoteShcCustomerBriefingRepetition 
               end as LocalRemoteCustomerBriefing

            , case when @approved = 0 then pro.LocalOnsiteShcCustomerBriefingEffort * pro.OnSiteHourlyRate * prosla.LocalOnsiteShcCustomerBriefingRepetition 
                else pro.LocalOnSiteShcCustomerBriefingEffort_Approved * pro.OnSiteHourlyRate_Approved * prosla.LocalOnsiteShcCustomerBriefingRepetition 
               end as LocalOnsiteCustomerBriefing

            , case when @approved = 0 then pro.TravellingTime * pro.OnSiteHourlyRate * prosla.TravellingTimeRepetition 
                else pro.TravellingTime_Approved * pro.OnSiteHourlyRate_Approved * prosla.TravellingTimeRepetition 
               end as Travel

            , case when @approved = 0 then pro.CentralExecutionShcReportCost * prosla.CentralExecutionShcReportRepetition 
                else pro.CentralExecutionShcReportCost_Approved * prosla.CentralExecutionShcReportRepetition 
               end as CentralExecutionReport

            --########## MANUAL COSTS ################
            , man.ListPrice          / er.Value as ListPrice                   
            , man.DealerDiscount                as DealerDiscount              
            , man.DealerPrice        / er.Value as DealerPrice                 
            , man.ServiceTC          / er.Value as ServiceTCManual                   
            , man.ServiceTP          / er.Value as ServiceTPManual                   
            , man.ServiceTP_Released / er.Value as ServiceTP_Released                  
            , u.Name                            as ChangeUserName
            , u.Email                           as ChangeUserEmail

    FROM @sla m

    INNER JOIN InputAtoms.Country c on c.id = m.CountryId

    INNER JOIN InputAtoms.WgView wg on wg.id = m.WgId

    INNER JOIN Dependencies.Availability av on av.Id= m.AvailabilityId

    INNER JOIN Dependencies.Duration dur on dur.id = m.DurationId

    INNER JOIN Dependencies.ReactionTime rtime on rtime.Id = m.ReactionTimeId

    INNER JOIN Dependencies.ReactionType rtype on rtype.Id = m.ReactionTypeId
   
    INNER JOIN Dependencies.ServiceLocation loc on loc.Id = m.ServiceLocationId

    INNER JOIN Dependencies.ProActiveSla prosla on prosla.id = m.ProActiveSlaId

    LEFT JOIN [References].ExchangeRate er on er.CurrencyId = c.CurrencyId

    LEFT JOIN Hardware.RoleCodeHourlyRates hr on hr.RoleCode = wg.RoleCodeId and hr.Country = m.CountryId

    LEFT JOIN Fsp.HwStandardWarrantyView stdw on stdw.Wg = m.WgId and stdw.Country = m.CountryId

    LEFT JOIN Hardware.AfrYear afr on afr.Wg = m.WgId

    LEFT JOIN Hardware.ServiceSupportCost ssc on ssc.Country = m.CountryId and ssc.ClusterPla = wg.ClusterPla

    LEFT JOIN Hardware.TaxAndDutiesView tax on tax.Country = m.CountryId

    LEFT JOIN Hardware.MaterialCostWarranty mcw on mcw.Wg = m.WgId AND mcw.ClusterRegion = c.ClusterRegionId

    LEFT JOIN Hardware.MaterialCostOowCalc mco on mco.Wg = m.WgId AND mco.Country = m.CountryId

    LEFT JOIN Hardware.ReinsuranceView r on r.Wg = m.WgId AND r.Duration = m.DurationId AND r.ReactionTimeAvailability = m.ReactionTime_Avalability

    LEFT JOIN Hardware.FieldServiceCost fsc ON fsc.Wg = m.WgId AND fsc.Country = m.CountryId AND fsc.ServiceLocation = m.ServiceLocationId AND fsc.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.FieldServiceCost fscStd ON fscStd.Country = stdw.Country AND fscStd.Wg = stdw.Wg AND fscStd.ServiceLocation = stdw.ServiceLocationId AND fscStd.ReactionTimeType = stdw.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lc on lc.Country = m.CountryId AND lc.Wg = m.WgId AND lc.ReactionTimeType = m.ReactionTime_ReactionType

    LEFT JOIN Hardware.LogisticsCosts lcStd on lcStd.Country = stdw.Country AND lcStd.Wg = stdw.Wg AND lcStd.ReactionTimeType = stdw.ReactionTime_ReactionType

    LEFT JOIN Hardware.MarkupOtherCosts moc on moc.Wg = m.WgId AND moc.Country = m.CountryId AND moc.ReactionTimeTypeAvailability = m.ReactionTime_ReactionType_Avalability

    LEFT JOIN Hardware.MarkupStandardWaranty msw on msw.Wg = m.WgId AND msw.Country = m.CountryId

    LEFT JOIN Hardware.AvailabilityFeeCalc af on af.Country = m.CountryId AND af.Wg = m.WgId

    LEFT JOIN Admin.AvailabilityFee afEx on afEx.CountryId = m.CountryId AND afEx.ReactionTimeId = m.ReactionTimeId AND afEx.ReactionTypeId = m.ReactionTypeId AND afEx.ServiceLocationId = m.ServiceLocationId

    LEFT JOIN Hardware.ProActive pro ON  pro.Country= m.CountryId and pro.Wg= m.WgId

    LEFT JOIN Hardware.ManualCost man on man.PortfolioId = m.Id

    LEFT JOIN dbo.[User] u on u.Id = man.ChangeUserId
)
GO

IF OBJECT_ID('[Hardware].[GetCostsSla]') IS NOT NULL
    DROP FUNCTION [Hardware].[GetCostsSla]
GO

CREATE FUNCTION [Hardware].[GetCostsSla](
    @approved       bit,
    @sla            Portfolio.Sla readonly
)
RETURNS TABLE 
AS
RETURN 
(
    with CostCte as (
        select    m.*

                , case when m.TaxAndDuties is null then 0 else m.TaxAndDuties end as TaxAndDutiesOrZero

                , case when m.Reinsurance is null then 0 else m.Reinsurance end as ReinsuranceOrZero

                , case when m.AvailabilityFee is null then 0 else m.AvailabilityFee end as AvailabilityFeeOrZero

                , case when m.TotalIb > 0 and m.TotalIbPla > 0 then m.[1stLevelSupportCosts] / m.TotalIb + m.[2ndLevelSupportCosts] / m.TotalIbPla end as ServiceSupportPerYear

                , m.StdLabourCost + m.StdTravelCost + coalesce(m.StdPerformanceRate, 0) as FieldServicePerYearStdw

                , (1 - m.TimeAndMaterialShare) * (m.TravelCost + m.LabourCost + m.PerformanceRate) + m.TimeAndMaterialShare * ((m.TravelTime + m.repairTime) * m.OnsiteHourlyRates + m.PerformanceRate) as FieldServicePerYear

                , m.StdStandardHandling + m.StdHighAvailabilityHandling + m.StdStandardDelivery + m.StdExpressDelivery + m.StdTaxiCourierDelivery + m.StdReturnDeliveryFactory as LogisticPerYearStdw

                , m.StandardHandling + m.HighAvailabilityHandling + m.StandardDelivery + m.ExpressDelivery + m.TaxiCourierDelivery + m.ReturnDeliveryFactory as LogisticPerYear

                , m.LocalRemoteAccessSetup + m.Year * (m.LocalPreparation + m.LocalRegularUpdate + m.LocalRemoteCustomerBriefing + m.LocalOnsiteCustomerBriefing + m.Travel + m.CentralExecutionReport) as ProActive
       
        from Hardware.GetCalcMemberSla(@approved, @sla) m
    )
    , CostCte2 as (
        select    m.*

                , case when m.StdWarranty >= 1 then m.MaterialCostWarranty * m.AFR1 else 0 end as mat1
                , case when m.StdWarranty >= 2 then m.MaterialCostWarranty * m.AFR2 else 0 end as mat2
                , case when m.StdWarranty >= 3 then m.MaterialCostWarranty * m.AFR3 else 0 end as mat3
                , case when m.StdWarranty >= 4 then m.MaterialCostWarranty * m.AFR4 else 0 end as mat4
                , case when m.StdWarranty >= 5 then m.MaterialCostWarranty * m.AFR5 else 0 end as mat5
                , 0  as mat1P

                , case when m.StdWarranty >= 1 then 0 else m.MaterialCostOow * m.AFR1 end as matO1
                , case when m.StdWarranty >= 2 then 0 else m.MaterialCostOow * m.AFR2 end as matO2
                , case when m.StdWarranty >= 3 then 0 else m.MaterialCostOow * m.AFR3 end as matO3
                , case when m.StdWarranty >= 4 then 0 else m.MaterialCostOow * m.AFR4 end as matO4
                , case when m.StdWarranty >= 5 then 0 else m.MaterialCostOow * m.AFR5 end as matO5
                , m.MaterialCostOow * m.AFRP1 as matO1P

                , m.FieldServicePerYearStdw * m.AFR1  as FieldServiceCostStdw1
                , m.FieldServicePerYearStdw * m.AFR2  as FieldServiceCostStdw2
                , m.FieldServicePerYearStdw * m.AFR3  as FieldServiceCostStdw3
                , m.FieldServicePerYearStdw * m.AFR4  as FieldServiceCostStdw4
                , m.FieldServicePerYearStdw * m.AFR5  as FieldServiceCostStdw5

                , m.FieldServicePerYear * m.AFR1  as FieldServiceCost1
                , m.FieldServicePerYear * m.AFR2  as FieldServiceCost2
                , m.FieldServicePerYear * m.AFR3  as FieldServiceCost3
                , m.FieldServicePerYear * m.AFR4  as FieldServiceCost4
                , m.FieldServicePerYear * m.AFR5  as FieldServiceCost5
                , m.FieldServicePerYear * m.AFRP1 as FieldServiceCost1P

                , m.LogisticPerYearStdw * m.AFR1  as LogisticStdw1
                , m.LogisticPerYearStdw * m.AFR2  as LogisticStdw2
                , m.LogisticPerYearStdw * m.AFR3  as LogisticStdw3
                , m.LogisticPerYearStdw * m.AFR4  as LogisticStdw4
                , m.LogisticPerYearStdw * m.AFR5  as LogisticStdw5

                , m.LogisticPerYear * m.AFR1  as Logistic1
                , m.LogisticPerYear * m.AFR2  as Logistic2
                , m.LogisticPerYear * m.AFR3  as Logistic3
                , m.LogisticPerYear * m.AFR4  as Logistic4
                , m.LogisticPerYear * m.AFR5  as Logistic5
                , m.LogisticPerYear * m.AFRP1 as Logistic1P

        from CostCte m
    )
    , CostCte2_2 as (
        select    m.*

                , case when m.StdWarranty >= 1 then m.TaxAndDutiesOrZero * m.mat1 else 0 end as tax1
                , case when m.StdWarranty >= 2 then m.TaxAndDutiesOrZero * m.mat2 else 0 end as tax2
                , case when m.StdWarranty >= 3 then m.TaxAndDutiesOrZero * m.mat3 else 0 end as tax3
                , case when m.StdWarranty >= 4 then m.TaxAndDutiesOrZero * m.mat4 else 0 end as tax4
                , case when m.StdWarranty >= 5 then m.TaxAndDutiesOrZero * m.mat5 else 0 end as tax5
                , 0  as tax1P

                , case when m.StdWarranty >= 1 then 0 else m.TaxAndDutiesOrZero * m.matO1 end as taxO1
                , case when m.StdWarranty >= 2 then 0 else m.TaxAndDutiesOrZero * m.matO2 end as taxO2
                , case when m.StdWarranty >= 3 then 0 else m.TaxAndDutiesOrZero * m.matO3 end as taxO3
                , case when m.StdWarranty >= 4 then 0 else m.TaxAndDutiesOrZero * m.matO4 end as taxO4
                , case when m.StdWarranty >= 5 then 0 else m.TaxAndDutiesOrZero * m.matO5 end as taxO5
                , m.TaxAndDutiesOrZero * m.matO1P as taxO1P

                , m.mat1  + m.matO1                     as matCost1
                , m.mat2  + m.matO2                     as matCost2
                , m.mat3  + m.matO3                     as matCost3
                , m.mat4  + m.matO4                     as matCost4
                , m.mat5  + m.matO5                     as matCost5
                , m.mat1P + m.matO1P                    as matCost1P

                , m.TaxAndDutiesOrZero * (m.mat1  + m.matO1)  as TaxAndDuties1
                , m.TaxAndDutiesOrZero * (m.mat2  + m.matO2)  as TaxAndDuties2
                , m.TaxAndDutiesOrZero * (m.mat3  + m.matO3)  as TaxAndDuties3
                , m.TaxAndDutiesOrZero * (m.mat4  + m.matO4)  as TaxAndDuties4
                , m.TaxAndDutiesOrZero * (m.mat5  + m.matO5)  as TaxAndDuties5
                , m.TaxAndDutiesOrZero * (m.mat1P + m.matO1P) as TaxAndDuties1P

        from CostCte2 m
    )
    , CostCte3 as (
        select    
                  m.*

                , Hardware.MarkupOrFixValue(m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1
                , Hardware.MarkupOrFixValue(m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect2
                , Hardware.MarkupOrFixValue(m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect3
                , Hardware.MarkupOrFixValue(m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect4
                , Hardware.MarkupOrFixValue(m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect5
                , Hardware.MarkupOrFixValue(m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.ReinsuranceOrZero + m.AvailabilityFeeOrZero, m.MarkupFactorOtherCost, m.MarkupOtherCost)  as OtherDirect1P

                , case when m.StdWarranty >= 1 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw1, m.ServiceSupportPerYear, m.LogisticStdw1, m.tax1, m.AFR1, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty1
                , case when m.StdWarranty >= 2 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw2, m.ServiceSupportPerYear, m.LogisticStdw2, m.tax2, m.AFR2, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty2
                , case when m.StdWarranty >= 3 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw3, m.ServiceSupportPerYear, m.LogisticStdw3, m.tax3, m.AFR3, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty3
                , case when m.StdWarranty >= 4 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw4, m.ServiceSupportPerYear, m.LogisticStdw4, m.tax4, m.AFR4, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty4
                , case when m.StdWarranty >= 5 
                        then Hardware.CalcLocSrvStandardWarranty(m.FieldServiceCostStdw5, m.ServiceSupportPerYear, m.LogisticStdw5, m.tax5, m.AFR5, 1 + m.MarkupFactorStandardWarranty, m.MarkupStandardWarranty)
                        else 0 
                    end as LocalServiceStandardWarranty5

        from CostCte2_2 m
    )
    , CostCte4 as (
        select m.*
             , m.mat1 + m.LocalServiceStandardWarranty1 as Credit1
             , m.mat2 + m.LocalServiceStandardWarranty2 as Credit2
             , m.mat3 + m.LocalServiceStandardWarranty3 as Credit3
             , m.mat4 + m.LocalServiceStandardWarranty4 as Credit4
             , m.mat5 + m.LocalServiceStandardWarranty5 as Credit5
        from CostCte3 m
    )
    , CostCte5 as (
        select m.*

             , m.FieldServiceCost1  + m.ServiceSupportPerYear + m.matCost1  + m.Logistic1  + m.TaxAndDuties1  + m.ReinsuranceOrZero + m.OtherDirect1  + m.AvailabilityFeeOrZero - m.Credit1  as ServiceTP1
             , m.FieldServiceCost2  + m.ServiceSupportPerYear + m.matCost2  + m.Logistic2  + m.TaxAndDuties2  + m.ReinsuranceOrZero + m.OtherDirect2  + m.AvailabilityFeeOrZero - m.Credit2  as ServiceTP2
             , m.FieldServiceCost3  + m.ServiceSupportPerYear + m.matCost3  + m.Logistic3  + m.TaxAndDuties3  + m.ReinsuranceOrZero + m.OtherDirect3  + m.AvailabilityFeeOrZero - m.Credit3  as ServiceTP3
             , m.FieldServiceCost4  + m.ServiceSupportPerYear + m.matCost4  + m.Logistic4  + m.TaxAndDuties4  + m.ReinsuranceOrZero + m.OtherDirect4  + m.AvailabilityFeeOrZero - m.Credit4  as ServiceTP4
             , m.FieldServiceCost5  + m.ServiceSupportPerYear + m.matCost5  + m.Logistic5  + m.TaxAndDuties5  + m.ReinsuranceOrZero + m.OtherDirect5  + m.AvailabilityFeeOrZero - m.Credit5  as ServiceTP5
             , m.FieldServiceCost1P + m.ServiceSupportPerYear + m.matCost1P + m.Logistic1P + m.TaxAndDuties1P + m.ReinsuranceOrZero + m.OtherDirect1P + m.AvailabilityFeeOrZero              as ServiceTP1P

        from CostCte4 m
    )
    , CostCte6 as (
        select m.*
                , case when m.ServiceTP1  < m.OtherDirect1  then 0 else m.ServiceTP1  - m.OtherDirect1  end as ServiceTC1
                , case when m.ServiceTP2  < m.OtherDirect2  then 0 else m.ServiceTP2  - m.OtherDirect2  end as ServiceTC2
                , case when m.ServiceTP3  < m.OtherDirect3  then 0 else m.ServiceTP3  - m.OtherDirect3  end as ServiceTC3
                , case when m.ServiceTP4  < m.OtherDirect4  then 0 else m.ServiceTP4  - m.OtherDirect4  end as ServiceTC4
                , case when m.ServiceTP5  < m.OtherDirect5  then 0 else m.ServiceTP5  - m.OtherDirect5  end as ServiceTC5
                , case when m.ServiceTP1P < m.OtherDirect1P then 0 else m.ServiceTP1P - m.OtherDirect1P end as ServiceTC1P
        from CostCte5 m
    )    
    select m.Id

         --SLA

         , m.CountryId
         , m.Country
         , m.CurrencyId
         , m.ExchangeRate
         , m.WgId
         , m.Wg
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

         , m.Fsp
         , m.FspDescription

         , m.Sla
         , m.SlaHash

         , m.StdWarranty

         --Cost

         , m.AvailabilityFee * m.Year as AvailabilityFee
         , m.tax1 + m.tax2 + m.tax3 + m.tax4 + m.tax5 as TaxAndDutiesW
         , m.taxO1 + m.taxO2 + m.taxO3 + m.taxO4 + m.taxO5 as TaxAndDutiesOow
         , m.Reinsurance
         , m.ProActive
         , m.Year * m.ServiceSupportPerYear as ServiceSupportCost

         , m.mat1 + m.mat2 + m.mat3 + m.mat4 + m.mat5 as MaterialW
         , m.matO1 + m.matO2 + m.matO3 + m.matO4 + m.matO5 as MaterialOow

         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.FieldServiceCost1, m.FieldServiceCost2, m.FieldServiceCost3, m.FieldServiceCost4, m.FieldServiceCost5, m.FieldServiceCost1P) as FieldServiceCost
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.Logistic1, m.Logistic2, m.Logistic3, m.Logistic4, m.Logistic5, m.Logistic1P) as Logistic
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.OtherDirect1, m.OtherDirect2, m.OtherDirect3, m.OtherDirect4, m.OtherDirect5, m.OtherDirect1P) as OtherDirect
       
         , m.LocalServiceStandardWarranty1 + m.LocalServiceStandardWarranty2 + m.LocalServiceStandardWarranty3 + m.LocalServiceStandardWarranty4 + m.LocalServiceStandardWarranty5 as LocalServiceStandardWarranty
       
         , m.Credit1 + m.Credit2 + m.Credit3 + m.Credit4 + m.Credit5 as Credits

         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTC1, m.ServiceTC2, m.ServiceTC3, m.ServiceTC4, m.ServiceTC5, m.ServiceTC1P) as ServiceTC
         , Hardware.CalcByDur(m.Year, m.IsProlongation, m.ServiceTP1, m.ServiceTP2, m.ServiceTP3, m.ServiceTP4, m.ServiceTP5, m.ServiceTP1P) as ServiceTP

         , m.ServiceTC1
         , m.ServiceTC2
         , m.ServiceTC3
         , m.ServiceTC4
         , m.ServiceTC5
         , m.ServiceTC1P

         , m.ServiceTP1
         , m.ServiceTP2
         , m.ServiceTP3
         , m.ServiceTP4
         , m.ServiceTP5
         , m.ServiceTP1P

         , m.ListPrice
         , m.DealerDiscount
         , m.DealerPrice
         , m.ServiceTCManual
         , m.ServiceTPManual
         , m.ServiceTP_Released

         , m.ChangeUserName
         , m.ChangeUserEmail

       from CostCte6 m
)
GO

IF OBJECT_ID('Hardware.SpGetCosts') IS NOT NULL
  DROP PROCEDURE Hardware.SpGetCosts;
go

CREATE PROCEDURE Hardware.SpGetCosts
    @approved     bit,
    @local        bit,
    @cnt          dbo.ListID readonly,
    @wg           dbo.ListID readonly,
    @av           dbo.ListID readonly,
    @dur          dbo.ListID readonly,
    @reactiontime dbo.ListID readonly,
    @reactiontype dbo.ListID readonly,
    @loc          dbo.ListID readonly,
    @pro          dbo.ListID readonly,
    @lastid       bigint,
    @limit        int,
    @total        int output
AS
BEGIN

    SET NOCOUNT ON;

    select @total = COUNT(Id) from Portfolio.GetBySla(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro);

    declare @sla Portfolio.Sla;
    insert into @sla select * from Portfolio.GetBySlaPaging(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro, @lastid, @limit) m

    declare @cur nvarchar(max);
    declare @exchange float;

    if @local = 1
    begin
    
        --convert values from EUR to local

        select costs.Id

             , Country
             , cur.Name as Currency
             , costs.ExchangeRate

             , Wg
             , Availability
             , Duration
             , ReactionTime
             , ReactionType
             , ServiceLocation
             , ProActiveSla

             , StdWarranty

             --Cost

             , AvailabilityFee               * costs.ExchangeRate  as AvailabilityFee 
             , TaxAndDutiesW                 * costs.ExchangeRate  as TaxAndDutiesW
             , TaxAndDutiesOow               * costs.ExchangeRate  as TaxAndDutiesOow
             , Reinsurance                   * costs.ExchangeRate  as Reinsurance
             , ProActive                     * costs.ExchangeRate  as ProActive
             , ServiceSupportCost            * costs.ExchangeRate  as ServiceSupportCost

             , MaterialW                     * costs.ExchangeRate  as MaterialW
             , MaterialOow                   * costs.ExchangeRate  as MaterialOow
             , FieldServiceCost              * costs.ExchangeRate  as FieldServiceCost
             , Logistic                      * costs.ExchangeRate  as Logistic
             , OtherDirect                   * costs.ExchangeRate  as OtherDirect
             , LocalServiceStandardWarranty  * costs.ExchangeRate  as LocalServiceStandardWarranty
             , Credits                       * costs.ExchangeRate  as Credits
             , ServiceTC                     * costs.ExchangeRate  as ServiceTC
             , ServiceTP                     * costs.ExchangeRate  as ServiceTP

             , ServiceTCManual               * costs.ExchangeRate  as ServiceTCManual
             , ServiceTPManual               * costs.ExchangeRate  as ServiceTPManual

             , ServiceTP_Released            * costs.ExchangeRate  as ServiceTP_Released

             , ListPrice                     * costs.ExchangeRate  as ListPrice
             , DealerPrice                   * costs.ExchangeRate  as DealerPrice
             , DealerDiscount                                      as DealerDiscount
                                                             
             , ChangeUserName                                      as ChangeUserName
             , ChangeUserEmail                                     as ChangeUserEmail

        from Hardware.GetCostsSla(@approved, @sla) costs
        join [References].Currency cur on cur.Id = costs.CurrencyId
        order by Id
        
    end
    else
    begin

        select costs.Id

             , Country
             , 'EUR' as Currency
             , costs.ExchangeRate

             , Wg
             , Availability
             , Duration
             , ReactionTime
             , ReactionType
             , ServiceLocation
             , ProActiveSla

             , StdWarranty

             --Cost

             , AvailabilityFee               
             , TaxAndDutiesW                 
             , TaxAndDutiesOow               
             , Reinsurance                   
             , ProActive                     
             , ServiceSupportCost            

             , MaterialW                     
             , MaterialOow                   
             , FieldServiceCost              
             , Logistic                      
             , OtherDirect                   
             , LocalServiceStandardWarranty  
             , Credits                       
             , ServiceTC                     
             , ServiceTP                     

             , ServiceTCManual               
             , ServiceTPManual               

             , ServiceTP_Released            

             , ListPrice                     
             , DealerPrice                   
             , DealerDiscount                
                                             
             , ChangeUserName                
             , ChangeUserEmail               

        from Hardware.GetCostsSla(@approved, @sla) costs
        order by Id
    end
END
go

--######### REPORTS ###############

IF OBJECT_ID('[Report].[GetCosts]') IS NOT NULL
    DROP FUNCTION [Report].[GetCosts]
GO

CREATE FUNCTION [Report].[GetCosts]
(
    @cnt bigint,
    @wg bigint,
    @av bigint,
    @dur bigint,
    @reactiontime bigint,
    @reactiontype bigint,
    @loc bigint,
    @pro bigint
)
RETURNS @tbl TABLE (
           Id                                bigint
         , Fsp                               nvarchar(255)
         , FspDescription                    nvarchar(255)
         , CountryId                         bigint
         , Country                           nvarchar(255)
         , CurrencyId                        bigint
         , ExchangeRate                      float
         , WgId                              bigint
         , Wg                                nvarchar(255)
         , AvailabilityId                    bigint
         , Availability                      nvarchar(255)
         , DurationId                        bigint
         , Duration                          nvarchar(255)
         , Year                              int
         , IsProlongation                    bit
         , ReactionTimeId                    bigint
         , ReactionTime                      nvarchar(255)
         , ReactionTypeId                    bigint
         , ReactionType                      nvarchar(255)
         , ServiceLocationId                 bigint
         , ServiceLocation                   nvarchar(255)
         , ProActiveSlaId                    bigint
         , ProActiveSla                      nvarchar(255)
         , Sla                               nvarchar(255)
         , SlaHash                           int
         , StdWarranty                       float
         , AvailabilityFee                   float
         , TaxAndDutiesW                     float
         , TaxAndDutiesOow                   float
         , Reinsurance                       float
         , ProActive                         float
         , ServiceSupportCost                float
         , MaterialW                         float
         , MaterialOow                       float
         , FieldServiceCost                  float
         , Logistic                          float
         , OtherDirect                       float
         , LocalServiceStandardWarranty      float
         , Credits                           float
         , ServiceTC                         float
         , ServiceTP                         float
         , ServiceTC1                        float
         , ServiceTC2                        float
         , ServiceTC3                        float
         , ServiceTC4                        float
         , ServiceTC5                        float
         , ServiceTC1P                       float
         , ServiceTP1                        float
         , ServiceTP2                        float
         , ServiceTP3                        float
         , ServiceTP4                        float
         , ServiceTP5                        float
         , ServiceTP1P                       float
         , ListPrice                         float
         , DealerDiscount                    float
         , DealerPrice                       float
         , ServiceTCManual                   float
         , ServiceTPManual                   float
         , ServiceTP_Released                float
         , ChangeUserName                    nvarchar(255)
         , ChangeUserEmail                   nvarchar(255)
)
AS
begin

    declare @sla Portfolio.Sla;
    insert into @sla 
        select -1 as rownum
              , Id
              , CountryId
              , WgId
              , AvailabilityId
              , DurationId
              , ReactionTimeId
              , ReactionTypeId
              , ServiceLocationId
              , ProActiveSlaId
              , Sla
              , SlaHash
              , ReactionTime_Avalability
              , ReactionTime_ReactionType
              , ReactionTime_ReactionType_Avalability
              , m.Fsp
              , m.FspDescription
        from Portfolio.GetBySlaFspSingle(@cnt, @wg, @av, @dur, @reactiontime, @reactiontype, @loc, @pro) m
    
    insert into @tbl 
    select 
              Id                               
            , Fsp                              
            , FspDescription                   
            , CountryId                        
            , Country                          
            , CurrencyId                       
            , ExchangeRate                     
            , WgId                             
            , Wg                               
            , AvailabilityId                   
            , Availability                     
            , DurationId                       
            , Duration                         
            , Year                             
            , IsProlongation                   
            , ReactionTimeId                   
            , ReactionTime                     
            , ReactionTypeId                   
            , ReactionType                     
            , ServiceLocationId                
            , ServiceLocation                  
            , ProActiveSlaId                   
            , ProActiveSla                     
            , Sla                              
            , SlaHash                          
            , StdWarranty                      
            , AvailabilityFee                  
            , TaxAndDutiesW                    
            , TaxAndDutiesOow                  
            , Reinsurance                      
            , ProActive                        
            , ServiceSupportCost               
            , MaterialW                        
            , MaterialOow                      
            , FieldServiceCost                 
            , Logistic                         
            , OtherDirect                      
            , LocalServiceStandardWarranty     
            , Credits                          
            , ServiceTC                        
            , ServiceTP                        
            , ServiceTC1                       
            , ServiceTC2                       
            , ServiceTC3                       
            , ServiceTC4                       
            , ServiceTC5                       
            , ServiceTC1P                      
            , ServiceTP1                       
            , ServiceTP2                       
            , ServiceTP3                       
            , ServiceTP4                       
            , ServiceTP5                       
            , ServiceTP1P                      
            , ListPrice                        
            , DealerDiscount                   
            , DealerPrice                      
            , ServiceTCManual                  
            , ServiceTPManual                  
            , ServiceTP_Released               
            , ChangeUserName                   
            , ChangeUserEmail                  
    from Hardware.GetCostsSla(1, @sla)
    
    return;
end
GO