/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"FromDate":"2024-01-05 00:00:00.000", "ToDate":"2026-01-05 00:00:00.000"}'
	EXEC [SafeGateIntegration_GetActualDepartureDateUpdated_Ruthu_20260210] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
**/
CREATE Procedure [dbo].[SafeGateIntegration_GetActualDepartureDateUpdated_Ruthu_20260210] 
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF


	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	
-- DECLARE 
	--@FromDate		DATETIME = '',
	--@ToDate			DATETIME = ''

DECLARE 
    @FromDate DATETIME = NULL,
    @ToDate   DATETIME = NULL

SELECT 
	@FromDate  = FromDate,
	@ToDate	   = ToDate
FROM OPENJSON(@JSONString)
WITH(
	FromDate DATETIME '$.FromDate',
	ToDate   DATETIME '$.ToDate'
)

	UPDATE AD
	SET AD.TMSActualArrival = RT.ActualArrival
	FROM SafeGateIntegration_ActualDepartureDateUpdate AD
	INNER JOIN Routes RT 
		ON AD.RouteKey = RT.RouteKey
	WHERE 
		AD.ContainerDesc = 'Checkin'
		AND AD.TMSActualArrival IS NULL
		AND RT.ActualArrival IS NOT NULL
		AND AD.createdDate >= @FromDate
		AND AD.createdDate <  @ToDate


	UPDATE AD
	SET AD.TMSActualDeparture = RT.ActualDeparture
	FROM SafeGateIntegration_ActualDepartureDateUpdate AD
	INNER JOIN Routes RT 
		ON AD.RouteKey = RT.RouteKey
	WHERE 
		AD.ContainerDesc = 'Checkout'
		AND AD.TMSActualDeparture IS NULL
		AND RT.ActualDeparture IS NOT NULL
		AND AD.createdDate >= @FromDate
		AND AD.createdDate <  @ToDate


	--SET			@FromDate = CASE WHEN ISNULL(@FromDate,'') = '' THEN '2015-01-17' ELSE @FromDate END
	--SET			@ToDate = CASE WHEN ISNULL(@ToDate,'') = '' THEN GETDATE() ELSE @ToDate END
	SET @FromDate = ISNULL(@FromDate, '2015-01-17')
	SET @ToDate   = ISNULL(@ToDate, GETDATE())

	SET			@FromDate = CAST(CONVERT(VARCHAR,@FromDate,101) AS DATETIME)
	SET			@ToDate = CAST(CONVERT(VARCHAR,@ToDate+1,101) AS DATETIME)

		SELECT
		AD.ActivityId,
		AD.ContainerNo,
		AD.createdDate AS CreatedDate,
		AD.SafeGateChassisNo,
		AD.SafegareDriverID,
		AD.SafegateYardName,
		AD.DestinationYard,
		AD.SourceYard,
		AD.ChassisKey,
		AD.DriverKey,
		AD.ChassisNo,
		AD.Carrier,
		AD.RouteStatus,
		AD.LegID,
		AD.TMSActualArrival,
		AD.TMSActualDeparture,
		AD.YardCheckIn,
		AD.YardCheckOut,
		AD.ActualArrival,
		AD.ActualDeparture,
		RT.ActualArrivalUpdateMethod,
		RT.ActualDepartureUpdateMethod
	FROM Routes RT WITH (NOLOCK)
	INNER JOIN SafeGateIntegration_ActualDepartureDateUpdate AD WITH (NOLOCK)
		ON RT.RouteKey = AD.RouteKey
	WHERE
	(
		AD.ContainerDesc = 'Checkout'
		AND AD.TMSActualDeparture IS NOT NULL
		AND RT.ActualDepartureUpdateMethod = 'Safegate'
	)
	OR
	(
		AD.ContainerDesc = 'Checkin'
		AND AD.TMSActualArrival IS NOT NULL
		AND RT.ActualArrivalUpdateMethod = 'Safegate'
	)
	AND AD.createdDate >= @FromDate
	AND AD.createdDate <  @ToDate
	ORDER BY AD.createdDate DESC
FOR JSON PATH;


	SET @Status = 1
	SET @Reason = 'Success'
END
