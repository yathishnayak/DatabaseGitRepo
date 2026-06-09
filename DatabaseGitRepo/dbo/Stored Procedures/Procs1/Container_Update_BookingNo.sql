CREATE PROCEDURE [dbo].[Container_Update_BookingNo]
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
	DECLARE @BookingNo	NVARCHAR(100)='', @OrderDetailKey INT=0, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='', @ContainerNo NVARCHAR(20)=''

	SELECT @BookingNo = BookingNo, @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			BookingNo			NVARCHAR(100)     '$.BookingNo',
			OrderDetailKey		INT				  '$.OrderDetailKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WHERE OrderDetailKey = OrderDetailKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderDetail 
	SET BookingNo= @BookingNo, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'Booking No', 'Text' , 'Booing No Updated'

	SET @Status=1;
	SET @Reason='Success';
END
