CREATE Procedure [dbo].[Get_BrokerDetail]
@BrokerName VARCHAR(50)=''
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT B.BrokerKey,B.BrokerID,B.BrokerName,B.AddrKey,
	AddressStr = (
		select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2, Email2, CityKey
		from Address A
		where A.AddrKey = B.AddrKey
		For  JSON PATH, without_array_wrapper
	)
	FROM [Broker] B
	WHERE B.BrokerName LIKE '%'+@BrokerName+'%' 
	For JSON PATH
END
