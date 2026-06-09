CREATE PROCEDURE [dbo].[Get_dispatchitems]
/*
fn_get_dispatchitems
*/
@OrderDetailkey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT DISTINCT
		oh.OrderNo ,
		oh.OrderDate ,
		oh.CustKey,
		oh.BillToAddrKey AS BillingAddress,billto.CustName AS BillToAddr,
		oh.SourceAddrKey AS SourceAddress, c.CustName AS SourceAddr,
		oh.DestinationAddrKey AS DestinationAddress,cus.CustName AS DestinationAddr,
		oh.ReturnAddrKey AS ReturnAddress,
		oh.OrderTypeKey ,  
		br.BrokerName,
		br.BrokerID ,
		oh.BrokerRefNo ,
		oh.PortoForiginKey ,
		oh.CarrierKey,
		oh.VesselName ,
		oh.BillOfLading ,
		oh.BookingNo ,
		od.CutOffDate ,  
		oh.CreateDate ,
		oh.CreateUserKey,
		oh.orderkey,
		ot.[Description] AS OrderTypeDescription,
		od.OrderDetailkey,
		od.ContainerID,
		od.ContainerNo,
		CS.[Description] AS ContainerSize,
		cs.[Description] AS ContainerSizeDesc,
		od.Chassis,
		od.SealNo,
		od.[Weight],
		od.ApptDateFrom,
		od.ApptDateTo,
		od.LastFreeDay,
		CM.[Description] AS SchedulerNotes  
	FROM dbo.Routes route 
		LEFT JOIN dbo.OrderDetail od		ON route.OrderDetailKey = od.OrderDetailkey 
		LEFT JOIN dbo.OrderHeader oh		ON oh.OrderKey = od.OrderKey    
		LEFT JOIN dbo.Customer c			ON c.AddrKey = oh.SourceAddrKey
		LEFT JOIN dbo.Customer cus			ON cus.AddrKey = oh.DestinationAddrKey
		LEFT JOIN dbo.Customer billto		ON billto.AddrKey = oh.BillToAddrKey 
		LEFT JOIN dbo.[Broker] br			ON oh.BrokerKey = br.BrokerKey
		LEFT JOIN dbo.OrderType ot			ON oh.OrderTypeKey = ot.OrderTypeKey 
		LEFT JOIN dbo.ContainerSize cs		ON cs.ContainerSizeKey = od.ContainerSizeKey
		LEFT JOIN SchedulerComment SC ON SC.RouteKey=route.RouteKey
		LEFT JOIN Comment CM ON CM.CommentKey=SC.Commentkey
	WHERE oh.[Status]=1 AND  (od.[Status] =7 OR  od.[Status] =8)  AND od.OrderKey = @OrderDetailkey
	ORDER BY oh.OrderDate DESC; 
END
