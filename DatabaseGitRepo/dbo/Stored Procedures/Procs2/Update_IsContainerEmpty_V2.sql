/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey" : 318, "OrderDetailKey" : 0, "IsContainerEmpty" : 1}'
	EXEC [Update_IsContainerEmpty_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_IsContainerEmpty_V2] 
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@RouteKey			INT,
		@OrderDetailKey 	INT = 0,
		@IsContainerEmpty	BIT,
		@EmptySetDate		DATETIME = null,
		@EmptyRemoveDate	DATETIME = null

	SELECT 
		@RouteKey		  = RouteKey,
		@OrderDetailKey   = OrderDetailKey,
		@IsContainerEmpty = IsContainerEmpty,
		@EmptySetDate	  = EmptySetDate,
		@EmptyRemoveDate  = EmptyRemoveDate
	FROM OPENJSON(@JSONString)
	WITH
	(
		RouteKey				INT				'$.RouteKey',
		OrderDetailKey			INT				'$.OrderDetailKey',
		IsContainerEmpty		BIT				'$.IsContainerEmpty',
		EmptySetDate			DATETIME		'$.EmptySetDate',
		EmptyRemoveDate			DATETIME		'$.EmptyRemoveDate'
	)

	DECLARE 
			@USerName varchar(100),
			@CommentKey int,
			@Comment varchar(500),
			@ContainerNo VARCHAR(20)=''

			SELECT @ContainerNo= ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey

	select @USerName = ISNULL(UserName,'') from [User] WITH (NOLOCK) where UserKey = @UserKey

	IF(@EmptySetDate > Getdate() + 10)
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
		SELECT @OrderDetailKey = OrderDetailKey FROM dbo.Routes WITH (NOLOCK) WHERE RouteKey = @RouteKey
	END

	UPDATE dbo.routes 
	SET IsEmpty = @IsContainerEmpty, EmptySetDate = GETDATE(), EmptySetUser = @UserKey
	WHERE OrderDetailKey = @OrderDetailKey AND RouteKey > @RouteKey AND Status <> 5 -- Status 5 is leg completed

	declare @StopNum  int = 0
	select @StopNum = StopNumber from ORderDetailStops WITH (NOLOCK) where ToRouteKey = @RouteKey

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
		Select @cnt = COUNT(1) FROM EmptyLegData WITH (NOLOCK) 
			WHERE OrderDetailKey = @OrderDetailKey and IsEmpty = 1 and EmptyRemoveDate is null
		IF(@cnt = 0)
		BEGIN
			INSERT INTO dbo.EmptyLegData (OrderDetailKey,IsEmpty, EmptySETDate, EmptySETRouteKey, UserKey)
			SELECT @OrderDetailKey,ISNULL(@IsContainerEmpty,0), isnull(@EmptySetDate,getdate()), @RouteKey, @UserKey
			
			set @Comment = 'Container Marked Empty by ' + @USerName --+ ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);

			Exec Insert_Comment @Comment,'',@userKey,0,0, @CommentKey OUTPUT
			Exec insert_OrderDetailComment @OrderDetailKey, @CommentKey

			INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
			VALUES(GETDATE(),@USerName,'Container',@ContainerNo,null,'Text',@Comment,@OrderDetailKey)
			SET @Status = 1
		END
	END
	
	IF (@IsContainerEmpty = 0)
	BEGIN
		SELECT @cnt = COUNT(1) FROM EmptyLegData WITH (NOLOCK)
		WHERE OrderDetailKey = @OrderDetailKey AND IsEmpty = 1 AND EmptyRemoveDate IS NULL
		IF(@cnt > 0)
		BEGIN
			UPDATE dbo.EmptyLegData 
			SET EmptyRemoveDate = ISNULL(@EmptyRemoveDate,GETDATE()), 
				EmptyRemoveRouteKey = @RouteKey, IsEmpty = @IsContainerEmpty
			WHERE OrderDetailKey = @OrderDetailKey AND IsEmpty = 1 AND EmptyRemoveDate IS NULL

			set @Comment = 'Container Removed Empty by ' + @USerName --+ ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);

			Exec Insert_Comment @Comment,'',@userKey,0,0, @CommentKey OUTPUT
			Exec insert_OrderDetailComment @OrderDetailKey, @CommentKey

			INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
			VALUES(GETDATE(),@USerName,'Container',@ContainerNo,null,'Text',@Comment,@OrderDetailKey)

			SET @Status = 1
		END
	END
	-- SELECT @Status AS Result
	SET @Status = 1
	SET @Reason = 'Success'
END