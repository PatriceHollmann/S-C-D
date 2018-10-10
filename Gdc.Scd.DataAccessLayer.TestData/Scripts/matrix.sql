IF OBJECT_ID('dbo.AddMatrixRules') IS NOT NULL
  DROP PROCEDURE dbo.AddMatrixRules;
go

IF OBJECT_ID('dbo.AllowMatrixRows') IS NOT NULL
  DROP PROCEDURE dbo.AllowMatrixRows;
go

IF OBJECT_ID('dbo.DelMatrixRules') IS NOT NULL
  DROP PROCEDURE dbo.DelMatrixRules;
go

IF OBJECT_ID('dbo.DenyMatrixRows') IS NOT NULL
  DROP PROCEDURE dbo.DenyMatrixRows;
go

IF OBJECT_ID('dbo.FindMatrixRowsByRule') IS NOT NULL
  DROP FUNCTION dbo.FindMatrixRowsByRule;
go 

IF OBJECT_ID('dbo.CrossJoinMatrixRule') IS NOT NULL
  DROP FUNCTION dbo.CrossJoinMatrixRule;
go

IF OBJECT_ID('dbo.IsListEmpty') IS NOT NULL
  DROP FUNCTION dbo.IsListEmpty;
go

IF OBJECT_ID('dbo.GetListOrNull') IS NOT NULL
  DROP FUNCTION dbo.GetListOrNull;
go

IF TYPE_ID('dbo.ListID') IS NOT NULL
  DROP Type dbo.ListID;
go

CREATE TYPE [dbo].[ListID] AS TABLE(
	[id] [bigint] NULL
)
go

CREATE FUNCTION [dbo].[IsListEmpty](@list ListID readonly)
RETURNS bit
AS
BEGIN
	
	declare @result bit = 1;

    if exists(select 1 from @list)
       set @result = 0;
   
   	RETURN @result;

END
go

CREATE FUNCTION [dbo].[GetListOrNull](@list ListID readonly)
RETURNS @tbl table(id bigint)
AS
BEGIN

    insert into @tbl(id) select id from @list;

	if not exists (select 1 from @tbl)
        insert into @tbl (id) values (null);
	
	RETURN 
END
go    
      
CREATE FUNCTION [dbo].[CrossJoinMatrixRule] (	
	@cnt bigint,
	@wg ListID readonly,
	@av ListID readonly,
	@dur ListID readonly,
	@rtype ListID readonly,
	@rtime ListID readonly,
	@loc ListID readonly,
	@globalPortfolio bit, 
	@masterPortfolio bit, 
	@corePortfolio bit
)
RETURNS TABLE 
AS
return SELECT @cnt as 'Country', 
			wg.Id as 'WG', 
			av.Id as 'Availability', 
			dur.Id as 'Duration', 
			rtype.Id as 'ReactionType', 
			rtime.Id as 'ReactionTime', 
			loc.Id as 'ServiceLocation', 
			@globalPortfolio as 'FujitsuGlobalPortfolio',
			@masterPortfolio as 'MasterPortfolio',
			@corePortfolio as 'CorePortfolio'
		FROM GetListOrNull(@wg) as wg
		CROSS JOIN GetListOrNull(@av) as av
		CROSS JOIN GetListOrNull(@dur) as dur
		CROSS JOIN GetListOrNull(@rtype) as rtype
		CROSS JOIN GetListOrNull(@rtime) as rtime
		CROSS JOIN GetListOrNull(@loc) as loc

go

CREATE FUNCTION [dbo].[FindMatrixRowsByRule](@rules ListID readonly)
RETURNS TABLE  
AS  
RETURN 

	select m.Id
		from Matrix m, MatrixRule mr
		where mr.Id in (select id from @rules)
			  and ((mr.CountryId is null and m.CountryId is null) or m.CountryId = mr.CountryId)

			  and m.FujitsuGlobalPortfolio = mr.FujitsuGlobalPortfolio
			  and m.MasterPortfolio = mr.MasterPortfolio
			  and m.CorePortfolio = mr.CorePortfolio

			  and (mr.AvailabilityId is null or m.AvailabilityId = mr.AvailabilityId)
			  and (mr.DurationId is null or m.DurationId = mr.DurationId)
			  and (mr.ReactionTimeId is null or m.ReactionTimeId = mr.ReactionTimeId)
			  and (mr.ReactionTypeId is null or m.ReactionTypeId = mr.ReactionTypeId)
			  and (mr.ServiceLocationId is null or m.ServiceLocationId = mr.ServiceLocationId)
			  and (mr.WgId is null or m.WgId = mr.WgId)
      
	except

	SELECT m.Id
			from Matrix m, (
				SELECT * from (
					select  mr2.*
					from MatrixRule mr1, MatrixRule mr2
					where mr1.Id in (select id from @rules)

			        		and ((mr1.CountryId is null and mr2.CountryId is null) or mr1.CountryId = mr2.CountryId)
			        		and mr1.FujitsuGlobalPortfolio = mr2.FujitsuGlobalPortfolio
			        		and mr1.MasterPortfolio = mr2.MasterPortfolio
			        		and mr1.CorePortfolio = mr2.CorePortfolio
			        
			        		and (mr1.AvailabilityId is null or mr1.AvailabilityId = mr2.AvailabilityId)
			        		and (mr1.DurationId is null or mr1.DurationId = mr2.DurationId)
			        		and (mr1.ReactionTimeId is null or mr1.ReactionTimeId = mr2.ReactionTimeId)
			        		and (mr1.ReactionTypeId is null or mr1.ReactionTypeId = mr2.ReactionTypeId)
			        		and (mr1.ServiceLocationId is null or mr1.ServiceLocationId = mr2.ServiceLocationId)
			        		and (mr1.WgId is null or mr1.WgId = mr2.WgId)
				) t where t.Id not in (select id from @rules)
			) mr

			where ((mr.CountryId is null and m.CountryId is null) or m.CountryId = mr.CountryId)

				  and m.FujitsuGlobalPortfolio = mr.FujitsuGlobalPortfolio
				  and m.MasterPortfolio = mr.MasterPortfolio
				  and m.CorePortfolio = mr.CorePortfolio

				  and (mr.AvailabilityId is null or m.AvailabilityId = mr.AvailabilityId)
				  and (mr.DurationId is null or m.DurationId = mr.DurationId)
				  and (mr.ReactionTimeId is null or m.ReactionTimeId = mr.ReactionTimeId)
				  and (mr.ReactionTypeId is null or m.ReactionTypeId = mr.ReactionTypeId)
				  and (mr.ServiceLocationId is null or m.ServiceLocationId = mr.ServiceLocationId)
				  and (mr.WgId is null or m.WgId = mr.WgId);

go

CREATE PROCEDURE [dbo].[AllowMatrixRows]
	@rules ListID READONLY
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE Matrix set Denied = 0 where Id in (SELECT Id FROM FindMatrixRowsByRule(@rules));
END

go

CREATE PROCEDURE [dbo].[DelMatrixRules]
	@rules ListID READONLY
AS
BEGIN

	SET NOCOUNT ON;

    exec AllowMatrixRows @rules;
	DELETE FROM MatrixRule WHERE Id in (select Id from @rules);
END

go

CREATE PROCEDURE [dbo].[DenyMatrixRows]
	@cnt bigint,
	@wg ListID readonly,
	@av ListID readonly,
	@dur ListID readonly,
	@rtype ListID readonly,
	@rtime ListID readonly,
	@loc ListID readonly,
	@globalPortfolio bit, 
	@masterPortfolio bit, 
	@corePortfolio bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @isEmptyWG bit = dbo.IsListEmpty(@wg);
	declare @isEmptyAv bit = dbo.IsListEmpty(@av);
	declare @isEmptyDur bit = dbo.IsListEmpty(@dur);
	declare @isEmptyRType bit = dbo.IsListEmpty(@rtype);
	declare @isEmptyRTime bit = dbo.IsListEmpty(@rtime);
	declare @isEmptyLoc bit = dbo.IsListEmpty(@loc);

	UPDATE Matrix SET Denied = 1
			WHERE ((@cnt is null and CountryId is null) or (CountryId = @cnt))

					AND FujitsuGlobalPortfolio = @globalPortfolio
					AND MasterPortfolio = @masterPortfolio
					AND CorePortfolio = @corePortfolio

					AND (@isEmptyWG = 1 or WgId in (select id from @wg))
					AND (@isEmptyAv = 1 or AvailabilityId in (select id from @av))
					AND (@isEmptyDur = 1 or DurationId in (select id from @dur))
					AND (@isEmptyRTime = 1 or ReactionTimeId in (select id from @rtime))
					AND (@isEmptyRType = 1 or ReactionTypeId in (select id from @rtype))
					AND (@isEmptyLoc = 1 or ServiceLocationId in (select id from @loc))
END

go

CREATE procedure [dbo].[AddMatrixRules] (	
	@cnt bigint,
	@wg ListID readonly,
	@av ListID readonly,
	@dur ListID readonly,
	@rtype ListID readonly,
	@rtime ListID readonly,
	@loc ListID readonly,
	@globalPortfolio bit, 
	@masterPortfolio bit, 
	@corePortfolio bit
)
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO MatrixRule(CountryId, WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio,MasterPortfolio, CorePortfolio) 

	SELECT Country, WG, Availability, Duration, ReactionType, ReactionTime, ServiceLocation, FujitsuGlobalPortfolio,MasterPortfolio,CorePortfolio
	FROM CrossJoinMatrixRule(@cnt, @wg, @av, @dur, @rtype, @rtime, @loc, @globalPortfolio, @masterPortfolio, @corePortfolio)

	EXCEPT

	SELECT CountryId, WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio 
	FROM MatrixRule;


	exec DenyMatrixRows @cnt, @wg, @av, @dur, @rtype, @rtime, @loc, @globalPortfolio, @masterPortfolio, @corePortfolio;

END

go


