USE [Scd_2]
GO
/****** Object:  StoredProcedure [dbo].[SrvSupportCostAll]    Script Date: 14.08.2018 17:44:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SrvSupportCostAll] 
AS
BEGIN

	SET NOCOUNT ON;

	declare @pla bigint;
	declare @wg bigint;
	declare @cnt bigint;
	declare @ibCnt float;
	declare @ibCntPLA float;
	declare @firstLevelSupportCostsCountry float;
	declare @secondLevelSupportCostsClusterRegion float;
	declare @secondLevelSupportCostsLocal float;

	declare cur cursor for 
		select ib.Pla,
			   ib.Wg,
			   ib.Country,
			   ib.InstalledBaseCountry as ibCnt,
			   (select sum(InstalledBaseCountry) 
				   from Atom.InstallBase 
				   where Country = ib.Country 
						 and Pla = ib.Pla 
						 and InstalledBaseCountry is not null) as ib_Cnt_PLA,
			   ssc.[1stLevelSupportCostsCountry],
			   ssc.[2ndLevelSupportCostsClusterRegion],
			   ssc.[2ndLevelSupportCostsLocal]
		from Atom.InstallBase ib
		left join Hardware.ServiceSupportCost ssc on ib.Country = ssc.Country;

	open cur
	fetch next from cur into @pla, @wg, @cnt, @ibCnt, @ibCntPLA, @firstLevelSupportCostsCountry, @secondLevelSupportCostsClusterRegion, @secondLevelSupportCostsLocal;

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		PRINT 'row here.... ' ;-- + @pla;

		fetch next from cur into @pla, @wg, @cnt, @ibCnt, @ibCntPLA, @firstLevelSupportCostsCountry, @secondLevelSupportCostsClusterRegion, @secondLevelSupportCostsLocal;
	end

	close cur;
	deallocate cur;

END
