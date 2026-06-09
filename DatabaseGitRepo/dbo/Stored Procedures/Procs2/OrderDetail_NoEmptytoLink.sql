
CREATE PROCEDURE [dbo].[OrderDetail_NoEmptytoLink]
(
	@OrderDetailKey			int,
	@UserKey				INT,
	@Output					Bit = 0 output,
	@Reason					varchar(100) = '' output
)
AS
BEGIN

	DECLARE @UserName VARCHAR(100)='',@ContainerNo VARCHAR(20)=''
	SELECT @UserName= UserName FROM [USER] WHERE UserKey=@UserKey
	SELECT @ContainerNo= ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey

	UPDATE OrderDetail SET
				MarkedNoEmptyAvailable = 1,
				MarkedNoEmptyAvailableBY=@UserKey
	WHERE  OrderDetailKey = @OrderDetailKey

	Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	select getDate(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' updated as no empty to mark ' 

	SET @Output=1
	SET @Reason ='Success'
END

