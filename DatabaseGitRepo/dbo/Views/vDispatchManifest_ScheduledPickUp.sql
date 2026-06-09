

CREATE View [dbo].[vDispatchManifest_ScheduledPickUp]
AS

select oh.OrderNo,od.ContainerNo,r.RouteKey,r.LegKey,l.LegID,r.ScheduledPickupDate as scheduledpickUP,r.PickupDateFrom,r.DeliveryDateFrom,  r.ActualArrival as Deliverydate,
 r.DestinationAddrKey,a.AddrName as DeliverName,
a.Address1 as DeliverAddress,a.city as City,d.DriverID
from OrderHeader oh (nolock)
Inner join OrderDetail od (nolock) ON oh.OrderKey=od.OrderKey
INNER JOIN Routes r (nolock) ON od.OrderDetailKey=r.OrderDetailKey
Inner Join Address a (nolock) On r.DestinationAddrKey=a.AddrKey
Left Join Driver d (nolock) ON r.DriverKey=d.DriverKey
Inner Join Leg l (nolock) On r.LegKey=l.LegKey
inner join Legtype lg (nolock) On lg.LegtypeKey=l.LegTypeKey
where lg.LegTypeID like '%to consignee%'
and OrderNo like 'FL0%'--- this query is for flexport orders
--and (isNull(r.PickupDateFrom,'2022-06-01') >='2022-06-29' OR isnull(r.DeliveryDateFrom,'2022-06-01')>='2022-06-29' )
and (isNull(r.PickupDateFrom,'2022-06-01') between '2022-06-29' and '2022-06-30' OR isnull(r.DeliveryDateFrom,'2022-06-01') between '2022-06-29' and '2022-06-30' )

--order by ContainerNo 

