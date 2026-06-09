



-- SELECT * FROM Integration_JCB.dbo.Century_ContainerList 

CREATE VIEW [dbo].[vRoutes_Century_New] -- SELECT * FROM vRoutes_Century

AS

WITH PortDetailKey AS (
    SELECT		DISTINCT OH.BillOfLading,
				OD.ContainerNo,
				RT.OrderDetailKey AS PortOrderDetailKey
    FROM		OrderHeader  OH WITH (NOLOCK)
	INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
    INNER JOIN	OrderDetail OD WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
    INNER JOIN	Routes RT WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
    INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
    WHERE		(L.FromLocation IN ('Port') OR L.ToLocation IN ('Consignee','Customer'))
				 -- AND OD.ContainerNo = 'MSKU8894344'
)

-- Step 2: Join everything as before, but use the CTE to fetch PortOrderDetailKey
SELECT		DISTINCT COALESCE(PDK.PortOrderDetailKey, RT.OrderDetailKey) AS AppliedOrderDetailKey,RT.*, L.FromLocation LegFromLocation	, L.ToLocation 	 LegToLocation				
FROM		OrderHeader OH WITH (NOLOCK)
INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
INNER JOIN	OrderDetail OD WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
INNER JOIN	(SELECT		ContainerNo, BillOfLading, COUNT(*) TT
			FROM		OrderHeader OH WITH (NOLOCK)
			INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
			INNER JOIN  OrderDetail OD WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
			GROUP BY	ContainerNo, BillOfLading
			HAVING		COUNT(*) > 1 ) SCB ON OH.BillOfLading = SCB.BillOfLading AND OD.ContainerNo = SCB.ContainerNo
INNER JOIN	Routes RT WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
LEFT JOIN	PortDetailKey PDK WITH (NOLOCK) ON PDK.BillOfLading = OH.BillOfLading AND PDK.ContainerNo = OD.ContainerNo
-- WHERE	  AND SCB.ContainerNo = 'MSKU8894344'
UNION ALL

SELECT		OD.OrderDetailKey AS AppliedOrderDetailKey,RT.*, L.FromLocation LegFromLocation	, L.ToLocation 	 LegToLocation	
FROM		OrderHeader OH WITH (NOLOCK)
INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
INNER JOIN	OrderDetail OD WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
INNER JOIN	(SELECT		ContainerNo, BillOfLading, COUNT(*) TT
			FROM		OrderHeader OH WITH (NOLOCK)
			INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
			INNER JOIN  OrderDetail OD WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
			GROUP BY	ContainerNo, BillOfLading
			HAVING		COUNT(*) = 1 ) SCB ON OH.BillOfLading = SCB.BillOfLading AND OD.ContainerNo = SCB.ContainerNo
INNER JOIN	Routes RT WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
-- WHERE		SCB.ContainerNo = 'MSKU8894344'

