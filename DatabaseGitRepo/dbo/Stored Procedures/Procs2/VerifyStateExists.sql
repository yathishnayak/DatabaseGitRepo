/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"State": "CA"}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [VerifyStateExists] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[VerifyStateExists]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"State": ""}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @State NVARCHAR(50) = '';
    
    -- Parse JSON input
    SELECT	@State	= ISNULL([State], 0)
    FROM OPENJSON(@JSONString)
    WITH (
        [State] NVARCHAR(50) '$.State'
    );    

    -- Validate ZipCode parameter
    IF (LTRIM(RTRIM(@State)) = '' OR @State IS NULL)
    BEGIN
        SET @Status = 0;
        SET @Reason = 'State cannot be null or empty';
        RETURN;
    END
        
    -- Check if ZipCode exists in LocationData
    IF EXISTS(SELECT 1 FROM LocationData WITH(NOLOCK) WHERE [State] = @State)
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