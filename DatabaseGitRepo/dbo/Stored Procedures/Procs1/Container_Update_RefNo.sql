CREATE PROCEDURE [dbo].[Container_Update_RefNo]
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
	DECLARE @RefNo	NVARCHAR(100)='', @OrderDetailKey INT=0, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='', @ContainerNo NVARCHAR(20)=''

	SELECT @RefNo = RefNo, @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			RefNo			NVARCHAR(100)     '$.RefNo',
			OrderDetailKey	INT				  '$.OrderDetailKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
	SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey = @OrderDetailKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderDetail 
	SET CustRefNo= @RefNo, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'CustRef No', 'Text' , 'CustRef No Updated'

	SET @Status=1;
	SET @Reason='Success';
END
