CREATE Procedure [dbo].[GetPortByKey]  --GetPortByKey   0

	@ShippingPortKey	INT

AS

BEGIN
	--SELECT ShippingPortKey,ShippingPortID,AddrKey,StatusKey,CompanyKey
	--FROM ShippingPort
	--WHERE (ShippingPortKey = @ShippingPortKey)


	SELECT				PriceGroupingKey,ShippingPortKey,ShippingPortID,MarketLocationKey,IsActive,IsDeleted,StatusKey,S.AddrKey,
						[Address] = (SELECT AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey, Phone,Phone2,
									 Email,Email2,Fax,Website
						FROM Address A WHERE (S.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM				ShippingPort S
	WHERE				ShippingPortKey = @ShippingPortKey
	ORDER BY			ShippingPortID
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
