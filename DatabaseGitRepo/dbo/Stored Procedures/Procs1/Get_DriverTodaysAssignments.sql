



CREATE PROC [dbo].[Get_DriverTodaysAssignments] -- Get_DriverTodaysAssignments 5, '2021/03/10',1
(
	@DriverKey int = 5,
	@TodaysDate date = '2021-04-05',
	@MyAssignments bit = 0
)
AS 
BEGIN

	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT distinct OD.ContainerNo,
		--L.LegNo, 
		L.[LegID],RT.PickupDateFrom ,RT.SwitchTo,
		RT.DeliveryDateFrom ,ISNULL(Sour.AddrName,'') AS FromLocation,ISNULL(Dest.AddrName,'') AS ToLocation,	
		ISNULL(DR.DriverID,'') + ': ' + ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,RT.ChassisNo,RT.ChassisType,
		CASE WHEN ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualDeparture END AS ActualPickup,
		CASE WHEN ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualArrival END AS  ActualDelDate,
		DR.DriverKey, RT.RouteKey,OD.OrderDetailKey,OD.OrderKey, RTS.[Description] AS StatusName, 
		RT.[Status] AS StatusKey, OD.ConfirmationNo , RT.ChassisKey,
					CASE WHEN DO.DriverStartDate IS NOT NULL THEN 1 ELSE 0 END AS IsStarted,
			CASE WHEN DO.DriverCompleteDate IS NOT NULL THEN 1 ELSE 0 END AS IsCompleted,
		RT.PickupDateFrom AS ScheduledPickupDate,	RT.PickupDateTo AS ScheduledPickupDateTo,
		RT.DeliveryDateFrom AS ScheduledDeliveryDate,RT.DeliveryDateTo AS ScheduledDeliveryDateTo, CH.chassisNo as ChassisID,
--		CASE WHEN ISNULL(RT.driverKey ,0) > 0 AND ISNULL(RT.ChassisNo,'') <> '' AND ISNULL(RT.chassistype,'') <> '' AND 
--				ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' and
--				ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
--			then 1 else 0 end as ReadyToMarkComplete,
		Case when dbo.FN_IsRouteComplete(RT.RouteKey) = 1 then 1 else 0 end as ReadyToMarkComplete,
		Sour.AddrKey as FromLocationKey, Dest.AddrKey as ToLocationKey, L.LegKey,
		Sour.AddrName AS SR_AddrName,Sour.Address1 AS SR_Address1,Sour.City AS SR_City,Sour.[State] AS SR_State,Sour.ZipCode AS SR_ZipCode,Sour.Country AS SR_Country,
		Dest.AddrName AS DR_AddrName,Dest.Address1 AS DR_Address1,Dest.City AS DR_City,Dest.[State] AS DR_State,Dest.ZipCode AS DR_ZipCode,Dest.Country AS DR_Country,
		YL.FromLocation as LegFromLocationType, L.ToLocation as LegToLocationType , 
		YL.YardLocationKey, YL.YardLocationName, YL.SourceYardID, YL.DestinationYardID,
		RT.IsEmpty,RT.IsAbandoned,DRA.[Description] AS RouteStatus,SWFrom.ToRouteKey AS SWT_RouteKey
		,SWRTo.LegKey AS SWT_LegKey,SWRTo.OrderDetailKey AS SWT_OrderDetailKey,SWRTo.ContainerNo AS SWT_ContainerNo
		, SWRTo.LegKey as SWR_LegKey, SWRTo.LegID as SWR_LegID, SWRTo.LegNo as SWR_LegNo
		--From Route Detail
		,SWRFROM.RouteKey AS SWTFrom_RouteKey
		,SWRFROM.LegKey AS SWTFrom_LegKey,SWRFROM.OrderDetailKey AS SWTFrom_OrderDetailKey,SWRFROM.ContainerNo AS SWTFrom_ContainerNo
		, SWRFROM.LegKey AS SWRFrom_LegKey, SWRFROM.LegID AS SWRFrom_LegID, SWRFROM.LegNo as SWRFrom_LegNo
		, RT.Status
		into #Data
		FROM OrderDetail OD 
		INNER JOIN  dbo.[Routes] RT		ON RT.OrderDetailKey=OD.OrderDetailKey --and RT.DriverKey = @DriverKey
		INNER JOIN  dbo.Leg L			ON RT.LegKey=L.LegKey
		INNER JOIN  dbo.LegType LT		ON LT.LegtypeKey=L.LegTypeKey
		INNER JOIN  dbo.RouteStatus RTS ON RTS.[Status]=RT.[Status]	
		LEFT JOIN   dbo.[Address] Sour	ON Sour.Addrkey=RT.SourceAddrkey
		LEFT JOIN   dbo.[Address] Dest	ON Dest.Addrkey=RT.DestinationAddrkey
		LEFT JOIN   dbo.Driver DR		ON DR.DriverKey=RT.DriverKey
		LEFT JOIN   dbo.Chassis CH		ON CH.chassisKey=RT.ChassisKey	
		LEFT JOIN  dbo.OrderDetailStatus ODS ON ODS.[Status]=OD.[Status]	
		LEFT JOIN dbo.DriverRoute DO ON DO.RouteKey=RT.RouteKey 
		LEft JOIN  DBO.RouteYardLink YL		 ON RT.RouteKey = YL.RouteKey
		LEFT JOIN dbo.DriverRouteAcceptance DRA ON DRA.RouteKey=RT.RouteKey
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

		select distinct RT.Routekey, 
		CAST(ROW_number () OVER (partition by RT.OrderdetailKey ORDER BY RT.RouteKey) AS SMALLINT ) as LegNo
		into #LegNos
		from routes RT
		inner join #Data A on RT.RouteKey = A.RouteKey 

		select distinct A.OrderDetailKey, count(1) as LegCount
		into #LegCount
		from #Data A
		group by A.OrderDetailKey

	if @MyAssignments = 0
	BEGIN
	Select distinct A.*, B.LegCount as TotLegs, C.LegNo, 
		convert(varchar, C.LegNo) + ' of ' + convert(varchar,B.LegCount) as LegStep
	from #Data A
	Left join #LegCount B on A.OrderDetailKey = B.OrderDetailKey
	Left join #LegNos C on a.RouteKey = C.RouteKey
	WHERE A.DriverKey = @DriverKey and 
		(convert(varchar, A.ScheduledPickupDate,101) = convert(varchar, @TodaysDate, 101) 
		OR convert(varchar, A.ScheduledPickupDateTo, 101) = convert(varchar, @TodaysDate, 101) 
		or @TodaysDate  between A.ScheduledPickupDate and A.ScheduledPickupDateTo
		)
		and A.Status in (2, 4)
		order by A.ScheduledPickupDate
	END
	ELSE
	BEGIN
		Select distinct A.*, B.LegCount as TotLegs, C.LegNo, 
		convert(varchar, C.LegNo) + ' of ' + convert(varchar,B.LegCount) as LegStep
	from #Data A
	Left join #LegCount B on A.OrderDetailKey = B.OrderDetailKey
	Left join #LegNos C on a.RouteKey = C.RouteKey
	WHERE A.DriverKey = @DriverKey  
		and A.Status in (2, 4)
	order by A.ScheduledPickupDate
	END

END
