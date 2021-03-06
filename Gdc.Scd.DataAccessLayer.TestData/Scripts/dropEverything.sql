ALTER DATABASE SCD_2 SET RECOVERY SIMPLE
GO 

declare @WorkTest char(1) = 'w'

declare @SQL varchar(4000)
declare @msg varchar(500)
 
IF OBJECT_ID('tempdb..#dropcode') IS NOT NULL DROP TABLE #dropcode
CREATE TABLE #dropcode
(
   ID int identity(1,1)
  ,SQLstatement varchar(1000)
 )
 
-- removes all the foreign keys that reference a PK in the target schema
 SELECT @SQL =
  'select
       '' ALTER TABLE "''+SCHEMA_NAME(fk.schema_id)+''"."''+OBJECT_NAME(fk.parent_object_id)+''" DROP CONSTRAINT ''+ fk.name
  FROM sys.foreign_keys fk
  join sys.tables t on t.object_id = fk.referenced_object_id
  order by fk.name desc'
 
 IF @WorkTest = 't' PRINT (@SQL )
 INSERT INTO #dropcode
 EXEC (@SQL)
  
 -- drop all default constraints, check constraints and Foreign Keys
 SELECT @SQL =
 'SELECT
       '' ALTER TABLE "''+schema_name(t.schema_id)+''"."''+OBJECT_NAME(fk.parent_object_id)+''" DROP CONSTRAINT ''+ fk.[Name]
  FROM sys.objects fk
  join sys.tables t on t.object_id = fk.parent_object_id
  where fk.type IN (''D'', ''C'', ''F'')'
  
 IF @WorkTest = 't' PRINT (@SQL )
 INSERT INTO #dropcode
 EXEC (@SQL)
 
 -- drop all other objects in order   
 SELECT @SQL =  
 'SELECT
      CASE WHEN SO.type=''PK'' THEN '' ALTER TABLE "''+SCHEMA_NAME(SO.schema_id)+''"."''+OBJECT_NAME(SO.parent_object_id)+''" DROP CONSTRAINT "''+ SO.name+''"''
           WHEN SO.type=''U'' THEN '' DROP TABLE "''+SCHEMA_NAME(SO.schema_id)+''"."''+ SO.[Name]+''"''
           WHEN SO.type=''V'' THEN '' DROP VIEW  "''+SCHEMA_NAME(SO.schema_id)+''"."''+ SO.[Name]+''"''
           WHEN SO.type=''P'' THEN '' DROP PROCEDURE  "''+SCHEMA_NAME(SO.schema_id)+''"."''+ SO.[Name]+''"''    
           WHEN SO.type=''TR'' THEN ''  DROP TRIGGER  "''+SCHEMA_NAME(SO.schema_id)+''"."''+ SO.[Name]+''"''
           WHEN SO.type=''SN'' THEN '' DROP SYNONYM "''+SCHEMA_NAME(SO.schema_id)+''"."''+ SO.[Name]+''"''
           WHEN SO.type= ''SO'' THEN '' DROP SEQUENCE "''+SCHEMA_NAME(SO.schema_id)+''"."''+ SO.[Name]+''"''
           WHEN SO.type  IN (''FN'', ''TF'',''IF'',''FS'',''FT'') THEN '' DROP FUNCTION  "''+SCHEMA_NAME(SO.schema_id)+''"."''+ SO.[Name]+''"''
       END
FROM SYS.OBJECTS SO
WHERE SO.type IN (''PK'', ''FN'', ''TF'', ''TR'', ''V'', ''U'', ''P'', ''SN'', ''IF'',''SO'')
ORDER BY CASE WHEN type = ''PK'' THEN 1
              WHEN type in (''FN'', ''TF'', ''P'',''IF'',''FS'',''FT'') THEN 2
              WHEN type = ''TR'' THEN 3
              WHEN type = ''V'' THEN 4
              WHEN type = ''U'' THEN 5
            ELSE 6
          END'
 
IF @WorkTest = 't' PRINT (@SQL )
INSERT INTO #dropcode
EXEC (@SQL)
 
DECLARE @ID int, @statement varchar(1000)
DECLARE statement_cursor CURSOR
FOR SELECT SQLStatement
      FROM #dropcode
  ORDER BY ID ASC
    
 OPEN statement_cursor
 FETCH statement_cursor INTO @statement
 WHILE (@@FETCH_STATUS = 0)
 BEGIN
 
 IF @WorkTest = 't' PRINT (@statement)
 ELSE
  BEGIN
    PRINT (@statement)
    EXEC(@statement)
  END
  
 FETCH statement_cursor INTO @statement    
END
 
CLOSE statement_cursor
DEALLOCATE statement_cursor

DROP SCHEMA "Admin"
DROP SCHEMA Dependencies 
DROP SCHEMA Fsp
DROP SCHEMA Hardware 
DROP SCHEMA History 
DROP SCHEMA History_RelatedItems 
DROP SCHEMA Import
DROP SCHEMA InputAtoms
DROP SCHEMA Matrix
DROP SCHEMA "References" 
DROP SCHEMA Report
DROP SCHEMA SoftwareSolution
DROP SCHEMA Spooler
 
ALTER DATABASE SCD_2 SET RECOVERY FULL
GO 