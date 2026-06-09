
CREATE PROCEDURE [dbo].[Get_OrderHeaderbyOrderKey]
/*
dbo.fn_get_orderheaderbykey
Order Screen > Order level Detail
*/
@OrderKey INT=0
AS
BEGIN
    SET NOCOUNT ON
    SET FMTONLY OFF

	SELECT COUNT (1) AS ContainerCount ,OrderKey INTO #ContainerCount
	FROM OrderDetail  
	WHERE orderkey=@OrderKey OR @OrderKey = 0
	GROUP BY OrderKey
	
    SELECT 
        oh.OrderNo ,  oh.OrderDate ,  oh.CustKey,  
        cus.AddrKey as BillToAddressKey,  cus.CustName as BillToAddrName,
        oh.SourceAddrKey as SourceAddressKey, SR.AddrName as SourceAddrName,
        oh.DestinationAddrKey as DestinationAddressKey,DT.AddrName as DestinationAddrName,
        oh.ReturnAddrKey as ReturnAddressKey, 
        oh.OrderTypeKey ,oh.PriorityKey,
        oh.[Status] ,  
		OH.StatusDate AS StatusDate,
        HR.[Description] AS HoldReason ,
        oh.HoldDate ,
        br.BrokerName,
		br.BrokerKey,
        br.BrokerID ,
        oh.BrokerRefNo ,
        oh.PortoForiginKey ,
        oh.CarrierKey,
        oh.VesselName ,
        oh.BillOfLading ,
        oh.BookingNo ,
        NULL AS CutOffDate ,  
        oh.CreateDate ,
        oh.CreateUserKey,
        oh.OrderKey,
        ot.OrderType as OrderTypeDescription,
        os.Description as StatusDescription,     
		'' as NextAction,
		CS.CsrKey as CSRKey,
		CS.CsrName as CSRName,
		CT.ContainerCount,
		SR.City AS PickupLocation,
		DT.City AS DeliveryLocation,
		CUS.CustName,
		oh.SalesPersonKey,
		SP.SalesPersonName,
		CM.CsrKey as CSRManagerKey,
		CM.CsrName as CSRManagerName
    FROM dbo.OrderHeader oh   with ( NOLOCK)      
        LEFT JOIN dbo.Customer cus with ( NOLOCK) on cus.CustKey = oh.CustKey
        --LEFT JOIN dbo.Company pickup with ( NOLOCK) on pickup.AddrKey = oh.SourceAddrKey
        --LEFT JOIN dbo.Company delivery with ( NOLOCK) on delivery.AddrKey = oh.DestinationAddrKey 
		LEFT JOIN [Address] SR	with ( NOLOCK) 		ON	SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [Address] DT	with ( NOLOCK) 		ON	DT.AddrKey=OH.DestinationAddrKey
        LEFT JOIN dbo.[Broker] br with ( NOLOCK) on oh.BrokerKey = br.BrokerKey
        LEFT JOIN dbo.OrderType ot  with ( NOLOCK) on oh.OrderTypeKey = ot.OrderTypeKey   
        LEFT JOIN dbo.OrderStatus os with ( NOLOCK) on os.[Status] = oh.[Status]
		LEFT JOIN Dbo.Holdreason	HR	with ( NOLOCK) ON HR.HoldReasonKey=OH.HoldReasonKey
		LEFT JOIN #ContainerCount CT with ( NOLOCK) ON CT.OrderKey=OH.OrderKey
		LEft join SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CS with ( NOLOCK) on OH.CSRKey = CS.CSRKey
		Left join CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey

    WHERE (oh.orderkey=@OrderKey OR @OrderKey = 0)	
END
