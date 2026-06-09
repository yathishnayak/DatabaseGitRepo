/*
DECLARE @UserKey INT = 1144, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"MarketLocationKey":2}'
 
EXEC [User_InsertMarketLocation_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason
*/
 
CREATE PROCEDURE [dbo].[User_InsertMarketLocation_V2]
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
	SET FMTONLY OFF
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;
 
	DECLARE @MarketLocationKey	INT;

	SELECT @MarketLocationKey =  MarketLocationKey
	FROM OpenJSON(@JSONString, '$')
	WITH (
		MarketLocationKey			INT				'$.MarketLocationKey'
	)

	BEGIN TRY
		UPDATE [User] SET MarketLocationKey=@MarketLocationKey Where UserKey=@UserKey
		SET @Status=1
		SET @Reason='Market Location Updated Successfully'
	END TRY
	BEGIN CATCH
		SET @Status=0
		SET @Reason='Error Occured'
	END CATCH

END
