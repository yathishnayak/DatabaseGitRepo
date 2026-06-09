



CREATE VIEW [dbo].[vw_MelroseIntegrate_RouteEventData]
--  SELECT * FROM vw_MelroseIntegrate_RouteEventData WHERE OrderDetailKey = 267782
AS


WITH InitialData AS (
SELECT		DISTINCT OD.OrderDetailKey,RT.RouteKey,  '' AS LocationCode, OD.OrderKey
			, ISNULL(OH.OrderTypeKey,OD.OrderTypeKey)OrderTypeKey ,'' AS LocationType, RT.LegNo,
			RT.IsEmpty,RT.IsDryRun, RT.LegKey, RT.SourceAddrKey, RT.DestinationAddrKey , L.FromLocation, L.ToLocation
			,ISNULL(ISNULL(RT.PickupDateTo, RT.PickupDateFrom), RT.ActualDeparture) AS SchedPickup,
			ActualDeparture AS ActualPickup,
			ISNULL(ISNULL(RT.DeliveryDateTo, RT.DeliveryDateFrom), RT.ActualArrival) AS SchedDelivery,
			RT.ActualArrival AS ActualDelivery, OD.ContainerNo, OH.OrderNo, EmptySetDate EmptyDate
			,RT.CreateDate, RT.LastUpdateDate, OH.CustKey  
FROM		OrderDetail OD WITH (NOLOCK)   
INNER JOIN	OrderHeader OH WITH (NOLOCK)   ON OD.OrderKey = OH.OrderKey
INNER JOIN	Routes RT WITH (NOLOCK)   ON OD.OrderDetailKey = RT.OrderDetailKey
INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey 
WHERE		ISNULL(RT.IsDryRun,0) = 0
-- WHERE		OD.OrderDetailKey = 267782
),

EmptyLegData AS (
SELECT		OrderDetailKey, EmptySetDate
FROM		(SELECT		LD.OrderDetailKey, LD.EmptySetDate,
						ROW_NUMBER() OVER (PARTITION BY LD.OrderDetailKey ORDER BY LD.EmptySetDate DESC) AS rn
			FROM		JCBDB_Live.dbo.EmptyLegData LD WITH (NOLOCK) 
			) x
WHERE		rn = 1
),
EventDetails AS (
SELECT		'SF' StopType, 1 OrderBy
UNION ALL
SELECT		'ST' StopType, 2 OrderBy
UNION ALL
SELECT		'ER' StopType, 3 OrderBy
UNION ALL
SELECT		'EP' StopType, 4 OrderBy
UNION ALL
SELECT		'RT' StopType, 5 OrderBy
)


SELECT		DISTINCT A.*,CAST(EventDate AT TIME ZONE 'Pacific Standard Time' AT TIME ZONE 'UTC' AS DATETIME)  UTCEventDate 
			, ED.OrderBy 
FROM		(SELECT		OrderDetailKey, Routekey,'SF' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,SchedPickup EventDate
						,'S' ScheduleActual,SourceAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo, 'Pickup' AS DateType, LastUpdateDate, CustKey
			FROM		(SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate) AS SL 
						FROM		InitialData 
						WHERE		FromLocation = 'Port') A
			WHERE		SL = 1
			UNION ALL
			SELECT		OrderDetailKey, Routekey,'SF' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,ActualPickup  EventDate
						,'A' ScheduleActual,SourceAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo, 'Pickup' AS DateType, LastUpdateDate, CustKey
			FROM		(SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate) AS SL
						FROM		InitialData 
						WHERE		FromLocation = 'Port' ) A
			WHERE		SL = 1
			UNION ALL
			SELECT		OrderDetailKey, Routekey,'ST' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,SchedDelivery  EventDate
						,'S' ScheduleActual,DestinationAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo , 'Delivery' AS DateType, LastUpdateDate, CustKey
			FROM		(SELECT		*, ROW_NUMBER() OVER ( PARTITION BY OrderDetailkey Order By CreateDate ) AS SL
						FROM		InitialData 
						WHERE		ToLocation in ('Consignee','Customer','Shipper')) A
			WHERE		SL = 1
			UNION ALL
			SELECT		OrderDetailKey, Routekey,'ST' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey
						,ActualDelivery  EventDate
						,'A' ScheduleActual,DestinationAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo , 'Delivery' AS DateType , LastUpdateDate, CustKey
			FROM		(SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate ) AS SL
						FROM		InitialData 
						WHERE		ToLocation in ('Consignee','Customer','Shipper')) A
			WHERE		SL = 1
			UNION ALL
			SELECT		OrderDetailKey, Routekey,'ER' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey, EventDate
						,'A' ScheduleActual,DestinationAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo , 'Empty' AS DateType, LastUpdateDate, CustKey
			FROM		(SELECT		A.*, ISNULL(A.EmptyDate,LD.EmptySetDate) EventDate , ROW_NUMBER() OVER (Order By CreateDate) AS SL 
						FROM		InitialData  A
						LEFT JOIN	EmptyLegData LD ON A.OrderDetailKey = LD.OrderDetailKey
						WHERE ToLocation in ('Consignee','Customer','Shipper')) A
			WHERE		EventDate IS NOT NULL
			UNION ALL
			SELECT		OrderDetailKey, Routekey,'EP' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,ActualPickup  EventDate
						,'A' ScheduleActual,SourceAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo  , 'Pickup' AS DateType, LastUpdateDate, CustKey
			FROM		(SELECT		*, ROW_NUMBER() OVER (PARTITION BY OrderDetailkey Order By CreateDate) AS SL 
						FROM		InitialData 
						WHERE		FromLocation in ('Consignee','Customer','Shipper') ) A
			WHERE		SL = 1
			UNION ALL
			SELECT		OrderDetailKey, Routekey,'RT' LocationCode,OrderKey,OrderTypeKey,LocationType,LegNo, IsEmpty,IsDryRun,LegKey,ActualDelivery  EventDate
						,'A' ScheduleActual,DestinationAddrKey AddrKey, 0 RefDataKey, ContainerNo, OrderNo  , 'Delivery' AS DateType, LastUpdateDate, CustKey
			FROM		(SELECT		*, ROW_NUMBER() OVER ( PARTITION BY OrderDetailkey Order By CreateDate DESC) AS SL
						FROM		InitialData 
						WHERE		ToLocation = 'Port' ) A
			WHERE		SL = 1  ) A
INNER JOIN	EventDetails ED ON A.LocationCode = ED.StopType 

