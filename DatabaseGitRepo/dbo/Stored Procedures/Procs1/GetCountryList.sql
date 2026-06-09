/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [GetCountryList] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[GetCountryList]
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
    
    SET @Status = 1;
    SET @Reason = 'Success';

    SELECT DISTINCT Country FROM LocationData WITH (NOLOCK)
        FOR JSON PATH
    
END