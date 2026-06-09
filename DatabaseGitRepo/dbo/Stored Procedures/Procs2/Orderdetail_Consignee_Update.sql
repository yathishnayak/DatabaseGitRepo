/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"ConsigneeKey" : 98, "OrderDetailKey" : 47697}',
	@Status	BIT = 0, 
	@JSONOutput   NVARCHAR(MAX) = '', 
	@Reason	VARCHAR(100)=''
	EXEC [Orderdetail_Consignee_Update] @UserKey,@JSONString,@JSONOutput OUTPUT, @Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Orderdetail_Consignee_Update]
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
	DECLARE @ConsigneeKey	INT=0, @OrderDetailKey INT=0, @USerName VARCHAR(100), 
			@ContainerNo NVARCHAR(20)=''	, @PrevConsigneeKey INT=0, @PrevConsignee NVARCHAR(100)='',
			@ConsigneeName NVARCHAR(100)=''

	SELECT @ConsigneeKey = ConsigneeKey, @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JSONString,'$')
    WITH (
			ConsigneeKey		INT			'$.ConsigneeKey',
			OrderDetailKey		INT			'$.OrderDetailKey'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	SELECT @ContainerNo = ISNULL(ContainerNo,'') FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey
	SELECT @PrevConsigneeKey= ISNULL(ConsigneeKey ,0)FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey
	SELECT @PrevConsignee = ISNULL(ConsigneeName,'') FROM Customer_Consignee WHERE ConsigneeKey = @PrevConsigneeKey
	SELECT @ConsigneeName = ISNULL(ConsigneeName,'') FROM Customer_Consignee WHERE ConsigneeKey = @ConsigneeKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE OrderDetail 
	SET ConsigneeKey= @ConsigneeKey, LastUpdateDate = GETDATE(), UpdateUserKey = @UserKey  
	WHERE OrderDetailKey= @OrderDetailKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, 
								Stage, CommentType, Comments)
						Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 
						'Consignee', 'Text' , 'Consignee changed from '+@PrevConsignee+' to '+@ConsigneeName+' by '+ @USerName

	SET @Status=1;
	SET @Reason='Success';
END