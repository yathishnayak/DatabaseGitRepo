


CREATE proc [dbo].[TMS_Integration_GetScheduleAndActuals_Flexport_New] -- TMS_Integration_GetScheduleAndActuals_Flexport_New 158335, 62558 
(
	@TMS_OrderKey	int,
	@DataKey		int
)
as
BEGIN
SET NOCOUNT ON
SET FMTONLY OFF
	
DECLARE @SiteID	VARCHAR(10) = 'Flexport'

DELETE		A
FROM		TKT_RouteDataNew  a 
LEFT JOIN	routes RT WITH (NOLOCK) on a.RouteKey = Rt.RouteKey and a.TMS_LegKey = Rt.LegKey
WHERE		a.orderkey = @TMS_OrderKey and Rt.routekey is null

EXEC [UPDATE_TKT_ROUTESDATANEW_ONReverseMapping] @TMS_OrderKey

SELECT * INTO #TMS_Flexport_ScheduleActuals FROM vw_TMS_Flexport_ScheduleActuals WHERE OrderKey = @TMS_OrderKey
SELECT * INTO #OrderHeader FROM OrderHeader WHERE OrderKey = @TMS_OrderKey
SELECT * INTO #OrderDetail FROM OrderDetail WHERE OrderKey = @TMS_OrderKey


SELECT TOP 1	OH.OrderKey,TH.DataKey,TH.SiteID,TH.TMS_OrderKey,TH.WorkOrdernumber,TH.WorKOrderDate,OH.status,
					(SELECT OD.OrderDetailKey,TC.ContainerKey,OD.ContainerNo,OD.status AS [Status],
						(SELECT A.RouteKey,A.LegKey,A.StopKey,A.TMS_LegKey,A.TMS_RouteKey,A.LocationType,A.OrderDetailKey,A.SchedPickup,
								A.SchedDelivery, A.ActualPickup,A.ActualDelivery,A.StopNum
						FROM	#TMS_Flexport_ScheduleActuals A WITH (NOLOCK)
						WHERE	A.DataKey = TH.DataKey
								AND A.SiteID = TH.SiteID
								AND A.OrderDetailKey = OD.OrderDetailKey
						ORDER BY A.StopNum
						FOR JSON PATH
						) AS STOPDATA
					FROM		TMS_Integration_Container TC WITH (NOLOCK)
					INNER JOIN	#OrderDetail OD WITH (NOLOCK) ON TC.TMS_OrderDetailKey = OD.OrderDetailKey
					WHERE		TC.DataKey = TH.DataKey AND TC.SiteID = TH.SiteID
					FOR JSON PATH
					) AS ContainerData
FROM			#OrderHeader OH WITH (NOLOCK)
INNER JOIN		TMS_Integration_Header TH WITH (NOLOCK) ON OH.OrderKey = TH.TMS_OrderKey
WHERE			TH.SiteID = @SiteID
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER 

DROP TABLE #TMS_Flexport_ScheduleActuals
DROP TABLE #OrderHeader
DROP TABLE #OrderDetail

END