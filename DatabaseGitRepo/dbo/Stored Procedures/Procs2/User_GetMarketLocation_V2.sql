/*
DECLARE 
	@UserKey INT = 1144, 
	@JSONString NVARCHAR(MAX) = '',
	@Status BIT = 0,
	@Reason VARCHAR(1000), 
	@IsDebug BIT = 1
EXEC [User_GetMarketLocation_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason
*/
 
CREATE PROCEDURE [dbo].[User_GetMarketLocation_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	DECLARE @JSONOutput NVARCHAR(MAX) = ''

	SET @JSONOutput = (
		SELECT UserKey, ISNULL(MarketLocationKey,0) MarketLocationKey 
		FROM [User] WITH(NOLOCK) 
		WHERE UserKey=@UserKey
            
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	);
 
	SELECT @JSONOutput AS JSONOutput

	SET @Status = 1;
	SET @Reason = 'Success';

END