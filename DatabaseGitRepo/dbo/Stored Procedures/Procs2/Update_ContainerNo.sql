CREATE proc [dbo].[Update_ContainerNo]
(
	@OrderDetailKey	int,
	@ContainerNo	varchar(20),
	@ContainerID	varchar(50),
	@UserKey		int
)
as
BEGIN
	DECLARE @CNT INT = 0,
			@OldContainerNo	NVARCHAR(20)='',
			@UserName		NVARCHAR(100)=''
	SELECT @CNT = COUNT(1) FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey
	IF(@CNT > 0)
	BEGIN
		SELECT @OldContainerNo=ISNULL(ContainerNo,'') FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey
		SELECT @UserName=ISNULL(UserName,'') FROM [User] WHERE UserKey=@UserKey

		UPDATE OrderDetail
		SET ContainerNo = @ContainerNo, ContainerID = @ContainerID, UpdateUserKey = @UserKey
		where OrderDetailKey = @OrderDetailKey

		UPDATE Invoicedetail
		SET Container=@ContainerNo 
		Where OrderDetailKey=@OrderDetailKey

		UPDATE InvoiceContainers
		SET ContainerNo=@ContainerNo 
		Where OrderDetailsKey = @OrderDetailKey

		INSERT INTO AuditLogDetail 
				(DateCreated, CreateUser, RefType, RefId, RefKey, 
				Stage, CommentType, Comments)
	    Select   GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 
				'Container No', 'Text' , 'Container no Updated from '+@OldContainerNo+ ' to '+@ContainerNo+ ' by '+@UserName
	END
END
