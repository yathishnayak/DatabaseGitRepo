




CREATE PROCEDURE [dbo].[GetActiveShippingPortTerminalList]  --GetActiveShippingPortTerminalList 

AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT				TerminalKey,TerminaID,PortKey,StatusKey,IsActive,IsDeleted,
						[Address] = (SELECT AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey
						FROM Address A WHERE (S.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM				ShippingPortTerminals  S
	WHERE				ISNULL(IsActive,0) = 1 and ISNULL(IsDeleted,0) = 0
	ORDER BY			TerminaID
						FOR JSON PATH

END



