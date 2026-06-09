CREATE PROCEDURE [dbo].[Update_RouteIsBobtail]
@RouteKey	INT,
@IsBobtail	BIT,
@UserKey	INT,
@OutPut		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @USerName varchar(100),
	        @CommentKey int,
			@Comment varchar(500),
			@OrderDetailKey INT=0

			select @USerName = ISNULL(UserName,'') from [User] where UserKey = @UserKey

	SET @OutPut=0;
	SET @OrderDetailKey =(SELECT TOP 1 OrderDetailKey FROM [Routes] WHERE RouteKey=@RouteKey)

	if(isnull(@UserKey,0) = 0)
	begin
		set @Output = 0
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
		from OrderDetailStops ODS
		inner join Routes RT on ODS.ToRouteKey = RT.RouteKey
		inner join LEg L on RT.legkey = L.legkey
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
		from OrderDetailStops ODS
		inner join Routes RT on ODS.ToRouteKey = RT.RouteKey
		inner join LEg L on RT.legkey = L.legkey
		where Rt.RouteKey = @RouteKey 

		set @Comment = 'Container Leg UnChecked Bobtail by ' + @USerName + ' on ' + convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108);
	End
	
	INSERT INTO  AuditLogDetail	(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
	VALUES(GETDATE(),@UserName,'Container',
		(SELECT ContainerNo FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey),null,'Text',@Comment,@OrderDetailKey)

	SET @OutPut=1;

END;
