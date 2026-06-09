CREATE Proc [dbo].[Update_OrderDetailStreetTurn]
(
	@OrderDetailKey			int,
	@routeKey				int,
	@isStreetTurn			Bit = 0,
	@StreetTurnSetUserKey	int = 0,
	@Output					Bit = 0 OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @USerName varchar(100),
			@CommentKey int,
			@Comment varchar(500)

	select @USerName = ISNULL(UserName,'') from [User] where UserKey = @StreetTurnSetUserKey

	DECLARE @IsFound	int = 0
	SELECT  @IsFound = count(1) from OrderDetail where OrderDetailKey = @OrderDetailKey
	if(isnull(@IsFound,0) = 0)
	begin
		set @Output  = 0
		return
	end

	if(isnull(@StreetTurnSetUserKey,0) = 0)
	begin
		set @Output = 0
		return
	end


	declare @CompletedStatusKey int = 5, 
			@StreeTurnPrevStatusKey		int = 0

	if(isnull(@isStreetTurn ,0) =1)
	Begin
		update OrderDetail set 
				isStreetTurn = 1, 
				StreetTurnSetUser = @StreetTurnSetUserKey, 
				StreetTurnSetDate = GETDATE()
		where OrderDetailKey = @OrderDetailKey

		update routes set
				isStreetTurn = 1, 
				StreetTurnSetUser = @StreetTurnSetUserKey, 
				StreetTurnSetDate = GETDATE()
		where OrderDetailKey = @OrderDetailKey and RouteKey = @routeKey

		update ODS set 
			IsStreetTurn = 1, StreetSturnSetUserKey = @StreetTurnSetUserKey,
			StreetSturnSetDateTime = GETDATE()
		from OrderDetailStops ODS
		inner join Routes RT on ODS.ToRouteKey = RT.RouteKey
		inner join LEg L on RT.legkey = L.legkey
		where Rt.RouteKey = @RouteKey 

		
		select @CompletedStatusKey = Status from RouteStatus where Description = 'Leg Completed'

		update routes set StreeTurnPrevStatusKey = status 
		where orderdetailkey = @OrderDetailKey
	
		update R set Status = @CompletedStatusKey 
		--select *
		from Routes R
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
			IsStreetTurn = 0, StreetSturnSetUserKey = @StreetTurnSetUserKey,
			StreetSturnSetDateTime = GETDATE()
		from OrderDetailStops ODS
		inner join Routes RT on ODS.ToRouteKey = RT.RouteKey
		inner join LEg L on RT.legkey = L.legkey
		where Rt.RouteKey = @RouteKey 

		select @StreeTurnPrevStatusKey =  Status from Routes where RouteKey = @routeKey
	
		update R set Status =  StreeTurnPrevStatusKey, StreeTurnPrevStatusKey = null
		--select *
		from Routes R
		where R.OrderDetailKey = @OrderDetailKey 
			and Status = @CompletedStatusKey

	
		set @Comment = 'Container UnChecked StreetTurn by ' + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);
	
		
	End

	Exec Insert_Comment @Comment,'',@StreetTurnSetUserKey,0,0, @CommentKey OUTPUT
	Exec insert_OrderDetailComment @OrderDetailKey, @CommentKey

	INSERT INTO  AuditLogDetail	(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
	VALUES(GETDATE(),@UserName,'Container',
		(SELECT ContainerNo FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey),null,'Text',@Comment,@OrderDetailKey)

	set @Output = 1
END
