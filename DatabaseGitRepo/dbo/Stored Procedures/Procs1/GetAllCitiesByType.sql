/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"Type": "Z", "State":"PA", "ZipCode":"15612"}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [GetAllCitiesByType] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[GetAllCitiesByType]
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
    
    DECLARE @Type CHAR = '',
			@State NVARCHAR(50) = '',
			@ZipCode NVARCHAR(50) = '';
    
    -- Parse JSON input
    SELECT	@Type		= ISNULL([Type],''),
			@State		= ISNULL([State], ''),
			@ZipCode	= ISNULL(ZipCode, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        [Type] CHAR '$.Type',
		[State] NVARCHAR(50) '$.State',
		ZipCode NVARCHAR(50) '$.ZipCode'
    );
    
    SET @Status = 1;
    SET @Reason = 'Success';

    IF (@Type = 'A')
    BEGIN
        SELECT CityKey, Country, [State], City, ZipCode, StatusKey, CreateDate
        FROM LocationData WITH (NOLOCK)
        ORDER BY City
        FOR JSON PATH;
    END
    ELSE IF (@Type = 'T')
    BEGIN
        SELECT TOP 50 CityKey, Country, [State], City, ZipCode, StatusKey, CreateDate
        FROM LocationData WITH (NOLOCK)
        ORDER BY City
        FOR JSON PATH;
    END
    ELSE IF (@Type = 'S')
    BEGIN
        SELECT CityKey, Country, [State], City, ZipCode, StatusKey, CreateDate
        FROM LocationData WITH (NOLOCK)
        WHERE [State] = @State
        ORDER BY City
        FOR JSON PATH;
    END
    ELSE IF (@Type = 'Z')
    BEGIN
        SELECT CityKey, Country, [State], City, ZipCode, StatusKey, CreateDate
        FROM LocationData WITH (NOLOCK)
        WHERE ZipCode = @ZipCode
        ORDER BY City
        FOR JSON PATH;
    END
    ELSE
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Select proper type';
    END	
END