CREATE PROCEDURE [dbo].[Get_OrdersToDispatchAssignment]
/*
dbo.fn_get_orders_to_dispatch_assignment
*/
AS
BEGIN	
	DECLARE @OrderHeaderStatus SMALLINT
	DECLARE @OrderDetailStatus SMALLINT

	SET @OrderHeaderStatus= ( SELECT [Status] FROM orderstatus WHERE Description='In Progress' )
	SET @OrderDetailStatus= ( SELECT [Status] FROM orderstatus WHERE Description='Send To Dispatch' )

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
		ro.PickupDateFrom AS ScheduledDeparture ,
		cs.[Description]
	FROM
		dbo.orderheader oh  
		LEFT JOIN dbo.orderdetail od	 ON oh.orderkey = od.orderkey
		LEFT JOIN dbo.orderdetailcomments oc ON oc.orderdetailkey = od.orderdetailkey
		LEFT JOIN dbo.comment c					 ON c.commentkey = oc.commentkey
		LEFT JOIN dbo.orderstatus osh		 ON osh.[Status]= oh.[Status]
		LEFT JOIN dbo.orderstatus osd		 ON osd.[Status]= od.[Status]
		LEFT JOIN dbo.containersize cs		 ON cs.containersizeKey = od.containersizeKey
		LEFT JOIN dbo.routes ro ON ro.orderkey = oh.orderkey AND ro.orderdetailkey = od.orderdetailkey
	WHERE osh.[Status] = @OrderHeaderStatus AND osd.[Status] = @OrderDetailStatus
	ORDER BY od.orderkey,od.orderdetailkey;
END
