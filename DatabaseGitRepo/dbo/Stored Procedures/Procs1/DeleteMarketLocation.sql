/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"MarketLocationKey": 55}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [DeleteMarketLocation] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/
CREATE PROCEDURE [dbo].[DeleteMarketLocation]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF(@JSONString='' OR @JSONString IS NULL)
	BEGIN
		SET @Reason='Parameter not Present';
		SET @Status=0
		RETURN;
	END

	SET @Status=0;
	SET @Reason='Failure';

	DECLARE
		@MarketLocationKey		SMALLINT	= 0

	SELECT
			@MarketLocationKey = MarketLocationKey
		FROM OPENJSON(@JsonString, '$')
		WITH(
				MarketLocationKey	SMALLINT	'$.MarketLocationKey'
			)

	BEGIN TRY
		-- Validate UserKey exists
		IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE UserKey = @UserKey)
		BEGIN
			SET @Reason='Invalid UserKey - User does not exist';
			SET @Status=0;
			RETURN;
		END

		DECLARE @CNT INT=0
		SET @CNT=(SELECT COUNT(MarketLocationKey) FROM dbo.MarketLocation WHERE MarketLocationKey=@MarketLocationKey)

		IF(@CNT=0)
		BEGIN
			SET @Reason='No record found for the given MarketLocationKey';
			SET @Status=0;
			RETURN;
		END
		ELSE
		BEGIN
			BEGIN TRAN;

			UPDATE	dbo.MarketLocation 
			SET		IsDeleted = 1, 
					IsActive = 0, 
					UpdateDate = GETDATE(), 
					UpdateUserKey = @UserKey 
			WHERE	MarketLocationKey=@MarketLocationKey			

			COMMIT;
			SET @Reason='MarketLocation Deleted Successfully';
			SET @Status=1;
			RETURN;
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		SET @Status=0;
		SET @Reason=ERROR_MESSAGE();
	END CATCH
END