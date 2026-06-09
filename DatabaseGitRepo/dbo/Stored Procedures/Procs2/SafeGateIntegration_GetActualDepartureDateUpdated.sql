
CREATE PRocedure [dbo].[SafeGateIntegration_GetActualDepartureDateUpdated] -- SafeGateIntegration_GetActualDepartureDateUpdated '2024-01-05 00:00:00.000','2026-01-05 00:00:00.000'
(
	@FromDate		DATETIME = '',
	@ToDate			DATETIME = ''
)
AS


BEGIN
	/*
	SELECT CAST(CONVERT(VARCHAR,createdDate,101) AS DATETIME),ActualArrivalUpdateMethod, COUNT(*)  FROm Routes RT 
	INNER JOIN	SafeGateIntegration_ActualDepartureDateUpdate AD ON RT.RouteKey = AD.RouteKey 
	-- WHERE AD.createdDate   > = '2024-01-11 00:00:00.000' AND AD.createdDate < '2024-01-12 00:00:00.000'
	 GROUP BY CAST(CONVERT(VARCHAR,createdDate,101) AS DATETIME),ActualArrivalUpdateMethod
	 */


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

	SET			@FromDate = CASE WHEN ISNULL(@FromDate,'') = '' THEN '2015-01-17' ELSE @FromDate END
	SET			@ToDate = CASE WHEN ISNULL(@ToDate,'') = '' THEN GETDATE() ELSE @ToDate END

	SET			@FromDate = CAST(CONVERT(VARCHAR,@FromDate,101) AS DATETIME)
	SET			@ToDate = CAST(CONVERT(VARCHAR,@ToDate+1,101) AS DATETIME)

	-- SELECT GETDATE()
	--SELECT		@FromDate, @ToDate

	SELECT		AD.ActivityId,AD.ContainerNo,AD.createdDate,AD.SafeGateChassisNo,AD.SafegareDriverID,AD.SafegateYardName,AD.DestinationYard,AD.SourceYard,AD.ChassisKey,AD.DriverKey,AD.ChassisNo,AD.Carrier
				,AD.RouteStatus,AD.LegID,AD.TMSActualArrival,AD.TMSActualDeparture,AD.YardCheckIn,AD.YardCheckOut,AD.ActualArrival,AD.ActualDeparture ,ActualArrivalUpdateMethod, ActualDepartureUpdateMethod
	FROM		Routes RT 
	INNER JOIN	SafeGateIntegration_ActualDepartureDateUpdate AD ON RT.RouteKey = AD.RouteKey 
	--WHERE		ActualArrivalUpdateMethod IN ('Internal', 'A')  AND AD.createdDate > = @FromDate AND AD.createdDate <  @ToDate
	WHERE		((ContainerDesc = 'Checkout' AND  ISNULL(TMSActualDeparture,'') <> '' AND RT.ActualDepartureUpdateMethod = 'Safegate' ) 
				OR (ContainerDesc = 'Checkin' AND ISNULL(TMSActualArrival,'') <> '' AND RT.ActualArrivalUpdateMethod = 'Safegate' ))
				-- AND AD.ContainerNo = 'MRKU6556916'
	ORDER By	AD.createdDate DESC
END
