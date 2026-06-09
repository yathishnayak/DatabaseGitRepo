/*
Declare
@UserKey INT = 0,
@JSONString NVARCHAR(MAX)='{"OrderDetailKey":"144920", "MLKey":2}',
@Status BIT = 0,
@Reason NVARCHAR(100)=''
EXEC UpdateMarketLocation_OD @UserKey, @JSONString, @Status OUTPUT, @Reason Output
Select @Status, @Reason
*/

CREATE Procedure [dbo].[UpdateMarketLocation_OD] 
(
	@UserKey INT =0,
	@JSONString NVARCHAR(MAX) = '' OUTPUT,
	@Status BIT=0 OUTPUT,
	@Reason NVARCHAR(100) = '' OUTPUT	
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @OrderDetailKey	INT = 0,
			@MLKey		INT

	SELECT @OrderDetailKey = OrderKey, @MLKey = MLKey
	FROM OPENJSON(@JSONString, '$')
	WITH(
		OrderKey	INT		'$.OrderKey',
		MLKey		INT		'$.MLKey'
	)
	print '@MLKey='
	print @MLKey
	BEGIN TRY
		BEGIN TRANSACTION
		print '@MLKey='
		print @MLKey
			
			/*
			UPDATE OrderDetail
			SET MarketLocationKey = @MLKey
			WHERE OrderDetailKey = @OrderDetailKey AND STATUS IN (1)
			*/

			IF @@ROWCOUNT != 0
			BEGIN
				SET @Status=1;
				SET @Reason='Success';
			END
			ELSE
			BEGIN
				SET @Status=0;
				SET @Reason='Cannot Update';				
			END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SET @Status=0;
		SET @Reason='Failed';
	END CATCH

END
