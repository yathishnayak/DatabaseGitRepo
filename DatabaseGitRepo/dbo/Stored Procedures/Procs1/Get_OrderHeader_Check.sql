CREATE PROCEDURE [dbo].[Get_OrderHeader_Check]
/*
dbo.fn_get_order_header
*/
@DeliveryOrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 
		oh.OrderKey,	
		oh.OrderNo,
		oh.OrderDate,
		oh.CustKey,
		oh.BillToAddrKey,
		oh.SourceAddrKey ,
		oh.DestinationAddrKey ,
		oh.ReturnAddrKey ,
		oh.SourceAddrKey,
		oh.OrderTypeKey,
		oh.[Status],
		oh.StatusDate,
		HR.[Description] AS HoldReason,
		oh.HoldDate,
		oh.BrokerKey,
		br.BrokerName,
		br.BrokerID,
		oh.BrokerRefNo,
		oh.PortoForiginKey,
		oh.PortofDestinationKey,
		oh.CarrierKey,
		oh.VesselName,
		oh.BillOfLading,
		oh.BookingNo,
		NULL AS CutOffDate,
		oh.IsHazardous,
		oh.PriorityKey,
		oh.CreateDate,
		oh.CreateUserKey,
		ot.Description as OrderTypeDescription,
		osh.Description as StatusDescription,
		'' as CommentDesc
	FROM dbo.OrderHeader  oh 
		LEFT JOIN dbo.Broker br					ON oh.BrokerKey = br.BrokerKey
		LEFT JOIN dbo.OrderHeaderComments  ohc	ON ohc.OrderKey = oh.OrderKey
		--LEFT JOIN dbo.Comment   com				ON com.commentKey = ohc.commentKey	
		LEFT JOIN  dbo.OrderType ot				ON oh.OrderTypeKey = ot.OrdertypeKey  
		LEFT JOIN dbo.OrderStatus osh			ON osh.[Status] = oh.[Status] 
		LEFT JOIN Dbo.Holdreason	HR			ON HR.HoldReasonKey=OH.HoldReasonKey
	WHERE oh.orderkey = @DeliveryOrderKey;	
END
