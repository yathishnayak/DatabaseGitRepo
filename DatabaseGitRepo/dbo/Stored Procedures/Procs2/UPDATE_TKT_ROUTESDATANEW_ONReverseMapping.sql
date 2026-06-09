
--select * from TKT_RouteDataNew WHERE orderkey = 95797
CREATE PROC [dbo].[UPDATE_TKT_ROUTESDATANEW_ONReverseMapping] -- [UPDATE_TKT_ROUTESDATANEW_ONReverseMapping] 234049
(
	@OrderKey	int
)
AS

DELETE FROM TKT_RouteDataNew WHERE   OrderKey = @OrderKey

--SELECT DISTINCT OrderKey INTO #TMP FROM vRoutes_Century_StopType WITH (NOLOCK)
--WHERE AppliedOrderDetailkey IN (SELECT DISTINCt OrderDetailKey FROM OrderDetail WITH (NOLOCK) WHERE OrderKey = @OrderKey )

SELECT DISTINCT Routekey INTO #DataRT FROM vRoutes_Century_StopType WHERE StopType = 'RT'
SELECT DISTINCT Routekey INTO #DataPP FROM vRoutes_Century_StopType WHERE StopType = 'PP'
SELECT DISTINCT Routekey INTO #DataRP FROM vRoutes_Century_StopType WHERE StopType = 'RP'
SELECT DISTINCT Routekey INTO #DataCP FROM vRoutes_Century_StopType WHERE StopType = 'CP'

--SELECT *
--INTO #RTA
--FROM vRoutes_Century WITH (NOLOCK)
--WHERE AppliedOrderDetailKey <> OrderDetailKey;

INSERT INTO TKT_RouteDataNew (OrderDetailKey, RouteKey, LocationType, OrderKey, OrderTypeKey, Location, 
			TMS_Legno, IsEmpty, IsDryRun, TMS_LegKey,AppliedOrderDetailKey)
SELECT		OrderDetailKey, RouteKey, LocationType,OrderKey, OrderTypeKey, FromLocation,
			LegNo, IsEmpty, IsDryRun, LegKey, AppliedOrderDetailKey
FROM		(SELECT		Rt.OrderDetailKey, Rt.routekey, 'SF' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.FromLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey, 0 AS AppliedOrderDetailKey
			FROM		OrderHeader OH WITH (NOLOCK)
			INNER JOIN	OrderDetail OD	 WITH (NOLOCK)		ON OH.orderKey = OD.OrderKey
			INNER JOIN	Routes RT	 WITH (NOLOCK)			ON OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	Leg L		 WITH (NOLOCK)			ON RT.LegKey  = L.LegKey
			--INNER JOIN	LegType LT				ON OH.OrderTypeKey = Lt.OrderTypeKey AND (L.LegTypeKey = Lt.LegtypeKey OR L.LegID = LT.LegTypeID)
			LEFT JOIN	TKT_RouteDataNew RTN WITH (NOLOCK) ON OD.OrderDetailKey = RTN.OrderDetailKey AND RT.RouteKey = RTN.RouteKey AND RTN.LocationType in ('SF')
			WHERE		OH.OrderKey = @OrderKey  AND L.FromLocation = 'PORT' AND OH.OrderTypeKey = 1 AND ISNULL(RT.IsDryRun ,0) = 0 
						AND rtn.OrderDetailKey IS NULL

			UNION ALL

			SELECT		Rt.OrderDetailKey, Rt.routekey, 'ST' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0
			FROM		OrderHeader OH WITH (NOLOCK)
			INNER JOIN	OrderDetail OD	 WITH (NOLOCK)		ON OH.orderKey = OD.OrderKey
			INNER JOIN	Routes RT		 WITH (NOLOCK)		ON OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	Leg L			 WITH (NOLOCK)		ON RT.LegKey = L.LegKey
			--INNER JOIN	LegType LT				ON OH.OrderTypeKey = Lt.OrderTypeKey AND L.LegTypeKey = Lt.LegtypeKey
			LEFT JOIN	TKT_RouteDataNew RTN WITH (NOLOCK)	ON OD.OrderDetailKey = RTN.OrderDetailKey AND RT.RouteKey = RTN.RouteKey AND RTN.LocationType in ('ST')
			WHERE		OH.OrderKey = @Orderkey AND L.ToLocation in ('Consignee','Customer','Shipper') AND OH.OrderTypeKey = 1  AND ISNULL(RT.IsDryRun ,0) = 0
						AND rtn.OrderDetailKey IS NULL

			UNION ALL

			SELECT		Rt.OrderDetailKey, Rt.routekey, 'RP' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0
			FROM		OrderHeader OH  WITH (NOLOCK)
			INNER JOIN	OrderDetail OD	 WITH (NOLOCK)		ON OH.orderKey = OD.OrderKey
			INNER JOIN	Routes RT		 WITH (NOLOCK)		ON OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	Leg L			 WITH (NOLOCK)		ON RT.LegKey = L.LegKey
			--INNER JOIN	LegType LT				ON OH.OrderTypeKey = Lt.OrderTypeKey and L.LegTypeKey = Lt.LegtypeKey
			LEFT JOIN	TKT_RouteDataNew RTN	 WITH (NOLOCK)ON OD.OrderDetailKey = RTN.OrderDetailKey and RT.RouteKey = RTN.RouteKey and RTN.LocationType in ('RP')
			WHERE		OH.OrderKey = @Orderkey and
						L.FromLocation in ('Consignee','Customer','Shipper') and OH.OrderTypeKey = 1  and isnull(RT.IsDryRun ,0) = 0
						AND rtn.OrderDetailKey IS NULL
			
			---------------------------------------------- Flexport EP ------------------------------------------
			UNION ALL				
			SELECT		DISTINCT Rt.OrderDetailKey, Rt.routekey, 'EP' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.FromLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0
			FROM		(SELECT * FROM OrderHeader  WITH (NOLOCK) WHERE CustKey = 1966)  OH
			INNER JOIN	OrderDetail OD WITH (NOLOCK) on OH.orderKey = OD.OrderKey
			INNER JOIN	Routes RT  WITH (NOLOCK) on OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	(SELECT * FROM Leg   WITH (NOLOCK)
						WHERE FromLocation in ('Consignee','Customer','Shipper') ) L on RT.LegKey = L.LegKey
			--INNER JOIN	LegType LT on OH.OrderTypeKey = Lt.OrderTypeKey and L.LegTypeKey = Lt.LegtypeKey
			LEFT JOIN	(SELECT		OrderDetailKey, L.ToLocation
						FROM		Leg L  WITH (NOLOCK)
						INNER JOIN	Routes R  WITH (NOLOCK) ON L.LegKey = R.LegKey
						WHERE		L.ToLocation in ('Consignee','Customer','Shipper') AND (L.LegID LIKE '%Drop%' OR R.LegType = 'Drop') ) L1 ON RT.OrderDetailKey = L1.OrderDetailKey
			LEFT JOIN	TKT_RouteDataNew RTN  WITH (NOLOCK) on OD.OrderDetailKey = RTN.OrderDetailKey and RT.RouteKey = RTN.RouteKey and RTN.LocationType in ('EP')
			WHERE		OH.OrderKey = @Orderkey and L1.ToLocation IS NOT NULL AND OH.OrderTypeKey = 1  and isnull(RT.IsDryRun ,0) = 0 -- AND RT.IsEmpty = 0 
						AND CONVERT(DATETIME, OH.CreateDate) > CONVERT(DATE, '2024-10-01')
						AND rtn.OrderDetailKey IS NULL 
						-- AND OD.OrderDetailKey IN (97356,151207,149573,150345,149578,150764,151571,151755,150624,152198,151701,152173)  


			---------------------------------------------- Flexport ER ------------------------------------------
			UNION ALL
			SELECT		DISTINCT Rt.OrderDetailKey, Rt.routekey, 'ER' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
							Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey ,0
				FROM		(SELECT * FROM OrderHeader WITH (NOLOCK) WHERE CustKey = 1966)  OH
				INNER JOIN	OrderDetail  OD WITH (NOLOCK)  on OH.orderKey = OD.OrderKey
				INNER JOIN	(SELECT RT.* FROM Routes RT  WITH (NOLOCK) 
							INNER JOIN OrderDetail OD  WITH (NOLOCK)  ON RT.OrderDetailKey = OD.OrderDetailKey
							WHERE RT.IsEmpty = 1 OR OD.IsEmpty = 1 ) RT on OD.OrderDetailKey = RT.OrderDetailKey
				INNER JOIN	(SELECT * FROM Leg  WITH (NOLOCK) 
							WHERE ToLocation in ('Consignee','Customer','Shipper'))  L on RT.LegKey = L.LegKey
				--INNER JOIN	LegType LT  WITH (NOLOCK)  on OH.OrderTypeKey = Lt.OrderTypeKey and L.LegTypeKey = Lt.LegtypeKey
				INNER JOIN	(SELECT		OrderDetailKey, L.ToLocation
							FROM		Leg L  WITH (NOLOCK) 
							INNER JOIN	Routes R  WITH (NOLOCK)  ON L.LegKey = R.LegKey
							WHERE		L.ToLocation in ('Consignee','Customer','Shipper') AND (L.LegID LIKE '%Drop%' OR R.LegType= 'Drop')) L1 ON RT.OrderDetailKey = L1.OrderDetailKey
				LEFT JOIN	TKT_RouteDataNew RTN  WITH (NOLOCK)  on OD.OrderDetailKey = RTN.OrderDetailKey and RT.RouteKey = RTN.RouteKey and RTN.LocationType in ('ER')
				WHERE		OH.OrderKey = @Orderkey and L.ToLocation = 'Consignee'  AND OH.OrderTypeKey = 1  and isnull(RT.IsDryRun ,0) = 0 
							AND CONVERT(DATETIME, OH.CreateDate) > CONVERT(DATE, '2024-10-01') 
							AND rtn.OrderDetailKey IS NULL 
							-- AND OD.OrderDetailKey IN (151726,151755,152155,152173,152198,151701,150624,121916) 
				-----------------------------------------------------------------------------------------------------------------------------


			UNION ALL

			SELECT		Rt.OrderDetailKey, Rt.routekey, 'RT' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0
			FROM		OrderHeader OH  WITH (NOLOCK)
			INNER JOIN	OrderDetail OD	 WITH (NOLOCK)		ON OH.orderKey = OD.OrderKey
			INNER JOIN	Routes RT		 WITH (NOLOCK)		ON OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	Leg L			 WITH (NOLOCK)		ON RT.LegKey = L.LegKey
			--INNER JOIN	LegType LT				ON OH.OrderTypeKey = Lt.OrderTypeKey AND L.LegTypeKey = Lt.LegtypeKey
			LEFT JOIN	TKT_RouteDataNew RTN WITH (NOLOCK)	ON OD.OrderDetailKey = RTN.OrderDetailKey AND RT.RouteKey = RTN.RouteKey AND RTN.LocationType in ('RT')
			WHERE		OH.OrderKey = @Orderkey AND L.ToLocation in ('PORT') AND OH.OrderTypeKey = 1  
						AND OH.CustKey NOT IN  ( SELECT CustKey FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) 
						AND ISNULL(RT.IsDryRun ,0) = 0
						AND rtn.OrderDetailKey IS NULL

			UNION ALL

			SELECT		Rt.OrderDetailKey, Rt.routekey, 'RT' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0
			FROM		OrderHeader OH WITH (NOLOCK)
			INNER JOIN	OrderDetail OD	WITH (NOLOCK)		ON OH.orderKey = OD.OrderKey
			INNER JOIN	Routes RT	WITH (NOLOCK)			ON OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	Leg L		WITH (NOLOCK)			ON RT.LegKey = L.LegKey
			--INNER JOIN	LegType LT				ON OH.OrderTypeKey = Lt.OrderTypeKey AND L.LegTypeKey = Lt.LegtypeKey
			LEFT JOIN	TKT_RouteDataNew RTN WITH (NOLOCK)	ON OD.OrderDetailKey = RTN.OrderDetailKey AND RT.RouteKey = RTN.RouteKey AND RTN.LocationType in ('SF','ST','RT')
			WHERE		OH.OrderKey = @Orderkey AND OH.OrderTypeKey = 1  
						AND OH.CustKey NOT IN  ( SELECT CustKey FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) 
						AND ISNULL(RT.IsDryRun ,0) = 0 AND RT.isStreetTurn = 1 
						AND L.ToLocation = 'YARD' 
						AND RTN.OrderDetailKey IS  null

			UNION ALL

			SELECT		Rt.OrderDetailKey, Rt.routekey, 'SF' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.FromLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0
			FROM		OrderHeader OH WITH (NOLOCK)
			INNER JOIN	OrderDetail OD	WITH (NOLOCK)		ON OH.orderKey = OD.OrderKey
			INNER JOIN	Routes RT		WITH (NOLOCK)		ON OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	Leg L			WITH (NOLOCK)		ON RT.LegKey = L.LegKey
			--INNER JOIN	LegType LT				ON OH.OrderTypeKey = Lt.OrderTypeKey AND L.LegTypeKey = Lt.LegtypeKey
			LEFT JOIN	TKT_RouteDataNew RTN WITH (NOLOCK)	ON OD.OrderDetailKey = RTN.OrderDetailKey AND RT.RouteKey = RTN.RouteKey AND RTN.LocationType in ('SF')
			WHERE		OH.OrderKey = @Orderkey AND L.FromLocation in ('Consignee','Customer','Shipper') AND OH.OrderTypeKey = 2  AND ISNULL(RT.IsDryRun ,0) = 0
						AND rtn.OrderDetailKey IS NULL

			UNION ALL

			SELECT		Rt.OrderDetailKey, Rt.routekey, 'ST' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
						Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0
			FROM		OrderHeader OH WITH (NOLOCK)
			INNER JOIN	OrderDetail OD WITH (NOLOCK)			ON OH.orderKey = OD.OrderKey
			INNER JOIN	Routes RT	   WITH (NOLOCK)		ON OD.OrderDetailKey = RT.OrderDetailKey
			INNER JOIN	Leg L			WITH (NOLOCK)		ON RT.LegKey = L.LegKey
			--INNER JOIN	LegType LT				ON OH.OrderTypeKey = Lt.OrderTypeKey AND L.LegTypeKey = Lt.LegtypeKey
			LEFT JOIN	TKT_RouteDataNew RTN WITH (NOLOCK)	ON OD.OrderDetailKey = RTN.OrderDetailKey AND RT.RouteKey = RTN.RouteKey AND RTN.LocationType in ('ST')
			WHERE		OH.OrderKey = @Orderkey AND L.ToLocation in ('PORT') AND OH.OrderTypeKey = 2  AND ISNULL(RT.IsDryRun ,0) = 0
						AND RTN.OrderDetailKey IS NULL

			--------------------------------CENTURY CE CB-----------------------------------------------
				--UNION ALL
				--SELECT		ISNULL(RT.AppliedOrderDetailKey,Rt.OrderDetailKey)OrderDetailKey
				--			, CASE WHEN D.DocumentType = 21 THEN Rt.routekey ELSE RTA.RouteKey END routekey
				--			, CASE WHEN D.DocumentType = 21 THEN 'CE' ELSE 'CB' END as LocationType
				--			, OH.orderKey, Oh.OrderTypeKey
				--			, CASE WHEN D.DocumentType = 21 THEN L.FromLocation ELSE L.ToLocation END PDLocation ,
				--			Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0 
				--FROM		OrderHeader OH  WITH (NOLOCK) 
				--INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
				--INNER JOIN	OrderDetail OD  WITH (NOLOCK)  on OH.orderKey = OD.OrderKey
				--INNER JOIN	vRoutes_Century RT  WITH (NOLOCK)  on OD.OrderDetailKey = RT.AppliedOrderDetailKey
				--INNER JOIN	Leg L  WITH (NOLOCK)  on RT.LegKey = L.LegKey
				----INNER JOIN	LegType LT  WITH (NOLOCK)  on OH.OrderTypeKey = Lt.OrderTypeKey and L.LegTypeKey = Lt.LegtypeKey
				--INNER JOIN	ContainerLegDocuments  LD WITH (NOLOCK) ON RT.RouteKey = LD.RouteKey
				--INNER JOIN	Document D WITH (NOLOCK) ON LD.DocumentKey = D.DocumentKey
				--LEFT JOIN	(SELECT * FROM vRoutes_Century WITH (NOLOCK) 
				--			WHERE AppliedOrderDetailKey <> OrderDetailKey   AND LegToLocation = 'Port' ) RTA
				--			ON RT.AppliedOrderDetailKey = RTA.AppliedOrderDetailKey
				--LEFT JOIN	(SELECT * FROM TKT_RouteDataNew  WITH (NOLOCK)  WHERE LocationType in ('CE','CB') ) RTN  
				--			on OD.OrderDetailKey = ISNULL(RTN.OrderDetailKey,0) and RT.RouteKey = ISNULL(RTN.RouteKey,0)
				--			AND CASE WHEN D.DocumentType = 21 THEN 'CE' ELSE 'CB' END = ISNULL(RTN.LocationType ,'')
				--WHERE		OH.OrderKey = @OrderKey AND  D.DocumentType IN (20,21)  --   AND D.CreateDate > CAST('2025-05-01' AS DATE)
				--			AND CASE WHEN D.DocumentType = 21 THEN Rt.routekey ELSE RTA.RouteKey END IS NOT NULL
				--			--AND OH.OrderKey = 175441
				--			AND RTN.OrderDetailKey IS NULL
				------------------------------------------Century RT -----------------------------------------------------------------------------
				--UNION ALL
				--SELECT		DISTINCT Rt.OrderDetailKey, Rt.routekey, 'RT' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
				--			Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,RT.AppliedOrderDetailKey
				--FROM		(SELECT * FROM OrderHeader WITH (NOLOCK) WHERE OrderKey IN (SELECT OrderKey FROm #TMP) )  OH
				--INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
				--INNER JOIN	OrderDetail OD  WITH (NOLOCK)  on OH.orderKey = OD.OrderKey
				--INNER JOIN	VRoutes_Century RT  WITH (NOLOCK)  on OD.OrderDetailKey = RT.AppliedOrderDetailKey
				--INNER JOIN	#DataRT  ST ON RT.RouteKey = ST.Routekey
				--INNER JOIN	Leg L  WITH (NOLOCK)  on RT.LegKey = L.LegKey
				----INNER JOIN	LegType LT  WITH (NOLOCK)  on OH.OrderTypeKey = Lt.OrderTypeKey and L.LegTypeKey = Lt.LegtypeKey
				--LEFT JOIN	TKT_RouteDataNew RTN  WITH (NOLOCK) ON  RT.AppliedOrderDetailKey = RTN.AppliedOrderDetailKey and RT.RouteKey = RTN.RouteKey 
				--			and RTN.LocationType in ('RT')
				--WHERE		L.ToLocation in ('PORT') -- and OH.OrderTypeKey = 1  AND OH.CreateDate > '2025-05-01'
				--			--AND OH.OrderKey IN (175049)
				--			and isnull(RT.IsDryRun ,0) = 0 	AND rtn.OrderDetailKey IS NULL

				--------------------------------------------Century PP (PrePull)  -----------------------------------------------------------------------------
				--UNION ALL
				--SELECT		DISTINCT Rt.OrderDetailKey, Rt.routekey, 'PP' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.ToLocation,
				--			Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,0
				--FROM		(SELECT * FROM OrderHeader WITH (NOLOCK) WHERE OrderKey IN (SELECT OrderKey FROm #TMP) )  OH
				--INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
				--INNER JOIN	OrderDetail OD  WITH (NOLOCK)  on OH.orderKey = OD.OrderKey
				--INNER JOIN	Routes RT  WITH (NOLOCK)  on OD.OrderDetailKey = RT.OrderDetailKey
				--INNER JOIN	#DataPP  ST ON RT.RouteKey = ST.Routekey
				--INNER JOIN	(SELECT * FROM Leg WITH (NOLOCK)  WHERE LegID LIKE '%Pre-Pull%') L   on RT.LegKey = L.LegKey
				----INNER JOIN	LegType LT  WITH (NOLOCK)  on OH.OrderTypeKey = Lt.OrderTypeKey and L.LegTypeKey = Lt.LegtypeKey
				--LEFT JOIN	TKT_RouteDataNew RTN  WITH (NOLOCK) ON  RT.OrderDetailKey = RTN.OrderDetailKey and RT.RouteKey = RTN.RouteKey 
				--			and RTN.LocationType in ('PP')
				--WHERE		L.FromLocation = 'Port' AND L.ToLocation in ('Yard') and OH.OrderTypeKey = 1  AND OH.CreateDate > '2025-04-28'
				--			--AND OH.OrderKey IN (175441)
				--			and isnull(RT.IsDryRun ,0) = 0 	AND rtn.OrderDetailKey IS NULL

				--------------------------------------------Century RP    -----------------------------------------------------------------------------
				--UNION ALL

				--SELECT		DISTINCT  Rt.OrderDetailKey, Rt.routekey, 'RP' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.FromLocation,
				--			Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,RT.AppliedOrderDetailKey
				--FROM		(SELECT * FROM OrderHeader WITH (NOLOCK) WHERE OrderKey IN (SELECT OrderKey FROm #TMP) )  OH
				--INNER JOIN	OrderDetail OD  WITH (NOLOCK)  on OH.orderKey = OD.OrderKey
				--INNER JOIN	VRoutes_Century RT  WITH (NOLOCK)  on OD.OrderDetailKey = RT.AppliedOrderDetailKey
				--INNER JOIN	#DataRP ST ON RT.RouteKey = ST.Routekey
				--INNER JOIN	Leg L  WITH (NOLOCK)  on RT.LegKey = L.LegKey
				--LEFT JOIN	TKT_RouteDataNew RTN  WITH (NOLOCK)  on  RT.AppliedOrderDetailKey = RTN.AppliedOrderDetailKey 
				--			and RT.RouteKey = RTN.RouteKey 
				--			and RTN.LocationType in ('RP')
				--WHERE		rtn.OrderDetailKey IS NULL
				

				--------------------------------------------Century CP    -----------------------------------------------------------------------------
				--UNION ALL

				--SELECT		DISTINCT Rt.OrderDetailKey, Rt.routekey, 'CP' as LocationType, OH.orderKey, Oh.OrderTypeKey, L.FromLocation,
				--			Rt.LegNo, RT.IsEmpty, rt.IsDryRun, L.LegKey,RT.AppliedOrderDetailKey
				--FROM		(SELECT * FROM OrderHeader WITH (NOLOCK) WHERE OrderKey IN (SELECT OrderKey FROm #TMP) )  OH
				--INNER JOIN	OrderDetail OD  WITH (NOLOCK)  on OH.orderKey = OD.OrderKey
				--INNER JOIN	VRoutes_Century RT  WITH (NOLOCK)  on OD.OrderDetailKey = RT.AppliedOrderDetailKey
				--INNER JOIN	#DataCP ST ON RT.RouteKey = ST.Routekey
				--INNER JOIN	Leg L  WITH (NOLOCK)  on RT.LegKey = L.LegKey
				--LEFT JOIN	TKT_RouteDataNew RTN  WITH (NOLOCK)  on  RT.AppliedOrderDetailKey = RTN.AppliedOrderDetailKey and RT.RouteKey = RTN.RouteKey 
				--			and RTN.LocationType in ('CP')
				--WHERE		rtn.OrderDetailKey IS NULL
				----------------------------------------------------- CNB - Added Stops -------------------------------------------------------------------------------
				--UNION ALL
				--SELECT		RT.OrderDetailKey,RT.routekey,RT.LocationType,RT.orderKey,RT.OrderTypeKey,ToLocation,LegNo,RT.IsEmpty,RT.IsDryRun,LegKey,
				--			0 AS AppliedOrderDetailKey 
				--FROM		vw_GetAddedStops_CNB RT				
				--LEFT JOIN	TKT_RouteDataNew RTN  WITH (NOLOCK) ON  RT.OrderDetailKey = RTN.OrderDetailKey and RT.RouteKey = RTN.RouteKey 
				--			and RTN.LocationType in ('AF','AT')
				--WHERE		RT.OrderKey = @Orderkey AND CreateDate > '2025-08-15' --  AND RT.Orderkey IN (204400,204401,204404,204418,204421)
				--			and isnull(RT.IsDryRun ,0) = 0 	AND rtn.OrderDetailKey IS NULL
				------------------------------------------------------------------------------------------------------------------------------------------------
) A


--DROP TABLE #DataCP
--DROP TABLE #DataRP
--DROP TABLE #DataRT
--DROP TABLE #DataPP