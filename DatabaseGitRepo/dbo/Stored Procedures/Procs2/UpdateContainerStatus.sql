

CREATE proc [dbo].[UpdateContainerStatus] -- UpdateContainerStatus 44904
(
	@OrderDetailKey	int 
)
as
Begin
	set nocount on
	set fmtonly off

	DECLARE @RouteCompletedStatus	int = 0

	select @RouteCompletedStatus = Status
		from RouteStatus with (nolock)
		where Description = 'Leg Completed'

	update RT set LegNo = A.newLegNo
	from Routes RT 
	inner join (
	select  orderdetailkey, routekey, legno, ROW_NUMBER() over(partition by orderdetailkey order by legno) as newLegNo 
	from routes RT
	where orderdetailkey = @OrderDetailKey
	) A on rt.OrderDetailKey = a.OrderDetailKey and rt.RouteKey = a.RouteKey
	where A.legno <> newLegNo 


	SELECT OD.OrderDetailKey,LegNo,RT.RouteKey,DriverKey, RT.Status 
			INTO #OrderStautsbyLeg
			FROM orderdetail OD WITH (NOLOCK)
			inner join Routes RT  WITH (NOLOCK) on OD.OrderDetailKey = Rt.OrderDetailKey
			where OD.OrderDetailKey = @OrderDetailKey
			ORDER BY OrderDetailKey,LegNo


	
	--select * from #OrderStautsbyLeg
	
	declare @StatusCount smallint = 0, 
			@StatusKey smallint,
			@CurrentRouteKey	int = 0,
			@totalLegs	smallint = 0,
			@currentLegNo	smallint ,
			@OpenLegs	smallint

	select @totalLegs = count(routekey) from #OrderStautsbyLeg
	select @currentLegNo = min(legno) from #OrderStautsbyLeg where status <> @RouteCompletedStatus
	select @OpenLegs = count(1) from #OrderStautsbyLeg where status <> @RouteCompletedStatus
	select @StatusCount = count(distinct Status) 
			from #OrderStautsbyLeg

	if(@StatusCount = 1  )
	begin
		print '1'
		select top 1 @StatusKey = status from #OrderStautsbyLeg
		if(@StatusKey = @RouteCompletedStatus)
		begin
			print '1A'
			select @CurrentRouteKey = max(routekey) from #OrderStautsbyLeg
			update orderdetail set 
				ContainerStatusKey = @StatusKey, 
				CurrentRouteKey = @CurrentRouteKey,
				TotalLegs = @totalLegs,
				CurrentLegNo = case when isnull(@OpenLegs,0) = 0 then null else @currentLegNo end,
				openLegs = @OpenLegs
			where OrderDetailKey = @OrderDetailKey
		end
		else
		begin
			print '1B'
			select @CurrentRouteKey = min(routekey) from #OrderStautsbyLeg
			update orderdetail set 
				ContainerStatusKey = @StatusKey, 
				CurrentRouteKey = @CurrentRouteKey ,
				TotalLegs = @totalLegs,
				CurrentLegNo = case when isnull(@OpenLegs,0) = 0 then null else @currentLegNo end,
				openLegs = @OpenLegs
			where OrderDetailKey = @OrderDetailKey
		end
	end
	else if (@StatusCount > 1)
	begin
		print '2'
		select  @CurrentRouteKey = min(routekey) 
		from #OrderStautsbyLeg
		where status <> @RouteCompletedStatus

		select @StatusKey = Status from #OrderStautsbyLeg where RouteKey = @CurrentRouteKey
		update orderdetail set 
			ContainerStatusKey = @StatusKey, 
			CurrentRouteKey = @CurrentRouteKey ,
			TotalLegs = @totalLegs,
			CurrentLegNo = case when isnull(@OpenLegs,0) = 0 then null else @currentLegNo end,
				openLegs = @OpenLegs
		where OrderDetailKey = @OrderDetailKey
	end
End
