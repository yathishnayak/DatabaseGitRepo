


CREATE PROCEDURE [dbo].[Get_ContainerDispatchData]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT 
		RT.LegNo,L.[Description],RT.PickupDateFrom ,
		RT.DeliveryDateFrom ,Sour.City AS FromLocation,Dest.city AS ToLocation,	
		ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,RT.ChassisNo,CH.[ChassisType] AS ChassisType,
		RT.ActualDeparture AS ActualPickup,RT.ActualDeparture AS ActualDelDate,
		DR.DriverKey, RT.RouteKey,OD.OrderDetailKey,OD.OrderKey,0 AS PercentageComplete,--,RT.SwitchTo
		OD.VesselETA
	FROM OrderDetail OD 
		INNER JOIN OrderHeader OH ON OH.OrderKey=OH.OrderKey
		INNER JOIN dbo.[Routes] RT	ON RT.OrderDetailKey=OD.OrderDetailKey
		LEFT JOIN  dbo.OrderDetailStatus ODS ON ODS.[Status]=OD.[Status]
		INNER JOIN dbo.Leg L		ON RT.LegKey=L.LegKey
		INNER JOIN dbo.LegType LT	ON LT.LegtypeKey=L.LegTypeKey
		LEFT JOIN  dbo.[Address] Sour	ON Sour.Addrkey=RT.SourceAddrkey
		LEFT JOIN  dbo.[Address] Dest	ON Dest.Addrkey=RT.DestinationAddrkey
		LEFT JOIN  dbo.Driver DR		ON DR.DriverKey=RT.DriverKey
		LEFT JOIN dbo.Chassis CH		ON CH.chassisKey=RT.ChassisKey
	WHERE OH.[Status]=1 AND  (od.[Status] =7 OR  od.[Status] =8);
END
