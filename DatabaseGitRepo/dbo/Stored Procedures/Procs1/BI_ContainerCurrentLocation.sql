


CREATE Proc [dbo].[BI_ContainerCurrentLocation]
as
SET NOCOUNT ON;
set fmtonly off;




select OD.OrderDetailKey, Rt.LegNo, Rt.RouteKey, L.FromLocation, L.ToLocation, Rt.ActualArrival, A.AddrName, 
 ELD.EmptySetDate as EmptySetDate, G.Empty_returned_dt
into #ContainerData
from orderDetail OD WITH (NOLOCK)
inner join Routes Rt  WITH (NOLOCK) on Od.OrderDetailKey = RT.OrderDetailKey
inner join OrderHeader OH  WITH (NOLOCK) on Od.OrderKey = OH.OrderKey
inner join Leg L  WITH (NOLOCK) on Rt.LegKey = L.LegKey
inner join Address A  WITH (NOLOCK) on Rt.DestinationAddrKey = A.AddrKey
Left join EmptyLegData ELD WITH (NoLock) on Od.OrderDetailKey = ELD.OrderDetailKey
Left join (SELECT od.orderdetailkey,containerno,isnull(G.Empty_returned_dt, RT1.ActualArrival) as Empty_returned_dt
	FROM orderdetail od
	LEFT JOIN (
		SELECT OrderDetailKey, max(RouteKey) routekey 
		FROM Routes group by OrderDetailkey) AS RT ON od.orderdetailkey = rt.OrderDetailKey 
	INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey and Custkey=3442
	INNER JOIN Routes RT1 WITH (NOLOCK) ON RT1.RouteKey=RT.RouteKey
	INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=RT1.LegKey AND L.ToLocation='Port'
	Left join Gnosis_Integration_Container_Final G WITH (NOLOCK) on OD.OrderDetailKey = G.OrderDetailKey
	WHERE ActualArrival IS NOT NULL) G on Od.OrderDetailKey = G.OrderDetailKey
where OH.custkey = 3442
--order by OD.OrderDetailKey, Rt.LegNo

select distinct A.OrderDetailKey,ML.max_legno, firstLegStart.ActualArrival , ConsLeg.ConsLegNo,
	case when isnull(max_legno,0) = 0 and  isnull(firstLegStart.LegNo,1) = 1 then 'Terminal' 
		 when A.Empty_returned_dt is not null then 'Terminal- Returned'
		 When isnull(max_legno,0) <> 0 and A.LegNo = ConsLeg.ConsLegNo and A.AddrName = 'TRIUS LOGISTICS' and A.EmptySetDate is null  
		 then A.AddrName + '- Loaded'
		  When isnull(max_legno,0) <> 0 and A.LegNo = ConsLeg.ConsLegNo and A.AddrName = 'TRIUS LOGISTICS' and A.EmptySetDate is not null  
		 then A.AddrName + '- Empty'
		  When isnull(max_legno,0) <> 0 and A.LegNo = ConsLeg.ConsLegNo and A.AddrName <> 'TRIUS LOGISTICS'  
		 then A.AddrName 
		 When isnull(max_legno,0) <> 0 and ConsLeg.ConsLegNo is null and (a.ToLocation = 'Yard' OR A.AddrName like '%Jct%') then 'Prepull'
		 
	else null end as DelLocation,
	A.addrname
from #ContainerData A WITH (NOLOCK)
left join (select OrderDetailKey, max(legno) max_legno from #ContainerData where ActualArrival is not null group by OrderDetailKey) ML 
	on a.OrderDetailKey = ML.OrderDetailKey
inner join #ContainerData firstLegStart  WITH (NOLOCK)
	on A.OrderDetailKey = firstLegStart.OrderDetailKey and firstLegStart.LegNo = 1 
left join #ContainerData firstLeg WITH (NOLOCK) on A.OrderDetailKey = firstLeg.OrderDetailKey and firstLeg.LegNo = 1 and  firstLeg.ActualArrival is not null
left join (select OrderDetailKey, max(LEgNo) as ConsLegNo from #ContainerData WITH (NOLOCK) where ToLocation in ('Consignee','Customer','Shipper') group by ORderdetailKey) ConsLeg 
	on A.OrderDetailKey = ConsLeg.OrderDetailKey 
where A.LegNo <= isnull(ConsLeg.ConsLegNo,99) 

drop table #ContainerData
