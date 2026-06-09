/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@JSONSTRING		NVARCHAR(Max) = '{"BillOfLading":"Test11221","OrderKey":260362}'
	EXEC [Update_OrderHeader_BillOfLading_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_OrderHeader_BillOfLading_V2]
(
	@UserKey	INT	= 952,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT	= 0 OUTPUT,
	@Reason		NVARCHAR(200) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @Status = 0;
	SET @Reason = 'No Records Found';
	
	DECLARE @UserName NVARCHAR(200), @OrderNo NVARCHAR(100);

	DECLARE 
    @BillOfLading NVARCHAR(100),
    @OrderKey     INT;

	SELECT
		@BillOfLading = BillOfLading,
		@OrderKey     = OrderKey
	FROM OPENJSON(@JSONString, '$')
	WITH (
		BillOfLading NVARCHAR(100) '$.BillOfLading',
		OrderKey     INT           '$.OrderKey'
	);

	SELECT @UserName = ISNULL(UserName, '') 
	FROM [User] 
	WHERE UserKey = @UserKey;

	SELECT @OrderNo = ISNULL(OrderNo, '') 
	FROM OrderHeader 
	WHERE OrderKey = @OrderKey;

	UPDATE OrderHeader
	SET 
		BillOfLading = @BillOfLading,
		LastUpdateDate = GETDATE(),
		LastUpdateUserKey = @UserKey
	WHERE OrderKey = @OrderKey;

	UPDATE OrderHeader
	SET 
		BillOfLading = @BillOfLading,
		LastUpdateDate = GETDATE(),
		LastUpdateUserKey = @UserKey
	WHERE OrderKey = @OrderKey;

	--IF @@ROWCOUNT > 0
	--BEGIN
		SET @Status = 1;
		SET @Reason = 'Success';
	--END

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @UserName, 'Order', @OrderNo, @OrderKey, 'CSR', 'Text' , 'MBL Updated'

END