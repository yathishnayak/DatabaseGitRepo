
CREATE PROCEDURE [dbo].[SafeGateIntegration_GetYardDifference_Base20241025]
AS
BEGIN
	DECLARE @IsDebug BIT = 0
	----------------------Safegate Data ------------------------------------------------------------------------
	SELECT		ActivityId, YardName,CD.ContainerNo,CreatedDate, ContainerDesc -- ,Y.ShortName TMSYardName
				,  Effect,ContainerType, YM.TMSYardID, Y.AddrKey
				,CASE WHEN ContainerType = 'Empty Container' THEN 1 ELSE 0 END IsEmpty
				, ROW_NUMBER() OVER (Partition BY CD.ContainerNo, CONVERT(VARCHAR,CreatedDate,101),Effect,ISNULL(COntainerType,'') ORDER BY CreatedDate) AS SL
	INTO		#SFGData
	FROM		SafeGateIntegration_ContainerDetails CD 
	INNER JOIN	(SELECT		DISTINCT ContainerNo
				FROM		SafeGateIntegration_ContainerDetails CD
				WHERE		CreatedDate > CAST(CONVERT(VARCHAR,GETDATE()-30,102) AS DATETIME) ) CD1 ON CD.ContainerNo = CD1.ContainerNo
	INNER JOIN	SafegateIntegration_SafegateTMSYardNameMapping YM ON CD.YardName = YM.SafeGateYardName
	INNER JOIN	Yard Y ON YM.TMSYardID = Y.YardId
	WHERE		1 = 1   --AND CD.ContainerNo = 'TCLU4475276'

	-------------------------TMS Data----------------------------------------------------------------------------
	SELECT		OrderType,ContainerNo,ActualDeparture,ActualArrival, ISNULL(DeliveryYard,PickupYard) YardLocation
				, ISNULL(DeliveryYardID,PickupYardID) YardLocationID
				,ISNULL(IsDeliveryYard,IsPickupYard) Effect,FromLocation,ToLocation,IsEmpty , LegID, LegNo, RouteKey
				, DestinationAddrKey,SourceAddrKey
	INTO		#TMSData
	FROM		(SELECT		 OT.OrderType, ContainerNo,ActualDeparture, ActualArrival
							,YS.ShortName PickupYard, YD.ShortName DeliveryYard, RT.RouteKey, RT.DestinationAddrKey,RT.SourceAddrKey
							,YS.YardId PickupYardID, YD.YardId DeliveryYardID, L.LegID,RT.LegNo
							, CASE WHEN YS.ShortName IS NULL THEN NULL ELSE -1 END IsPickupYard
							, CASE WHEN YD.ShortName IS NULL THEN NULL ELSE 1 END IsDeliveryYard
							,  L.FromLocation,L.ToLocation
							, CASE WHEN OT.OrderType = 'Import' AND (L.FromLocation = 'Consignee' OR L.ToLocation = 'Port') THEN  1 ELSE  
							CASE WHEN OT.OrderType = 'Export' AND (L.FromLocation = 'Port' OR L.ToLocation = 'Consignee') THEN  1 ELSE  0 END
							END AS  IsEmpty 
							,CASE WHEN L.FromLocation = 'Yard' AND L.ToLocation = 'Yard' THEN 1 ELSE 0 END ISExclude
				FROM		OrderDetail OD
				INNER JOIN	Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
				INNER JOIN	OrderHeader OH ON OD.OrderKey = OH.OrderKey
				INNER JOIN	OrderType OT ON OH.OrderTypeKey = OT.OrderTypeKey
				INNER JOIN	Leg L ON RT.LegKey = L.LegKey
				LEFT JOIN	Yard YD ON RT.DestinationAddrKey = YD.AddrKey
				LEFT JOIN	Yard YS ON RT.SourceAddrKey = YS.AddrKey
				WHERE		1 = 1 -- AND ContainerNo = 'TCLU4475276' 
							AND (L.FromLocation = 'Yard' OR L.ToLocation = 'Yard')							
				)A 
	WHERE		ISExclude = 0

	------------------------------------------------------------------------------------------------------------------------------------------------------------

	IF(@IsDebug = 1)
	BEGIN
		SELECT * FROM #SFGData
		SELECT * FROM #TMSData
	END

	SELECT		A.ActivityId, A.ContainerNo,A.YardName, A.ContainerDesc, A.AddrKey, A.ContainerType ,A.Effect,A.CreatedDate,B.YardLocation TMSYardName, B.LegID, B.RouteKey
				,   CAST(ISNULL(B.LegNo,'') AS VARCHAR)LegNo
				, CASE WHEN B.Effect = 1 THEN B.ActualArrival ELSE B.ActualDeparture END AS ArrivalDepartureDate 
				, DestinationAddrKey,SourceAddrKey
				,CASE WHEN C.YardName <> A.YardName 
				THEN 'One more Record found with ActivityID ' +  CAST(C.ActivityId AS VARCHAR) +  ' for the same Leg on same day (' + CAST(C.CreatedDate AS VARCHAR)  
				+') where Location is ' +  C.YardName  ELSE NULL END AS Remarks
				-- ,A.ContainerNo , B.ContainerNo , A.Effect , B.Effect , A.IsEmpty , B.IsEmpty, C.ContainerNo,C.Effect,C.IsEmpty
	FROM		#SFGData A
	INNER JOIN	#TMSData B ON A.ContainerNo = B.ContainerNo AND A.Effect = B.Effect AND A.IsEmpty = B.IsEmpty
				AND CONVERT(VARCHAR,CreatedDate,101) = CONVERT(VARCHAR, CASE WHEN B.Effect = 1 THEN B.ActualArrival ELSE B.ActualDeparture END,101)  AND SL = 1
	LEFT JOIN	(SELECT * FROM #SFGData WHERE SL = 2) C ON A.ContainerNo = C.ContainerNo AND A.Effect = C.Effect AND A.IsEmpty = C.IsEmpty
				AND CONVERT(VARCHAR,A.CreatedDate,101) = CONVERT(VARCHAR,A.CreatedDate,101) 
	WHERE		1 = 1  AND A.TMSYardID <> B.YardLocationID
	ORDER BY	A.ContainerNo,A.CreatedDate

	DROP TABLE	#SFGData
	DROP TABLE	#TMSData
	 
END

