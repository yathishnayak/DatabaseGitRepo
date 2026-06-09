CREATE PROCEDURE [dbo].[Get_OrdersToDispatch]
/*
dbo.fn_get_orders_to_dispatch
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @OrderHeaderStatus SMALLINT
	DECLARE @OrderDetailStatus SMALLINT

	SET @OrderHeaderStatus= ( SELECT [Status] FROM orderstatus WHERE Description='In Progress' )
	SET @OrderDetailStatus= ( SELECT [Status] FROM orderstatus WHERE Description='Send To Billing' )

	SELECT
		od.OrderKey,
		od.OrderDetailkey,
		od.ContainerID,
		od.ContainerNo,
		CS.[Description] AS ContainerSize,
		od.Chassis,
		od.SealNo,
		od.Weight,
		od.ApptDateFrom,
		od.ApptDateTo,
		od.LastFreeDay,
		 CMS.[Description] AS SchedulerNotes,  
		route.DeliveryDateFrom AS ScheduledArrival,
		route.PickupDateFrom ASScheduledDeparture  ,
		CM.[Description] AS DriverNotes,
		cs.[Description] AS ContainerSize
	FROM
		dbo.OrderHeader oh
		LEFT JOIN dbo.OrderDetail od	ON oh.OrderKey = od.OrderKey
		LEFT JOIN dbo.OrderDetailComments oc ON oc.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN dbo.Comment c			ON c.CommentKey = oc.CommentKey
		LEFT JOIN dbo.OrderStatus osd	ON osd.[Status]= od.[Status]
		LEFT JOIN dbo.OrderStatus oSh	ON osh.[Status]= oh.[Status]
		LEFT JOIN dbo.ContainerSize cs	ON cs.ContainerSizeKey = od.ContainerSizeKey
		LEFT JOIN dbo.routes route on route.RouteKey = od.RouteKey AND route.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN SchedulerDriverComment SD ON SD.RouteKey=route.RouteKey
		LEFT JOIN Comment CM ON CM.CommentKey=SD.Commentkey
		LEFT JOIN SchedulerComment SC ON SC.RouteKey=route.RouteKey
		LEFT JOIN Comment CMS ON CMS.CommentKey=SC.Commentkey
	WHERE oSh.[Status] = @OrderHeaderStatus  and osd.[Status] = @OrderDetailStatus
	ORDER BY od.OrderKey,od.OrderDetailkey;
END
