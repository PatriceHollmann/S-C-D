USE [Scd_2]
GO
/****** Object:  UserDefinedFunction [dbo].[SrvSupportCost]    Script Date: 13.08.2018 15:24:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE PROCEDURE [dbo].[SrvSupportCost]
    @firstLevelSupport float,
	@secondLevelSupportPla float,
	@ibCountry float,
	@ibPla float,
	@result float = null out,
	@msg execError = null out
as
BEGIN
    SET NOCOUNT ON; 

	if @ibCountry = 0 or @ibPla = 0
	begin
	   set @result = null;
	   set @msg = 'Divide by zero';
	   return;
	end

	set @result = @firstLevelSupport / @ibCountry + @secondLevelSupportPla / @ibPla;

	if @result < 0
	begin
	   set @result = null;
	   set @msg = 'Negative value'
	end

END
