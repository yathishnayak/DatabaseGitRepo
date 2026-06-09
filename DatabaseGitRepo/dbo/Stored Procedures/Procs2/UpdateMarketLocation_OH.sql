/*
Declare
@UserKey INT = 0,
@JSONString NVARCHAR(MAX)='{"OrderKey":"144920", "MLKey":2}',
@Status BIT = 0,
@Reason NVARCHAR(100)=''
EXEC UpdateMarketLocation_OH @UserKey, @JSONString, @Status OUTPUT, @Reason Output
Select @Status, @Reason
*/

CREATE Procedure [dbo].[UpdateMarketLocation_OH] 
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
	DECLARE @OrderKey	INT = 0,
			@MLKey		INT,
			@USerName VARCHAR(100),
			@Comment VARCHAR(500)='', 
			@OrderNo NVARCHAR(20)=''

	SELECT @OrderKey = OrderKey, @MLKey = MLKey
	FROM OPENJSON(@JSONString, '$')
	WITH(
		OrderKey	INT		'$.OrderKey',
		MLKey		INT		'$.MLKey'
	)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @OrderNo = ISNULL(OrderNo,'') FROM OrderHeader WHERE OrderKey = @OrderKey

	print '@MLKey='
	print @MLKey
	BEGIN TRY
		BEGIN TRANSACTION
		print '@MLKey='
		print @MLKey
			UPDATE OrderHeader
			SET MarketLocationKey = @MLKey
			WHERE OrderKey = @OrderKey AND STATUS IN (12,1)

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), @USerName, 'Order', @OrderNo, @OrderKey, 'CSR', 'Text' , 'Market Location Updated'

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
