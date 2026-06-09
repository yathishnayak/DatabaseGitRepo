/*
declare @OrderDetailKey		int = 210,	@ContainerProperty	varchar(50) = 'OTR',@IsLink	bit = 0,
	@UserKey			int = 29, 	@Status				bit = 0 ,	@Reason				varchar(100) = '' 
exec ContainerProperties_Update @OrderDetailKey, @ContainerProperty, @IsLink, @UserKey, @Status output, @Reason output
select @Status, @Reason
*/
CREATE proc [dbo].[ContainerProperties_Update]
(
	@OrderDetailKey		int = 0,
	@ContainerProperty	varchar(50) = '',
	@IsLink				bit = 0,
	@UserKey			int = 0,
	@Status				bit = 0 OUTPUT,
	@Reason				varchar(100) = '' OUTPUT
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @CNT INT = 0, @userName varchar(50) = '', @ContainerNo varchar(50)=''
	select @userName = UserName from [User] where UserKey = @UserKey
	select @ContainerNo = ContainerNo from OrderDetail where OrderDetailKey = @OrderDetailKey
	
	SELECT @CNT  = COUNT(1) FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey
	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Container not Found'
		RETURN
	END

	DECLARE @CommentKey int = 0
	Select top 1 @CommentKey = ctl.CommentKey
	from OrderDetail OD WITH (NOLOCK)
	inner join ContainerTypesLink CTL WITH (NOLOCK) on OD.OrderDetailKey = ctl.OrderDetailKey
	inner join Comment C WITH (NOLOCK) on CTL.CommentKey = C.CommentKey
	where OD.OrderDetailKey = @OrderDetailKey
	print @commentKey

	BEGIN TRY
		if(isnull(@CommentKey,0) = 0 AND ISNULL(@IsLink,0) = 1)
		begin
			-- INSERT NEW COMMENT
			BEGIN TRANSACTION 
			INSERT INTO Comment(Description, CreateDate, CreateUserKey)
			select @ContainerProperty, GETDATE(), @UserKey
			set @CommentKey = SCOPE_IDENTITY()

			insert into OrderDetailComments(OrderDetailKey, CommentKey)
			select @OrderDetailKey, @CommentKey

			exec [Container_TypeInsert] @OrderDetailKey, @CommentKey

			insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			select Getdate(), @userName, 'Container', @ContainerNo, @OrderdetailKey, '', '', @ContainerProperty + ' added'
			SET @Status = 1
			SET @Reason = 'Inserted Successflly'
			COMMIT TRANSACTION 
			RETURN
		end
		ELSE
		BEGIN
			-- UPDATE EXISTING COMMENT
			IF(ISNULL(@IsLink,0) = 1)
			BEGIN
				declare @comment nvarchar(max) = ''
				select @comment = Description
				from Comment  WITH (NOLOCK)
				where CommentKey = @CommentKey

				print @Comment
				print @ContainerProperty
				if(@comment like '%' + @ContainerProperty + '%')
				begin
					SET @Status = 0
					SET @Reason = 'Duplicate Container Property';
					THROW 51600,'ERROR',1;
					return;
				end
				else
				begin
					set @comment = @comment + ',' + @ContainerProperty
					BEGIN TRANSACTION 
					update Comment set
						Description = @comment
					where CommentKey = @CommentKey

					exec [Container_TypeInsert] @OrderDetailKey, @CommentKey

					insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
					select Getdate(), @userName, 'Container', @ContainerNo, @OrderdetailKey, '', '', @ContainerProperty + ' added'

					SET @Status = 1
					SET @Reason = 'Updated Successflly'
					COMMIT TRANSACTION 
					RETURN
				end
			END
			IF(ISNULL(@IsLink,0) = 0 AND isnull(@CommentKey,0) > 0)
			BEGIN
				declare @comment1 nvarchar(max) = ''
				select @comment1 = Description
				from Comment  WITH (NOLOCK)
				where CommentKey = @CommentKey

				set @comment1 = REPLACE(@comment1,@ContainerProperty, '') 
				BEGIN TRANSACTION 
				update Comment set
					Description = @comment1
				where CommentKey = @CommentKey

				exec [Container_TypeInsert] @OrderDetailKey, @CommentKey

				insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				select Getdate(), @userName, 'Container', @ContainerNo, @OrderdetailKey, '', '', @ContainerProperty + ' added'

				SET @Status = 1
				SET @Reason = 'Unlinked Successflly'
				COMMIT TRANSACTION 
				RETURN
			END
			Exec Auto_ChargeContainerProps @Orderdetailkey
			IF(ISNULL(@IsLink,0) = 0 AND isnull(@CommentKey,0) > 0)
			BEGIN
				SET @Status = 0
				SET @Reason = 'No Container Properties found'
				return
			END
			
		END
	END TRY
	BEGIN CATCH
		SET @Status = 0
		SET @Reason = ERROR_MESSAGE()
		if(@@trancount > 0)
		begin
			ROLLBACK TRANSACTION 
		end
		RETURN
	END CATCH
End
