
CREATE proc [dbo].[Get_DriverFlowSchedule] --Get_DriverFlowSchedule 2, '2020-10-15','2020-10-25'
(
	@DriverKey  int = 0,
	@FromDate	datetime = '2020-12-01',
	@ToDate		datetime = '2020-12-31', 
	@StatusKey	smallint	= 0,
	@Type		varchar(100) = ''
)
AS
BEGIN
	select R.DriverKey, D.DriverID, R.PickupDateFrom, R.PickupDateTo, OT.OrderType,OH.OrderNo, OH.OrderDate, 
		OH.VesselName, OH.BillOfLading, OH.BookingNo, 
		R.LegKey, R.LegNo, L.LegID, R.DeliveryDateFrom, R.DeliveryDateTo, 
		replace(isnull(SA.AddrName, '') + ', ' + isnull(SA.city,'') + ', ' + isnull(SA.State,'') + ', '+ isnull(SA.Country,''),', , ','') as SourceAddress,
		replace(isnull(DA.AddrName, '') + ', ' + isnull(DA.city,'') + ', ' + isnull(DA.State,'') + ', '+ isnull(DA.Country,''),', , ','') as DestinationAddress
	from routes R
		inner join Driver D on D.DriverKey = R.DriverKey
		inner join OrderHeader OH on R.OrderKey = OH.OrderKey
		inner join OrderType OT on OH.OrderTypeKey = OT.OrderTypeKey
		left join address SA on R.SourceAddrKey = SA.AddrKey
		left join Address DA on R.DestinationAddrKey = DA.AddrKey
		left join Leg L on R.LegKey = L.LegKey
	where
		R.DriverKey = @DriverKey
		and R.PickupDateFrom >= convert(date,@FromDate)
		and R.DeliveryDateFrom <= convert(date, @ToDate)

END	
