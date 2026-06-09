/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"Country": "USA"}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [VerifyCountryExists] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[VerifyCountryExists]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"Country": ""}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @Country NVARCHAR(50) = '';
    
    -- Parse JSON input
    SELECT	@Country	= ISNULL(Country, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        Country NVARCHAR(50) '$.Country'
    );    

    -- Validate ZipCode parameter
    IF (LTRIM(RTRIM(@Country)) = '' OR @Country IS NULL)
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Country cannot be null or empty';
        RETURN;
    END
        
    -- Check if ZipCode exists in LocationData
    IF EXISTS(SELECT 1 FROM LocationData WITH(NOLOCK) WHERE Country = @Country)
    BEGIN
        SET @Status = 1;
        SET @Reason = 'Found';
    END
    ELSE
    BEGIN
        SET @Status = 1;
        SET @Reason = 'Not Found';
    END       
    
END