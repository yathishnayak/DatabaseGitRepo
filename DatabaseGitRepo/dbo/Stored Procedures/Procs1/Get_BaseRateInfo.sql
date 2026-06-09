

CREATE PROCEDURE [dbo].[Get_BaseRateInfo]  -- Execute [Get_BaseRateInfo] 15,0,'14410'
/*
Get Base rate to show in the order entry screen
*/
@CustomerKey INT,
@BrokerKey	 INT,
@ZipCode	 VARCHAR(10)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @CityKey INT
	DECLARE @City VARCHAR
	DECLARE @BaseRateItemKey INT
	DECLARE @BaseRateKey	 INT

	SET @BaseRateItemKey = ( SELECT ItemKey FROM Item WHERE ItemID ='BR' )

	--SELECT @CityKey =
	--				 ISNULL(A.CityKey,0) , @City = A.City
	--				FROM dbo.LocationData A 
	--					INNER JOIN dbo.[Status] S ON S.StatusKey=A.StatusKey
	--				WHERE A.ZipCode= LTRIM(RTRIM(@ZipCode)) AND S.StatusName='Active'	
	
	SET @BaseRateKey= (
				SELECT TOP 1 BaseRateKey
				FROM CustomerItemRate A
					LEFT JOIN dbo.LocationData LD on LD.CityKey = A.CityKey
				WHERE CustomerKey=@CustomerKey AND LD.ZipCode= LTRIM(RTRIM(@ZipCode)) AND EffectiveDate<= GETDATE() AND Itemkey= @BaseRateItemKey
				ORDER BY BaseRateKey DESC
				)	
	
	--SELECT ISNULL(UnitPrice,0) as 'UnitPrice',BaseRateKey,LD.City,LD.CityKey,EffectiveDate
	--FROM dbo.CustomerItemRate A
	--	LEFT JOIN dbo.LocationData LD on LD.CityKey = A.CityKey
	--WHERE CustomerKey= @CustomerKey AND ( ClientOrBrokerKey= @BrokerKey OR @BrokerKey=0 OR @BrokerKey IS NULL)		
	--		AND A.ItemKey=@BaseRateItemKey

	SELECT   ISNULL(UnitPrice,0) as 'UnitPrice',br.BaserateKey, LD.City,BR.CityKey,BR.EffectiveDate
	FROM dbo.CustomerItemRate BR 
		LEFT JOIN dbo.Customer CUS	ON br.CustomerKey = cus.CustKey	
		LEFT JOIN dbo.[Address] A ON CUS.AddrKey = A.AddrKey
		LEFT JOIN dbo.LocationData LD on LD.CityKey = A.CityKey
	WHERE	BR.BaseRateKey= @BaseRateKey
			--  br.CustomerKey = @CustomerKey AND
			--( BR.ClientOrBrokerKey = @ClientOrBrokerKey OR @ClientOrBrokerKey=0 OR @ClientOrBrokerKey IS NULL ) AND
			--  LD.ZipCode = @ZipCode AND BR.Itemkey=@BaseRateItemKey
			--AND CONVERT(DATE,BR.EffectiveDate) <= @EffectiveDate
	--ORDER BY convert(datetime, BR.effectivedate) desc
END

