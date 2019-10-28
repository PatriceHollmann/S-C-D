﻿IF OBJECT_ID('[Portfolio].[GetBySlaSinglePaging]') IS NOT NULL
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