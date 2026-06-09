CREATE proc [dbo].[Update_ContainerSize]
(
	@OrderDetailKey		int,
	@ContainerSizeKey	int,
	@UserKey			int,
	@Output				Bit = 0 OUTPUT
)
as
BEGIN
	DECLARE @CNT INT = 0,
			@UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)
	set @Output = 0
	SELECT @CNT = COUNT(1) FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey
	IF(@CNT > 0)
	BEGIN
		SELECT  @UserName=ISNULL(UserName,'') FROM [User] WHERE UserKey=@UserKey			
		SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey
		
		UPDATE OrderDetail
		SET ContainerSizeKey = @ContainerSizeKey, UpdateUserKey = @UserKey
		where OrderDetailKey = @OrderDetailKey

		INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			null,'Text','Container size is updated by '+@UserName

		set @Output = 1
	END
END
