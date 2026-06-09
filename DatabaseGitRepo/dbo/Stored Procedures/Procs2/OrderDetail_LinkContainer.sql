CREATE proc [dbo].[OrderDetail_LinkContainer]
(
	@OrderDetailKey			int,
	@LinkedContainerNo		varchar(20),
	@User					varchar(20),
	@Output					Bit = 0 output,
	@Reason					varchar(100) = '' output
)
AS
Begin
	Set NoCount on
	Set fmtonly off
	set @Output = 0
	Set @Reason = ''

	declare @cnt int = 0, @LinkedOrderdetailKey	int = 0, @ContainerNo varchar(20) = '', @cntLinked int = 0, @UserName VARCHAR(100)=''
	Select @cnt = count(1) from OrderDetail where OrderDetailKey = @OrderDetailKey
	Select @ContainerNo = ContainerNo from ORderDetail where OrderDetailKey = @OrderDetailKey
	select @cntLinked = count(1) from OrderDetail where ContainerNo = @LinkedContainerNo and isnull(IsLinked,0) <> 0
	select top 1 @LinkedOrderdetailKey = OrderDetailKey from OrderDetail 
		where ContainerNo = @LinkedContainerNo and isnull(LinkedContainerNo,'') = ''
	SELECT @UserName= UserName FROM [USER] WHERE UserKey=@User

	IF(@LinkedContainerNo=@ContainerNo)
	begin
		Set @output = 0
		Set @Reason = 'You cannot link the container to itself'
		return;
	end

	IF(isnull(@cntLinked ,0) > 0)
	begin
		Set @output = 0
		Set @Reason = 'Linked Container is Already Linked with another Container'
	end

	Begin Try
		Begin Transaction
		
		If(@cnt > 0 and @LinkedOrderdetailKey > 0)
		Begin
			update OrderDetail set
				IsLinked = 1,
				LinkedContainerNo = @LinkedContainerNo,
				LinkedOrderDetailKey = @LinkedOrderdetailKey
			where  OrderDetailKey = @OrderDetailKey

			update OrderDetail set
				IsLinked = 1,
				LinkedContainerNo = @ContainerNo,
				LinkedOrderDetailKey = @OrderDetailKey
			where  OrderDetailKey = @LinkedOrderdetailKey

			update R
			set LinkedContainer = @LinkedContainerNo,
				LinkedBy = @User,
				LinkedDate = GETDATE()	
			from Routes R	
			inner join OrderDetail od on od.CurrentRouteKey = r.RouteKey
			where od.OrderDetailKey = @OrderDetailKey

			Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select getDate(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' Linked to ' + @LinkedContainerNo 

			UPDATE OrderDetail SET
				MarkedNoEmptyAvailable = 0,
				MarkedNoEmptyAvailableBY=null
			WHERE  OrderDetailKey = @OrderDetailKey

			Commit Transaction
			Set @output = 1
			Set @Reason = 'Linked Successfully.'
			Return
		end
		ELSE IF(@cnt > 0 and @LinkedOrderdetailKey = 0)
		BEGIN
			update OrderDetail set
				IsLinked = 1,
				LinkedContainerNo = @LinkedContainerNo,
				LinkedOrderDetailKey = 0
			where  OrderDetailKey = @OrderDetailKey

			Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select getDate(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' Linked to ' + @LinkedContainerNo 

			UPDATE OrderDetail SET
				MarkedNoEmptyAvailable = 0,
				MarkedNoEmptyAvailableBY=null
			WHERE  OrderDetailKey = @OrderDetailKey

			Commit Transaction
			Set @output = 1
			Set @Reason = 'Linked Successfully.'
			Return
		END
		Set @output = 0
		Set @Reason = 'Error. Container nos. not found'
		
	End Try
	Begin Catch
		Set @output = 0
		Set @Reason = 'Technical Error'
		Rollback Transaction
	End Catch
End

