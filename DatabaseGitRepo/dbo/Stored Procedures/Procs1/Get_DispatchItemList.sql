CREATE PROCEDURE [dbo].[Get_DispatchItemList]
/*
fn_get_dispatchitemslist
*/
@OrderDetailKey INT  =10   
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT [route].RouteKey, [route].OrderDetailKey, [route].LegNo, LT.LegTypeID AS LegType, LG.[Description] LegTypeDesc,
	route.DriverKey, d.DriverID,[Route].DeliveryDateFrom AS ScheduledArrival, [route].PickupDateFrom AS ScheduledDeparture,[route].ActualArrival, [route].ActualDeparture, 
	CM.[Description] AS DriverNotes, [route].AppointmentNo, [route].PortWaitingTimeFrom, [route].PortWaitingTimeTo,[route].CustomerWaitingTimeFrom, 
	[route].CustomerWaitingTimeTo,od.ContainerID,od.ContainerNo
	FROM dbo.[Routes] [route] 
		LEFT JOIN dbo.OrderDetail od		ON [route].OrderDetailKey = od.OrderDetailkey
		LEFT JOIN dbo.OrderHeader oh		ON oh.OrderKey = od.OrderKey
		LEFT JOIN Leg			LG			ON LG.LegKey=[route].LegKey
		LEFT JOIN dbo.LegType LT			ON LT.LegtypeKey=LG.LegTypeKey
		LEFT JOIN dbo.Driver d				ON d.DriverKey = [route].DriverKey
		LEFT JOIN SchedulerDriverComment SC ON SC.RouteKey=[route].RouteKey
		LEFT JOIN Comment CM				ON CM.CommentKey=SC.Commentkey
	WHERE oh.[Status]=1 AND  (od.[Status] =7 OR  od.[Status] =8) AND [route].OrderDetailKey = @OrderDetailKey
END
