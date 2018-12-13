IF OBJECT_ID('matrix.AddRules') IS NOT NULL
  DROP PROCEDURE matrix.AddRules;
go

IF OBJECT_ID('matrix.AllowRows') IS NOT NULL
  DROP PROCEDURE matrix.AllowRows;
go

IF OBJECT_ID('matrix.AllowMasterRows') IS NOT NULL
  DROP PROCEDURE matrix.AllowMasterRows;
go

IF OBJECT_ID('matrix.DelRules') IS NOT NULL
  DROP PROCEDURE matrix.DelRules;
go

IF OBJECT_ID('matrix.DenyRows') IS NOT NULL
  DROP PROCEDURE matrix.DenyRows;
go

IF OBJECT_ID('matrix.DenyMasterRows') IS NOT NULL
  DROP PROCEDURE matrix.DenyMasterRows;
go

IF OBJECT_ID('matrix.FindRowsByRule') IS NOT NULL
  DROP FUNCTION matrix.FindRowsByRule;
go 

IF OBJECT_ID('matrix.FindMasterRowsByRule') IS NOT NULL
  DROP FUNCTION matrix.FindMasterRowsByRule;
go 

IF OBJECT_ID('matrix.GenRules') IS NOT NULL
  DROP FUNCTION matrix.GenRules;
go

IF OBJECT_ID('matrix.IsListEmpty') IS NOT NULL
  DROP FUNCTION matrix.IsListEmpty;
go

IF OBJECT_ID('matrix.GetListOrNull') IS NOT NULL
  DROP FUNCTION matrix.GetListOrNull;
go

IF TYPE_ID('dbo.ListID') IS NOT NULL
  DROP Type dbo.ListID;
go

CREATE TYPE dbo.ListID AS TABLE(
	id bigint NULL
)
go

CREATE FUNCTION matrix.IsListEmpty(@list dbo.ListID readonly)
RETURNS bit
AS
BEGIN
	
	declare @result bit = 1;

    if exists(select 1 from @list)
       set @result = 0;
   
   	RETURN @result;

END
go

CREATE FUNCTION matrix.GetListOrNull(@list dbo.ListID readonly)
RETURNS @tbl table(id bigint)
AS
BEGIN

    insert into @tbl(id) select id from @list;

	if not exists (select 1 from @tbl)
        insert into @tbl (id) values (null);
	
	RETURN 
END
go    
      
CREATE FUNCTION matrix.GenRules (
	@wg dbo.ListID readonly,
	@av dbo.ListID readonly,
	@dur dbo.ListID readonly,
	@rtype dbo.ListID readonly,
	@rtime dbo.ListID readonly,
	@loc dbo.ListID readonly
)
RETURNS TABLE 
AS
return SELECT wg.Id as WG, 
			av.Id as Availability, 
			dur.Id as Duration, 
			rtype.Id as ReactionType, 
			rtime.Id as ReactionTime, 
			loc.Id as ServiceLocation
		FROM matrix.GetListOrNull(@wg) as wg
		CROSS JOIN GetListOrNull(@av) as av
		CROSS JOIN GetListOrNull(@dur) as dur
		CROSS JOIN GetListOrNull(@rtype) as rtype
		CROSS JOIN GetListOrNull(@rtime) as rtime
		CROSS JOIN GetListOrNull(@loc) as loc

go

CREATE FUNCTION [Matrix].[FindRowsByRule](@rules dbo.ListID readonly)
RETURNS TABLE  
AS  
RETURN 

    with ExceptRuleCte as (
        select  mr2.*
        from matrix.MatrixRule mr1, matrix.MatrixRule mr2
        where       mr1.Id in (select id from @rules)
                and mr2.id <> mr1.Id
                and (mr1.CountryId = mr2.CountryId)
    )
    select m.Id
	    from matrix.Matrix m, matrix.MatrixRule mr
	    where mr.Id in (select id from @rules)
			    and (m.CountryId = mr.CountryId)

			    and (mr.AvailabilityId is null or m.AvailabilityId = mr.AvailabilityId)
			    and (mr.DurationId is null or m.DurationId = mr.DurationId)
			    and (mr.ReactionTimeId is null or m.ReactionTimeId = mr.ReactionTimeId)
			    and (mr.ReactionTypeId is null or m.ReactionTypeId = mr.ReactionTypeId)
			    and (mr.ServiceLocationId is null or m.ServiceLocationId = mr.ServiceLocationId)
			    and (mr.WgId is null or m.WgId = mr.WgId)
      
    except

    SELECT m.Id
		    from matrix.Matrix m, ExceptRuleCte mr

		    where     (m.CountryId = mr.CountryId)
				    and (mr.AvailabilityId is null or m.AvailabilityId = mr.AvailabilityId)
				    and (mr.DurationId is null or m.DurationId = mr.DurationId)
				    and (mr.ReactionTimeId is null or m.ReactionTimeId = mr.ReactionTimeId)
				    and (mr.ReactionTypeId is null or m.ReactionTypeId = mr.ReactionTypeId)
				    and (mr.ServiceLocationId is null or m.ServiceLocationId = mr.ServiceLocationId)
				    and (mr.WgId is null or m.WgId = mr.WgId);

go

CREATE FUNCTION [Matrix].[FindMasterRowsByRule](
    @rules dbo.ListID readonly, 
    @fujitsu bit,
    @master bit,
    @core bit
)
RETURNS TABLE  
AS  
RETURN 

	with ExceptRuleCte as (
        select  mr2.*
        from matrix.MatrixRule mr1, matrix.MatrixRule mr2
        where       mr1.Id in (select id from @rules)
                and mr2.id <> mr1.Id
         
	            and (mr1.CountryId is null and mr2.CountryId is null)
	            and mr1.FujitsuGlobalPortfolio = mr2.FujitsuGlobalPortfolio
	            and mr1.MasterPortfolio = mr2.MasterPortfolio
	            and mr1.CorePortfolio = mr2.CorePortfolio
    )
    select m.Id
	    from matrix.MatrixMaster m, matrix.MatrixRule mr
	    where       mr.Id in (select id from @rules)
                and mr.CountryId is null
			    and mr.FujitsuGlobalPortfolio = @fujitsu
			    and mr.MasterPortfolio = @master
			    and mr.CorePortfolio = @core

			    and (mr.AvailabilityId is null or m.AvailabilityId = mr.AvailabilityId)
			    and (mr.DurationId is null or m.DurationId = mr.DurationId)
			    and (mr.ReactionTimeId is null or m.ReactionTimeId = mr.ReactionTimeId)
			    and (mr.ReactionTypeId is null or m.ReactionTypeId = mr.ReactionTypeId)
			    and (mr.ServiceLocationId is null or m.ServiceLocationId = mr.ServiceLocationId)
			    and (mr.WgId is null or m.WgId = mr.WgId)
      
    except

    SELECT m.Id
		    from matrix.MatrixMaster m, ExceptRuleCte mr

		    where     mr.CountryId is null

			        and mr.FujitsuGlobalPortfolio = @fujitsu
			        and mr.MasterPortfolio = @master
			        and mr.CorePortfolio = @core


				    and (mr.AvailabilityId is null or m.AvailabilityId = mr.AvailabilityId)
				    and (mr.DurationId is null or m.DurationId = mr.DurationId)
				    and (mr.ReactionTimeId is null or m.ReactionTimeId = mr.ReactionTimeId)
				    and (mr.ReactionTypeId is null or m.ReactionTypeId = mr.ReactionTypeId)
				    and (mr.ServiceLocationId is null or m.ServiceLocationId = mr.ServiceLocationId)
				    and (mr.WgId is null or m.WgId = mr.WgId);

go

CREATE PROCEDURE matrix.AllowRows
	@rules dbo.ListID READONLY
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE m set Denied = 0
    from matrix.Matrix m
    join matrix.FindRowsByRule(@rules) r on r.id = m.Id
END

go

CREATE PROCEDURE [Matrix].[AllowMasterRows]
	@rules dbo.ListID READONLY,
    @globalPortfolio bit,
    @masterPortfolio bit,
    @corePortfolio   bit
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE matrix.MatrixMaster 
        SET   DeniedFujitsu = case when @globalPortfolio = 1 then 0 else DeniedFujitsu end
            , DeniedMaster =  case when @masterPortfolio = 1 then 0 else DeniedMaster end
            , DeniedCore =    case when @corePortfolio   = 1 then 0 else DeniedCore end
    from matrix.MatrixMaster m
    join matrix.FindMasterRowsByRule(@rules, @globalPortfolio, @masterPortfolio, @corePortfolio) r on r.Id = m.Id
END

go


CREATE PROCEDURE matrix.DelRules
	@rules dbo.ListID READONLY
AS
BEGIN

	SET NOCOUNT ON;

    exec Matrix.AllowRows @rules;
    exec Matrix.AllowMasterRows @rules, 1, 0, 0;
    exec Matrix.AllowMasterRows @rules, 0, 1, 0;
    exec Matrix.AllowMasterRows @rules, 0, 0, 1;
    DELETE FROM Matrix.MatrixRule WHERE Id in (select Id from @rules);
END

go

CREATE PROCEDURE matrix.DenyRows
	@cnt bigint,
	@wg dbo.ListID readonly,
	@av dbo.ListID readonly,
	@dur dbo.ListID readonly,
	@rtype dbo.ListID readonly,
	@rtime dbo.ListID readonly,
	@loc dbo.ListID readonly
AS
BEGIN

	SET NOCOUNT ON;

	declare @isEmptyWG bit = matrix.IsListEmpty(@wg);
	declare @isEmptyAv bit = matrix.IsListEmpty(@av);
	declare @isEmptyDur bit = matrix.IsListEmpty(@dur);
	declare @isEmptyRType bit = matrix.IsListEmpty(@rtype);
	declare @isEmptyRTime bit = matrix.IsListEmpty(@rtime);
	declare @isEmptyLoc bit = matrix.IsListEmpty(@loc);

	UPDATE matrix.Matrix SET Denied = 1
			WHERE       (CountryId = @cnt)

					AND (@isEmptyWG = 1 or WgId in (select id from @wg))
					AND (@isEmptyAv = 1 or AvailabilityId in (select id from @av))
					AND (@isEmptyDur = 1 or DurationId in (select id from @dur))
					AND (@isEmptyRTime = 1 or ReactionTimeId in (select id from @rtime))
					AND (@isEmptyRType = 1 or ReactionTypeId in (select id from @rtype))
					AND (@isEmptyLoc = 1 or ServiceLocationId in (select id from @loc))
END

go

CREATE PROCEDURE Matrix.DenyMasterRows
	@wg dbo.ListID readonly,
	@av dbo.ListID readonly,
	@dur dbo.ListID readonly,
	@rtype dbo.ListID readonly,
	@rtime dbo.ListID readonly,
	@loc dbo.ListID readonly,
	@globalPortfolio bit, 
	@masterPortfolio bit, 
	@corePortfolio bit
AS
BEGIN

	SET NOCOUNT ON;

	declare @isEmptyWG bit = matrix.IsListEmpty(@wg);
	declare @isEmptyAv bit = matrix.IsListEmpty(@av);
	declare @isEmptyDur bit = matrix.IsListEmpty(@dur);
	declare @isEmptyRType bit = matrix.IsListEmpty(@rtype);
	declare @isEmptyRTime bit = matrix.IsListEmpty(@rtime);
	declare @isEmptyLoc bit = matrix.IsListEmpty(@loc);

	UPDATE matrix.MatrixMaster 
        SET   DeniedFujitsu = case when @globalPortfolio = 1 then 1 else DeniedFujitsu end
            , DeniedMaster =  case when @masterPortfolio = 1 then 1 else DeniedMaster end
            , DeniedCore =    case when @corePortfolio   = 1 then 1 else DeniedCore end

			WHERE       (@isEmptyWG = 1 or WgId in (select id from @wg))
					AND (@isEmptyAv = 1 or AvailabilityId in (select id from @av))
					AND (@isEmptyDur = 1 or DurationId in (select id from @dur))
					AND (@isEmptyRTime = 1 or ReactionTimeId in (select id from @rtime))
					AND (@isEmptyRType = 1 or ReactionTypeId in (select id from @rtype))
					AND (@isEmptyLoc = 1 or ServiceLocationId in (select id from @loc))
END

go

CREATE procedure [Matrix].[AddRules] (	
	@cnt bigint,
	@wg dbo.ListID readonly,
	@av dbo.ListID readonly,
	@dur dbo.ListID readonly,
	@rtype dbo.ListID readonly,
	@rtime dbo.ListID readonly,
	@loc dbo.ListID readonly
)
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO matrix.MatrixRule(CountryId, WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio,MasterPortfolio, CorePortfolio) 

    SELECT @cnt, WG, Availability, Duration, ReactionType, ReactionTime, ServiceLocation, 0, 0, 0
    FROM matrix.GenRules(@wg, @av, @dur, @rtype, @rtime, @loc)

    EXCEPT

    SELECT CountryId, WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio 
    FROM matrix.MatrixRule
    WHERE CountryId = @cnt;

    exec Matrix.DenyRows @cnt, @wg, @av, @dur, @rtype, @rtime, @loc;
END

go

CREATE procedure [Matrix].[AddMasterRules] (	
	@wg dbo.ListID readonly,
	@av dbo.ListID readonly,
	@dur dbo.ListID readonly,
	@rtype dbo.ListID readonly,
	@rtime dbo.ListID readonly,
	@loc dbo.ListID readonly,
	@globalPortfolio bit, 
	@masterPortfolio bit, 
	@corePortfolio bit
)
AS
BEGIN

	SET NOCOUNT ON;

    if @globalPortfolio = 1
    begin

        INSERT INTO matrix.MatrixRule(WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio) 

        SELECT WG, Availability, Duration, ReactionType, ReactionTime, ServiceLocation, 1, 0, 0
        FROM matrix.GenRules(@wg, @av, @dur, @rtype, @rtime, @loc)

        EXCEPT

        SELECT WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio 
        FROM matrix.MatrixRule
        where CountryId is null and FujitsuGlobalPortfolio = 1 and MasterPortfolio = 0 and CorePortfolio = 0;
    end

    if @masterPortfolio = 1
    begin

        INSERT INTO matrix.MatrixRule(WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio) 

        SELECT WG, Availability, Duration, ReactionType, ReactionTime, ServiceLocation, 0, 1, 0
        FROM matrix.GenRules(@wg, @av, @dur, @rtype, @rtime, @loc)

        EXCEPT

        SELECT WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio 
        FROM matrix.MatrixRule
        where CountryId is null and FujitsuGlobalPortfolio = 0 and MasterPortfolio = 1 and CorePortfolio = 0;
    end

    if @corePortfolio = 1
    begin

        INSERT INTO matrix.MatrixRule(WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio) 

        SELECT WG, Availability, Duration, ReactionType, ReactionTime, ServiceLocation, 0, 0, 1
        FROM matrix.GenRules(@wg, @av, @dur, @rtype, @rtime, @loc)

        EXCEPT

        SELECT WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio 
        FROM matrix.MatrixRule
        where CountryId is null and FujitsuGlobalPortfolio = 0 and MasterPortfolio = 0 and CorePortfolio = 1;
    end

    if @globalPortfolio = 1 or @masterPortfolio = 1 or @corePortfolio = 1
    begin
        exec Matrix.DenyMasterRows @wg, @av, @dur, @rtype, @rtime, @loc, @globalPortfolio, @masterPortfolio, @corePortfolio;
    end
END


