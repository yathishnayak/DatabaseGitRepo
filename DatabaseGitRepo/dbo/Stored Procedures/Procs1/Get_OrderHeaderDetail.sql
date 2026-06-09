CREATE PROCEDURE [dbo].[Get_OrderHeaderDetail]
@OrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	EXEC Insert_OrderDetailStops_ByOrderKey @OrderKey

	SELECT
		oh.OrderNo ,  oh.OrderDate ,  oh.CustKey,  oh.BillToAddrKey as BillToAddress,
		cus.CustName as BillToAddr,oh.SourceAddrKey as SourceAddress, SR.AddrName as SourceAddr,
		oh.DestinationAddrKey ,DT.AddrName as DestinationAddr,oh.ReturnAddrKey , 
		oh.OrderTypeKey,OH.PriorityKey,-- CASE WHEN ISNULL(oh.PriorityKey,0) IN (1,2,3,4) THEN null ELSE oh.PriorityKey END PriorityKey,
		oh.[Status] ,  
		HR.[Description] AS HoldReason ,
		oh.HoldDate ,
		br.BrokerName,
		br.BrokerKey ,
		br.BrokerID,
		oh.BrokerRefNo ,
		oh.Ach_Enabled,
		oh.Ach_Amount,
		oh.PortoForiginKey ,
		oh.CarrierKey,
		oh.VesselName ,
		oh.BillOfLading ,
		oh.BookingNo ,
		NULL AS CutOffDate ,  
		oh.CreateDate ,
		oh.CreateUserKey,
		oh.OrderKey,	
		os.StatusName as StatusDescription,
		'' as CommentDesc,
		OT.OrderType as ordertypedescription,
		oh.CsrKey as CSRKey,
		OH.ETADate,
		OH.BaseRateAmount,
		OH.SalesPersonKey,
		OH.ReleaseNo,
		CS.CsrKey as CSRKey,
		CS.CsrName as CSRName,
		oh.SalesPersonKey,
		SP.SalesPersonName,
		CM.CsrKey as CSRManagerKey,
		CM.CsrName as CSRManagerName,
		OH.MarketLocationKey,
		OH.Consignee,
		ISNULL(CC.ConsigneeKey,0) ConsigneeKey,
		OH.SteamShipLinekey,
		OH.DropLive as DropOrLive,
		SenderInfo
	FROM dbo.OrderHeader oh 		
		LEFT JOIN [Address] SR	with ( NOLOCK)		ON	SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [Address] DT	with ( NOLOCK)		ON	DT.AddrKey=OH.DestinationAddrKey
		LEFT JOIN dbo.Customer cus with ( NOLOCK)		ON cus.CustKey = oh.CustKey
		LEFT JOIN dbo.Customer_Consignee CC with ( NOLOCK)  ON CC.ConsigneeKey = OH.ConsigneeKey
		LEFT JOIN dbo.Company pickup with ( NOLOCK)	ON pickup.AddrKey = oh.SourceAddrKey
		LEFT JOIN dbo.company delivery with ( NOLOCK)	ON delivery.AddrKey = oh.DestinationAddrKey 
		LEFT JOIN dbo.[Broker] br with ( NOLOCK)		ON oh.brokerkey = br.brokerkey
		LEFT JOIN dbo.OrderType ot	with ( NOLOCK)	ON oh.OrderTypekey = ot.OrderTypeKey   
		LEFT JOIN dbo.[Status] os	with ( NOLOCK)	ON os.StatusKey = oh.[Status] 
		LEFT JOIN Dbo.Holdreason HR	with ( NOLOCK)	ON HR.HoldReasonKey=OH.HoldReasonKey
		LEft join SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CS with ( NOLOCK) on OH.CSRKey = CS.CSRKey
		Left join CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey
		LEFT JOIN SteamShipLine SL WITH(NOLOCK) ON SL.LineKey = OH.SteamShipLinekey
	WHERE oh.OrderKey=@OrderKey
END
