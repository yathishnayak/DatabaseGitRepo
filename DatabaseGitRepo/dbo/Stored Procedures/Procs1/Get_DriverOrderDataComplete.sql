
create PROCEDURE [dbo].[Get_DriverOrderDataComplete] -- [Get_DriverOrderDataComplete] 08
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
		case when  isnull(B.OrderDetailKey,0) = 0 then 0 else 1 end as IsLive,
		LegData = (
			SELECT	ROW_Number() OVER (Partition by RT.OrderKey  ORDER BY RT.RouteKey) AS LegNo  ,L.LegID,
				PickupDateFrom AS ScheduledPickDateFrom,PickupDateTo AS ScheduledPickDateTo,
				DeliveryDateFrom AS ScheduledDeliveryDateFrom,DeliveryDateTo AS ScheduledDeliveryDateTo,
				CASE WHEN isnull(RT.IsAbandoned,0) = 0 THEN ( 
					CASE WHEN RT.ActualDeparture IS NOT NULL THEN 1 ELSE 0 END
					) ELSE 1 END AS IsStarted,
				CASE WHEN isnull(RT.IsAbandoned,0) = 0 THEN (
					CASE WHEN RT.ActualArrival IS NOT NULL THEN 1 ELSE 0 END 
					) ELSE 1 END AS IsCompleted,
				OD.OrderDetailKey,RT.RouteKey,RT.LegKey,RT.OrderKey,
				isnull(AF.AddrName,'') + ', ' + isnull(AF.Address1,'') + ', ' + isnull(AF.Address2,'') 
					+', '+ isnull(AF.city,'') + '-' + isnull(AF.ZipCode,'') + ', '+ isnull(AF.state,'') as FromLocation,
				isnull(AD.AddrName,'') + ', ' + isnull(AD.Address1,'') + ', ' + isnull(AD.Address2,'') 
					+', '+ isnull(AD.city,'') + '-' + isnull(AD.ZipCode,'') + ', '+ isnull(AD.state,'') as ToLocation
					,
					YL.SourceYardID, YL.DestinationYardID,
			RT.IsEmpty,RT.IsAbandoned,DRA.[Description] AS RouteStatus,SWFrom.ToRouteKey AS SWT_RouteKey
			,SWRTo.LegKey AS SWT_LegKey,SWRTo.OrderDetailKey AS SWT_OrderDetailKey,SWRTo.ContainerNo AS SWT_ContainerNo
			, SWRTo.LegKey as SWR_LegKey, SWRTo.LegID as SWR_LegID, SWRTo.LegNo as SWR_LegNo
			--From Route Detail
			,SWRFROM.RouteKey AS SWTFrom_RouteKey
			,SWRFROM.LegKey AS SWTFrom_LegKey,SWRFROM.OrderDetailKey AS SWTFrom_OrderDetailKey,SWRFROM.ContainerNo AS SWTFrom_ContainerNo
			, SWRFROM.LegKey AS SWRFrom_LegKey, SWRFROM.LegID AS SWRFrom_LegID, SWRFROM.LegNo as SWRFrom_LegNo,
			left(upper(OD.ContainerNo),4) + '-' + substring(upper(OD.ContainerNo),5,7) + '-' + right(upper(OD.ContainerNo),1) as ContainerNo,		--L.LegNo,
			RTS.Description as LegStatus, RT.DriverKey,
			convert(varchar, RT.LegNo) + ' of ' + convert(varchar, OD.TotalLegs) as LegStep, 
				isnull(OD.TotalLegs,0) as TotLegs
		FROM dbo.Routes RT 
			INNER JOIN dbo.OrderDetail OD	ON RT.OrderDetailKey=OD.OrderDetailKey
			INNER JOIN Dbo.OrderHeader OH	ON OD.OrderKey=OH.OrderKey
			INNER JOIN dbo.RouteStatus RTS	ON RTS.Status=RT.Status
			INNER JOIN dbo.Leg L ON L.LegKey=RT.LegKey
			LEFT JOIN dbo.DriverRoute DO ON DO.RouteKey=RT.RouteKey 
			LEft join dbo.Address AF on RT.SourceAddrKey = AF.AddrKey
			Left Join dbo.Address AD on RT.DestinationAddrKey = AD.AddrKey
			LEft JOIN  DBO.RouteYardLink YL		 ON RT.RouteKey = YL.RouteKey
			LEFT JOIN dbo.DriverRouteAcceptance DRA ON DRA.RouteKey=RT.RouteKey --and RT.DriverKey = DRA.DriverKey
			LEFT JOIN Routeswitch SWFrom ON SWFrom.FromRouteKey=RT.RouteKey
			LEFT JOIN Routeswitch SWTo ON SWTo.ToRouteKey=RT.RouteKey
			LEFT JOIN ( SELECT RT.LegKey,RT.RouteKey ,OD.OrderDetailKey,OD.ContainerNo
								, OH.OrderNo, L.LegID, L.LegNo
						FROM dbo.Routes RT 
							INNER JOIN dbo.Routeswitch SWC ON SWC.ToRouteKey=RT.RouteKey
							INNER JOIN dbo.OrderDetail OD  ON OD.OrderDetailKey=RT.OrderDetailKey
							INNER JOIN dbo.OrderHeader OH  ON OH.OrderKey=OD.OrderKey
							LEFT JOIN dbo.Leg L			   ON RT.LegKey = L.LegKey
					 )SWRTo ON SWRTo.RouteKey=SWFrom.ToRouteKey
			LEFT JOIN ( SELECT RT.LegKey,RT.RouteKey ,OD.OrderDetailKey,OD.ContainerNo
								, OH.OrderNo, L.LegID, L.LegNo
						FROM dbo.Routes RT 
							--INNER JOIN dbo.Routeswitch SWC ON SWC.FromRouteKey=RT.RouteKey
							INNER JOIN dbo.OrderDetail OD  ON OD.OrderDetailKey=RT.OrderDetailKey
							INNER JOIN dbo.OrderHeader OH  ON OH.OrderKey=OD.OrderKey
							LEFT JOIN dbo.Leg L			   ON RT.LegKey = L.LegKey
					 )SWRFROM ON SWRFROM.RouteKey=SWTo.FromRouteKey
		WHERE RT.OrderDetailKey = A.OrderDetailKey AND RT.DriverKey IS NOT NULL AND RTS.Description<>'Completed'
		FOR JSON PATH
		)
	FROM #DriverOrder A
	Left join #liveRoutes B on A.OrderDetailKey = B.OrderDetailKey
	WHERE ROUTEKey IN ( SELECT RouteKey FROM #FirstRoute WHERE FirstPickup=1e ) --and DriverKey = @DriverKey
	order by OrderKey desc
	FOR JSON PATH

	
END
