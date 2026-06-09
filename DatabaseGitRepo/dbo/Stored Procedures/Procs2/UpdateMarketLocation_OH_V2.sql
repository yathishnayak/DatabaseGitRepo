/*
Declare
@UserKey INT = 0,
@JSONString NVARCHAR(MAX)='{"OrderKey":"151337", "MarketLocationKey":2}',
@Status BIT = 0,
@Reason NVARCHAR(100)=''
EXEC UpdateMarketLocation_OH_V2 @UserKey, @JSONString, @Status OUTPUT, @Reason Output
Select @Status AS Status, @Reason AS Reason
*/

CREATE Procedure [dbo].[UpdateMarketLocation_OH_V2] 
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
			@MarketLocationKey		INT,
			@USerName VARCHAR(100),
			@Comment VARCHAR(500)='', 
			@OrderNo NVARCHAR(20)=''

	SELECT @OrderKey = OrderKey, @MarketLocationKey = MarketLocationKey
	FROM OPENJSON(@JSONString, '$')
	WITH(
		OrderKey	INT		'$.OrderKey',
		MarketLocationKey		INT		'$.MarketLocationKey'
	)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
	SELECT @OrderNo = ISNULL(OrderNo,'') FROM OrderHeader WITH(NOLOCK) WHERE OrderKey = @OrderKey

	print '@MarketLocationKey='
	print @MarketLocationKey
	BEGIN TRY
		BEGIN TRANSACTION
		print '@MarketLocationKey='
		print @MarketLocationKey
			UPDATE OrderHeader
			SET MarketLocationKey = @MarketLocationKey
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
