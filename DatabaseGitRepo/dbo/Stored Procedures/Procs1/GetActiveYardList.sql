

CREATE PROCEDURE [dbo].[GetActiveYardList]  --GetActiveYardList
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT				YardId,ShortName,[Name],MarketLocationKey,IsActive,IsDeleted,
						[Address] = (SELECT AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey
						FROM Address A WHERE (Y.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM				Yard Y
	WHERE				ISNULL(IsActive,0) = 1 AND ISNULL(IsDeleted,0) = 0
	ORDER BY			[Name]
						FOR JSON PATH

END
