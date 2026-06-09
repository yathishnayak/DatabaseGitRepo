CREATE PROCEDURE [dbo].[Orderheader_Consignee_Update]
(
	@UserKey      INT=488,
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
	DECLARE @ConsigneeKey	INT=0, @OrderKey INT=0, @USerName VARCHAR(100), @OrderNo NVARCHAR(20)=''	

	SELECT @ConsigneeKey = ConsigneeKey, @OrderKey = OrderKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			ConsigneeKey		INT				  '$.ConsigneeKey',
			OrderKey		    INT				  '$.OrderKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @OrderNo = ISNULL(OrderNo,'') FROM OrderHeader WHERE OrderKey = @OrderKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderHeader
	SET ConsigneeKey= @ConsigneeKey, LastUpdateDate = GETDATE(), LastUpdateUserKey = @UserKey  
	WHERE OrderKey= @OrderKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Order', @OrderNo, @OrderKey, 'Consignee', 'Text' , 'Consignee Updated'

	SET @Status=1;
	SET @Reason='Success';
END
