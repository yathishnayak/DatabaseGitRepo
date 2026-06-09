
CREATE PRocedure [dbo].[SafeGateIntegration_GetActualDepartureUpdateInfo]
AS


BEGIN

	 	-- SELECT			A.Routekey, B.ActualArrival, TMSActualArrival, B.ActualArrivalUpdateMethod, A.ActualArrival
	UPDATE		A SET TMSActualArrival = B.ActualArrival
	FROM			SafeGateIntegration_ActualDepartureDateUpdate A
	INNER JOIN		Routes B ON A.RouteKey = B.RouteKey 
	WHERE			1 = 1  --  AND COntainerNo = 'CAAU6089165'
					AND (ContainerDesc = 'Checkin' 	AND ISNULL(TMSActualArrival,'') = '')
					AND ISNULL(B.ActualArrival,'') <> '' 

	-- SELECT			A.Routekey, B.ActualDeparture,TMSActualDeparture ,  B.ActualDepartureUpdateMethod, A.ActualDeparture
	UPDATE		A SET TMSActualDeparture = B.ActualDeparture
	FROM			SafeGateIntegration_ActualDepartureDateUpdate A
	INNER JOIN		Routes B ON A.RouteKey = B.RouteKey 
	WHERE			1 = 1  --  AND COntainerNo = 'CAAU6089165'
					AND	((ContainerDesc = 'Checkout' AND  ISNULL(TMSActualDeparture,'') = ''))
					AND ISNULL(B.ActualDeparture,'') <> ''	




	SELECT	ActivityId,ContainerNo,createdDate,ContainerDesc,SafeGateChassisNo,SafegareDriverID,SafegateYardName,DestinationYard,SourceYard,ChassisKey,DriverKey,ChassisNo,Carrier
			,RouteStatus,LegID,TMSActualArrival,TMSActualDeparture,YardCheckIn,YardCheckOut,ActualArrival,ActualDeparture , RouteKey 
			, CAST(0 as BIT) as IsDiffinYard
	FROM	 SafeGateIntegration_ActualDepartureDateUpdate	
	WHERE	1 = 1  --  AND COntainerNo = 'CAAU6089165'
			AND	((ContainerDesc = 'Checkout' AND  ISNULL(TMSActualDeparture,'') = '') OR (ContainerDesc = 'Checkin' AND ISNULL(TMSActualArrival,'') = ''))
	ORDER By createdDate DESC
		
END
