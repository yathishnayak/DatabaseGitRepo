
Create view vDispatchManifest
AS
select  oh.OrderNo,od.ContainerNo,r.RouteKey,r.LegKey,l.LegID,Convert(Varchar, r.ActualArrival,101) as Deliverydate,
r.DestinationAddrKey,a.AddrName as DeliverName,a.Address1 as DeliverAddress,a.city as City,
Convert(Varchar, r.ActualArrival,108) as DeliveryTime,d.DriverID
  
  from OrderHeader oh
Inner join OrderDetail od
ON oh.OrderKey=od.OrderKey
INNER JOIN Routes r
ON od.OrderDetailKey=r.OrderDetailKey
Inner Join Address a
On r.DestinationAddrKey=a.AddrKey
Inner Join Driver d
ON r.DriverKey=d.DriverKey
Inner Join Leg l
On r.LegKey=l.LegKey

where od.OrderKey in (select oh.OrderKey from OrderHeader(nolock) 
where oh.CustKey=411)
--order by oh.OrderNo,od.ContainerNo,Convert(Varchar, r.ActualArrival,101),
--Convert(Varchar, r.ActualArrival,108) 
