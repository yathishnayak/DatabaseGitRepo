/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderTypeKey" : 3, "OrderDetailKey" : 47700}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@Status	BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Container_Update_OrderType] @UserKey,@JSONString,@JSONOutput OUTPUT, @Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Container_Update_OrderType]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @OrderTypeKey	INT= 1, @OrderDetailKey INT=0, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='', @ContainerNo NVARCHAR(20)=''

	SELECT @OrderTypeKey = OrderTypeKey, @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderTypeKey		INT     '$.OrderTypeKey',
			OrderDetailKey		INT		'$.OrderDetailKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
	SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey = @OrderDetailKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderDetail 
	SET OrderTypeKey= @OrderTypeKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'OrderType', 'Text' , 'Order Type Updated'

	SET @Status=1;
	SET @Reason='Success';
END
