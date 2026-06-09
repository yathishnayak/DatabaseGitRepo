CREATE PROCEDURE [dbo].[Get_BrokerByKey]  --[Get_BrokerByKey] 4
@BrokerKey	int = 0
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT B.BrokerKey,B.BrokerID,B.BrokerName,B.AddrKey,B.MarketLocationKey,
	[Address] = (
		select AddrKey, AddrName, Address1, Address2, City, State, ZipCode AS Zip, Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey
		from Address A
		where A.AddrKey = B.AddrKey
		For  JSON PATH, without_array_wrapper
	)
	FROM [Broker] B
	WHERE B.BrokerKey = @BrokerKey
	For JSON PATH, WITHOUT_ARRAY_WRAPPER
END