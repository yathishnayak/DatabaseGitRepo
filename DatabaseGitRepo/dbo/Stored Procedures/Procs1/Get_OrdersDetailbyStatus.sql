CREATE PROCEDURE [dbo].[Get_OrdersDetailbyStatus]
/*
dbo.fn_get_dispatchitems
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT DISTINCT
		oh.OrderNo ,
		oh.OrderDate ,
		oh.CustKey,
		oh.BillToAddrKey as BillingAddress
		,billto.CustName as BillToAddr,
		oh.SourceAddrKey as SourceAddress, c.CustName as SourceAddr,
		oh.DestinationAddrkey as DestinationAddress,cus.CustName as DestinationAddr,
		oh.ReturnAddrkey as ReturnAddress,
		oh.OrderTypeKey ,  
		br.BrokerName,
		br.BrokerID ,
		oh.BrokerRefno ,
		oh.PortoForiginKey ,
		oh.CarrierKey,
		oh.VesselName ,
		oh.BillOfLading ,
		oh.BookingNo ,
		od.CutOffDate ,  
		oh.CreateDate ,
		oh.CreateUserKey,
		oh.OrderKey,
		ot.[Description] as OrderTypeDescription,
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
		 CM.[Description] AS SchedulerNotes,
		ods.[Description] AS [Status]
	FROM 
		dbo.OrderDetail od 
			LEFT JOIN  dbo.OrderHeader oh  on oh.OrderKey = od.OrderKey 
			LEFT JOIN dbo.Routes [route] ON [route].OrderDetailkey=od.Orderdetailkey     
			LEFT JOIN  dbo.Customer c on c.AddrKey = oh.SourceAddrKey
			LEFT JOIN  dbo.Customer cus on cus.AddrKey = oh.DestinationAddrKey
			LEFT JOIN  dbo.Customer billto on billto.AddrKey = oh.BillToAddrKey 
			LEFT JOIN  dbo.[Broker] br on oh.BrokerKey = br.BrokerKey
			LEFT JOIN  dbo.OrderType ot on oh.OrderTypekey = ot.OrdertypeKey  
			LEFT JOIN  dbo.ContainerSize cs on cs.ContainerSizeKey = od.ContainerSizeKey
			LEFT JOIN  dbo.OrderDetailStatus ods on ods.[Status] = od.[Status]
			LEFT JOIN OrderStatus OS ON OS.[Status]=oh.[Status]
			LEFT JOIN SchedulerComment SC ON SC.RouteKey= route.RouteKey
			LEFT JOIN Comment CM ON CM.CommentKey=SC.Commentkey
	WHERE  OH.[Status] = 1 and (OD.[Status] =7 or  od.[Status] =8) 
	ORDER BY oh.OrderDate DESC; 
END
