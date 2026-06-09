CREATE PROCEDURE [dbo].[Get_ContainerScheduleByOrderDetailKey]
@OrderDetailKey INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT 
		OD.OrderDetailkey,
		OD.OrderKey,
		RT.RouteKey,
		RT.DriverKey,
		LT.LegTypeID AS LegType,		
		RT.PickupDateFrom AS PickupTime,
		RT.DeliveryDateFrom AS DeliverTime,
		RT.FromLocation, 
		RT.ToLocation ,
		RT.ConfirmationNo,
		rt.DelConfirmationNo,
		OD.LastFreeDay,
		OD.CutOffDate,
		OD.VesselETA,
		CASE WHEN ISNULL(L.[Action],'') LIKE '%switch%' THEN 1 ELSE 0 END AS SwitchTo
	FROM dbo.OrderDetail od 	
		LEFT JOIN  dbo.[Routes] RT	ON RT.RouteKey = od.RouteKey
		LEFT JOIN  dbo.Leg L		ON L.LegKey=RT.LegKey
		LEFT JOIN  dbo.LegType LT	ON LT.LegtypeKey=L.LegTypeKey	
	WHERE  Od.Orderdetailkey =@OrderDetailKey;
END;