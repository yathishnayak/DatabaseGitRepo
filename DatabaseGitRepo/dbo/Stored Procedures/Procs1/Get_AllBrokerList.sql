CREATE PROCEDURE [dbo].[Get_AllBrokerList]
@MarketLocationKey	INT=0
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT B.BrokerKey,B.BrokerID,B.BrokerName,B.AddrKey,B.MarketLocationKey,ML.MarketLocation,
	[Address] = (
		select AddrKey, AddrName, Address1, Address2, City, State, ZipCode AS Zip, Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey
		from Address A
		where A.AddrKey = B.AddrKey
		For  JSON PATH, without_array_wrapper
	)
	FROM [Broker] B
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON B.MarketLocationKey=ML.MarketLocationKey
	WHERE @MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(B.MarketLocationKey,0) END = @marketLocationKey
	For JSON PATH
END