
CREATE PROCEDURE [dbo].[Get_OrderDetailbyRouteKey]
@RouteKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT
		OH.OrderKey,
		OD.OrderDetailkey,
		OH.OrderNo,
		OD.ContainerNo,
		OD.VesselETA,
		[Route].SourceAddrkey AS PickupAddrkey,
		[Route].DestinationAddrkey AS DeliveryAddrkey,
		DriverID,
		DR.FirstName,
		DR.LastName
		, isnull(od.isStreetTurn,0) as isStreetTurn
		, isnull(U1.UserName,'') AS StreetTurnSetUser
		, ISNULL(od.StreetTurnSetDate,CONVERT(DATE,'2000-01-01')) AS StreetTurnSetDate
	FROM 
		dbo.OrderHeader oh
			LEFT JOIN  dbo.OrderDetail od	ON oh.OrderKey = od.OrderKey 
			LEFT JOIN  dbo.Routes [route]	ON [route].OrderDetailkey=od.Orderdetailkey     
			LEFT JOIN  dbo.Customer c		ON c.AddrKey = oh.SourceAddrKey
			LEFT JOIN  dbo.Customer cus		ON cus.AddrKey = oh.DestinationAddrKey
			LEFT JOIN  dbo.Customer billto	ON billto.AddrKey = oh.BillToAddrKey 
			LEFT JOIN  dbo.[Broker] br		ON oh.BrokerKey = br.BrokerKey
			LEFT JOIN  dbo.OrderType ot		ON oh.OrderTypeKey = ot.OrderTypeKey  
			LEFT JOIN  Driver DR			ON DR.Driverkey=[route].Driverkey		
			LEFT JOIN DBO.[User] U1				  ON OD.StreetTurnSetUser = U1.UserKey
	WHERE  [route].RouteKey= @RouteKey
END
