CREATE proc TMS_Integration_LegVerificationReport
as
declare @DateToVerify datetime 
set @DateToVerify = Getdate() -2 
select RT.OrderKey, RT.OrderDetailKey, RT.RouteKey, OD.ContainerNo, OH.OrderNo,
		L.LegID, L.FromLocation, L.ToLocation, RTD.DateType,
		case when RTD.DateType = 'SP' then isnull(RT.PickupDateTo, Rt.PickupDateFrom) else '' end as ScheduledPickup,
		case when RTD.DateType = 'SD' then isnull(RT.DeliveryDateTo, RT.DeliveryDateFrom) else '' end as ScheduledDelivery,
		case when RTD.DateType = 'AP' then RT.ActualDeparture else '' end as ActualPickup, 
		case when RTD.DateType = 'AD' then RT.ActualArrival else '' end as ActualDelivery,
		RTD.CreateDate
		
from Routes Rt
inner join OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
inner join OrderHeader OH on OD.OrderKey = OH.OrderKey
inner join Leg L on RT.LEgkey = L.LegKey
left join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey
where RT.LastUpdateDate > @DateToVerify
and (PickupDateFrom > @DateToVerify OR DeliveryDateFrom > @DateToVerify OR
		ActualArrival > @DateToVerify OR ActualDeparture > @DateToVerify)
		and isnull(IsDryRun ,0) = 0
		and OH.custkey in (1966, 3170, 3165)
Order by Oh.OrderNo, OD.ContainerNo,Rt.LEgNo
