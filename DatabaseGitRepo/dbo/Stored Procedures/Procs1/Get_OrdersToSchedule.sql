CREATE PROCEDURE [dbo].[Get_OrdersToSchedule]
/*
dbo.fn_get_orders_to_schedule
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @OrderHeaderStatus SMALLINT
	DECLARE @OrderDetailStatus SMALLINT

	SET @OrderHeaderStatus= ( SELECT [Status] FROM orderstatus WHERE Description='In Progress' )
	SET @OrderDetailStatus= ( SELECT [Status] FROM orderstatus WHERE Description='In Progress' )

	SELECT
		od.OrderKey,
		od.OrderDetailkey,
		od.ContainerID,
		od.ContainerNo,
		CS.[Description] AS ContainerSize,
		od.Chassis,
		od.SealNo,
		od.Weight,
		cs.Description
	FROM
		dbo.OrderHeader oh
		LEFT JOIN dbo.OrderDetail od  ON oh.orderkey = od.orderkey
		LEFT JOIN dbo.OrderDetailComments oc ON oc.orderdetailkey = od.orderdetailkey
		LEFT JOIN dbo.Comment c					 ON c.commentkey = oc.commentkey
		LEFT JOIN dbo.OrderStatus osh		 ON osh.[Status]= oh.[Status]
		LEFT JOIN dbo.OrderStatus osd		 ON osd.[Status]= od.[Status]
		LEFT JOIN dbo.ContainerSize cs		 ON cs.containersizeKey = od.containersizeKey
	WHERE osh.[Status] = @OrderHeaderStatus and osd.[Status] = @OrderDetailStatus
	ORDER BY od.OrderKey,od.OrderDetailkey;
END
