
CREATE proc [dbo].[TMS_Integration_GetOrderInfo_Century]
as
SET NOCOUNT ON
SET FMTONLY OFF
-- EXEC [TMS_Integration_GetOrderInfo_Century_Delete]
-- DECLARE		@CustKey	int = 0 -- 1447
--SELECT		@CustKey = custkey from customer where left(custname,4) = 'Century'

SELECT		OH.OrderKey, OD.OrderDetailKey, count(1) as OrderSent
INTO		#ContainersPending
FROM		orderdetail  OD WITH (NOLOCK)
INNER JOIN	OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
LEFT JOIN	TMS_Integration_Header IH WITH (NOLOCK) on OH.orderkey = IH.TMS_OrderKey
LEFT JOIN	TMS_Integration_Container IC WITH (NOLOCK) on OD.OrderDetailKey = IC.TMS_OrderDetailKey
WHERE		OD.Status not in (1,3) and isnull(IC.TMS_OrderDetailKey,0) > 0 AND IC.SiteID = 'Century'
GROUP BY	OH.OrderKey, OD.OrderDetailKey

 

SELECT		DISTINCT    OH.OrderKey, OrderNo, OrderDate, OH.BillToAddrKey, 
			Oh.CustKey, CU.CustID, CU.CustName,OD.SourceAddrKey, OD.DestinationAddrKey, 
			OH.OrderTypeKey, CarrierKey, BrokerName, OH.BrokerKey,OT.OrderType,
			BillOfLading, OH.BookingNo, OH.CsrKey, C.CsrName, OH.Consignee,
			BillToAddress = (
				Select AddrKey, REPLACE(AddrName,'"','')AddrName, REPLACE(Address1,'"','')Address1, Address2, City, State, ZipCode, Country
				from Address A WITH (NOLOCK) where A.AddrKey = OH.BillToAddrKey
				for JSON PATH
			),
			SourceAddress = (
				Select AddrKey, REPLACE(AddrName,'"','')AddrName, REPLACE(Address1,'"','')Address1, Address2, City, State, ZipCode, Country
				from Address A WITH (NOLOCK) where A.AddrKey = OH.SourceAddrKey
				for JSON PATH
			),
			DestAddress = (
				Select AddrKey, REPLACE(AddrName,'"','')AddrName, REPLACE(Address1,'"','')Address1, Address2, City, State, ZipCode, Country
				from Address A WITH (NOLOCK) where A.AddrKey = OH.DestinationAddrKey
				for JSON PATH
			),
			ConsigneeAddress = (
				Select AddrKey, REPLACE(AddrName,'"','')AddrName, REPLACE(Address1,'"','')Address1, Address2, City, State, ZipCode, Country
				from Address A WITH (NOLOCK) where A.AddrKey = CU.AddrKey
				for JSON PATH
			),
			ContainerInfo = (
				select OrderDetailKey, OD.ContainerNo, OD.ContainerSizeKey, CS.Description as ContainerSize, Weight, WeightUnit,
				LegInfo = (
					Select RouteKey, PickupDateFrom, DeliveryDateFrom, ActualArrival, ActualDeparture, RT.LegKey, SourceAddrKey, DestinationAddrKey,
					AF.AddrKey as SAddrKey, REPLACE(AF.AddrName,'"','') SAddrName, REPLACE(AF.Address1,'"','') SAddress1, AF.Address2 SAddress2, 
						AF.City SCity, AF.State SState, AF.ZipCode SZipCode, AF.Country SCountry,
					AT.AddrKey as TAddrKey, REPLACE(AT.AddrName,'"','') TAddrName, REPLACE(AT.Address1,'"','') TAddress1, AT.Address2 TAddress2, 
					AT.City TCity, AT.State TState, AT.ZipCode TZipCode, AT.Country TCountry, CH.chassisNo,
					L.FromLocation,L.ToLocation,
					CASE WHEN L.FromLocation = 'Consignee' AND L.ToLocation = 'Consignee' THEN 'CC' ELSE '' END AS PrepullFlag
					From Routes RT WITH (NOLOCK)
					Left join Address AF WITH (NOLOCK) on RT.SourceAddrKey = AF.AddrKey
					Left join Address AT WITH (NOLOCK) on RT.DestinationAddrKey = AT.AddrKey
					LEFT Join Chassis CH WITH (NOLOCK) on RT.ChassisKey = CH.chassisKey
					LEFT JOIN Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
					where RT.OrderDetailKey = OD.OrderDetailKey
					for JSON PATH
				)
				From OrderDetail OD WITH (NOLOCK)
				inner join ContainerSize CS WITH (NOLOCK) on OD.ContainerSizeKey = CS.ContainerSizeKey
				where OD.OrderKey = OH.OrderKey
				for JSON PATH
			)
FROM		(SELECT * FROM OrderHeader WITH (NOLOCK) WHERE  CreateDate >= '2025-01-06') OH
INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
INNER JOIN	OrderDetail OD WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
LEFT JOIN	TMS_Integration_Header TH WITH (NOLOCK) on OH.OrderKey = TH.TMS_OrderKey
LEFT JOIN	#ContainersPending CP WITH (NOLOCK) on OH.OrderKey = CP.OrderKey and OD.OrderDetailKey = CP.OrderDetailKey
LEFT JOIN	Broker B WITH (NOLOCK) on OH.BrokerKey = B.BrokerKey
LEFT JOIN	OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
LEFT JOIN	CSR C WITH (NOLOCK) on OH.CsrKey = C.CsrKey
LEFT JOIN	Customer CU WITH (NOLOCK) on OH.CustKey = CU.CustKey
WHERE		isnull(CP.OrderSent,0) = 0 --  AND OH.OrderKey > 158831 --  OH.OrderKey IN (150060,154876,155223,155811,155819)
			AND LEFT(LTRIM(RTRIM(OD.ContainerNo)),4) NOT IN ('UUUU','JFLT')
			
ORDER BY OrderKey 
for JSON PATH
