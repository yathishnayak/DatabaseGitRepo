CREATE PROCEDURE [dbo].[Get_AllScheduledContainers]
/*
dbo.getscheduledcontainers
*/
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT od.OrderDetailkey, 
		od.ContainerNo,
		od.ContainerID,
		CS.[Description] AS ContainerSize,
		cs.[Description] AS ContainerDesc,
		od.RouteKey,	
		RT.DeliveryDateFrom AS ScheduledArrival,
		RT.PickupDateFrom AS ScheduledDeparture
	FROM dbo.OrderDetail od 	
		LEFT JOIN dbo.[Routes] RT ON RT.RouteKey = od.RouteKey	AND RT.OrderDetailKey=OD.OrderDetailKey	
		LEFT JOIN dbo.ContainerSize cs ON cs.ContainerSizeKey = od.ContainerSizeKey;
END;
