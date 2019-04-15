USE [Scd_2]
GO

IF OBJECT_ID('dbo.EnableAndRunTriggerOnTable') IS NOT NULL
	DROP PROCEDURE [dbo].[EnableAndRunTriggerOnTable]
GO

CREATE PROCEDURE [dbo].[EnableAndRunTriggerOnTable] 
	@tableName nvarchar(500)
AS
BEGIN
	SET NOCOUNT ON;

	--RUN ENABLE TRIGGER
	DECLARE @cmd AS nvarchar(MAX)
	SET @cmd = N'ENABLE TRIGGER ALL ON ' + @tableName
	EXEC sp_executesql @cmd

	--CALCULATE PRIMARY KEY COLUMN
	DECLARE @primaryKey AS nvarchar(max)
	SELECT @primaryKey = column_name
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC
	INNER JOIN
		INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU
			  ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' AND
				 TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME AND
				 '['+KU.TABLE_SCHEMA+'].['+KU.TABLE_NAME + ']'=@tableName
	ORDER BY KU.TABLE_NAME, KU.ORDINAL_POSITION;

	--CALCULATE COLUMN TO UPDATE
	DECLARE @columnToUpdate AS nvarchar(max)
	SELECT TOP(1) @columnToUpdate=[name] 
	FROM syscolumns 
	WHERE id=OBJECT_ID(@tableName) AND [name] != @primaryKey
	
	--UPDATE COLUMN TO RUN TRIGGER
	SET @cmd = N'UPDATE ' + @tableName + 
	             ' SET '+ @columnToUpdate + ' = ' + @columnToUpdate + 
				 ' WHERE ' + @primaryKey + ' = (SELECT TOP(1) ' + @primaryKey + ' FROM ' + @tableName+')';
	EXEC sp_executesql @cmd
END

GO

IF OBJECT_ID('dbo.DisableTriggerOnTable') IS NOT NULL
	DROP PROCEDURE [dbo].[DisableTriggerOnTable]
GO

CREATE PROCEDURE [dbo].[DisableTriggerOnTable] 
	@tableName nvarchar(500) 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @cmd AS nvarchar(MAX)
	SET @cmd = N'DISABLE TRIGGER ALL ON ' + @tableName
	
	EXEC sp_executesql @cmd
END

GO

