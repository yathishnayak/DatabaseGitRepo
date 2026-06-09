/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CityKey": 0}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [GetCityByKey] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[GetCityByKey]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"StatusKey": 0}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @CityKey INT = 0;
    
    -- Parse JSON input
    SELECT	@CityKey	= ISNULL(CityKey,0)
    FROM OPENJSON(@JSONString)
    WITH (
        CityKey INT '$.CityKey'
    );
    
    SET @Status = 1;
    SET @Reason = 'Success';
    
        SELECT CityKey, Country, [State], City, ZipCode, StatusKey, CreateDate
        FROM LocationData  WITH (NOLOCK)
        WHERE CityKey = @CityKey
        ORDER BY City
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    
END