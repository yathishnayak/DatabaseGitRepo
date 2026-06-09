





CREATE PROCEDURE [dbo].[GetShippingPortTerminalListByKey]  --GetShippingPortTerminalListByKey 148
(
	@TerminalKey INT
)
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT				TerminalKey,TerminaID,PortKey,StatusKey,IsActive,IsDeleted,
						[Address] = (SELECT AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey, Email,Email2,Phone,Phone2,Fax,Website
						FROM Address A WHERE (S.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM				ShippingPortTerminals  S
	WHERE				TerminalKey = @TerminalKey
	ORDER BY			TerminaID
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

END



