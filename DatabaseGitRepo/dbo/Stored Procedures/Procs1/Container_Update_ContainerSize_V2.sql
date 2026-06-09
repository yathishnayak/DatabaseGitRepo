CREATE PROCEDURE [dbo].[Container_Update_ContainerSize_V2]
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
	DECLARE @SizeKey	INT=0, @OrderDetailKey INT=0, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='', @ContainerNo NVARCHAR(20)=''

	SELECT @SizeKey = SizeKey, @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			SizeKey			INT     '$.ContainerSizeKey',
			OrderDetailKey	INT		'$.OrderDetailKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderDetail 
	SET ContainerSizeKey= @SizeKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'Container Size', 'Text' , 'Container Size Updated'

	SET @Status=1;
	SET @Reason='Success';
END
