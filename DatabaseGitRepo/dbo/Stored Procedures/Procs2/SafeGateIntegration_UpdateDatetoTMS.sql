
CREATE PRocedure	[dbo].[SafeGateIntegration_UpdateDatetoTMS]
AS
BEGIN

	/*
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
	*/

	CREATE TABLE  #TMP
		(
			ActivityID			INT ,
			CreatedDate			DATETIME ,
			Yardname			VARCHAR(100) ,
			ContainerNo			VARCHAR(50) ,
			ContainerDesc		VARCHAR(20) ,
			SafeGateChassisNo	VARCHAR(50) ,
			SafegareDriverID	VARCHAR(20) ,
			RouteKey			INT ,
			FromLocation		VARCHAR(50) ,
			ToLocation			VARCHAR(50) ,
			ScheduledPickupDate DATETIME ,
			ActualPickupDate	DATETIME ,
			LegID				VARCHAR(50) ,
			ActualArrival		DATETIME ,
			ActualDeparture		DATETIME ,
			SourceYard			VARCHAR(20) ,
			DestinationYard		VARCHAR(20) ,
			ChassisKey			INT ,
			ChassisNo			VARCHAR(50) ,
			DriverKey			INT ,
			TMSYardID			INT ,
			DestyardID			INT ,
			SourceYardID		INT 
	)


	INSERT INTO #TMP
	EXEC SafeGateIntegration_UpdateDatetoTMS_GetData


	SELECT			ROW_NUMBER() OVER (PARTITION BY TM.ContainerNo ORDER BY TM.ContainerNo, TM.createdDate DESC ) SL, TM.ActivityId, RT.RouteKey, TM.ContainerNo, TM.createdDate,ContainerDesc,SafeGateChassisNo,SafegareDriverID, Yardname AS SafegateYardName,  TM.DestinationYard,TM.SourceYard,  RT.ChassisKey , RT.DriverKey
					,RT.ChassisNo,D.DriverID as Carrier , RS.Description AS RouteStatus	, TM.LegID	, RT.Status AS RouteStatusID
					,RT.ActualArrival AS TMSActualArrival , RT.ActualDeparture AS TMSActualDeparture , TMSYardID ,  DestyardID,  SourceYardID
					,CASE WHEN DestinationYard <> '' THEN TM.CreatedDate ELSE NULL END AS YardCheckIn
					,CASE WHEN SourceYard <> '' THEN TM.CreatedDate ELSE NULL END AS YardCheckOut					
					,CASE WHEN DestinationYard <> ''  AND RT.DriverKey <> '' AND RS.Status = 2  THEN TM.CreatedDate ELSE NULL END AS ActualArrival
					,CASE WHEN SourceYard <> ''   AND RT.DriverKey <> '' AND RS.Status = 4  THEN TM.CreatedDate ELSE NULL END AS ActualDeparture
	INTO			#UPDATEDATA
	FROM			#TMP TM
	INNER JOIN		Routes RT WITH (NOLOCK) ON TM.RouteKey = RT.RouteKey 
	INNER JOIN		RouteStatus RS  WITH (NOLOCK) ON RT.Status = RS.Status
	LEFT JOIN		Driver D  WITH (NOLOCK) ON RT.DriverKey = D.DriverKey
	ORDER BY		TM.ContainerNo

	-- SELECT * FROM #UPDATEDATA

	-- DELETE FROM #UPDATEDATA WHERE SL <> 1

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
					,[Status]=(CASE WHEN Status NOT IN(3,5) THEN 2 ELSE [Status] END)
	FROM			#SafeGateIntegration_ActualDepartureDateUpdate AD
	INNER JOIN		Routes RT ON AD.RouteKey = RT.RouteKey
	WHERE			RouteStatusID = 4 AND ISNULL(RT.ActualDeparture,'') = '' AND ISNULL(AD.ActualDeparture,'') <> ''


	-- SELECT			RouteStatus, AD.YardCheckIn, AD.TMSActualArrival,AD.ActualArrival, RouteStatusID
	UPDATE			RT SET ActualArrival = AD.ActualArrival, ActualArrivalUpdateMethod = 'Safegate'
					,[Status]=(CASE WHEN Status<>5 THEN 3 ELSE [Status] END)
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
