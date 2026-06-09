CREATE PROCEDURE [dbo].[Update_OrderDetail_CutOffDate]
/*
Update detail data from Container Screen
*/
@OrderDetailKey		INT,
@CutOffDate		Datetime,
@UpdateUserKey INT,
@OutPut		   BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	DECLARE @UserName				NVARCHAR(100)='',
			@ContainerNo			NVARCHAR(20)

	SELECT  @UserName=ISNULL(UserName,'') FROM [User] WHERE UserKey=@UpdateUserKey			
	SELECT TOP 1 @ContainerNo = ContainerNo FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey

	UPDATE OrderDetail 
	SET CutOffDate= @CutOffDate, LastUpdateDate = GETDATE(), UpdateUserKey = @UpdateUserKey  
	WHERE OrderDetailKey= @OrderDetailKey 

	INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,
			 Stage,CommentType,Comments)
	SELECT   GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,
			 null,'Text','Schedule T is updated by '+@UserName

	SET @OutPut=1;
END
