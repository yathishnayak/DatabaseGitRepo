CREATE PROCEDURE [dbo].[Get_OrderItemListByStatus]
/*
dbo.fn_get_dispatchitemslist
*/
@OrderDetailkey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT RT.RouteKey, RT.OrderDetailKey, RT.LegNo, L.LegTypeID AS LegType, LG.Description AS LegTypeDesc,
		RT.DriverKey, d.DriverID,RT.DeliveryDateFrom AS ScheduledArrival, RT.PickupDateFrom AS ScheduledDeparture,RT.ActualArrival, RT.ActualDeparture, 
		CM.[Description] AS DriverNotes, RT.AppointmentNo, RT.PortWaitingTimeFrom, RT.PortWaitingTimeTo,RT.CustomerWaitingTimeFrom, 
		RT.CustomerWaitingTimeTo,od.ContainerID,od.ContainerNo
	FROM  dbo.OrderHeader oh  
		LEFT JOIN dbo.OrderDetail od	ON oh.OrderKey = od.OrderKey
		LEFT JOIN dbo.routes RT			ON RT.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN dbo.Leg LG		ON LG.LegKey = RT.LegKey
		LEFT JOIN dbo.LegType L			ON L.LegtypeKey = LG.LegTypeKey
		LEFT JOIN dbo.Driver d			ON d.DriverKey = RT.DriverKey
		LEFT JOIN OrderStatus OS		ON OS.[Status]=oh.[Status]
		LEFT JOIN SchedulerComment SN   ON SN.RouteKey=RT.RouteKey
		LEFT JOIN Comment CM  ON CM.CommentKey=SN.Commentkey
	WHERE od.orderdetailkey = @OrderDetailkey;
END
