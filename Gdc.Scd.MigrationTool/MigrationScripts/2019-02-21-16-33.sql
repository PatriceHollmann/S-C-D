  declare @reportId bigint = (select Id from Report.Report where upper(Name) = 'SW-CALC-RESULT');
  UPDATE [Scd_2].[Report].[ReportColumn] SET [Text] = 'Transfer price' WHERE [Name] = 'TransferPrice' AND ReportId = @reportId