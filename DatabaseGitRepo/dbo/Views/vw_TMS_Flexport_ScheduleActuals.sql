



/*
SELECT *
FROM dbo.vw_TMS_Flexport_ScheduleActuals
WHERE OrderKey = 158335 
  AND DataKey = 62558
FOR JSON PATH, ROOT('ContainerData');
*/

CREATE VIEW [dbo].[vw_TMS_Flexport_ScheduleActuals] -- SELECT * FROM vw_TMS_Flexport_ScheduleActuals WHERE Orderkey = 158335 AND Datakey = 62558

AS
WITH LocationTypeMap AS (
    SELECT 'SF' AS LocationType, 1 AS StopNO UNION ALL
    SELECT 'ST', 2 UNION ALL
    SELECT 'ER', 4 UNION ALL
    SELECT 'EP', 3 UNION ALL
    SELECT 'RT', 5
),
LatestEmptyLeg AS (
    SELECT OrderDetailKey, EmptySetDate
    FROM (
        SELECT OrderDetailKey, EmptySetDate,
               ROW_NUMBER() OVER (PARTITION BY OrderDetailKey ORDER BY EmptySetDate DESC) AS rn
        FROM JCBDB_Live.dbo.EmptyLegData
    ) x
    WHERE rn = 1
),
AllStops AS (
    SELECT		DISTINCT
				OD.OrderKey,TR.StopKey,RT.OrderDetailKey,DT.RouteKey AS TMS_RouteKey,RT.RouteKey AS RouteKey,
				OH.OrderTypeKey,OT.OrderType,L.FromLocation,RT.LegKey AS TMS_LegKey,L.ToLocation,
				RT.LegNo,RT.IsEmpty,RT.LegKey,SD.SiteID,
				CASE WHEN DT.LocationType IN ('SF','EP','ER') THEN 'FROM' ELSE 'TO' END AS StopType,
				ISNULL(ISNULL(RT.PickupDateTo, RT.PickupDateFrom), RT.ActualDeparture) AS SchedPickup,
				ActualDeparture AS ActualPickup,
				ISNULL(ISNULL(RT.DeliveryDateTo, RT.DeliveryDateFrom), RT.ActualArrival) AS SchedDelivery,
				RT.ActualArrival AS ActualDelivery,
				DT.LocationType,RT.EmptySetDate RouteEmptyDate, LEL.EmptySetDate TableEmptyDate,
				TR.DataKey, RT.CreateDate AS RouteCreatedDate
    FROM		TKT_RouteDataNew DT WITH(NOLOCK)
    INNER JOIN	Routes RT	WITH(NOLOCK)					ON DT.RouteKey = RT.RouteKey
    INNER JOIN	OrderDetail OD	WITH(NOLOCK)				ON RT.OrderDetailKey = OD.OrderDetailKey
    INNER JOIN	TKT_SyncData SD	 WITH(NOLOCK)				ON OD.OrderDetailKey = SD.TMS_OrderDetailKey
    INNER JOIN	OrderHeader OH WITH(NOLOCK)					ON SD.TMS_OrderKey = OH.OrderKey
    INNER JOIN	OrderType OT WITH(NOLOCK)					ON OH.OrderTypeKey = OT.OrderTypeKey
    INNER JOIN	Leg L	 WITH(NOLOCK)						ON RT.LegKey = L.LegKey
    INNER JOIN	TMS_Integration_Routes TR WITH(NOLOCK)		ON SD.TKT_DataKey = TR.DataKey
															AND TR.SiteID = 'Flexport'
															AND TR.TMS_RouteKey = RT.RouteKey
    INNER JOIN	integration_jcb.dbo.Flexpro_StopList SL	ON TR.StopKey = SL.StopKey
															AND DT.LocationType = SL.facilityCode
    LEFT JOIN	LatestEmptyLeg LEL						ON OD.OrderDetailKey = LEL.OrderDetailKey
    WHERE		OT.OrderType IN ('IMPORT', 'EXPORT')
				AND ISNULL(RT.IsDryRun,0) = 0
				AND DT.LocationType IN ('SF','EP','ER','ST','RT')
)

SELECT		-- header / workorder-level fields (from integration header & order)
			A.OrderKey,
			A.DataKey,                 -- DataKey (Workorder DataKey)
			A.SiteID,
			TH.TMS_OrderKey,
			TH.DataKey    AS HeaderDataKey,    -- same as A.DataKey (kept for clarity)
			TH.WorkOrdernumber,
			TH.WorKOrderDate,
			OH.status     AS OrderStatus,

			-- container-level fields (via TMS_Integration_Container + OrderDetail)
			TC.ContainerKey,
			A.OrderDetailKey,
			OD.ContainerNo,
			OD.status     AS OrderDetailStatus,

			-- stop-level fields
			A.TMS_RouteKey,
			A.RouteKey,
			A.TMS_LegKey,
			A.LegKey,
			A.StopKey,
			A.LocationType,
			A.StopType,
			A.SchedPickup,
			A.ActualPickup,
			A.SchedDelivery,
			A.RouteEmptyDate,
			A.TableEmptyDate,
			A.ActualDelivery,
			A.LegNo,
			A.IsEmpty
			, CASE A.LocationType 
				WHEN 'SF' THEN ActualPickup
				WHEN 'ST' THEN ActualDelivery
				WHEN 'RT' THEN ActualDelivery
				WHEN 'EP' THEN ActualPickup 
				WHEN 'ER' THEN ISNULL(RouteEmptyDate,TableEmptyDate) END  AS ActualEventDate
			, CASE A.LocationType 
				WHEN 'SF' THEN SchedPickup
				WHEN 'ST' THEN SchedDelivery
				WHEN 'RT' THEN SchedDelivery
				WHEN 'EP' THEN SchedPickup 
				WHEN 'ER' THEN NULL END  AS ScheduleEventDate,
				OH.CreateDate AS OrderCreatedDate,

			-- computed stop number (partition per order detail)
			ROW_NUMBER() OVER (PARTITION BY A.OrderDetailKey ORDER BY L.StopNO, A.LegNo) AS StopNum

FROM		AllStops A
INNER JOIN	LocationTypeMap L			ON A.LocationType = L.LocationType
LEFT JOIN	TMS_Integration_Header TH	ON A.DataKey = TH.DataKey
											AND TH.SiteID = A.SiteID
LEFT JOIN	TMS_Integration_Container TC ON TH.DataKey = TC.DataKey
											  AND TC.SiteID = TH.SiteID
											  AND TC.TMS_OrderDetailKey = A.OrderDetailKey
LEFT JOIN	OrderDetail OD				ON A.OrderDetailKey = OD.OrderDetailKey
LEFT JOIN	OrderHeader OH				ON A.OrderKey = OH.OrderKey;
