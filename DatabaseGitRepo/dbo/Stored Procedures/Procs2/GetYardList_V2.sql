/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [GetYardList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[GetYardList_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"MarketLocationKey": 0}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @MarketLocationKey INT = 0;
    
    -- Parse JSON input
    SELECT @MarketLocationKey = ISNULL(MarketLocationKey, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        MarketLocationKey INT '$.MarketLocationKey'
    );

	SELECT 			
		YardId,ShortName,[Name],Y.YardType,Y.MarketLocationKey,Y.IsActive,Y.IsDeleted,MarketLocation,
		JSON_QUERY ((
			SELECT '' as AddrName,
					ISNULL(Address1, '') AS Address1,
					ISNULL(Address2, '') AS Address2,
					City,
					CityKey,
					[State],
					ZipCode AS Zip,
					Country, 
					AddrKey
					FROM Address A WITH (NOLOCK) WHERE (Y.AddrKey=A.AddrKey)
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
		AS [Address]
	FROM Yard Y WITH (NOLOCK)
	LEFT JOIN MarketLocation ML WITH(NOLOCK) ON ML.MarketLocationKey=Y.MarketLocationKey
	WHERE (@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(Y.MarketLocationKey,0) END = @marketLocationKey)		
			AND ISNULL(Y.IsActive,0)=1 AND ISNULL(Y.IsDeleted,0)=0
	ORDER BY
		MarketLocation, [Name] ASC
		FOR JSON PATH

	SET @Status = 1;
    SET @Reason = 'Success';
END