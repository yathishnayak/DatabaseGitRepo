CREATE PROCEDURE [dbo].[OrderHeader_Update_BrokerRef]
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
	DECLARE @BrokerRefNo	nvarchar(30)= '', @OrderKey INT=0, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='', @OrderNo NVARCHAR(20)=''

	SELECT @BrokerRefNo = BrokerRefNo, @OrderKey = OrderKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			BrokerRefNo		NVARCHAR(30)     '$.BrokerRefNo',
			OrderKey		INT				 '$.OrderKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @OrderNo = ISNULL(OrderNo,'') FROM OrderHeader WHERE OrderKey = @OrderKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderHeader 
	SET BrokerRefNo= @BrokerRefNo, LastUpdateDate = GETDATE(), LastUpdateUserKey = @UserKey  
	WHERE OrderKey= @OrderKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Order', @OrderNo, @OrderKey, 'CSR', 'Text' , 'Beroker Ref No Updated'

	SET @Status=1;
	SET @Reason='Success';
END
