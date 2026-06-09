
CREATE PRocedure	[dbo].[SafeGateIntegration_UpdateDatetoTMS_BKP20250219]
AS
BEGIN


	DELETE A
	FROM (SELECT  * FROM SafeGateIntegration_VContainerDetails ) A
	WHERE SL <> 1

	SELECT			CD.ActivityID, CD.CreatedDate, CD.Yardname, CD.ContainerNo,ContainerDesc
					,CD.ChassisNo AS SafeGateChassisNo, CD.DriverId AS SafegareDriverID
					, RT.RouteKey, L.FromLocation,L.ToLocation , ScheduledPickupDate, ActualPickupDate  , L.LegID  , RT.ActualArrival, ActualDeparture 
					,YS.ShortName   SourceYard, YD.ShortName DestinationYard, RT.ChassisKey, RT.ChassisNo,RT.DriverKey,  YM.TMSYardID , YD.YardID DestyardID
					, YS.YardID SourceYardID
	INTO			#TMP
	FROM			(SELECT * FROM SafeGateIntegration_VContainerDetails) CD
	INNER JOIN		SafegateIntegration_SafegateTMSYardNameMapping YM ON CD.YardName = YM.SafeGateYardName
	INNER JOIN		OrderDetail OD ON CD.ContainerNo = OD.ContainerNo
	INNER JOIN		Routes RT On OD.OrderDetailKey = RT.OrderDetailKey 
	INNER JOIN		Leg L On RT.LegKey = L.LegKey 
	LEFT JOIN		Yard YD ON RT.DestinationAddrKey = YD.AddrKey  AND Effect = 1 -- AND YM.TMSYardID = YD.YardID
	LEFT JOIN		Yard YS ON RT.SourceAddrKey = YS.AddrKey   AND Effect = -1  -- AND YM.TMSYardID = YS.YardID
	WHERE			ISNULL(CD.ContainerNo,'') <> ''  AND 
					(1 = CASE WHEN EFFECT = 1 AND ISNULL(YD.ShortName,'') <> '' THEN 1 ELSE 0 END OR
					1 = CASE WHEN EFFECT = -1 AND ISNULL(YS.ShortName,'') <> '' THEN 1 ELSE 0 END) AND
					((ISNULL(YD.ShortName,'') <> '' AND ActualArrival IS NULL ) OR (ISNULL(YS.ShortName,'') <> '' AND ActualDeparture IS NULL ))
	ORDER BY		CD.ContainerNo 
	--BMOU4921284

	SELECT			ROW_NUMBER() OVER (PARTITION BY TM.ContainerNo ORDER BY TM.ContainerNo, TM.createdDate DESC ) SL, TM.ActivityId, RT.RouteKey, TM.ContainerNo, TM.createdDate,ContainerDesc,SafeGateChassisNo,SafegareDriverID, Yardname AS SafegateYardName,  TM.DestinationYard,TM.SourceYard,  RT.ChassisKey , RT.DriverKey
					,RT.ChassisNo,D.DriverID as Carrier , RS.Description AS RouteStatus	, LegID	, RT.Status AS RouteStatusID
					,RT.ActualArrival AS TMSActualArrival , RT.ActualDeparture AS TMSActualDeparture , TMSYardID ,  DestyardID,  SourceYardID
					,CASE WHEN DestinationYard <> '' THEN TM.CreatedDate ELSE NULL END AS YardCheckIn
					,CASE WHEN SourceYard <> '' THEN TM.CreatedDate ELSE NULL END AS YardCheckOut					
					,CASE WHEN DestinationYard <> ''  AND RT.DriverKey <> '' AND RS.Status = 2  THEN TM.CreatedDate ELSE NULL END AS ActualArrival
					,CASE WHEN SourceYard <> ''   AND RT.DriverKey <> '' AND RS.Status = 4  THEN TM.CreatedDate ELSE NULL END AS ActualDeparture
	INTO			#UPDATEDATA
	FROM			#TMP TM
	INNER JOIN		Routes RT ON TM.RouteKey = RT.RouteKey 
	INNER JOIN		RouteStatus RS ON RT.Status = RS.Status
	LEFT JOIN		Driver D ON RT.DriverKey = D.DriverKey
	ORDER BY		TM.ContainerNo

	-- SELECT * FROM #UPDATEDATA

	DELETE FROM #UPDATEDATA WHERE SL <> 1

	------------------------------------------------------------------------------
	-- SELECT		B.YardName, A.SourceYard, B.TMSYardName, A.RouteKey , B.RouteKey , A.TMSYardID,B.TMSYARDID, A.SourceYardID, B.SourceYardID
	UPDATE		B 
	SET			TMSYardName = SourceYard, RouteKey = A.Routekey,  TMSYARDID = A.TMSYardID, SourceYardID = A.SourceYardID, IsProcessed = 1
	FROM		#UPDATEDATA A
	INNER JOIN	SafeGateIntegration_VContainerDetails B ON A.ActivityId = B.ActivityId 
	WHERE		ISNULL(SourceYard,'') <> ''

	-- SELECT		B.YardName, A.DestinationYard, B.TMSYardName, A.RouteKey , B.RouteKey , A.TMSYardID,B.TMSYARDID, A.DestYardID, B.DestinationYardID
	UPDATE		B 
	SET			TMSYardName = DestinationYard, RouteKey = A.Routekey  , TMSYARDID = A.TMSYardID, DestinationYardID = A.DestYardID, IsProcessed = 1
	FROM		#UPDATEDATA A
	INNER JOIN	SafeGateIntegration_VContainerDetails B ON A.ActivityId = B.ActivityId 
	WHERE		ISNULL(DestinationYard,'') <> ''

	DELETE FROM #UPDATEDATA 
	WHERE		(TMSyardID <> ISNULL(SourceyardID,'') AND ISNULL(SourceyardID,'') <> '') OR (TMSyardID <> ISNULL(DestyardID,'') AND  ISNULL(DestyardID,'') <> '')
	-------------------------------------------------------------------------------------------------------------------------------------------------------------

	--SELECT		RT.YardCheckIn, RT.YardCheckOut  , UD.YardCheckIn, UD.YardCheckOut
	UPDATE		RT SET YardCheckIn = UD.YardCheckIn, YardCheckOut = UD.YardCheckOut
	FROM		#UPDATEDATA UD
	INNER JOIN	Routes RT ON UD.Routekey = RT.RouteKey
	
	DELETE			A
	FROM			SafeGateIntegration_ActualDepartureDateUpdate A
	INNER JOIN		#UPDATEDATA B ON A.ActivityId = B.ActivityId


	-- SELECT COUNT(*) FROM #UPDATEDATA

	INSERT INTO		SafeGateIntegration_ActualDepartureDateUpdate
					(ActivityId,RouteKey,ContainerNo,createdDate,ContainerDesc,SafeGateChassisNo,SafegareDriverID,SafegateYardName,DestinationYard,SourceYard,ChassisKey,DriverKey,ChassisNo,Carrier
					,RouteStatusID,RouteStatus,LegID,TMSActualArrival,TMSActualDeparture, YardCheckIn,YardCheckOut,ActualArrival,ActualDeparture)
	SELECT			ActivityId,RouteKey,ContainerNo,createdDate,ContainerDesc,SafeGateChassisNo,SafegareDriverID,SafegateYardName,DestinationYard,SourceYard,ChassisKey,DriverKey,ChassisNo,Carrier
					,RouteStatusID,RouteStatus,LegID,TMSActualArrival,TMSActualDeparture,YardCheckIn,YardCheckOut,ActualArrival,ActualDeparture
	FROM			#UPDATEDATA


	SELECT * 
	INTO #SafeGateIntegration_ActualDepartureDateUpdate
	FROm SafeGateIntegration_ActualDepartureDateUpdate
	--

	
	-- SELECT			AD.RouteStatus, AD.YardCheckOut, AD.TMSActualDeparture,AD.ActualDeparture ,RouteStatusID
	UPDATE			RT SET ActualDeparture = AD.ActualDeparture, ActualDepartureUpdateMethod = 'Safegate'
	FROM			SafeGateIntegration_ActualDepartureDateUpdate AD
	INNER JOIN		Routes RT ON AD.RouteKey = RT.RouteKey
	WHERE			RouteStatusID = 4 AND ISNULL(RT.ActualDeparture,'') = '' AND ISNULL(AD.ActualDeparture,'') <> ''


	-- SELECT			RouteStatus, AD.YardCheckIn, AD.TMSActualArrival,AD.ActualArrival, RouteStatusID
	UPDATE			RT SET ActualArrival = AD.ActualArrival, ActualArrivalUpdateMethod = 'Safegate'
	FROM			#SafeGateIntegration_ActualDepartureDateUpdate AD
	INNER JOIN		Routes RT ON AD.RouteKey = RT.RouteKey
	WHERE			RouteStatusID = 2  AND ISNULL(RT.ActualArrival,'') = '' AND ISNULL(AD.ActualArrival,'') <> ''

	

	/*
	UPDATE RT SET ActualArrival = NULL, ActualArrivalUpdateMethod = ''
	FROM Routes RT 
	WHERE ActualArrivalUpdateMethod = 'Internal'

	UPDATE RT SET ActualDeparture = NULL, ActualDepartureUpdateMethod = ''
	FROM Routes RT
	WHERE ActualDepartureUpdateMethod = 'Internal'	
	
	SELECT *
	FROM Routes RT 
	INNER JOIN SafeGateIntegration_ActualDepartureDateUpdate AD ON RT.RouteKey = AD.RouteKey 
	WHERE ActualArrivalUpdateMethod = 'Internal'	

	SELECT AD.* 
	FROM Routes RT
	INNER JOIN SafeGateIntegration_ActualDepartureDateUpdate AD ON RT.RouteKey = AD.RouteKey 
	WHERE ActualDepartureUpdateMethod = 'Internal'
	*/

	

END
