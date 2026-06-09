CREATE PROCEDURE [dbo].[Get_OrderDetailStatus]
/*
dbo.fn_getalldoheaderanddetails
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT
		oh.OrderKey,
		oh.OrderNo,
		oh.OrderDate, oh.CustKey, oh.BillToAddrKey,oh.SourceAddrKey, oh.DestinationAddrKey , 
		oh.ReturnAddrKey, oh.SourceKey, oh.OrderTypeKey, oh.[Status], oh.StatusDate, HR.[Description] AS HoldReason, oh.HoldDate,
		oh.BrokerKey, oh.BrokerRefNo, oh.PortoForiginKey, oh.CarrierKey, oh.VesselName, oh.BillOfLading, 
		oh.BookingNo, od.CutOffDate, oh.IsHazardous, oh.PriorityKey, 
		oh.CreateDate,oh.CreateUserKey, oh.PortofDestinationKey,	
		od.OrderDetailkey,
		od.ContainerID,
		od.ContainerNo,
		CS.[Description] AS ContainerSize,
		od.Chassis,
		od.SealNo,
		od.Weight,
		od.ApptDateTo,
		od.ApptDateTo,
		od.PickupDate,
		od.PickupTime,
		od.DropOffDate,
		od.DropOffTime,
		od.ActualPickupTime,
		od.ActualPickupTime,
		od.ActualPickupDate,
		od.ActualDropOffDate,
		od.[Status],
		od.StatusDate,
		HR.[Description] AS HoldReason,
		od.HoldDate,
		c.[Description] AS OrderDetialComment,
		os.[Description] AS OrderHeaderStatus,
		cs.[Description] AS ContainerSize,
		hr.[Description] AS HoldReasonDescr
	FROM
		dbo.OrderHeader oh 
		LEFT JOIN dbo.OrderDetail od		 ON oh.OrderKey = od.OrderKey
		LEFT JOIN dbo.orderdetailcomments oc ON oc.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN dbo.comment c				ON c.CommentKey = oc.CommentKey
		LEFT JOIN dbo.OrderStatus os		ON os.[Status]= od.[Status]
		LEFT JOIN dbo.ContainerSize cs		ON cs.ContainerSizeKey = od.ContainerSizeKey
		LEFT JOIN dbo.Holdreason hr			ON hr.HoldReasonKey = od.HoldReasonKey
	ORDER BY oh.OrderKey;
END
