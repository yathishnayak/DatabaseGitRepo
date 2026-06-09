CREATE PROCEDURE [dbo].[Get_DelayedContainerLeg]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT C.CustName,OH.OrderNo,A.OrderKey,A.OrderDetailKey ,A.RouteKey,L.LegID,
		Sour.AddrName AS FromLocation,Dst.AddrName AS ToLocation,A.IsEmpty, A.PickupDateFrom,
		A.PickupDateTo,A.DeliveryDateFrom,A.DeliveryDateTo,OD.ContainerNo,
		A.ActualDeparture as ActualPickup, A.ActualArrival As ActualDelivery,
		case when A.ActualDeparture is null then 'Not Picked' else 'Not Delivered' end as Remarks,
		case when A.ActualDeparture is null then DATEDIFF(d,isnull(A.pickupDateTo,A.PickupDateFrom), GETDATE()) else 0 end as DelayedPickupDays,
		case when A.ActualArrival is null then  DATEDIFF(d,isnull(A.DeliveryDateTo,A.DeliveryDateFrom), GETDATE()) else 0 end as DelayedDeliveryDays
	FROM dbo.Routes A 
		INNER JOIN dbo.OrderHeader OH	ON OH.OrderKey=A.OrderKey
		INNER JOIN dbo.OrderDetail OD	ON A.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN dbo.Customer C		ON C.CustKey=OH.CustKey
		INNER JOIN dbo.Leg L			ON L.LegKey=A.LegKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=A.[Status]
		LEFT JOIN  dbo.[Address] Sour	ON Sour.AddrKey=A.SourceAddrKey
		LEFT JOIN  dbo.[Address] Dst	ON Dst.AddrKey=A.DestinationAddrKey
	WHERE  
	(( ISNULL(A.PickupDateTo, A.PickupDateFrom)<GETDATE() AND A.ActualDeparture IS NULL )
	OR( ISNULL(A.DeliveryDateTo,A.DeliveryDateFrom)<GETDATE() AND A.ActualArrival IS NULL ))
END