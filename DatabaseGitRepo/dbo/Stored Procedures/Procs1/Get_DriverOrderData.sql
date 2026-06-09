--exec [Get_DriverOrderData] 5


CREATE PROCEDURE [dbo].[Get_DriverOrderData]
@DriverKey INT =9
AS
BEGIN
set nocount on
set fmtonly off

	select distinct OrderDetailKey
	into #liveRoutes
	from Routes R
	--inner join DriverRouteAcceptance DRA on R.RouteKey = DRA.RouteKey and R.DriverKey = DRA.DriverKey
	where R.DriverKey = @DriverKey 
	--and DRA.Description = 'Accept' 
	and ActualDeparture is not null and ActualArrival is null and IsAbandoned = 0

	SELECT	--'ORDER: ' +
		OH.OrderNo as OrderNo,
			upper(T.LegTypeID) as LegTypeID ,PickupDateFrom AS ScheduledPickDateFrom,PickupDateTo AS ScheduledPickDateTo,
			DeliveryDateFrom AS ScheduledDeliveryDateFrom,DeliveryDateTo AS ScheduledDeliveryDateTo,
			1 as IsStarted, --CASE WHEN DO.StartDate IS NOT NULL THEN 1 ELSE 0 END AS IsStarted,
			1 as IsCompleted, --CASE WHEN DO.CompleteDate IS NOT NULL THEN 1 ELSE 0 END AS IsCompleted,
			OD.OrderKey,OD.OrderDetailKey,RT.RouteKey ,
			isnull(AF.AddrName,'') + ', ' + isnull(AF.Address1,'') + ', ' + isnull(AF.Address2,'') 
				+', '+ isnull(AF.city,'') + '-' + isnull(AF.ZipCode,'') + ', '+ isnull(AF.state,'') as FromLocation,
			isnull(AD.AddrName,'') + ', ' + isnull(AD.Address1,'') + ', ' + isnull(AD.Address2,'') 
				+', '+ isnull(AD.city,'') + '-' + isnull(AD.ZipCode,'') + ', '+ isnull(AD.state,'') as ToLocation,
			--'CONTAINER: ' + 
			left(upper(OD.ContainerNo),4) + '-' + substring(upper(OD.ContainerNo),4,6) + '-' + right(upper(OD.ContainerNo),1) as ContainerNo, OD.IsHazardus, RTS.Description as Status,
			RT.DriverKey
			INTO #DriverOrder 
	FROM dbo.Routes RT
		INNER JOIN dbo.OrderDetail OD	ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN Dbo.OrderHeader OH	ON OD.OrderKey=OH.OrderKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.Status=RT.Status				
		INNER JOIN dbo.Leg L			ON L.LegKey=RT.LegKey
		INNER JOIN dbo.LegType T		ON T.LegtypeKey=L.LegTypeKey
		LEFT JOIN dbo.DriverOrder DO	ON DO.OrderKey=OD.OrderDetailKey
		LEft join dbo.Address AF on RT.SourceAddrKey = AF.AddrKey
		Left Join dbo.Address AD on RT.DestinationAddrKey = AD.AddrKey
	WHERE RT.DriverKey=@DriverKey  -- AND RTS.Description <> 'Leg Completed' 

	SELECT OrderKey,OrderDetailKey,RouteKey,ScheduledPickDateFrom,
		ROW_NUMBER() OVER ( PARTITION BY OrderDetailKey ORDER BY ScheduledPickDateFrom ) AS FirstPickup INTO #FirstRoute
	FROM #DriverOrder
	

	SELECT OrderNo, LegTypeID as LegID,ScheduledPickDateFrom,ScheduledPickDateTo,
		ScheduledDeliveryDateFrom,ScheduledDeliveryDateTo,IsStarted,IsCompleted,
		OrderKey, A.OrderDetailKey, FromLocation,ToLocation , ContainerNo, IsHazardus, Status, 
		case when  isnull(B.OrderDetailKey,0) = 0 then 0 else 1 end as IsLive
	FROM #DriverOrder A
	Left join #liveRoutes B on A.OrderDetailKey = B.OrderDetailKey
	WHERE ROUTEKey IN ( SELECT RouteKey FROM #FirstRoute WHERE FirstPickup=1e ) --and DriverKey = @DriverKey
	order by OrderKey desc

END
