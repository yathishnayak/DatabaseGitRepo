
/**
DECLARE @OrderDetailKey			int=200,
	@LinkedContainerNo		varchar(20)='null',
	@User					varchar(20)=488,
	@Output					Bit = 0,
	@Reason					varchar(100) = ''
exec OrderDetail_UnLinkContainer @OrderDetailKey,@LinkedContainerNo,@User,@Output OUTPUT,@Reason OUTPUT
select @Output,@Reason
**/
CREATE Proc [dbo].[OrderDetail_UnLinkContainer]  
(
	@OrderDetailKey			int,
	@LinkedContainerNo		varchar(20),
	@User					varchar(20),
	@Output					Bit = 0 output,
	@Reason					varchar(100) = '' output
)
As
Begin
	set nocount on
	set fmtonly off
	set @output = 0
	set @Reason = ''

	declare @cnt int = 0, @ContainerNo varchar(20) = '', @LinkedOrderDetailKey	int = 0, @UserName VARCHAR(100)=''
	
	
	
	Begin Try
	
		Begin Transaction
		IF(@LinkedContainerNo IS NULL OR ISNULL(@LinkedContainerNo,'')='' OR @LinkedContainerNo=null OR @LinkedContainerNo='null')
		BEGIN
			SELECT @LinkedContainerNo = LinkedContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey
		END
		Select @ContainerNo = ContainerNo from ORderDetail where OrderDetailKey = @OrderDetailKey
		Select @cnt = count(1) from OrderDetail where OrderDetailKey = @OrderDetailKey and LinkedContainerNo = @LinkedContainerNo
		select @LinkedOrderDetailKey = LinkedOrderDetailKey from orderdetail where OrderDetailKey = @OrderDetailKey
		SELECT @UserName= UserName FROM [USER] WHERE UserKey=@User

		IF(@cnt > 0)
		begin
			update OrderDetail set
				IsLinked = 0,
				LinkedContainerNo = null,
				LinkedOrderDetailKey = null
			where  OrderDetailKey = @OrderDetailKey

			update OrderDetail set
				IsLinked = 0,
				LinkedContainerNo = null,
				LinkedOrderDetailKey = null
			where  OrderDetailKey = @LinkedOrderDetailKey

			Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select getDate(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' UnLinked from ' + @LinkedContainerNo 

			Commit Transaction
			Set @output = 1
			Set @Reason = 'UnLinked Successfully.'
			Return
		end
		
		Set @output = 0
		Set @Reason = 'Error. Container nos. not found'
		return
	End Try
	Begin Catch
		Set @output = 0
		Set @Reason = 'Technical Error'
		Rollback Transaction
		return
	End Catch
End

