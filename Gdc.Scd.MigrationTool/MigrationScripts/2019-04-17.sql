ALTER TABLE [Fsp].[HwFspCodeTranslation]
ADD IsGlobalSP bit null
GO;

UPDATE [InputAtoms].[CountryGroup]
SET [LUTCode] = 'FUJ;GSP'
WHERE [LUTCode] = 'FUJ'

UPDATE [InputAtoms].[CountryGroup]
SET [LUTCode] = 'FUJ;GSP;CAM'
WHERE [Name] = 'Mexico'