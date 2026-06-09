CREATE PROCEDURE [dbo].[Update_IsContainerEmpty] -- [Update_IsContainerEmpty] 318,0,null,null,1,1
@RouteKey			INT,
@OrderDetailKey 	INT = 0,
@EmptySETDate		DATETIME = null,
@EmptyRemoveDate	DATETIME = null,
@IsContainerEmpty	BIT,
@UserKey			INT = 1
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	DECLARE @output INT = 0,
			@USerName varchar(100),
			@CommentKey int,
			@Comment varchar(500),
			@ContainerNo VARCHAR(20)=''

			SELECT @ContainerNo= ContainerNo FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey

	select @USerName = ISNULL(UserName,'') from [User] where UserKey = @UserKey

	IF(@EmptySETDate > Getdate() + 10)
	BEGIN
		SET @EmptySETDate = NULL
	END
	IF(@EmptyRemoveDate > GETDATE() + 10)
	BEGIN
		SET @EmptyRemoveDate = NULL
	END



	UPDATE dbo.[routes]
	SET IsEmpty= @IsContainerEmpty
	WHERE RouteKey=@RouteKey

	IF(@OrderDetailKey = 0)
	BEGIN
		SELECT @OrderDetailKey = OrderDetailKey FROM dbo.Routes WHERE RouteKey = @RouteKey
	END


	UPDATE dbo.routes 
	SET IsEmpty = @IsContainerEmpty, EmptySetDate = GETDATE(), EmptySetUser = @UserKey
	WHERE OrderDetailKey = @OrderDetailKey AND RouteKey > @RouteKey AND Status <> 5 -- Status 5 is leg completed

	declare @StopNum  int = 0
	select @StopNum = StopNumber from ORderDetailStops where ToRouteKey = @RouteKey

	Update ODS set IsEmpty = @IsContainerEmpty,
		EmptySetUserKey = @UserKey,
		EmptySetDateTime = GetDate()
	from ORderDetailStops ODS
	inner join Routes RT on ODS.OrderDetailKey = RT.OrderDetailKey
	where Rt.OrderDetailKey = @OrderDetailKey and StopNumber >= @StopNum 

	UPDATE DBO.OrderDetail
	SET IsEmpty = @IsContainerEmpty
	WHERE OrderDetailKey = @OrderDetailKey AND isnull(IsEmpty,0) <> @IsContainerEmpty

	DECLARE @Cnt SMALLINT = 0
	IF(@IsContainerEmpty = 1)
	BEGIN
		Select @cnt = COUNT(1) FROM EmptyLegData 
			WHERE OrderDetailKey = @OrderDetailKey and IsEmpty = 1 and EmptyRemoveDate is null
		IF(@cnt = 0)
		BEGIN
			INSERT INTO dbo.EmptyLegData (OrderDetailKey,IsEmpty, EmptySETDate, EmptySETRouteKey, UserKey)
			SELECT @OrderDetailKey,ISNULL(@IsContainerEmpty,0), isnull(@EmptySETDate,getdate()), @RouteKey, @UserKey
			
			set @Comment = 'Container Marked Empty by ' -- + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);

			Exec Insert_Comment @Comment,'',@userKey,0,0, @CommentKey OUTPUT
			Exec insert_OrderDetailComment @OrderDetailKey, @CommentKey

			INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
			VALUES(GETDATE(),@USerName,'Container',@ContainerNo,null,'Text',@Comment,@OrderDetailKey)
			SET @output = 1
		END
	END
	
	IF (@IsContainerEmpty = 0)
	BEGIN
		SELECT @cnt = COUNT(1) FROM EmptyLegData
		WHERE OrderDetailKey = @OrderDetailKey AND IsEmpty = 1 AND EmptyRemoveDate IS NULL
		IF(@cnt > 0)
		BEGIN
			UPDATE dbo.EmptyLegData 
			SET EmptyRemoveDate = ISNULL(@EmptyRemoveDate,GETDATE()), 
				EmptyRemoveRouteKey = @RouteKey, IsEmpty = @IsContainerEmpty
			WHERE OrderDetailKey = @OrderDetailKey AND IsEmpty = 1 AND EmptyRemoveDate IS NULL

			set @Comment = 'Container Removed Empty by '-- + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);

			Exec Insert_Comment @Comment,'',@userKey,0,0, @CommentKey OUTPUT
			Exec insert_OrderDetailComment @OrderDetailKey, @CommentKey

			INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
			VALUES(GETDATE(),@USerName,'Container',@ContainerNo,null,'Text',@Comment,@OrderDetailKey)

			SET @output = 1
		END
	END
	SELECT @output AS Result
END
