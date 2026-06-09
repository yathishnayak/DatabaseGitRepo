CREATE PROC [dbo].[MelroseIntegrate_ROUTESDATA] -- MelroseIntegrate_ROUTESDATA 191930
(
	@OrderKey	int
)
AS


SELECT		Orderkey, OrderTypeKey, CreateDate
INTO		#OrderHeader
FROM		OrderHeader WITH (NOLOCK)
WHERE		OrderKey = @Orderkey

SELECT		Orderkey , OrderDetailKey, IsEmpty
INTO		#OrderDetail
FROM		OrderDetail WITH (NOLOCK)
WHERE		OrderKey = @Orderkey

SELECT		RouteKey, RT.OrderDetailKey, IsDryRun,RT.IsEmpty, LegNo, LegKey, LegType,isStreetTurn
INTO		#Routes
FROM		Routes RT WITH (NOLOCK)
INNER JOIN	#OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey


SELECT		Rt.OrderDetailKey, Rt.routekey, OH.orderKey, Oh.OrderTypeKey, L.FromLocation,
			Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey, L.ToLocation,RT.isStreetTurn
INTO		#TMP
FROM		#OrderHeader OH WITH (NOLOCK)
INNER JOIN	#OrderDetail OD WITH (NOLOCK)	ON OH.orderKey = OD.OrderKey
INNER JOIN	#Routes RT WITH (NOLOCK)			ON OD.OrderDetailKey = RT.OrderDetailKey
INNER JOIN	Leg L WITH (NOLOCK)				ON RT.LegKey = L.LegKey
--INNER JOIN	LegType LT WITH (NOLOCK)		ON OH.OrderTypeKey = Lt.OrderTypeKey AND L.LegTypeKey = Lt.LegtypeKey
WHERE		OH.OrderKey = @Orderkey

SELECT		OrderDetailKey, RouteKey, LocationType ,OrderKey, OrderTypeKey, '' LocationType1,
			LegNo, IsEmpty, IsDryRun, LegKey, GETDATE() AS EventDate, 'A' AS ScheuleActual, 18872 AS AddrKey
INTO		#Data
FROM		(SELECT		OrderDetailKey, routekey, 'SF' as LocationType, orderKey, OrderTypeKey, FromLocation,
						LegNo, IsEmpty, IsDryRun, LegKey
			FROM		#TMP
			WHERE		FromLocation = 'PORT' AND OrderTypeKey = 1 AND ISNULL(IsDryRun ,0) = 0 

			UNION ALL

			SELECT		OrderDetailKey, routekey, 'ST' as LocationType, orderKey, OrderTypeKey, ToLocation,
						LegNo, IsEmpty, IsDryRun, LegKey
			FROM		#TMP 
			WHERE		ToLocation	in ('Consignee','Customer','Shipper') AND OrderTypeKey = 1  AND ISNULL(IsDryRun ,0) = 0

			--UNION ALL

			--SELECT		OrderDetailKey, routekey, 'RP' as LocationType, orderKey, OrderTypeKey, ToLocation,
			--			LegNo, IsEmpty, IsDryRun, LegKey
			--FROM		#TMP
			--WHERE		FromLocation in ('Consignee','Customer','Shipper') and OrderTypeKey = 1  and isnull(IsDryRun ,0) = 0
			
			---------------------------------------------- Flexport EP ------------------------------------------
			UNION ALL				
			SELECT		DISTINCT Rt.OrderDetailKey, Rt.routekey, 'EP' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.FromLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey
			FROM		(SELECT * FROM #OrderHeader )  OH
			INNER JOIN	(SELECT * FROM #OrderDetail ) OD on OH.orderKey = OD.OrderKey
			INNER JOIN	#Routes RT on OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	(SELECT * FROM Leg WITH (NOLOCK)
						WHERE FromLocation in ('Consignee','Customer','Shipper') ) L on RT.LegKey = L.LegKey
			--INNER JOIN	LegType LT on OH.OrderTypeKey = Lt.OrderTypeKey and L.LegTypeKey = Lt.LegtypeKey
			LEFT JOIN	(SELECT		OrderDetailKey, L.ToLocation
						FROM		Leg  L  WITH (NOLOCK)
						INNER JOIN	#Routes R ON L.LegKey = R.LegKey
						WHERE		L.ToLocation in ('Consignee','Customer','Shipper') AND (LegID LIKE '%Drop%' OR R.Legtype = 'Drop') ) L1 ON RT.OrderDetailKey = L1.OrderDetailKey
			--LEFT JOIN	TKT_RouteDataNew RTN on OD.OrderDetailKey = RTN.OrderDetailKey and RT.RouteKey = RTN.RouteKey and RTN.LocationType in ('EP')
			WHERE		L1.ToLocation IS NOT NULL AND OH.OrderTypeKey = 1  and isnull(RT.IsDryRun ,0) = 0 -- AND RT.IsEmpty = 0 
						AND CONVERT(DATETIME, OH.CreateDate) > CONVERT(DATE, '2024-10-01')
						-- AND rtn.OrderDetailKey IS NULL 
						-- AND OD.OrderDetailKey IN (97356,151207,149573,150345,149578,150764,151571,151755,150624,152198,151701,152173)  


			---------------------------------------------- Flexport ER ------------------------------------------
			UNION ALL
			SELECT		DISTINCT Rt.OrderDetailKey, Rt.routekey, 'ER' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
							Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey 
				FROM		(SELECT * FROM #OrderHeader WITH (NOLOCK) )  OH
				INNER JOIN	(SELECT * FROM #OrderDetail  WITH (NOLOCK)  ) OD on OH.orderKey = OD.OrderKey
				INNER JOIN	(SELECT RT.* FROM #Routes RT  WITH (NOLOCK) 
							INNER JOIN #OrderDetail OD  WITH (NOLOCK)  ON RT.OrderDetailKey = OD.OrderDetailKey
							WHERE RT.IsEmpty = 1 OR OD.IsEmpty = 1 ) RT on OD.OrderDetailKey = RT.OrderDetailKey
				INNER JOIN	(SELECT * FROM Leg  WITH (NOLOCK) 
							WHERE ToLocation in ('Consignee','Customer','Shipper'))  L on RT.LegKey = L.LegKey
				-- INNER JOIN	LegType LT  WITH (NOLOCK)  on OH.OrderTypeKey = Lt.OrderTypeKey and L.LegTypeKey = Lt.LegtypeKey
				INNER JOIN	(SELECT		OrderDetailKey, L.ToLocation
							FROM		Leg L   WITH (NOLOCK) 
							INNER JOIN	#Routes R  WITH (NOLOCK)  ON L.LegKey = R.LegKey
							WHERE		L.ToLocation in ('Consignee','Customer','Shipper') AND (LegID LIKE '%Drop%' OR R.Legtype = 'Drop')  ) L1 ON RT.OrderDetailKey = L1.OrderDetailKey
				--LEFT JOIN	TKT_RouteDataNew RTN  WITH (NOLOCK)  on OD.OrderDetailKey = RTN.OrderDetailKey and RT.RouteKey = RTN.RouteKey and RTN.LocationType in ('ER')
				WHERE		L.ToLocation in ('Consignee','Customer','Shipper') AND OH.OrderTypeKey = 1  and isnull(RT.IsDryRun ,0) = 0 
							AND CONVERT(DATETIME, OH.CreateDate) > CONVERT(DATE, '2024-10-01') 
							--AND rtn.OrderDetailKey IS NULL 
							-- AND OD.OrderDetailKey IN (151726,151755,152155,152173,152198,151701,150624,121916) 
				-----------------------------------------------------------------------------------------------------------------------------


			UNION ALL

			SELECT		OrderDetailKey, routekey, 'RT' as LocationType, orderKey, OrderTypeKey, ToLocation,
						LegNo, IsEmpty, IsDryRun, LegKey
			FROM		#tmp
			WHERE		ToLocation in ('PORT') AND OrderTypeKey = 1  AND ISNULL(IsDryRun ,0) = 0

			UNION ALL

			SELECT		OrderDetailKey,routekey, 'RT' as LocationType, orderKey, OrderTypeKey, ToLocation,
						LegNo, IsEmpty, IsDryRun, LegKey
			FROM		#TMP
			WHERE		OrderTypeKey = 1  AND ISNULL(IsDryRun ,0) = 0 AND isStreetTurn = 1 AND ToLocation = 'YARD' 

			UNION ALL

			SELECT		OrderDetailKey, routekey, 'SF' as LocationType, orderKey, OrderTypeKey, FromLocation,
						LegNo, IsEmpty, IsDryRun, LegKey
			FROM		#TMP
			WHERE		FromLocation in ('Consignee','Customer','Shipper') AND OrderTypeKey = 2  AND ISNULL(IsDryRun ,0) = 0
			
			UNION ALL

			SELECT		OrderDetailKey, routekey, 'ST' as LocationType, orderKey, OrderTypeKey, ToLocation,
						LegNo,IsEmpty, IsDryRun, LegKey
			FROM		#TMP
			WHERE		ToLocation in ('PORT') AND OrderTypeKey = 2  AND ISNULL(IsDryRun ,0) = 0
) A


SELECT  OrderDetailKey, RouteKey, LocationType ,OrderKey, OrderTypeKey, '' LocationType1,
		LegNo, IsEmpty, IsDryRun, LegKey,   EventDate,  ScheuleActual,  AddrKey FROM #Data
UNION ALL
SELECT  OrderDetailKey, RouteKey, LocationType ,OrderKey, OrderTypeKey, '' LocationType1,
		LegNo, IsEmpty, IsDryRun, LegKey,   EventDate, 'S' ScheuleActual,  AddrKey FROM #Data
		WHERE LocationType IN ('SF','ST')


