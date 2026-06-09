CREATE PROCEDURE [dbo].[Get_AllOrdersToGenerateInvoice]
/*
dbo.fn_getorderstogenerateinvoice
*/
@OrderKey  INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT DISTINCT
	 oh.OrderKey,
	 oh.OrderNo,
	 oh.OrderDate, oh.CustKey, oh.BillToAddrKey,oh.SourceAddrKey, oh.DestinationAddrKey , 
	 oh.ReturnAddrKey, oh.SourceAddrKey, oh.OrderTypeKey, oh.[Status], oh.StatusDate
	 , HR.[Description] HoldReason, oh.HoldDate,
	 oh.BrokerKey, oh.BrokerRefNo, oh.PortoForiginKey, oh.CarrierKey, oh.VesselName
	 , oh.BillOfLading, oh.BookingNo, od.CutOffDate, oh.IsHazardous, oh.PriorityKey, 
	 oh.CreateDate,oh.CreateUserKey, oh.PortofDestinationKey,	
	 od.OrderDetailkey,
	 od.ContainerNo,
	 od.ContainerSizeKey,
	 od.Chassis,
	 od.SealNo,
	 od.[Weight],
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
	 od.HoldReasonKey,
	 od.HoldDate,
	 c.Description,
	 os.Description,
	 cs.Description,
	 hr.Description,
	 cr.CarrierID 
 FROM
	dbo.OrderHeader oh 
		join dbo.OrderDetail od				 ON oh.OrderKey = od.OrderKey 
		LEFT JOIN dbo.OrderDetailComments oc ON oc.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN dbo.Comment c				 ON c.CommentKey = oc.CommentKey
		LEFT JOIN dbo.OrderStatus os		 ON os.[Status]= od.[Status]
		LEFT JOIN dbo.ContainerSize cs		 ON cs.ContainerSizeKey = od.ContainerSizeKey
		LEFT JOIN dbo.Holdreason hr			 ON hr.HoldReasonKey = od.HoldReasonKey
		LEFT JOIN dbo.Carrier cr			 ON cr.CarrierKey = oh.CarrierKey
 ORDER BY oh.OrderKey;
END
