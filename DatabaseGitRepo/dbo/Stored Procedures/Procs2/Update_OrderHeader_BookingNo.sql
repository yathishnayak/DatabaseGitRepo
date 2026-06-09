CREATE PROCEDURE [dbo].[Update_OrderHeader_BookingNo]
/*
Update Header data from Container Screen
*/
@OrderKey		INT,
@BookingNo		VARCHAR(50),
@UpdateUserKey INT,
@OutPut		   BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	DECLARE  @Comment VARCHAR(500)='', @OrderNo NVARCHAR(20)='', @USerName VARCHAR(100)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UpdateUserKey
	SELECT @OrderNo = ISNULL(OrderNo,'') FROM OrderHeader WHERE OrderKey = @OrderKey

	UPDATE OrderHeader 
	SET BookingNo= @BookingNo, LastUpdateDate = GETDATE(), LastUpdateUserKey = @UpdateUserKey  
	WHERE OrderKey= @OrderKey;

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @USerName, 'Order', @OrderNo, @OrderKey, 'Booking No', 'Text' , 'Booking# Updated'

	SET @OutPut=1;
END
