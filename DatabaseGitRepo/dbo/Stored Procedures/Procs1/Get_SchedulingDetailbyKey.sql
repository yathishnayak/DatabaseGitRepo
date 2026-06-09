CREATE PROCEDURE [dbo].[Get_SchedulingDetailbyKey]
@OrderDetailKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 
		od.OrderDetailkey, 
		RT.LegNo,
		LT.LegTypeID AS LegType,
		RT.SourceAddrKey,
		RT.DestinationAddrKey,
		EstimatedDistanceInMiles,
		EstimatedTravelTime,
		OD.[Status],
		Driverkey,
		RT.DeliveryDateFrom AS ScheduledArrival,
		RT.PickupDateFrom AS ScheduledDeparture,
		OdometerAtSource,
		OdometerAtDestination,
		ActualArrival,
		ActualDeparture	
	FROM dbo.OrderDetail od 	
		LEFT JOIN dbo.routes RT ON RT.RouteKey = od.RouteKey
		LEFT JOIN Leg L ON L.LegKey=RT.LegKey
		LEFT JOIN LegType LT ON LT.LegtypeKey=L.LegTypeKey
		LEFT JOIN dbo.ContainerSize cs ON cs.ContainerSizeKey = od.ContainerSizeKey
		LEFT JOIN  dbo.OrderDetailComments oc ON oc.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN  dbo.OrderStatus osd ON osd.[Status] = od.[Status]
		LEFT JOIN  dbo.Comment com ON com.CommentKey = oc.CommentKey
	WHERE  Od.Orderdetailkey =@OrderDetailKey
END
