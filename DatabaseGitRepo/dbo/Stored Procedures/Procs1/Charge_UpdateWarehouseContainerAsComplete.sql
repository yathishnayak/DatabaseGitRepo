/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
	set @JsonString = '{"OrderDetailKey":221535}'
	exec Charge_UpdateWarehouseContainerAsComplete @UserKey, @JSONString, @Status output, @Reason output
	select @Status, @Reason
*/

CREATE  PROCEDURE [dbo].[Charge_UpdateWarehouseContainerAsComplete] -- Charge_UpdateWarehouseContainerAsComplete 
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;


	Declare 
		@OrderDetailKey				INT = 0,
		@Count						int = 0,
		@IsLongTermStorage			bit = 0,
		@CurStatusKey				Int = 0,
		@StorageStatusKey			int = 0,
		@CompleteStatusKey			int = 0,
		@CurDate					DateTime,
		@ContainerNo				varchar(20) = '',
		@UserName					varchar(20)
	
	set @CurDate = GetDate()

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End
	
	Select @OrderDetailKey = OrderDetailKey 
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey			int			'$.OrderDetailKey'
	)
	
	if(Isnull(@OrderDetailKey,0) = 0 )
	Begin
		set @Status = 0
		set @Reason = 'Container / Status info Not found'
	End

	
		print @OrderDetailKey
		select @StorageStatusKey = StatusKey from WarehouseStatus WITH (NOLOCK) where Description = 'Storage'
		select @CompleteStatusKey = StatusKey from WarehouseStatus WITH (NOLOCK) where Description = 'Complete'

		SElect @ContainerNo = ContainerNo from OrderDetail  WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey
		select @Count = count(1) from Warehouse_ContainerDetails WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey
		Select @CurStatusKey = 1
		select @CurStatusKey = StatusKey, @IsLongTermStorage = IsStoring 
			from Warehouse_ContainerDetails WITH (NOLOCK) 
			where OrderDetailKey = @OrderDetailKey
		SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey


		if(@Count = 0)
		Begin
			
			set @Status = 0
			set @Reason = 'Container Record Not Found '
			RETURN
		end 
		
		
		Begin Try
			BEGIN TRANSACTION

			if(isnull(@CurStatusKey,0) = 1 and Isnull(@IsLongTermStorage,0) = 1)
			Begin
				update Warehouse_ContainerDetails set
					StatusKey = @StorageStatusKey,
					UpdateDate = GETDATE(),
					UpdateUserKey = @UserKey
				where OrderDetailKey = @OrderDetailKey
			END

			if(isnull(@CurStatusKey,0) = 1 and Isnull(@IsLongTermStorage,0) = 0)
			Begin
				update Warehouse_ContainerDetails set
					StatusKey = @CompleteStatusKey,
					UpdateDate = GETDATE(),
					UpdateUserKey = @UserKey
				where OrderDetailKey = @OrderDetailKey
			END

			IF(ISNULL(@CurStatusKey,0)=2)
			BEGIN
				UPDATE Warehouse_ContainerDetails
				SET StatusKey=@CompleteStatusKey,
					UpdateDate=GETDATE(),
					UpdateUserKey=@UserKey
				WHERE OrderDetailKey=@OrderDetailKey
			END

			insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey,  CommentType, Comments)
			select @CurDate, @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Text', 'Warehouse Container Status changed to complete'
			--select @CurDate, U.UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Text', 
			--	'Warehouse Container Status changed to ' + WS.Description
			--from Warehouse_ContainerDetails WCD WITH (NOLOCK)
			--LEFT JOIN [USER] U WITH (NOLOCK) ON wcd.CreateUserKey = u.UserKey
			--LEFT join WarehouseStatus WS WITH (NOLOCK) on WCD.StatusKey = WS.StatusKey
			

		COMMIT TRANSACTION
		set @Status = 1
		set @Reason = 'SUCCESS'
	end try
	begin catch
		ROLLBACK TRANSACTION
		set @Status = 0
		set @Reason = 'ERROR IN PROC: ' + convert(varchar, ERROR_LINE()) + ' : ' + ERROR_MESSAGE()
	end catch
END