/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{}'
	EXEC [SafeGateIntegration_GetActualDepartureUpdateInfo_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PRocedure [dbo].[SafeGateIntegration_GetActualDepartureUpdateInfo_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS

BEGIN

	 	-- SELECT			A.Routekey, B.ActualArrival, TMSActualArrival, B.ActualArrivalUpdateMethod, A.ActualArrival
	UPDATE		A SET TMSActualArrival = B.ActualArrival
	FROM			SafeGateIntegration_ActualDepartureDateUpdate A WITH (NOLOCK) 
	INNER JOIN		Routes B WITH (NOLOCK)  ON A.RouteKey = B.RouteKey 
	WHERE			1 = 1  --  AND COntainerNo = 'CAAU6089165'
					AND (ContainerDesc = 'Checkin' 	AND ISNULL(TMSActualArrival,'') = '')
					AND ISNULL(B.ActualArrival,'') <> '' 

	-- SELECT			A.Routekey, B.ActualDeparture,TMSActualDeparture ,  B.ActualDepartureUpdateMethod, A.ActualDeparture
	UPDATE		A SET TMSActualDeparture = B.ActualDeparture
	FROM			SafeGateIntegration_ActualDepartureDateUpdate A WITH (NOLOCK) 
	INNER JOIN		Routes B WITH (NOLOCK)  ON A.RouteKey = B.RouteKey 
	WHERE			1 = 1  --  AND COntainerNo = 'CAAU6089165'
					AND	((ContainerDesc = 'Checkout' AND  ISNULL(TMSActualDeparture,'') = ''))
					AND ISNULL(B.ActualDeparture,'') <> ''	


	SELECT	 top 50 ActivityId,ContainerNo,createdDate AS CreatedDate,ContainerDesc,SafeGateChassisNo,SafegareDriverID,SafegateYardName,DestinationYard,SourceYard,ChassisKey,DriverKey,ChassisNo,Carrier
			,RouteStatus,LegID,TMSActualArrival,TMSActualDeparture,YardCheckIn,YardCheckOut,ActualArrival,ActualDeparture , RouteKey 
			, CAST(0 as BIT) as IsDiffinYard
	FROM	 SafeGateIntegration_ActualDepartureDateUpdate	WITH (NOLOCK)
	WHERE	1 = 1  --  AND COntainerNo = 'CAAU6089165'
			AND	((ContainerDesc = 'Checkout' AND  ISNULL(TMSActualDeparture,'') = '') OR (ContainerDesc = 'Checkin' AND ISNULL(TMSActualArrival,'') = ''))
	ORDER By createdDate DESC
	FOR JSON PATH
	SET @Status = 1
	SET @Reason = 'Success'
		
END