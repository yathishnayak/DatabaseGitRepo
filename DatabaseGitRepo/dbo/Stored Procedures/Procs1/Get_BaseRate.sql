
CREATE PROCEDURE [dbo].[Get_BaseRate]  -- Execute Get_BaseRate 318,4,'92154'
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

	SET @CityKey=(	
					SELECT ISNULL(A.CityKey,0) 
					FROM dbo.LocationData A 
						INNER JOIN dbo.[Status] S ON S.StatusKey=A.StatusKey
					WHERE A.ZipCode=LTRIM(RTRIM(@ZipCode)) AND S.StatusName='Active'
				 )
	
	SELECT ISNULL(UnitPrice,0) as 'UnitPrice',BaseRateKey 
	FROM dbo.CustomerItemRate  
	WHERE CityKey=@CityKey AND CustomerKey= @CustomerKey AND ( ClientOrBrokerKey= @BrokerKey OR @BrokerKey=0 OR @BrokerKey IS NULL)
				
END

