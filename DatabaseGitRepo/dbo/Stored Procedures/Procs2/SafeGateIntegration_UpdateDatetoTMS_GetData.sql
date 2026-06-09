

CREATE PROCEDURE [dbo].[SafeGateIntegration_UpdateDatetoTMS_GetData]
AS

BEGIN
	IF OBJECT_ID('tempdb..#ContainerDetails') IS NOT NULL
		DROP TABLE #ContainerDetails;

	IF OBJECT_ID('tempdb..#SafegateData') IS NOT NULL
		DROP TABLE #SafegateData;

	IF OBJECT_ID('tempdb..#TMSData') IS NOT NULL
		DROP TABLE #TMSData;

	IF OBJECT_ID('tempdb..#ContainerCountMapped') IS NOT NULL
		DROP TABLE #ContainerCountMapped;


	SELECT		DISTINCT ContainerNo 
	INTO		#ContainerDetails
	FROM		SafeGateIntegration_ContainerDetails
	WHERE		CreatedDate > GETDATE()-1


	SELECt		CD.ActivityID, CD.CreatedDate, CD.Yardname, CD.ContainerNo,ContainerDesc
				,CD.ChassisNo AS SafeGateChassisNo, CD.DriverId AS SafegareDriverID, ROW_NUMBER() OVER (PARTITION BY CD.ContainerNo ORDER BY CreatedDate) SL
				, Effect , YD.YardId ,  TYD.TMSYardID
	INTO		#SafegateData
	FROM		SafeGateIntegration_ContainerDetails CD
	INNER JOIN	SafegateIntegration_SafegateTMSYardNameMapping  TYD ON CD.YardName = TYD.SafeGateYardName 
	INNER JOIN	Yard YD ON TYD.TMSYardID = YD.YardId 
	INNER JOIN	#ContainerDetails TCD ON CD.ContainerNo = TCD.ContainerNo
	ORDER By	CD.ContainerNo,ActivityId 


	SELECT		ContainerNo, LegNo,0 OrderBy,  ShortName, YardId, RouteKey
				, FromLocation,ToLocation , ScheduledPickupDate, ActualPickupDate  , LegID  ,ActualArrival, ActualDeparture 
				, SourceYard,DestinationYard, ChassisKey, ChassisNo,DriverKey , DestyardID
				, SourceYardID
				, ROW_NUMBER() OVER (PARTITION BY ContainerNo ORDER BY LegNo, OrderBy ) SL, Checkoutin  
	INTO		#TMSData
	FROM		(SELECT		OD.ContainerNo, RT.LegNo,0 OrderBy,  YD.ShortName, YardId,-1 AS Checkoutin, RT.RouteKey
							, L.FromLocation,L.ToLocation , ScheduledPickupDate, ActualPickupDate  , L.LegID  , RT.ActualArrival, ActualDeparture 
							,YD.ShortName  SourceYard, ''  DestinationYard, RT.ChassisKey, RT.ChassisNo,RT.DriverKey , '' DestyardID
							,  YD.YardID SourceYardID
				FROM		OrderDetail OD
				INNER JOIN	Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
				INNER JOIN	Leg L ON RT.LegKey = L.LegKey
				INNER JOIN	Yard YD ON RT.SourceAddrKey = YD.AddrKey 
				INNER JOIN	#ContainerDetails TCD ON OD.ContainerNo = TCD.ContainerNo
				WHERE		L.FromLocation = 'Yard' AND ISNULL(RT.SourceAddrKey,0)  > 0
				UNION ALL
				SELECT		OD.ContainerNo, RT.LegNo,1, YD.ShortName, YardId,1, RT.RouteKey
							,L.FromLocation,L.ToLocation , ScheduledPickupDate, ActualPickupDate  , L.LegID  , RT.ActualArrival, ActualDeparture 
							, '' SourceYard, YD.ShortName DestinationYard, RT.ChassisKey, RT.ChassisNo,RT.DriverKey , YD.YardID DestyardID
							, '' SourceYardID
				FROM		OrderDetail OD
				INNER JOIN	Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
				INNER JOIN	Leg L ON RT.LegKey = L.LegKey
				INNER JOIN	Yard YD ON RT.DestinationAddrKey = YD.AddrKey
				INNER JOIN	#ContainerDetails TCD ON OD.ContainerNo = TCD.ContainerNo
				WHERE		L.ToLocation = 'Yard' AND ISNULL(RT.DestinationAddrKey,0)  > 0) A 
	Order By	ContainerNo, LegNo, OrderBy 



	SELECT		A.ContainerNo
	INTO		#ContainerCountMapped
	FROM		(SELECT ContainerNo, COUNT(*) CNT FROM #SafegateData  
				GROUP BY ContainerNo) A
	INNER JOIN	(SELECT ContainerNo, COUNT(*) CNT FROM #TMSData
				GROUP BY ContainerNo) B ON A.ContainerNo = B.ContainerNo AND A.CNT = B.CNT


				-- SELECT * FROM #TMSData 

	SELECT		ActivityID, CreatedDate, Yardname, SD.ContainerNo,ContainerDesc
				,SafeGateChassisNo,SafegareDriverID
				, RT.RouteKey, TD.FromLocation,TD.ToLocation , TD.ScheduledPickupDate, ActualPickupDate  , TD.LegID  , RT.ActualArrival, TD.ActualDeparture 
				,  SourceYard,  DestinationYard, RT.ChassisKey, RT.ChassisNo,RT.DriverKey,  TMSYardID , DestyardID,  SourceYardID
	FROM		#SafegateData SD 
	INNER JOIN	#TMSData TD ON SD.ContainerNo = TD.ContainerNo AND SD.YardId = TD.YardId AND SD.SL = TD.SL AND SD.Effect = TD.Checkoutin
	INNER JOIN	#ContainerCountMapped CM ON SD.ContainerNo = CM.ContainerNo
	INNER JOIN	Routes RT WITH (NOLOCK) ON TD.RouteKey = RT.RouteKey
	WHERE		(SD.Effect = 1 AND (TD.ActualArrival = '' OR TD.ActualArrival IS NULL ) AND SD.CreatedDate <>'')  
				OR (SD.Effect = -1 AND (TD.ActualDeparture = '' OR TD.ActualDeparture IS NULL ) AND SD.CreatedDate <>'') 
END