/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey" : 727864, "IsBobtail" : 1}'
	EXEC [Update_RouteIsBobtail_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_RouteIsBobtail_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

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
		@RouteKey	INT,
		@IsBobtail	BIT
	--@UserKey	INT,
	--@Status		BIT OUTPUT

	SELECT 
		@RouteKey	=	RouteKey,
		@IsBobtail	=	IsBobtail
	FROM OPENJSON(@JSONString)
	WITH
	(
		RouteKey		INT			'$.RouteKey',
		IsBobtail		BIT			'$.IsBobtail'
	)

	DECLARE @USerName varchar(100),
	        @CommentKey int,
			@Comment varchar(500),
			@OrderDetailKey INT=0

			select @USerName = ISNULL(UserName,'') from [User] WITH (NOLOCK) where UserKey = @UserKey

	SET @Status=0;
	SET @OrderDetailKey =(SELECT TOP 1 OrderDetailKey FROM [Routes] WITH (NOLOCK) WHERE RouteKey=@RouteKey)

	if(isnull(@UserKey,0) = 0)
	begin
		set @Status = 0
		return
	end

	if(isnull(@IsBobtail ,0) =1)
	Begin
		update Routes set 
				IsBobtail = 1, 
				UpdateUserKey=@UserKey,
				BobtailSetUser = @UserKey, 
				BobtailSetDate = GETDATE(),
				LastUpdateDate = GETDATE()
		where RouteKey = @RouteKey	
	
		update ODS set IsBobTail = 1, BobtailSetUserKey = @UserKey,
			BobtailSetDateTime = GETDATE()
		from OrderDetailStops ODS WITH(NOLOCK)
		inner join Routes RT WITH(NOLOCK) on ODS.ToRouteKey = RT.RouteKey
		inner join LEg L WITH(NOLOCK) on RT.legkey = L.legkey
		where Rt.RouteKey = @RouteKey 

		set @Comment = 'Container Leg Marked Bobtail by ' + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);
	End
	
	if(isnull(@IsBobtail ,0) =0)
	Begin

		update routes set
				IsBobtail = 0, 
				BobtailSetUser = null, 
				BobtailSetDate = null
		where  RouteKey = @RouteKey 

		update ODS set IsBobTail = 0, BobtailSetUserKey = @UserKey,
			BobtailSetDateTime = GETDATE()
		from OrderDetailStops ODS WITH(NOLOCK)
		inner join Routes RT WITH(NOLOCK) on ODS.ToRouteKey = RT.RouteKey
		inner join LEg L WITH(NOLOCK) on RT.legkey = L.legkey
		where Rt.RouteKey = @RouteKey 

		set @Comment = 'Container Leg UnChecked Bobtail by ' + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);
	End
	
	INSERT INTO  AuditLogDetail	(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
	VALUES(GETDATE(),@UserName,'Container',
		(SELECT ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey),null,'Text',@Comment,@OrderDetailKey)

	SET @Status=1
	SET @Reason = 'Success'

END;