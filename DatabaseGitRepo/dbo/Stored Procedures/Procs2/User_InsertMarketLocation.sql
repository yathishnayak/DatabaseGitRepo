CREATE PROCEDURE [dbo].[User_InsertMarketLocation]
(
	@UserKey			INT,
	@MarketLocationKey	INT,
	@Status				BIT=0 OUTPUT,
	@Reason				VARCHAR(200)='' OUTPUT
)
AS

BEGIN
	BEGIN TRY
		UPDATE [User] SET MarketLocationKey=@MarketLocationKey Where UserKey=@UserKey
		SET @Status=1
		SET @Reason='Location Updated Successfully'
	END TRY
	BEGIN CATCH
		SET @Status=0
		SET @Reason='Error Occured'
	END CATCH
END
