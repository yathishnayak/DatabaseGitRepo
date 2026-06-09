


CREATE VIEW [dbo].[vw_GetAddedStops_CNB] -- SELECT * FROM vw_GetAddedStops_CNB ORDER BY CreateDate DESC
AS
WITH BaseData AS (
    SELECT		OD.ContainerNo,OH.OrderKey,  RT.OrderDetailKey,RT.RouteKey,L.FromLocation,L.ToLocation, 
				RT.LegNo ,RT.IsEmpty, ISNULL(RT.IsDryRun,0)IsDryRun, OH.OrderTypeKey, L.LegKey , OH.CreateDate
    FROM		Routes RT WITH (NOLOCK)
    INNER JOIN	OrderHeader OH WITH (NOLOCK) ON RT.OrderKey = OH.OrderKey
    INNER JOIN	OrderDetail OD WITH (NOLOCK) ON RT.OrderKey = OD.OrderKey
    INNER JOIN	TMS_Integration_Customers C WITH (NOLOCK) ON OH.CustKey = C.CustKey
    INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey 
    WHERE		C.SiteID = 'CNB'
				-- AND OH.CreateDate > '2025-07-01' 
				AND ISNULL(IsDryRun, 0) = 0
),
ShipTO AS (
    SELECT		*
    FROM		(SELECT *,
				ROW_NUMBER() OVER (PARTITION BY OrderDetailkey ORDER BY LegNo) AS StopTypeKey
				FROM BaseData WITH (NOLOCK)
				WHERE ToLocation IN ('Consignee','Customer','Shipper') ) A
    WHERE		StopTypeKey = 1
),
ReturnData AS (
    SELECT		*
    FROM		(SELECT *,
					   ROW_NUMBER() OVER (PARTITION BY ContainerNo ORDER BY LegNo DESC) AS StopTypeKey
				FROM BaseData WITH (NOLOCK)
				WHERE ToLocation = 'Port' ) A
    WHERE		StopTypeKey = 1
)
SELECT			T.ContainerNo,
				T.OrderDetailKey, T.routekey, CASE 
					WHEN T.LegNo > ST1.LegNo THEN 'AT' 
					ELSE 'AF' 
				END AS LocationType, T.orderKey, T.OrderTypeKey, T.ToLocation,
						T.LegNo, T.IsEmpty, T.IsDryRun, T.LegKey , T.CreateDate
    
FROM			BaseData T WITH (NOLOCK)
LEFT JOIN		ShipTO ST WITH (NOLOCK) ON T.RouteKey = ST.RouteKey
LEFT JOIN		ReturnData RT WITH (NOLOCK) ON T.RouteKey = RT.RouteKey
LEFT JOIN		ShipTO ST1 WITH (NOLOCK) ON T.OrderDetailKey = ST1.OrderDetailKey
WHERE			T.ToLocation <> 'Port' 
				AND ST.RouteKey IS NULL 
				AND RT.RouteKey IS NULL;
