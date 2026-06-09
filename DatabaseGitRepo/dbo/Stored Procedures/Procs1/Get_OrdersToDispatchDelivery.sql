CREATE PROCEDURE [dbo].[Get_OrdersToDispatchDelivery]
/*
dbo.fn_get_orders_to_dispatch_delivery
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
		od.ContainerNo,
		CS.[Description] AS ContainerSize,
		od.Chassis,
		od.SealNo,
		od.[Weight],
		od.ApptDateFrom,
		od.ApptDateTo,
		ro.DeliveryDateFrom AS ScheduledArrival,
		ro.PickupDateFrom AS ScheduledDeparture  ,
		cs.[Description]
	FROM
		dbo.OrderHeader oh 
		LEFT JOIN dbo.OrderDetail od		 ON oh.OrderKey = od.OrderKey
		LEFT JOIN dbo.OrderDetailComments oc ON oc.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN dbo.Comment c				 ON c.CommentKey = oc.CommentKey
		LEFT JOIN dbo.OrderStatus osh		 ON osh.[Status]= oh.[Status]
		LEFT JOIN dbo.OrderStatus osd		 ON osd.[Status]= oh.[Status]
		LEFT JOIN dbo.containersize cs		 ON cs.ContainerSizeKey = od.ContainerSizeKey
		LEFT join dbo.routes ro				 ON ro.OrderKey = oh.OrderKey and ro.OrderDetailKey = od.OrderDetailkey
	WHERE osh.[Status] = @OrderHeaderStatus AND osd.[Status] = @OrderDetailStatus
	ORDER BY od.OrderKey,od.OrderDetailkey;
END
