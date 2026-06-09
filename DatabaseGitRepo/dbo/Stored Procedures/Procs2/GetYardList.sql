CREATE PROCEDURE [dbo].[GetYardList]  --GetYardList
@MarketLocationKey	INT=0
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT				YardId,ShortName,[Name],Y.MarketLocationKey,Y.IsActive,Y.IsDeleted,MarketLocation,
						[Address] = (SELECT '' as AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey
						FROM Address A WHERE (Y.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM				Yard Y
	LEFT JOIN MarketLocation ML WITH(NOLOCK) ON ML.MarketLocationKey=Y.MarketLocationKey
	WHERE (@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(Y.MarketLocationKey,0) END = @marketLocationKey)		AND ISNULL(Y.IsActive,0)=1 AND ISNULL(Y.IsDeleted,0)=0
	ORDER BY			MarketLocation, [Name] ASC
						FOR JSON PATH

END
