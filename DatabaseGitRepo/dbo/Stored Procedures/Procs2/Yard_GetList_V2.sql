/*

DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXEC [Yard_GetList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
SELECT @Status AS Status, @Reason AS Reason

*/
CREATE PROCEDURE [dbo].[Yard_GetList_V2]
(
	@UserKey    INT = 0,
	@JSONString NVARCHAR(MAX) = '',
	@Status     BIT = 0 OUTPUT,
	@Reason     VARCHAR(1000) = '' OUTPUT

)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;

	SELECT YardId,ShortName,[Name],Y.MarketLocationKey,Y.IsActive,Y.IsDeleted,MarketLocation, YardType,
	[Address] = JSON_QUERY((SELECT '' as AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey
						FROM Address A WITH (NOLOCK) WHERE (Y.AddrKey = A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
	FROM Yard Y WITH (NOLOCK)
	LEFT JOIN MarketLocation ML WITH(NOLOCK) ON ML.MarketLocationKey = Y.MarketLocationKey
	WHERE ISNULL(Y.IsActive,0) = 1 AND ISNULL(Y.IsDeleted,0) = 0
	ORDER BY MarketLocation, [Name] ASC
	
	FOR JSON PATH;

	SET @Status = 1;
	SET @Reason = 'Success';

	--SELECT				YardId,ShortName,[Name],Y.MarketLocationKey,Y.IsActive,Y.IsDeleted,MarketLocation
	--					[Address] = (SELECT '' as AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey
	--					FROM Address A WITH (NOLOCK) WHERE (Y.AddrKey=A.AddrKey)
	--					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	--FROM				Yard Y WITH (NOLOCK)
	--LEFT JOIN MarketLocation ML WITH(NOLOCK) ON ML.MarketLocationKey=Y.MarketLocationKey
	--WHERE 
	--(@MarketLocationKey=0 OR CASE WHEN @MarketLocationKey=0 THEN 0 ELSE ISNULL(Y.MarketLocationKey,0) END = @MarketLocationKey)
	--AND 
	--ISNULL(Y.IsActive,0)=1 AND ISNULL(Y.IsDeleted,0)=0
	--ORDER BY			MarketLocation, [Name] ASC		

END
