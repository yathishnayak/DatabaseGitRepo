
-- EXEC TMS_Integration_GetOrderInfo_ACER_Delete

CREATE proc [dbo].[TMS_Integration_GetOrderInfo_ACER_Delete]
as
SET NOCOUNT ON
SET FMTONLY OFF

-- DROP TABLE #ContainersPending
declare @CustKey	int = 3165 -- 1447
select @CustKey = custkey from customer where left(custname,4) = 'ACER'

select OH.OrderKey, OD.OrderDetailKey, count(1) as OrderSent
into #ContainersPending
from  (SELECT * FROM OrderDetail WHERE ISNULL(IsEmpty,0) = 0 AND OrderKey = 92977) OD
inner join OrderHeader OH on OD.OrderKey = OH.OrderKey
LEft join TMS_Integration_Header IH on OH.orderkey = IH.TMS_OrderKey
LEft join TMS_Integration_Container IC on OD.OrderDetailKey = IC.TMS_OrderDetailKey
where CustKey = @CustKey and OD.Status not in (1,3) and isnull(IC.TMS_OrderDetailKey,0) > 0 
and IH.SiteID = 'ACER'
group by OH.OrderKey, OD.OrderDetailKey


SELECT * FROM (
select DISTINCT OH.OrderKey, OrderNo, OrderDate, OH.BillToAddrKey, 
	Oh.CustKey, CU.CustID, CU.CustName,OD.SourceAddrKey, OD.DestinationAddrKey, 
	OH.OrderTypeKey, CarrierKey, BrokerName, OH.BrokerKey,OT.OrderType,
	BillOfLading, OH.BookingNo, OH.CsrKey, C.CsrName, OH.Consignee,TH.SiteID,
BillToAddress = (
	Select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country
	from Address A where A.AddrKey = OH.BillToAddrKey
	for JSON PATH
),
SourceAddress = (
	Select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country
	from Address A where A.AddrKey = OH.SourceAddrKey
	for JSON PATH
),
DestAddress = (
	Select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country
	from Address A where A.AddrKey = OH.DestinationAddrKey
	for JSON PATH
),
ConsigneeAddress = (
	Select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country
	from Address A where A.AddrKey = CU.AddrKey
	for JSON PATH
),
ContainerInfo = (
	select OrderDetailKey, OD.ContainerNo, OD.ContainerSizeKey, CS.Description as ContainerSize, Weight, WeightUnit,
	LegInfo = (
		Select RouteKey, PickupDateFrom, DeliveryDateFrom, ActualArrival, ActualDeparture, LegKey, SourceAddrKey, DestinationAddrKey,
		AF.AddrKey as SAddrKey, AF.AddrName SAddrName, AF.Address1 SAddress1, AF.Address2 SAddress2, 
			AF.City SCity, AF.State SState, AF.ZipCode SZipCode, AF.Country SCountry,
		AT.AddrKey as TAddrKey, AT.AddrName TAddrName, AT.Address1 TAddress1, AT.Address2 TAddress2, 
		AT.City TCity, AT.State TState, AT.ZipCode TZipCode, AT.Country TCountry, CH.chassisNo
		From Routes RT 
		Left join Address AF on RT.SourceAddrKey = AF.AddrKey
		Left join Address AT on RT.DestinationAddrKey = AT.AddrKey
		LEFT Join Chassis CH on RT.ChassisKey = CH.chassisKey
		where RT.OrderDetailKey = OD.OrderDetailKey
		for JSON PATH
	)
	From OrderDetail OD
	inner join ContainerSize CS on OD.ContainerSizeKey = CS.ContainerSizeKey
	where OD.OrderKey = OH.OrderKey AND ISNULL(IsEmpty,0) = 0
	for JSON PATH
)
from (SELECT * FROM OrderHeader ) OH
inner join (SELECT * FROM OrderDetail WHERE ISNULL(IsEmpty,0) = 0) OD on OD.OrderKey = OH.OrderKey
Left join TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey
left join #ContainersPending CP on OH.OrderKey = CP.OrderKey and OD.OrderDetailKey = CP.OrderDetailKey
left join Broker B on OH.BrokerKey = B.BrokerKey
LEft join OrderType OT on OH.OrderTypeKey = OT.OrderTypeKey
LEft join CSR C on OH.CsrKey = C.CsrKey
Left join Customer CU on OH.CustKey = CU.CustKey
where OH.CustKey = @CustKey and   isnull(CP.OrderSent,0) = 0  )A
WHERE ContainerInfo LIKE '%LegInfo%'
for JSON PATH
