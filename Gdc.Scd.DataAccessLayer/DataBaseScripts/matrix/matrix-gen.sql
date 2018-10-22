IF OBJECT_ID('tempdb..#Temp_SLA') IS NOT NULL DROP TABLE #Temp_SLA
IF OBJECT_ID('tempdb..#Temp_Wg') IS NOT NULL DROP TABLE #Temp_Wg
IF OBJECT_ID('tempdb..#ShrinkLog') IS NOT NULL DROP PROC #ShrinkLog

go

CREATE PROC #ShrinkLog
AS
    DBCC SHRINKFILE ('Scd_2_log', 1);
    RETURN 0
GO

ALTER INDEX IX_MatrixMaster_AvailabilityId    ON Matrix.MatrixMaster DISABLE;  
ALTER INDEX IX_MatrixMaster_DurationId        ON Matrix.MatrixMaster DISABLE;  
ALTER INDEX IX_MatrixMaster_ReactionTimeId    ON Matrix.MatrixMaster DISABLE;  
ALTER INDEX IX_MatrixMaster_ReactionTypeId    ON Matrix.MatrixMaster DISABLE;  
ALTER INDEX IX_MatrixMaster_ServiceLocationId ON Matrix.MatrixMaster DISABLE;  
ALTER INDEX IX_MatrixMaster_WgId              ON Matrix.MatrixMaster DISABLE;  

-- Disable all table constraints
ALTER TABLE Matrix.MatrixMaster NOCHECK CONSTRAINT ALL

DELETE FROM Matrix.MatrixMaster;

exec #ShrinkLog
GO

SELECT av.Id AS av, 
		dur.Id AS dur, 
		rtype.Id AS reacttype, 
		rtime.Id AS reacttime,
		sv.Id AS srvloc,
		gp AS FujitsuGlobalPortfolio,
		mp AS MasterPortfolio,
		cp AS CorePortfolio
INTO #Temp_Sla
FROM Dependencies.Availability AS av
CROSS JOIN Dependencies.Duration AS dur
CROSS JOIN Dependencies.ReactionType AS rtype
CROSS JOIN Dependencies.ReactionTime AS rtime
CROSS JOIN Dependencies.ServiceLocation AS sv
CROSS JOIN (VALUES (0), (1)) glport(gp)
CROSS JOIN (VALUES (0), (1)) mport(mp)
CROSS JOIN (VALUES (0), (1)) cport(cp);

declare @rownum int = 1;
declare @wg bigint;
declare @flag bit = 1;

SELECT ROW_NUMBER() over(order by Id) as rownum, Id
INTO #Temp_Wg
FROM InputAtoms.Wg

while @flag = 1
begin
    set @flag = 0;
    select @flag = 1, @wg = Id from #Temp_Wg where rownum = @rownum;
    set @rownum = @rownum + 1;

    if @flag = 0 break;

    INSERT INTO Matrix.MatrixMaster (WgId, AvailabilityId, DurationId, ReactionTypeId, ReactionTimeId, ServiceLocationId, FujitsuGlobalPortfolio, MasterPortfolio, CorePortfolio, Denied) (

            SELECT   @wg,
		                sla.av, 
		                sla.dur, 
		                sla.reacttype, 
		                sla.reacttime,
		                sla.srvloc,
		                sla.FujitsuGlobalPortfolio,
		                sla.MasterPortfolio,
		                sla.CorePortfolio,
		                0
            FROM #Temp_Sla sla
    );

    exec #ShrinkLog
end;

ALTER INDEX IX_MatrixMaster_AvailabilityId ON Matrix.MatrixMaster REBUILD;  
exec #ShrinkLog
GO

ALTER INDEX IX_MatrixMaster_DurationId ON Matrix.MatrixMaster REBUILD;  
exec #ShrinkLog
GO

ALTER INDEX IX_MatrixMaster_ReactionTimeId ON Matrix.MatrixMaster REBUILD;  
exec #ShrinkLog
GO

ALTER INDEX IX_MatrixMaster_ReactionTypeId ON Matrix.MatrixMaster REBUILD;  
exec #ShrinkLog
GO

ALTER INDEX IX_MatrixMaster_ServiceLocationId ON Matrix.MatrixMaster REBUILD;  
exec #ShrinkLog
GO

ALTER INDEX IX_MatrixMaster_WgId ON Matrix.MatrixMaster REBUILD;  
exec #ShrinkLog
GO

-- Enable all table constraints
ALTER TABLE Matrix.MatrixMaster CHECK CONSTRAINT ALL
exec #ShrinkLog
GO

IF OBJECT_ID('tempdb..#Temp_SLA') IS NOT NULL DROP TABLE #Temp_SLA
IF OBJECT_ID('tempdb..#Temp_Wg') IS NOT NULL DROP TABLE #Temp_Wg
IF OBJECT_ID('tempdb..#ShrinkLog') IS NOT NULL DROP PROC #ShrinkLog

