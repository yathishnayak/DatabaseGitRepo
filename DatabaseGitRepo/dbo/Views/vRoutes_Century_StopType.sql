






CREATE VIEW [dbo].[vRoutes_Century_StopType] -- SELECT * FROm vRoutes_Century_StopType WHERE AppliedOrderDetailkey = 278155
AS
SELECT		AppliedOrderDetailkey, OrderDetailkey,Routekey, StopType, A.OrderKey , OH.CustKey, 
FC.StopTypeCode , ChassisNo, Chassiskey, IsDryRun  
FROM		(SELECT		'SF' AS StopType,*
			FROM		(SELECT		ROW_NUMBER() OVER (PARTITION BY AppliedOrderDetailkey ORDER BY RouteKey ) Sl,   * 
						FROM		vRoutes_Century
						WHERE		LegFromLocation = 'Port' AND ISNULL(IsDryRun,0) = 0) A
			WHERE		Sl = 1
			UNION ALL
			SELECT		'ST' AS StopType,*
			FROM		(SELECT		ROW_NUMBER() OVER (PARTITION BY AppliedOrderDetailkey ORDER BY RouteKey ) Sl,   * 
						FROM		vRoutes_Century
						WHERE		LegToLocation IN ('Consignee','Customer','Shipper') AND ISNULL(IsDryRun,0) = 0) A
			WHERE		Sl = 1
			UNION ALL
			SELECT		'RP' AS StopType,*
			FROM		(SELECT		ROW_NUMBER() OVER (PARTITION BY AppliedOrderDetailkey ORDER BY RouteKey ) Sl,   * 
						FROM		vRoutes_Century
						WHERE		LegFromLocation IN ('Consignee','Customer','Shipper') AND ISNULL(IsDryRun,0) = 0) A
			WHERE		Sl = 1
			UNION ALL
			SELECT		'RT' AS StopType,*
			FROM		(SELECT		ROW_NUMBER() OVER (PARTITION BY AppliedOrderDetailkey ORDER BY RouteKey DESC ) Sl,   * 
						FROM		vRoutes_Century
						WHERE		LegToLocation IN ('Port') AND ISNULL(IsDryRun,0) = 0) A
			WHERE		Sl = 1 
			UNION ALL
			SELECT		'PP' AS StopType,*
			FROM		(SELECT		ROW_NUMBER() OVER (PARTITION BY AppliedOrderDetailkey ORDER BY RouteKey ) Sl,   CT.* 
						FROM		vRoutes_Century CT
						INNER JOIN	(SELECT Legkey FROM Leg WITH (NOLOCK)  WHERE LegType = 'Pre-Pull') L   on CT.LegKey = L.LegKey
						WHERE		ISNULL(IsDryRun,0) = 0) A
			WHERE		Sl = 1 
			UNION ALL
			SELECT		'CP' AS StopType,*
			FROM		(SELECT		ROW_NUMBER() OVER (PARTITION BY AppliedOrderDetailkey ORDER BY RouteKey ) Sl,   CT.* 
						FROM		vRoutes_Century CT
						WHERE		(LinkedContainerType IN ('OSY','DS') OR NoEmptyAvailableMarked = 1)) A
			WHERE		Sl = 1 	
			
			) A
INNER JOIN	OrderHeader OH WITH (NOLOCK) ON A.OrderKey = OH.OrderKey
INNER JOIN	TMS_Integration_Customers C  WITH (NOLOCK) On OH.CustKey = C.CustKey
INNER JOIN	(SELECT * FROM TMS_Integration_SiteIDFacilityCodes  WITH (NOLOCK) WHERE SiteID = 'Century') FC ON C.CustGroupID = FC.CustGroupID AND A.StopType = FC.FacilityCode



