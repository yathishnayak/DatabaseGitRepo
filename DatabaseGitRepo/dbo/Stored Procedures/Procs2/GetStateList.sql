/**
DECLARE 
	@UserKey INT=1144,
	@JSONString NVARCHAR(MAX)='{"Country" : "US"}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [GetStateList] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[GetStateList]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"Country": "US"}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @Country VARCHAR(50) = ''
    
    -- Parse JSON input
    SELECT	@Country		= ISNULL([Country],'')
    FROM OPENJSON(@JSONString)
    WITH (
		Country VARCHAR(50) '$.Country'
    );
    SET @Status = 1;
    SET @Reason = 'Success';

    SELECT DISTINCT [State] FROM LocationData WITH(NOLOCK)
    WHERE Country = @Country
    FOR JSON PATH
    
END