CREATE PROCEDURE [dbo].[Container_Update_DropOrLive]
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
	DECLARE @DropLive	NVARCHAR(20)='', @OrderDetailKey INT=0, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='', @ContainerNo NVARCHAR(20)=''

	SELECT @DropLive = DropLive, @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			DropLive			NVARCHAR(20)     '$.DropLive',
			OrderDetailKey	    INT				 '$.OrderDetailKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey
	SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey = @OrderDetailKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderDetail 
	SET DropOrLive= @DropLive, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'DropOrLive', 'Text' , 'DropOrLive Updated'

	SET @Status=1;
	SET @Reason='Success';
END
