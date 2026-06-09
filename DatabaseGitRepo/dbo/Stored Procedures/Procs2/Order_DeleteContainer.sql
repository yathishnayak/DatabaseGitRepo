/*
DECLARE @UserKey		INT=952,
		@JsonString		VARCHAR(MAX)='{"OrderDetailKey":227040}',
		@IsDebug		BIT = 0,
		@Status			BIT	= 0 ,
		@Reason			VARCHAR(1000) = '' 
EXEC Order_DeleteContainer @UserKey, @JsonString, @IsDebug, @Status output, @Reason output
Select @Status AS Status, @Reason AS Reason

	--64118, 174641, 147965
*/

CREATE Proc [dbo].[Order_DeleteContainer]
	@UserKey		INT=897,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
AS
BEGIN
	DECLARE @ISPresent				BIT		=	0,
			@ContainerNo			VARCHAR(100) = '' ,
			@OrderDetailKey			INT		=	0,
			@UserName				VARCHAR(100)
	
	SELECT @OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			OrderDetailKey	INT	'$.OrderDetailKey'
		)

	--Check If OrderDetailKey Present in OrderExpense
	Select @IsPresent = CASE WHEN (Select Count(*) FROM OrderExpense WITH(NOLOCK) Where OrderDetailKey = @OrderDetailKey)>0 THEN 1 ELSE 0 END
		
	IF(@ISPresent=1)
	BEGIN
		SELECT NULL AS Result FOR JSON PATH;
		SET @Status = 0
		SET @Reason = 'Cannot delete expense already added'
			IF(@IsDebug = 1)
			BEGIN
				Select @Status Status, @Reason Reason
			END
		print @Status 
		print @Reason
		RETURN
	END

	--Check If Status Is Archived or Dispatch Confirmed	
	Select @IsPresent = CASE WHEN (Select Count(*) FROM OrderDetail WITH(NOLOCK) Where OrderDetailKey = @OrderDetailKey AND [Status] IN (6,10))>0 THEN 1 ELSE 0 END
	--print 'Dispatch Confirmed?'
	--print @IsPresent

	IF(@ISPresent=1)
	BEGIN
		SELECT NULL AS Result FOR JSON PATH;
		SET @Status = 0
		SET @Reason = 'Cannot delete invoiced or dispatch confirmed'
			IF(@IsDebug = 1)
			BEGIN
				Select @Status Status, @Reason Reason
			END
		--print @Status 
		--print @Reason
		RETURN
	END

	--Check If Invoiced? In InvoiceDetail
	Select @IsPresent = CASE WHEN (Select Count(*) FROM InvoiceDetail WITH(NOLOCK) Where OrderDetailKey = @OrderDetailKey)>0 THEN 1 ELSE 0 END
	--print 'invoice detail'
	--print @IsPresent
	IF(@ISPresent=1)
	BEGIN
		SELECT NULL AS Result FOR JSON PATH;
		SET @Status = 0
		SET @Reason = 'Cannot delete already invoiced'
			IF(@IsDebug = 1)
			BEGIN
				Select @Status Status, @Reason Reason
			END
		--print @Status 
		--print @Reason
		RETURN
	END

	--Check If Container Is Linked? In Routes
	Select @ContainerNo = ContainerNo from OrderDetail WITH(NOLOCK) Where OrderDetailKey = @OrderDetailKey;
	Select @IsPresent = CASE WHEN (Select Count(*) FROM Routes WITH(NOLOCK) Where  LinkedContainer = @ContainerNo)>0 THEN 1 ELSE 0 END
	--print 'linked container'
	--print @IsPresent

	IF(@ISPresent=1)
	BEGIN
		SELECT NULL AS Result FOR JSON PATH;
		SET @Status = 0
		SET @Reason = 'Cannot delete container is linked'
			IF(@IsDebug = 1)
			BEGIN
				Select @Status Status, @Reason Reason
			END
		--print @Status 
		--print @Reason
		RETURN
	END

	SELECT @UserName=ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey

		BEGIN
			BEGIN TRY
			BEGIN TRANSACTION

				--Check If orderdetailkey is present in OrderDetailStops
				Select @IsPresent = CASE WHEN (Select Count(*) FROM OrderDetailStops WITH(NOLOCK) Where OrderDetailKey = @OrderDetailKey)>0 THEN 1 ELSE 0 END
				--print 'OrderDetailStops'
				--print @IsPresent
				IF(@ISPresent=1)
				BEGIN
					DELETE FROM OrderDetailStops WHERE OrderDetailKey = @OrderDetailKey
					print 'orderdetailstops deleted'

					INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
					SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','OrderdetailStops deleted for container ' + @ContainerNo
				END

				Select @IsPresent = CASE WHEN (Select Count(*) FROM OrderDetailComments WITH(NOLOCK) Where OrderDetailKey = @OrderDetailKey)>0 THEN 1 ELSE 0 END
				--print 'OrderDetailComments'
				--print @IsPresent

				IF(@ISPresent=1)
				BEGIN
					SELECT CommentKey INTO #CommentKey
					FROM Comment
					WHERE CommentKey IN (SELECT CommentKey from OrderDetailComments WITH(NOLOCK) WHERE OrderDetailKey = @OrderDetailKey)

					DELETE FROM OrderDetailComments WHERE OrderDetailKey = @OrderDetailKey
					DELETE FROM Comment WHERE CommentKey in (SELECT CommentKey FROM #CommentKey)

					INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
					SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Comments deleted for container ' + @ContainerNo
					--print 'OrderDetailComments deleted'
				END

				Select @IsPresent = CASE WHEN (Select Count(*) FROM OrderDetailDocuments WITH(NOLOCK) Where OrderDetailKey = @OrderDetailKey)>0 THEN 1 ELSE 0 END
				--print 'OrderDetailComments'
				--print @IsPresent

				IF(@ISPresent=1)
				BEGIN
					DELETE FROM OrderDetailDocuments WHERE OrderDetailKey = @OrderDetailKey

					INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
					SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','OrderDetailDocuments deleted for container ' + @ContainerNo
					--print 'OrderDetailDocuments deleted'
				END

				Delete From OrderDetail Where OrderDetailKey = @OrderDetailKey

				INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
				SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Container data deleted from OrderDetail'

				SET @Status = 1
				SET @Reason='Success'
				SELECT NULL AS Result FOR JSON PATH;
				SET @Reason = 'Deleted Successfully'
					IF(@IsDebug = 1)
					BEGIN
						Select @Status Status, @Reason Reason
					END
				--print @Status 
				--print @Reason
			COMMIT TRANSACTION
			END TRY

			BEGIN CATCH
				ROLLBACK TRANSACTION
				--print '**********************'
				--print 'Rolled Back'
				print error_message()
				print error_line()
				SET @Status = 0
				SET @Reason = 'eRROR IN pROCEDURE'
				--print @Status
				--print @Reason
					IF(@IsDebug = 1)
					BEGIN
						Select @Status Status, @Reason Reason
					END
				--print @Status 
				--print @Reason
			END CATCH
		END
END
