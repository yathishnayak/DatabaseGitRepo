/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"YardId": 10}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [GetYardByKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[GetYardByKey_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"YardId": 10}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @YardId INT = 0;
    
    -- Parse JSON input
    SELECT @YardId = ISNULL(YardId, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        YardId INT '$.YardId'
    );

	SELECT				
		YardId,ShortName,[Name],MarketLocationKey,IsActive,IsDeleted,y.AddrKey,
		JSON_QUERY ((
			SELECT AddrName,
					Address1,
					Address2,
					City,
					CityKey,
					[State],
					ZipCode AS Zip,
					Country, 
					AddrKey, 
					Phone,
					Phone2,
					Email,Email2,Fax,Website
		FROM Address A WITH (NOLOCK) WHERE (Y.AddrKey=A.AddrKey)
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
		AS [Address]
	FROM	Yard Y
	WHERE (YardId=@YardId)
	ORDER BY	[Name]
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Status = 1;
    SET @Reason = 'Success';

END