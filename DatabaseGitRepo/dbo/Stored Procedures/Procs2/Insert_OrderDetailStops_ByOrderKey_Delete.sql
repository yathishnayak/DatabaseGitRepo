

CREATE PROCEDURE Insert_OrderDetailStops_ByOrderKey_Delete -- Insert_OrderDetailStops_ByOrderKey_Delete 190088
(
	@OrderKey INT
)

AS

CREATE TABLE  #InsertedOrders (OrderStopKey INT);

SELECT		DISTINCT OH.OrderKey, OrderSource, OD1.ContainerNo, OrderNo, COUNT(*)  CNT
			, OD1.SourceAddrKey, OD1.DestinationAddrKey, ISNULL(ReturnAddrKey , RT1.DestinationAddrKey)ReturnAddrKey
INTO		#OrderDetail
FROM		OrderHeader OH WITH (NOLOCK)
INNER JOIN	(SELECT MIN(OrderDetailkey)OrderDetailkey, Orderkey FROM  OrderDetail WITH (NOLOCK) GROUP BY OrderKey) OD ON OH.OrderKey = OD.OrderKey
INNER JOIN	OrderDetail OD1 WITH (NOLOCK) ON OD.OrderDetailkey = OD1.OrderDetailKey
LEFT JOIn	(SELECT		MAX(Routekey)Routekey, OrderKey  FROM Routes  RT WITH (NOLOCK)
			INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey 
			WHERE		L.ToLocation = 'Port'
			GROUP BY	OrderKey) RT ON OH.OrderKey = RT.OrderKey 
LEFT JOIN	ROutes RT1 WITH (NOLOCK) ON RT.Routekey = RT1.RouteKey 
WHERE		OH.OrderKey = @OrderKey --AND  OS.OrderKey IS NULL 
GROUP BY	OH.OrderKey,  OrderSource, OD1.ContainerNo, OrderNo,  ReturnAddrKey,OD1.SourceAddrKey, OD1.DestinationAddrKey
			, ISNULL(ReturnAddrKey , RT1.DestinationAddrKey)
ORDER By	OH.OrderKey  DESC

DECLARE @CNT INT = 0
SET @CNT = (SELECT COUNT(*) FROM OrderStops WITH (NOLOCK) WHERE OrderKey = @OrderKey)

IF(@CNT = 0)
BEGIN
	INSERT INTO OrderStops (OrderKey,StopTypeKey,StopName,StopAddrKey,StopNumber, LocationType,CreateDate,CreateUserKey,UpdateDate, UpdateUserKey) OUTPUT INSERTED.OrderStopKey INTO #InsertedOrders
	SELECT		DISTINCT OD.OrderKey, 1,AddrName, SourceAddrKey,1,'Port',GETDATE(),714,GETDATE(),714
	FROM		#OrderDetail OD
	INNER JOIN	Address AD WITH (NOLOCK) ON OD.SourceAddrKey = AD.AddrKey
	LEFT JOIN	OrderStops OS WITH (NOLOCK) ON OD.OrderKey = OS.OrderKey
	WHERE		OD.OrderKey = @OrderKey AND OS.OrderKey IS NULL
	UNION ALL
	SELECT		DISTINCT OD.OrderKey, 3,AddrName, DestinationAddrKey,2,'Consignee',GETDATE(),714,GETDATE(),714
	FROM		#OrderDetail OD
	INNER JOIN	Address AD WITH (NOLOCK) ON OD.DestinationAddrKey = AD.AddrKey
	LEFT JOIN	OrderStops OS WITH (NOLOCK) ON OD.OrderKey = OS.OrderKey
	WHERE		OD.OrderKey = @OrderKey AND OS.OrderKey IS NULL
	UNION ALL
	SELECT		DISTINCT OD.OrderKey, 5,AddrName, ReturnAddrKey,3,'Port',GETDATE(),714,GETDATE(),714
	FROM		#OrderDetail OD
	INNER JOIN	Address AD WITH (NOLOCK) ON OD.ReturnAddrKey = AD.AddrKey
	LEFT JOIN	OrderStops OS WITH (NOLOCK) ON OD.OrderKey = OS.OrderKey
	WHERE		OD.OrderKey = @OrderKey AND OS.OrderKey IS NULL AND ISNULL(ReturnAddrKey,0) >0


	INSERT INTO OrderDetailStops (OrderDetailKey, StopTypeKey,StopName,StopAddrKey,StopNumber, LocationType)
	SELECT		OD.OrderDetailKey, OS.StopTypeKey,OS.StopName,OS.StopAddrKey,OS.StopNumber, OS.LocationType
	FROM		OrderStops OS WITH (NOLOCK)
	INNER JOIN	(SELECT MIN(OrderDetailkey)OrderDetailkey, Orderkey FROM  OrderDetail WITH (NOLOCK) GROUP BY OrderKey) OD ON OS.OrderKey = OD.OrderKey
	LEFT JOIN	OrderDetailStops ODS WITH (NOLOCK) ON OD.OrderDetailkey = ODS.OrderDetailKey 
	WHERE		OS.OrderStopKey IN (SELECT OrderStopKey FROM #InsertedOrders ) AND ODS.OrderDetailKey IS NULL
END
DROP TABLE #InsertedOrders
DROP TABLE #OrderDetail 

