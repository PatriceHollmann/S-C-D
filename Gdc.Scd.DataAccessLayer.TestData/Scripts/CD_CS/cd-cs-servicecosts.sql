IF OBJECT_ID('Report.[GetServiceCostsBySla') IS NOT NULL
  DROP FUNCTION Report.[GetServiceCostsBySla];
go 

CREATE FUNCTION [Report].[GetServiceCostsBySla]
(
    @cnt nvarchar(200),
    @loc nvarchar(200),
    @av nvarchar(200),
    @reactiontime nvarchar(200),
    @reactiontype nvarchar(200),
    @wg nvarchar(200),   
    @dur nvarchar(200)
)
RETURNS @tbl TABLE (
    Country nvarchar(200),
    ServiceTC float, 
    ServiceTP float, 
    ServiceTPMonthly1 float,
    ServiceTPMonthly2 float,
    ServiceTPMonthly3 float,
    ServiceTPMonthly4 float,
    ServiceTPMonthly5 float
)
AS
BEGIN

    declare @cntId dbo.ListId;
    declare @locId dbo.ListId;
    declare @avId dbo.ListId;
    declare @reactiontimeId dbo.ListId;
    declare @reactiontypeId dbo.ListId;
    declare @wgId dbo.ListId;
    declare @durId dbo.ListId;
	declare @proId dbo.ListId;

    insert into @cntId select id from InputAtoms.Country where UPPER(Name)= UPPER(@cnt);
    insert into @locId select  id from Dependencies.ServiceLocation where UPPER(Name) = UPPER(@loc);
    insert into @avId select   id from Dependencies.Availability where ExternalName like '%' + @av + '%';
    insert into @reactiontimeId select   id from Dependencies.ReactionTime where UPPER(Name)=UPPER(@reactiontime);
    insert into @reactiontypeId select   id from Dependencies.ReactionType where UPPER(Name)=UPPER(@reactiontype);
    insert into @wgId select id from InputAtoms.Wg where UPPER(Name)=UPPER(@wg);
    insert into @durId select id from Dependencies.Duration where UPPER(Name)=UPPER(@dur);

    INSERT @tbl
    select costs.Country,
           coalesce(costs.ServiceTCManual, costs.ServiceTC) as ServiceTC, 
		   costs.ServiceTP_Released as ServiceTP, 
		   case when costs.DurationId >= 1 then  costs.ServiceTP_Released / dur.Value / 12 else null end as ServiceTPMonthly1,
		   case when costs.DurationId >= 2 then  costs.ServiceTP_Released / dur.Value / 12 else null end as ServiceTPMonthly2,
		   case when costs.DurationId >= 3 then  costs.ServiceTP_Released / dur.Value / 12 else null end as ServiceTPMonthly3,
		   case when costs.DurationId >= 4 then  costs.ServiceTP_Released / dur.Value / 12 else null end as ServiceTPMonthly4,
		   case when costs.DurationId >= 5 then  costs.ServiceTP_Released / dur.Value / 12 else null end as ServiceTPMonthly5
     from Hardware.GetCosts(1, @cntId, @wgId, @avId, @durId, @reactiontimeId, @reactiontypeId, @locId, @proId, 0, -1) costs
	 join Dependencies.Duration dur on dur.id = costs.DurationId and dur.IsProlongation = 0

    return;

END
