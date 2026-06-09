
CREATE proc [dbo].[Get_BaseRateForCals]  -- Get_BaseRateForCals 0, 15, '14410','2021-07-08'
(
	@ClientOrBrokerKey  INT = 0,
	@CustomerKey		INT = 0,
	--@CityKey			INT,
	@ZipCode			VARCHAR(10)='',
	@EffectiveDate		DATE = '2020-12-01'
)
AS
BEGIN

	DECLARE @BaseRateItemKey INT
	DECLARE @BaseRateKey	 INT

	SET @BaseRateItemKey = ( SELECT ItemKey FROM Item WHERE ItemID ='BR' )


	IF(@EffectiveDate = '2020-12-01')
	BEGIN
		SET @EffectiveDate = CONVERT(DATE,GETDATE())
	END

	SET @BaseRateKey= (
					SELECT TOP 1 BaseRateKey
					FROM CustomerItemRate A
					 LEFT JOIN dbo.LocationData LD on LD.CityKey = A.CityKey
					WHERE CustomerKey=@CustomerKey AND LD.ZipCode= LTRIM(RTRIM(@ZipCode)) AND EffectiveDate<= @EffectiveDate AND Itemkey= @BaseRateItemKey
					ORDER BY BaseRateKey DESC
					)	

	SELECT  br.BaserateKey, br.CustomerKey,cus.CustName, LD.City, LD.ZipCode, br.UnitPrice, br.CreateDate,br.EffectiveDate,br.EmailContact
	FROM dbo.CustomerItemRate BR 
		LEFT JOIN dbo.Customer CUS	ON br.CustomerKey = cus.CustKey	
		LEFT JOIN dbo.[Address] A ON CUS.AddrKey = A.AddrKey
		LEFT JOIN dbo.LocationData LD on LD.CityKey = A.CityKey
	WHERE	BR.BaseRateKey= @BaseRateKey
			--  br.CustomerKey = @CustomerKey AND
			--( BR.ClientOrBrokerKey = @ClientOrBrokerKey OR @ClientOrBrokerKey=0 OR @ClientOrBrokerKey IS NULL ) AND
			--  LD.ZipCode = @ZipCode AND BR.Itemkey=@BaseRateItemKey
			--AND CONVERT(DATE,BR.EffectiveDate) <= @EffectiveDate
	ORDER BY convert(datetime, BR.effectivedate) desc
END
