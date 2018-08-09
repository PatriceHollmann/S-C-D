USE [Scd_2]
GO
/****** Object:  UserDefinedFunction [dbo].[CrossJoinMatrixRule]    Script Date: 07.08.2018 13:16:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
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