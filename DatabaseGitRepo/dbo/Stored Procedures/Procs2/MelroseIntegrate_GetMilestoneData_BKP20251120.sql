
CREATE PROCEDURE [dbo].[MelroseIntegrate_GetMilestoneData_BKP20251120] -- MelroseIntegrate_GetMilestoneData  0,'','',0
--MelroseIntegrate_GetMilestoneData  0,'Delivery','A',1
(
	@RouteKey		INT,
	@Datetype		VARCHAR(50),	-- Pickup, Delivery, Empty
	@ScheduleActual	VARCHAR(5),		-- A,S
	@IsDebug		BIT
)

AS

BEGIN
	-- DROP TABLE #Data

	CREATE TABLE #OrderDetailKey
	(
		OrderDetailKey		INT
	)

	IF(ISNULL(@RouteKey,0) = 0)
		BEGIN
			SET @ScheduleActual = ''
			SET @Datetype = ''
		END

	
	DELETE FROM MelroseIntegrate_DCSAProcess_WRK
	WHERE DATEDIFF(MINUTE, CreateDate, GETDATE()) > 5

	SELECT		CustKey, CustName 
	INTO		#Customer
	FROM		Customer WITH (NOLOCK) 
	WHERE		CustKey IN (3307,2102,2103,2681,2104,2994,3405)

	IF(@IsDebug = 1)
		BEGIN
			SELECT '#Customer',* FROM #Customer 
		END

	IF(ISNULL(@RouteKey,0) > 0)
		BEGIN
			INSERT INTO #OrderDetailKey
			SELECT OrderDetailKey FROM Routes WITH (NOLOCK) WHERE RouteKey = @RouteKey
		END
	ELSE
		BEGIN
			INSERT INTO #OrderDetailKey
			SELECT DISTINCT OrderDetailKey FROM Routes WITH (NOLOCK) 
			-- WHERE LastUpdateDate > DATEADD(MINUTE, -60, GETDATE())
			WHERE OrderDetailKey NOT IN (SELECT DISTINCT OrderDetailKey FROM MelroseIntegrate_DCSAProcess_WRK WITH (NOLOCK) ) 
			AND  LastUpdateDate > '2025-11-01'
			--WHERE OrderDetailKey = 274163
		END

	SELECT		OrderDetailKey, RouteKey, LegKey, IsEmpty,SourceAddrKey, DestinationAddrKey,PickupDateTo, PickupDateFrom,ActualDeparture
				, ActualArrival, IsDryRun,DeliveryDateFrom, DeliveryDateTo,EmptySetDate , LegNo, CreateDate
	INTO		#Routes
	FROM		(SELECT * FROM Routes WITH (NOLOCK)  WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKey) ) RT  
	INNER JOIN	(SELECT OrderKey FROM OrderHeader WITH (NOLOCK) 
				WHERE  CustKey IN (SELECT CustKey FROM #Customer)) OH ON RT.OrderKey = OH.OrderKey

	SELECT		DISTINCT OD.OrderDetailKey,RT.RouteKey,  '' AS LocationCode, OD.OrderKey
				, ISNULL(OH.OrderTypeKey,OD.OrderTypeKey)OrderTypeKey ,'' AS LocationType, RT.LegNo,
				RT.IsEmpty,RT.IsDryRun, RT.LegKey, RT.SourceAddrKey, RT.DestinationAddrKey , L.FromLocation, L.ToLocation
				,ISNULL(ISNULL(RT.PickupDateTo, RT.PickupDateFrom), RT.ActualDeparture) AS SchedPickup,
				ActualDeparture AS ActualPickup,
				ISNULL(ISNULL(RT.DeliveryDateTo, RT.DeliveryDateFrom), RT.ActualArrival) AS SchedDelivery,
				RT.ActualArrival AS ActualDelivery, OD.ContainerNo, OH.OrderNo, EmptySetDate EmptyDate
				,RT.CreateDate
	INTO		#Data
	FROM		OrderDetail OD WITH (NOLOCK)   
	INNER JOIN	OrderHeader OH WITH (NOLOCK)   ON OD.OrderKey = OH.OrderKey
	INNER JOIN	#Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
	INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey 
	ORDER BY	OD.OrderDetailKey , LegNo 


	IF(@IsDebug = 1)
		BEGIN
			SELECT 'InitialData', * FROM #Data --  WHERE FromRouteKey  = 851186
		END

	--SELECT * FROM #Data

	SELECT		OrderDetailKey, EmptySetDate
	INTO		#EmptyLegData
	FROM		(SELECT		LD.OrderDetailKey, LD.EmptySetDate,
							ROW_NUMBER() OVER (PARTITION BY LD.OrderDetailKey ORDER BY LD.EmptySetDate DESC) AS rn
				FROM		JCBDB_Live.dbo.EmptyLegData LD WITH (NOLOCK) 
				WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKey)  ) x
	WHERE		rn = 1

	-- SELECT * FROM #Data

	SELECT		DISTINCT *,CAST(EventDate AT TIME ZONE 'Pacific Standard Time' AT TIME ZONE 'UTC' AS DATETIME)  UTCEventDate 
	INTO		#FinalData
	FROM		(SELECT		OrderDetailKey, Routekey,'SF' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,SchedPickup EventDate
							,'S' ScheduleActual,SourceAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo, 'Pickup' AS DateType
				FROM		(SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate) AS SL
							FROM		#Data 
							WHERE		FromLocation = 'Port') A
				WHERE		SL = 1
				UNION ALL
				SELECT		OrderDetailKey, Routekey,'SF' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,ActualPickup  EventDate
							,'A' ScheduleActual,SourceAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo, 'Pickup' AS DateType
				FROM		(SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate) AS SL
							FROM		#Data 
							WHERE		FromLocation = 'Port' ) A
				WHERE		SL = 1
				UNION ALL
				SELECT		OrderDetailKey, Routekey,'ST' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,SchedDelivery  EventDate
							,'S' ScheduleActual,DestinationAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo , 'Delivery' AS DateType
				FROM		(SELECT		*, ROW_NUMBER() OVER ( PARTITION BY OrderDetailkey Order By CreateDate ) AS SL
							FROM		#Data 
							WHERE		ToLocation in ('Consignee','Customer','Shipper')) A
				WHERE		SL = 1
				UNION ALL
				SELECT		OrderDetailKey, Routekey,'ST' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey
							,ActualDelivery  EventDate
							,'A' ScheduleActual,DestinationAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo , 'Delivery' AS DateType
				FROM		(SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate ) AS SL
							FROM		#Data 
							WHERE		ToLocation in ('Consignee','Customer','Shipper')) A
				WHERE		SL = 1
				UNION ALL
				SELECT		OrderDetailKey, Routekey,'ER' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey, EventDate
							,'A' ScheduleActual,DestinationAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo , 'Empty' AS DateType
				FROM		(SELECT		A.*, ISNULL(A.EmptyDate,LD.EmptySetDate) EventDate , ROW_NUMBER() OVER (Order By CreateDate) AS SL
							FROM		#Data  A
							LEFT JOIN	#EmptyLegData LD ON A.OrderDetailKey = LD.OrderDetailKey
							WHERE ToLocation in ('Consignee','Customer','Shipper')) A
				WHERE		EventDate IS NOT NULL
				UNION ALL
				SELECT		OrderDetailKey, Routekey,'EP' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,ActualPickup  EventDate
							,'A' ScheduleActual,SourceAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo  , 'Pickup' AS DateType
				FROM		(SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate) AS SL
							FROM		#Data 
							WHERE		FromLocation in ('Consignee','Customer','Shipper') ) A
				WHERE		SL = 1
				UNION ALL
				SELECT		OrderDetailKey, Routekey,'RT' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,ActualDelivery  EventDate
							,'A' ScheduleActual,DestinationAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo  , 'Delivery' AS DateType
				FROM		(SELECT		*, ROW_NUMBER() OVER ( PARTITION BY OrderDetailkey Order By CreateDate DESC) AS SL
							FROM		#Data 
							WHERE		ToLocation = 'Port' ) A
				WHERE		SL = 1  ) A
	
		-- UPDATE #FinalData SET UTCEventDate = GETDATE()

	IF(@IsDebug = 1)
		BEGIN
			
			SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate) AS SL
							FROM		#Data 
							WHERE		FromLocation in ('Consignee','Customer','Shipper')

			SELECT		'FinalData',*
			FROM		#FinalData FD
			WHERE		(FD.Routekey = @RouteKey OR 0 = @RouteKey) 
						AND (FD.ScheduleActual = @ScheduleActual  OR '' = @ScheduleActual)
						AND ( DateType = @Datetype OR '' = @Datetype)


			SELECT		DISTINCT FD.OrderDetailKey,FD.Routekey,LocationCode StopType, FD.OrderKey,OrderTypeKey,FD.EventDate
						,CASE WHEN FD.ScheduleActual = 'A' THEN 'Actual' ELSE 'Schedule' END ScheduleActual
						,AddrKey
						,FD.ContainerNo, FD.OrderNo , MI.EventDate , UTCEventDate
						,ABS(DATEDIFF(MINUTE, UTCEventDate, MI.EventDate)) AS DiffInMinutes
						,LastUpdateDate
			FROM		#FinalData  FD
			LEFT JOIN	MelroseIntegrate.dbo.vw_IntegrationData_GetRecentTransactions MI WITH (NOLOCK)  ON FD.OrderDetailKey = MI.OrderDetailKey AND FD.ContainerNo = MI.ContainerNo
						AND LocationCode = MI.FacilityCode AND CASE WHEN FD.ScheduleActual = 'A' THEN 'Actual' ELSE 'Schedule' END = MI.ScheduleActual
			WHERE		(FD.Routekey = @RouteKey OR 0 = @RouteKey) 
						AND (FD.ScheduleActual = @ScheduleActual  OR '' = @ScheduleActual)
						AND ( DateType = @Datetype OR '' = @Datetype)
						--AND (ABS(DATEDIFF(MINUTE, UTCEventDate, MI.EventDate)) > 5 OR MI.EventDate IS NULL)
						AND FD.EventDate IS NOT NULL
						-- AND FD.Routekey = 851186
		END

	-- UPDATE #FinalData SET EventDate = GETDATE()


	SELECT		DISTINCT TOP 2 *
	INTO		#FinalProcessData
	FROM		#FinalData FD

	INSERT INTO MelroseIntegrate_DCSAProcess_WRK (OrderDetailkey,CreateDate)
	SELECT		DISTINCT OrderDetailKey, GETDATE() FROM #FinalProcessData
	
	DECLARE		@JsonResult NVARCHAR(MAX) = (
	SELECT		DISTINCT  FD.OrderDetailKey,FD.Routekey,LocationCode StopType, FD.OrderKey,OrderTypeKey,FD.EventDate,FD.ScheduleActual,AddrKey
				,FD.ContainerNo, FD.OrderNo 
	FROM		#FinalProcessData  FD
	LEFT JOIN	MelroseIntegrate.dbo.vw_IntegrationData_GetRecentTransactions MI WITH (NOLOCK)  ON FD.OrderDetailKey = MI.OrderDetailKey AND FD.ContainerNo = MI.ContainerNo
				AND LocationCode = MI.FacilityCode AND CASE WHEN FD.ScheduleActual = 'A' THEN 'Actual' ELSE 'Schedule' END = MI.ScheduleActual
	WHERE		(FD.Routekey = @RouteKey OR 0 = @RouteKey) 
				AND (FD.ScheduleActual = @ScheduleActual  OR '' = @ScheduleActual)
				AND ( DateType = @Datetype OR '' = @Datetype)
				AND (ABS(DATEDIFF(MINUTE, UTCEventDate, MI.EventDate)) > 5 OR MI.EventDate IS NULL)
				AND FD.EventDate IS NOT NULL
	FOR JSON PATH)

	SELECT		@JsonResult AS JsonResult
END
