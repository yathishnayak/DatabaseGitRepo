/** 
Declare 
	@UserKey		INT = 951,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"OrderDetailKey" : 224132, "RouteKey" : 727864, "IsStreetTurn" : 0}'
	EXEC [Update_OrderDetailStreetTurn_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[Update_OrderDetailStreetTurn_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE
		@OrderDetailKey			int,
		@RouteKey				int,
		@IsStreetTurn			Bit = 0

	SELECT 
		@OrderDetailKey	= OrderDetailKey,	
		@RouteKey		= RouteKey		,
		@IsStreetTurn	= IsStreetTurn	
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey		INT		'$.OrderDetailKey',
		RouteKey			INT		'$.RouteKey',		
		IsStreetTurn		BIT		'$.IsStreetTurn'
	)

	DECLARE @USerName varchar(100),
			@CommentKey int,
			@Comment varchar(500)

	select @USerName = ISNULL(UserName,'') from [User] WITH (NOLOCK) where UserKey = @UserKey

	DECLARE @IsFound	int = 0
	SELECT  @IsFound = count(1) from OrderDetail WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey
	if(isnull(@IsFound,0) = 0)
	begin
		set @Status  = 0
		return
	end

	if(isnull(@UserKey,0) = 0)
	begin
		set @Status = 0
		return
	end


	declare @CompletedStatusKey int = 5, 
			@StreeTurnPrevStatusKey		int = 0

	if(isnull(@isStreetTurn ,0) =1)
	Begin
		update OrderDetail set 
				isStreetTurn = 1, 
				StreetTurnSetUser = @UserKey, 
				StreetTurnSetDate = GETDATE()
		where OrderDetailKey = @OrderDetailKey

		update routes set
				isStreetTurn = 1, 
				StreetTurnSetUser = @UserKey, 
				StreetTurnSetDate = GETDATE()
		where OrderDetailKey = @OrderDetailKey and RouteKey = @routeKey

		update ODS set 
			IsStreetTurn = 1, StreetSturnSetUserKey = @UserKey,
			StreetSturnSetDateTime = GETDATE()
		from OrderDetailStops ODS WITH(NOLOCK)
		inner join Routes RT WITH(NOLOCK) on ODS.ToRouteKey = RT.RouteKey
		inner join LEg L WITH(NOLOCK) on RT.legkey = L.legkey
		where Rt.RouteKey = @RouteKey 

		
		select @CompletedStatusKey = Status from RouteStatus WITH (NOLOCK) where Description = 'Leg Completed'

		update routes set StreeTurnPrevStatusKey = status 
		where orderdetailkey = @OrderDetailKey
	
		update R set Status = @CompletedStatusKey 
		--select *
		from Routes R WITH(NOLOCK)
		where R.OrderDetailKey = @OrderDetailKey 
			and Status <> @CompletedStatusKey
			and RouteKey <> @routeKey
	
		set @Comment = 'Container Marked StreetTurn by ' + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);
	
	End
	
	if(isnull(@isStreetTurn ,0) =0)
	Begin
		update OrderDetail set 
				isStreetTurn = 0, 
				StreetTurnSetUser = null, 
				StreetTurnSetDate = null
		where OrderDetailKey = @OrderDetailKey

		update routes set
				isStreetTurn = 0, 
				StreetTurnSetUser = null, 
				StreetTurnSetDate = null
		where OrderDetailKey = @OrderDetailKey and RouteKey = @routeKey

		update ODS set 
			IsStreetTurn = 0, StreetSturnSetUserKey = @UserKey,
			StreetSturnSetDateTime = GETDATE()
		from OrderDetailStops ODS WITH(NOLOCK)
		inner join Routes RT WITH(NOLOCK) on ODS.ToRouteKey = RT.RouteKey
		inner join LEg L  WITH(NOLOCK) on RT.legkey = L.legkey
		where Rt.RouteKey = @RouteKey 

		select @StreeTurnPrevStatusKey =  Status from Routes WITH (NOLOCK) where RouteKey = @routeKey
	
		update R set Status =  StreeTurnPrevStatusKey, StreeTurnPrevStatusKey = null
		--select *
		from Routes R WITH(NOLOCK)
		where R.OrderDetailKey = @OrderDetailKey 
			and Status = @CompletedStatusKey

	
		set @Comment = 'Container UnChecked StreetTurn by ' + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);
	
		
	End

	Exec Insert_Comment @Comment,'',@UserKey,0,0, @CommentKey OUTPUT
	Exec insert_OrderDetailComment @OrderDetailKey, @CommentKey

	INSERT INTO  AuditLogDetail	(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
	VALUES(GETDATE(),@UserName,'Container',
		(SELECT ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey),null,'Text',@Comment,@OrderDetailKey)

	set @Status = 1
	SET @Reason = 'Success'
END