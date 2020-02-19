IF OBJECT_ID('[Hardware].[CalcServiceSupportCost]') IS NOT NULL
    DROP FUNCTION [Hardware].[CalcServiceSupportCost]
GO
CREATE FUNCTION [Hardware].[CalcServiceSupportCost]
(
	@serviceSupportCost FLOAT,
	@sar FLOAT,
	@durationYear INT = 0,
	@standardWarrantyYear INT = 0,
	@isProlongation BIT = 0
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @result FLOAT

	IF @sar IS NULL OR @isProlongation = 1
		SET @result = @serviceSupportCost * @durationYear
	ELSE
		SET @result = @durationYear * @serviceSupportCost * @sar / 100

    RETURN @result
END