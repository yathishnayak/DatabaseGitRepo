
CREATE PROCEDURE [dbo].[Update_OrderHeader_BillOfLoading]
/*
Update Header data from Container Screen
*/
@OrderKey		INT,
@BillOfLoading	VARCHAR(50),
@UpdateUserKey  INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @USerName VARCHAR(100),@Comment VARCHAR(500)='', @OrderNo NVARCHAR(20)=''

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UpdateUserKey
	SELECT @OrderNo = ISNULL(OrderNo,'') FROM OrderHeader WHERE OrderKey = @OrderKey

	UPDATE OrderHeader 
	SET BillOfLading= @BillOfLoading, LastUpdateDate = GETDATE(), LastUpdateUserKey = @UpdateUserKey  
	WHERE OrderKey= @OrderKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Order', @OrderNo, @OrderKey, 'CSR', 'Text' , 'MBL Updated'

	SET @OutPut=1;
END
