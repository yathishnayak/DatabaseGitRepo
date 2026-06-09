CREATE PROCEDURE [dbo].[Get_OrderDetails_Use]
/*
dbo.fn_get_order_detail
*/
@OrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT
		od.OrderDetailkey,
		od.ContainerID,
		od.ContainerNo,
		CS.[Description] AS ContainerSize,
		od.Chassis,
		od.SealNo,
		od.Weight,
		od.ApptDateFrom,
		od.ApptDateTo,
		od.PickupDate,
		od.PickupTime,
		od.DropOffDate,
		od.DropOffTime,
		od.ActualPickupTime,
		od.ActualDropOffTime,
		od.ActualPickupDate,
		od.ActualDropOffDate,
		od.[Status],
		od.StatusDate,
		HR.[Description] AS HoldReason,
		od.HoldDate,
		c.Description,
		os.Description,
		cs.Description,
		hr.Description 
	FROM
	dbo.OrderDetail od 
		LEFT JOIN dbo.OrderDetailComments oc ON oc.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN dbo.Comment c				 ON c.CommentKey = oc.CommentKey
		LEFT JOIN dbo.OrderStatus os		 ON os.[Status]= od.[Status]
		LEFT JOIN dbo.ContainerSize cs		 ON cs.ContainerSizeKey = od.ContainerSizeKey
		LEFT JOIN dbo.Holdreason hr			 ON hr.HoldReasonKey = od.HoldReasonKey
	WHERE OrderKey = @OrderKey;
END
