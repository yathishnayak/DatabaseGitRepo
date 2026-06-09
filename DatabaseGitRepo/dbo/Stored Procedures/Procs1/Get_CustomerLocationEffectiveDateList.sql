CREATE PROCEDURE [dbo].[Get_CustomerLocationEffectiveDateList]
@CustomerKey	INT = 15,
@CityKey		INT = 10198
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT DISTINCT  CONVERT(VARCHAR,EffectiveDate,101) AS EffectiveDate
	FROM dbo.CustomerItemRate 
	WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey 
	ORDER BY EffectiveDate DESC
END
