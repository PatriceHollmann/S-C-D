/****** Object:  UserDefinedFunction [Report].[GetServiceCostsBySla]    Script Date: 26.10.2018 15:29:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Report].[GetServiceCostsBySla]
(
    @cnt nvarchar(max),
    @loc nvarchar(max),
    @av nvarchar(max),
	@reactiontime nvarchar(max),
    @reactiontype nvarchar(max),
    @wg nvarchar(max),   
    @dur nvarchar(max)
)
RETURNS TABLE 
AS
RETURN (
    select costs.Country,
	coalesce(costs.ServiceTCManual, costs.ServiceTC) as ServiceTC, 
	coalesce(costs.ServiceTPManual, costs.ServiceTP) as ServiceTP, 
	costs.ServiceTP1,
	costs.ServiceTP2,
	costs.ServiceTP3,
	costs.ServiceTP4,
	costs.ServiceTP5
	from Matrix.Matrix
	join InputAtoms.Country cnt on cnt.Name = @cnt
	join Dependencies.ServiceLocation loc on loc.Name=@loc
	join Dependencies.Availability av on av.ExternalName like '%' + @av + '%'
	join Dependencies.ReactionTime rtime on rtime.Name=@reactiontime
	join Dependencies.ReactionType rtype on rtype.Name=@reactiontype
	join InputAtoms.Wg wg on wg.Name=@wg
	join Dependencies.Duration dur on dur.Name=@dur
	cross apply [Hardware].[GetCostsFull](0, cnt.Id, wg.Id, av.Id, dur.Id, rtime.Id, rtype.Id, loc.Id, 0, 1) costs
	where CountryId=cnt.Id and WgId=wg.Id and AvailabilityId=av.Id and DurationId=dur.Id and ReactionTimeId=rtime.Id and ReactionTypeId=rtype.Id and ServiceLocationId=loc.Id


)