
CREATE PROCEDURE [dbo].[Get_DriverLocationEffectiveDateList]
@driverKey	INT = 0,
@CityKey		INT = 10198
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT DISTINCT  CONVERT(VARCHAR,EffectiveDate,101) AS EffectiveDate
	FROM dbo.DriverLocationItem 
	WHERE (@driverKey = 0 OR  Driverkey=@driverKey)
		AND CityKey=@CityKey 
	ORDER BY EffectiveDate DESC
END