/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@JSONOutput NVARCHAR(MAX) = '',
	@JSONSTRING		NVARCHAR(Max) = '{"CsrKey" : 48, "OrderKey" : 36677}'
	EXEC [OrderHeader_Update_CSR] @Userkey, @JSONSTRING, @JSONOutput, @Status OUTPUT, @Reason Output
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[OrderHeader_Update_CSR]
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
	DECLARE @CSRKey	INT= 1, @OrderKey INT=0, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='', @OrderNo NVARCHAR(20)=''

	SELECT @CSRKey = CSRKey, @OrderKey = OrderKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			CSRKey		INT     '$.CsrKey',
			OrderKey	INT		'$.OrderKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @OrderNo = ISNULL(OrderNo,'') FROM OrderHeader WHERE OrderKey = @OrderKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderHeader 
	SET CsrKey= @CSRKey, LastUpdateDate = GETDATE(), LastUpdateUserKey = @UserKey  
	WHERE OrderKey= @OrderKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Order', @OrderNo, @OrderKey, 'CSR', 'Text' , 'CSR Updated'

	SET @Status=1;
	SET @Reason='Success';
END
