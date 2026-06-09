/**

DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"MarketLocationKey":1}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_MarketLocation_ByKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason

**/
CREATE PROCEDURE [dbo].[Get_MarketLocation_ByKey_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @MarketLocationKey INT = 0;
    
    -- Parse JSON input
    SELECT @MarketLocationKey = ISNULL(MarketLocationKey, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        MarketLocationKey INT '$.MarketLocationKey'
    );

	SELECT		
        MarketLocationKey,
        MarketLocation,
        ML.AddrKey,
        IsActive,
        IsDeleted,
				
	    JSON_QUERY(
            (
                SELECT 
                    A.AddrKey,
                    A.AddrName,
                    ISNULL(A.Address1,'') AS Address1,
                    ISNULL(A.Address2,'') AS Address2,
                    ISNULL(A.City,'') AS City,
                    A.CityKey,
                    ISNULL(A.ZipCode,'') AS Zip,
                    ISNULL(A.State,'') AS State,
                    ISNULL(A.Country,'') AS Country,
                    ISNULL(A.Email,'') AS Email,
                    ISNULL(A.Email2,'') AS Email2,
                    ISNULL(A.Phone,'') AS Phone,
                    ISNULL(A.Phone2,'') AS Phone2,
                    ISNULL(A.Fax,'') AS Fax
                FROM Address A WITH (NOLOCK)
                WHERE A.AddrKey = ML.AddrKey
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            )
        ) AS [Address]

	FROM		MarketLocation ML WITH (NOLOCK)
	WHERE		MarketLocationKey = @MarketLocationKey 
	ORDER BY	MarketLocation
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Status = 1;
	SET @Reason = 'Success';
END