
CREATE proc [dbo].[TMS_Integration_GetOrderInfo_Century_Check]
as
SET NOCOUNT ON
SET FMTONLY OFF
-- EXEC [TMS_Integration_GetOrderInfo_Century_Delete]
DECLARE		@CustKey	int = 3402 -- 1447
--SELECT		@CustKey = custkey from customer where left(custname,4) = 'Century'

SELECT		OH.OrderKey, OD.OrderDetailKey, count(1) as OrderSent
INTO		#ContainersPending
FROM		orderdetail OD
INNER JOIN	OrderHeader OH on OD.OrderKey = OH.OrderKey
LEFT JOIN	TMS_Integration_Header IH on OH.orderkey = IH.TMS_OrderKey
LEFT JOIN	TMS_Integration_Container IC on OD.OrderDetailKey = IC.TMS_OrderDetailKey
WHERE		CustKey = @CustKey and OD.Status not in (1,3) and isnull(IC.TMS_OrderDetailKey,0) > 0
GROUP BY	OH.OrderKey, OD.OrderDetailKey

 

SELECT		DISTINCT    OH.OrderKey, OrderNo, OD.ContainerNo,H.DataKey,FileName , OrderNo , OrderDate, OH.BillToAddrKey, 
			Oh.CustKey, CU.CustID, CU.CustName,OD.SourceAddrKey, OD.DestinationAddrKey, 
			OH.OrderTypeKey, CarrierKey, BrokerName, OH.BrokerKey,OT.OrderType,
			BillOfLading, BookingNo, OH.CsrKey, C.CsrName, OH.Consignee,
			BillToAddress = (
				Select AddrKey, REPLACE(AddrName,'"','')AddrName, REPLACE(Address1,'"','')Address1, Address2, City, State, ZipCode, Country
				from Address A where A.AddrKey = OH.BillToAddrKey
				for JSON PATH
			),
			SourceAddress = (
				Select AddrKey, REPLACE(AddrName,'"','')AddrName, REPLACE(Address1,'"','')Address1, Address2, City, State, ZipCode, Country
				from Address A where A.AddrKey = OH.SourceAddrKey
				for JSON PATH
			),
			DestAddress = (
				Select AddrKey, REPLACE(AddrName,'"','')AddrName, REPLACE(Address1,'"','')Address1, Address2, City, State, ZipCode, Country
				from Address A where A.AddrKey = OH.DestinationAddrKey
				for JSON PATH
			),
			ConsigneeAddress = (
				Select AddrKey, REPLACE(AddrName,'"','')AddrName, REPLACE(Address1,'"','')Address1, Address2, City, State, ZipCode, Country
				from Address A where A.AddrKey = CU.AddrKey
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
					From Routes RT 
					Left join Address AF on RT.SourceAddrKey = AF.AddrKey
					Left join Address AT on RT.DestinationAddrKey = AT.AddrKey
					LEFT Join Chassis CH on RT.ChassisKey = CH.chassisKey
					LEFT JOIN Leg L ON RT.LegKey = L.LegKey
					where RT.OrderDetailKey = OD.OrderDetailKey
					for JSON PATH
				)
				From OrderDetail OD
				inner join ContainerSize CS on OD.ContainerSizeKey = CS.ContainerSizeKey
				where OD.OrderKey = OH.OrderKey
				for JSON PATH
			)
FROM		(SELECT * FROM OrderHeader WHERE  CreateDate >= '2025-01-06') OH
INNER JOIN	OrderDetail OD on OD.OrderKey = OH.OrderKey
LEFT JOIN	TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey
LEFT JOIN	#ContainersPending CP on OH.OrderKey = CP.OrderKey and OD.OrderDetailKey = CP.OrderDetailKey
LEFT JOIN	Broker B on OH.BrokerKey = B.BrokerKey
LEFT JOIN	OrderType OT on OH.OrderTypeKey = OT.OrderTypeKey
LEFT JOIN	CSR C on OH.CsrKey = C.CsrKey
LEFT JOIN	Customer CU on OH.CustKey = CU.CustKey
LEFT JOIN	Integration_JCB.dbo.TMS_IntegrationFileProcessInfo FPI ON FileName = OrderNo AND FPI.SiteID = 'Century'
LEFT JOIN	Integration_JCB.dbo.Century_Header H ON FPI.FileProcessKey = H.FileProcessKey
WHERE		OH.CustKey = @CustKey and   isnull(CP.OrderSent,0) = 0 --  AND OH.OrderKey > 158831 --  OH.OrderKey IN (150060,154876,155223,155811,155819)
			AND H.DataKey IS NULL
ORDER BY	OrderKey 
-- for JSON PATH
