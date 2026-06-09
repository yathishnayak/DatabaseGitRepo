CREATE PROCEDURE [dbo].[Get_DelayedContainerLegCount]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	Select Count(1) As DelayedContainerLegCount from (
	SELECT C.CustName,OH.OrderNo,A.OrderKey,A.OrderDetailKey ,A.RouteKey,L.LegID,
		Sour.AddrName AS FromLocation,Dst.AddrName AS ToLocation,A.IsEmpty, A.PickupDateFrom,
		A.PickupDateTo,A.DeliveryDateFrom,A.DeliveryDateTo
	FROM dbo.Routes A 
		INNER JOIN dbo.OrderHeader OH	ON OH.OrderKey=A.OrderKey
		INNER JOIN dbo.Customer C		ON C.CustKey=OH.CustKey
		INNER JOIN dbo.Leg L			ON L.LegKey=A.LegKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=A.[Status]
		LEFT JOIN  dbo.[Address] Sour	ON Sour.AddrKey=A.SourceAddrKey
		LEFT JOIN  dbo.[Address] Dst	ON Dst.AddrKey=A.DestinationAddrKey
	WHERE  
	(( ISNULL(A.PickupDateTo, A.PickupDateFrom)<GETDATE() AND A.ActualDeparture IS NULL )
	OR( ISNULL(A.DeliveryDateTo,A.DeliveryDateFrom)<GETDATE() AND A.ActualArrival IS NULL ))
	) A
END