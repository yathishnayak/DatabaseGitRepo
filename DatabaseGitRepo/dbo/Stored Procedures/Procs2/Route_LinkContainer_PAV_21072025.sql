Create proc [dbo].[Route_LinkContainer_PAV_21072025]  
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
	
)
AS
Begin
	Set NoCount on
	Set fmtonly off
	SET ARITHABORT ON;
	set @Status = 0
	Set @Reason = ''

	DECLARE @OrderDetailKey	int,
	@RouteKey				INT,
	@LinkedContainerNo		varchar(20),
	@ContainerType			NVARCHAR(10)

	SELECT @OrderDetailKey=OrderDetailKey,@RouteKey=RouteKey,@LinkedContainerNo=LinkedContainerNo,@ContainerType=ContainerType
	FROM OPENJSON(@JsonString, '$')
	WITH (
			OrderDetailKey		INT				'$.OrderDetailKey',
			RouteKey			INT				'$.RouteKey',
			LinkedContainerNo	VARCHAR(20)		'$.LinkedContainerNo',
			ContainerType		NVARCHAR(10)	'$.ContainerType'
		)

	declare @cnt int = 0, @LinkedOrderdetailKey	int = 0, @ContainerNo varchar(20) = '', @cntLinked int = 0, @UserName VARCHAR(100)=''
	Select @cnt = count(1) from Routes where RouteKey = @RouteKey
	Select @ContainerNo = ContainerNo from ORderDetail where OrderDetailKey = @OrderDetailKey
	select @cntLinked = count(1) from OrderDetail where ContainerNo = @LinkedContainerNo and isnull(IsLinked,0) <> 0
	select top 1 @LinkedOrderdetailKey = OrderDetailKey from OrderDetail 
		WHERE ContainerNo = @LinkedContainerNo and isnull(LinkedContainerNo,'') = ''
	SELECT @UserName= UserName FROM [USER] WHERE UserKey=@UserKey

	--select @cnt coun,@LinkedOrderdetailKey linkor

	IF(@LinkedContainerNo=@ContainerNo)
	begin
		Set @Status = 0
		Set @Reason = 'You cannot link the container to itself'
		return;
	end

	IF(isnull(@cntLinked ,0) > 0)
	begin
		Set @Status = 0
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

			
			update RT
			set LinkedContainer = @LinkedContainerNo,
			    LinkedBy = @UserKey,
				LinkedDate = GETDATE(),
				LinkedContainerSource='JCB User',
				LinkedContainerType=@ContainerType
			from Routes RT	
			--inner join OrderDetail od on od.CurrentRouteKey = r.RouteKey
			where RT.RouteKey = @RouteKey
		

			Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select getDate(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' Linked to ' + @LinkedContainerNo 

			UPDATE OrderDetail SET
				MarkedNoEmptyAvailable = 0,
				MarkedNoEmptyAvailableBY=null
			WHERE  OrderDetailKey = @OrderDetailKey

			UPDATE Routes SET
				NoEmptyAvailableMarked = 0,
				NoEmptyAvailableMarkedBY=null
			WHERE  RouteKey = @RouteKey

			Commit Transaction
			Set @Status = 1
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

			update RT
			set LinkedContainer = @LinkedContainerNo,
			    LinkedBy = @UserKey,
				LinkedDate = GETDATE(),
				LinkedContainerSource='JCB User',
				LinkedContainerType=@ContainerType
			from Routes RT	
			--inner join OrderDetail od on od.CurrentRouteKey = r.RouteKey
			where RT.RouteKey = @RouteKey
		

			Insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select getDate(), @UserName, 'Container', @ContainerNo,@OrderDetailKey, null, 'Text', 'Container ' + @Containerno + ' Linked to ' + @LinkedContainerNo 

			UPDATE OrderDetail SET
				MarkedNoEmptyAvailable = 0,
				MarkedNoEmptyAvailableBY=null
			WHERE  OrderDetailKey = @OrderDetailKey

			UPDATE Routes SET
				NoEmptyAvailableMarked = 0,
				NoEmptyAvailableMarkedBY=null
			WHERE  RouteKey = @RouteKey

			Commit Transaction
			Set @Status = 1
			Set @Reason = 'Linked Successfully.'
			Return
		END
		Set @Status = 0
		Set @Reason = 'Error. Container nos. not found'
		
	End Try
	Begin Catch
		Set @Status = 0
		Set @Reason = 'Technical Error'
		Rollback Transaction
	End Catch
End

