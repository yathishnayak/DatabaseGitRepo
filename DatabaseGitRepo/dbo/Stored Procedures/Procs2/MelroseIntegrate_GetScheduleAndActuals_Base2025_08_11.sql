/*
DECLARE @OrderKey INT,  @OutputID VARCHAR(50)
SET @OrderKey = 183683
EXEC MelroseIntegrate_GetScheduleAndActuals @OrderKey , @OutputID OUTPUT
SELECT @OutputID

*/


CREATE PRoc [dbo].[MelroseIntegrate_GetScheduleAndActuals_Base2025_08_11] -- MelroseIntegrate_GetScheduleAndActuals 191930 
(
	@OrderKey		int,
	@OutputID		VARCHAR(50) OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	declare @OrderType varchar(20) = '',
			@SiteID	varchar(10) = 'Flexport',
			@Custkey int = 0

	select @OrderType = OT.OrderType, @Custkey = CustKey
	from OrderHeader OH WITH (NOLOCK)
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where OrderKey = @OrderKey

	CREATE TABLE #ProcessData
	(
		OrderDetailkey		INT,
		RouteKey			INT,
		LocationType		VARCHAR(10),
		OrderKey			INT,
		OrderTypeKey		INT,
		FromLocation		VARCHAR(20),
		LegNo				INT,
		IsEmpty				BIT,
		IsDryRun			BIT,
		LegKey				INT,
		EventDate			DATETIME,
		ScheduleActual		VARCHAR(5),
		AddrKey				INT
	)


	INSERT INTO	#ProcessData
	EXEC		MelroseIntegrate_ROUTESDATA @OrderKey
	-- SELECT * FROM #ProcessData
	select * into #TempData from TempPickupDelivery where 1=0

	CREATE TABLE  #MileStonesTobeSent
	(
		LocationType	VARCHAR(20),
		ScheduleActual	VARCHAR(20)
	)

	INSERT INTO #MileStonesTobeSent
	VALUES ('SF','S'),('ST','S'),('SF','A'),('ST','A'),('EP','A'),('ER','A'),('RT','A')

	DELETE		PD
	FROM		#ProcessData PD
	LEFT JOIN	#MileStonesTobeSent MS ON PD.LocationType = MS.LocationType AND PD.ScheduleActual = MS.ScheduleActual
	WHERE		MS.LocationType IS NULL

	-- SELECT * FROm #ProcessData

	ALTER TABLE #TempData
	ADD LocationType VARCHAR(10),
	OrderBy INT, SourceAddrKey INT, DestinationAddrKey INT

	ALTER TABLE #ProcessData
	ADD DeleteRecord BIT

	--SELECT '#ProcessData - Before',*  FROM #ProcessData

	Delete		PD
	FROM		#ProcessData PD
	INNER JOIN	MelroseIntegrate.dbo.Integration_Data ID WITH (NOLOCK) ON PD.OrderKey = ID.OrderKey 
				AND PD.OrderDetailkey = ID.OrderDetailKey AND PD.LocationType = ID.FacilityCode
				AND PD.ScheduleActual = CASE WHEN ID.ScheduleActual = 'Schedule' THEN 'S' ELSE 'A' END
				AND ID.IsSuccess = 1 --  AND PD.EventDate = ID.EventDate

	--SELECT '#ProcessData - After',* FROM #ProcessData
	
	if(@OrderType = 'Import')
	Begin
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum,LocationType, SourceAddrKey, DestinationAddrKey,OrderBy)
		select *, CASE WHEN LocationType = 'EP' THEN 1 WHEN LocationType = 'ER' THEN 2 ELSE 0 END  -- ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) as StopNum
		from (
			select distinct OD.OrderKey, 0 StopKey , RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey,  DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, '' AS SiteID, 'FROM' as StopType,
			isnull(isnull(RT.PickupDateTo, RT.PickupDateFrom),RT.ActualDeparture) as SchedPickup, 
			CASE WHEN LocationType = 'ER' THEN ISNULL(RT.EmptySetDate, ELD.EmptySetDate)  ELSE RT.ActualDeparture END as ActualPickup,
			null as SchedDelivery, null as ActualDelivery, 0 StopNum ,LocationType, RT.SourceAddrKey, RT.DestinationAddrKey
			from #ProcessData DT
			inner join Routes RT WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
			inner join OrderType OT WITH (NOLOCK)  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
			LEFT JOIN	(SELECT * FROM (SELECT OrderDetailKey,EMptySetDate, ROW_NUMBER() OVER (PARTITION BY OrderDetailKey ORDER BY EMptySetDate Desc )SL 
						FROM EmptyLegData  WITH (NOLOCK) ) A
						WHERE Sl = 1) ELD ON OD.OrderDetailKey = ELD.OrderDetailKey
			where  OT.OrderType = 'IMPORT' and isnull(RT.IsDryRun ,0) = 0 and DT.LocationType IN ( 'SF','EP','ER')
			AND DT.ScheduleActual = 'A' -- Only Actual is selected to eleminate duplicate entries
			--and SD.SiteID = @SiteID --and SL.stopNumber = 1
			and OD.Orderkey = @OrderKey 
		) A

		declare @CntImp int = 0
		select @CntImp = count(1) from #TempData
	
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum, LocationType, SourceAddrKey, DestinationAddrKey,OrderBy)
		select *,0 --  @CntImp + ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) AS StopNum
		from (
			select distinct OD.OrderKey, 0 StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, '' SiteID,
			'TO' as StopType, null as SchedPickup, null as ActualPickup,
			isnull(isnull(RT.DeliveryDateTo,RT.DeliveryDateFrom),  RT.ActualArrival) as SchedDelivery, 
			RT.ActualArrival as ActualDelivery, 0 StopNum,LocationType, RT.SourceAddrKey, RT.DestinationAddrKey
			from #ProcessData DT WITH (NOLOCK)
			inner join Routes RT WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
			inner join OrderType OT WITH (NOLOCK)  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
			where OT.OrderType = 'Import' and isnull(RT.IsDryRun ,0) = 0
				and DT.LocationType in ('ST','RT')
				AND DT.ScheduleActual = 'A' -- Only Actual is selected to eleminate duplicate entries
			-- and SD.SiteID = @SiteID --and SL.stopNumber in (2,3)
			and OD.OrderKey = @OrderKey 
		) A
		
	END

	if(@OrderType = 'Export')
	Begin
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum,LocationType, SourceAddrKey, DestinationAddrKey)
		select * --  ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) as StopNum
		from (
			select distinct OD.OrderKey, 0 StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, '' SiteID, 'FROM' as StopType,
			isnull(isnull(RT.PickupDateTo,RT.PickupDateFrom),RT.ActualDeparture) as SchedPickup, 
			RT.ActualDeparture as ActualPickup,
			null as SchedDelivery, null as ActualDelivery, 0 StopNum,LocationType, RT.SourceAddrKey, RT.DestinationAddrKey
			from #ProcessData DT WITH (NOLOCK)
			inner join Routes RT WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
			inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
			where OT.OrderType = 'EXPORT' and isnull(RT.IsDryRun ,0) = 0
			and DT.LocationType IN ( 'SF','EP')
			AND DT.ScheduleActual = 'A' -- Only Actual is selected to eleminate duplicate entries
			-- and SD.SiteID = @SiteID 
			and OD.Orderkey = @OrderKey   
		) A
	
		declare @CntExp int = 0
		select @cntExp = count(1) from #TempData

		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum,LocationType, SourceAddrKey, DestinationAddrKey)
		select * --  @CntExp + ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) AS StopNum
		from (
			select distinct OD.OrderKey, 0 StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, '' SiteID,
			'TO' as StopType,  null as SchedPickup, null as ActualPickup,
			isnull(isnull(RT.DeliveryDateTo,RT.DeliveryDateFrom),RT.ActualArrival) as SchedDelivery, 
			RT.ActualArrival as ActualDelivery , 0 StopNum,LocationType, RT.SourceAddrKey, RT.DestinationAddrKey
			from #ProcessData DT WITH (NOLOCK)
			inner join Routes RT WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
			inner join OrderType OT WITH (NOLOCK)  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
			where OT.OrderType = 'Export' and isnull(RT.IsDryRun ,0) = 0
				and DT.LocationType in ('ST','RT')
				AND DT.ScheduleActual = 'A' -- Only Actual is selected to eleminate duplicate entries
			-- and SD.SiteID = @SiteID --and SL.stopNumber =2
			and OD.OrderKey = @OrderKey  
		) A

	End
	
	-- SELECT * FROM #TempData

	DECLARE @Id VARCHAR(50) = NEWID()

	SET @OutputID = @Id


	-- SELECT '#TempData',* FROM #TempData

	INSERT INTO MelroseIntegrate_SchedulesActuals_WRK
	SELECT		@Id ID, OrderDetailKey, RouteKey,TD.Locationtype,OrderKey,OrderTypeKey,'' Loco, LegNo,IsEmpty, NULL AS IsDryRun, LegKey
				, ISNULL(SchedPickup,SchedDelivery) AS EventDate,'S' AS ScheduleActual
				, CASE WHEN StopType = 'From' THEN SourceAddrKey ELSE DestinationAddrKey END  AS AddrKey
	-- INTO		MelroseIntegrate_SchedulesActuals_WRK
	FROM		#TempData TD
	INNER JOIn	(SELECT LocationType, ScheduleActual FROM #ProcessData)  PD ON TD.Locationtype = PD.LocationType
	WHERE		(SchedPickup IS NOT NULL OR SchedDelivery IS NOT NULL) AND TD.Locationtype IN ('SF','ST') AND PD.ScheduleActual = 'S'

	INSERT INTO MelroseIntegrate_SchedulesActuals_WRK
	SELECT		@Id ID,OrderDetailKey, RouteKey,Locationtype,OrderKey,OrderTypeKey,'', LegNo,IsEmpty, NULL AS IsDryRun, LegKey
				, ISNULL(ActualPickup,ActualDelivery) AS EventDate,'A' AS ScheduleActual
				, CASE WHEN StopType = 'From' THEN SourceAddrKey ELSE DestinationAddrKey END  AS AddrKey
	FROM		#TempData
	WHERE		ActualPickup IS NOT NULL OR ActualDelivery IS NOT NULL
	-- select *, ROW_NUMBER() OVER (PARTITION BY OrderDetailKey ORDER BY LegNo, OrderBy )  StopNum from #TempData
	
	--SELECT top 1 OH.OrderKey, TH.DataKey, Th.SiteID, TMS_OrderKey, WorkOrdernumber, WorKOrderDate, OH.status,
	--		ContainerData = ( select OD.OrderDetailKey, TC.ContainerKey, OD.ContainerNo, OD.status,
	--		STOPDATA = (
	--			SELECT  RouteKey, LegKey, StopKey, TMS_LegKey, TMS_RouteKey,
	--				SchedPickup, SchedDelivery, ActualPickup, ActualDelivery, ROW_NUMBER() OVER (PARTITION BY OrderDetailKey ORDER BY LegNo, OrderBy ) StopNum
	--			FROM #TempData A
	--			FOR JSON PATH
	--			)
	--			from TMS_integration_Container TC WITH (NOLOCK)
	--			inner join OrderDetail OD WITH (NOLOCK) on TC.TMS_OrderDetailKey = OD.orderDetailKey 
	--			where TC.DataKey = TH.DataKey and TC.SiteID = TH.SiteID
	--			FOR JSON PATH
	--		)
	--FROM OrderHeader OH WITH (NOLOCK)
	--inner join OrderDetail OD WITH (NOLOCK) on Oh.OrderKey = OD.OrderKey
	--inner join TMS_Integration_Header TH WITH (NOLOCK) on OH.OrderKey = TH.TMS_OrderKey 
	--inner join TMS_Integration_Container TC WITH (NOLOCK) on TH.DataKey = TC.DataKey and TH.SiteID = Tc.SiteID and TC.TMS_OrderDetailKey = OD.OrderDetailKey
	--WHERE OH.OrderKey = @OrderKey and TH.SiteID = @SiteID
	--FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	-- SELECT * FROm MelroseIntegrate_SchedulesActuals_WRK WHERE ID = @Id

	DROP TABLE #ProcessData
	DROp TABLE #TempData

END
