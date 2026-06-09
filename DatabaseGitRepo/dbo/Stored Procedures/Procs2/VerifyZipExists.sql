/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"Type": "Z", "State":"PA", "ZipCode":"15612"}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [VerifyZipExists] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[VerifyZipExists]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"ZipCode": ""}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @ZipCode NVARCHAR(50) = '';
    
    -- Parse JSON input
    SELECT	@ZipCode	= ISNULL(ZipCode, '')
    FROM OPENJSON(@JSONString)
    WITH (
        ZipCode NVARCHAR(50) '$.ZipCode'
    );    

    -- Validate ZipCode parameter
    IF (LTRIM(RTRIM(@ZipCode)) = '' OR @ZipCode IS NULL)
    BEGIN
        SET @Status = 0;
        SET @Reason = 'ZipCode cannot be null or empty';
        RETURN;
    END
        
    -- Check if ZipCode exists in LocationData
    IF EXISTS(SELECT 1 FROM LocationData WITH(NOLOCK) WHERE ZipCode = @ZipCode)
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