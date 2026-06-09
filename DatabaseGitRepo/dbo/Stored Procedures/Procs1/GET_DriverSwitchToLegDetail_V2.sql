/** 
Declare 
	@UserKey		INT=953,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey":727577, "ActualArrival":"2026-02-05 14:52", "UpdateType":"JCB User"}'
	EXEC [Update_DispatchActionData_ActualArrival_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
    SELECT @Status, @Reason
**/
  

CREATE PROCEDURE [dbo].[GET_DriverSwitchToLegDetail_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)

AS  
BEGIN  
 SET NOCOUNT ON;  
 SET FMTONLY OFF; 
 
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

			 DECLARE
				 @RouteKey  INT,  
				 @DriverKey INT


			SELECT 
				@RouteKey = RouteKey,  
				@DriverKey = DriverKey   
			FROM OPENJSON(@JSONString)
			WITH
			(
				RouteKey    INT     '$.RouteKey',
				DriverKey   INT      '$.DriverKey'
			)


	Declare @OrderDetailKey int;
	select @OrderDetailKey = OrderDetailKey from Routes where RouteKey = @RouteKey
	-- print @OrderDetailKey

		SELECT OD.ContainerNo ,OH.OrderNo,RT.PickupDateFrom,RT.PickupDateTo,RT.DeliveryDateFrom,RT.DeliveryDateTo,
				SR.AddrName AS SR_AddrName,SR.Address1 AS SR_Address1,SR.City AS SR_City,SR.[State] AS SR_State,
				SR.ZipCode AS SR_ZipCode,SR.Country AS SR_Country,
				DT.AddrName AS DR_AddrName,DT.Address1 AS DR_Address1,DT.City AS DR_City,
				DT.[State] AS DR_State,DT.ZipCode AS DR_ZipCode,DT.Country AS DR_Country,
				CH.chassisNo as ChassisID,CH.ChassisType,
				 ISNULL(DR.DriverID,'') + ': ' + ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,
				 RT.RouteKey,RT.OrderDetailKey ,
				 CASE WHEN ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualDeparture END AS ActualPickup,
				 CASE WHEN ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualArrival END AS  ActualDelDate,
				 L.[LegID],0 AS LegNo , RT.DriverKey
				 INTO #DriverAssignedLegs
		FROM dbo.Routes RT 
		INNER JOIN dbo.RouteStatus RST	ON RST.[Status]=RT.[Status]
		INNER JOIN dbo.OrderDetail OD	ON OD.OrderDetailKey=RT.OrderDetailKey
		INNER JOIN DBO.OrderHeader OH	ON OH.OrderKey=OD.OrderKey
		LEFT JOIN dbo.Driver DR			ON DR.DriverKey=RT.DriverKey
		LEFT JOIN dbo.[Address] SR		ON SR.AddrKey=RT.SourceAddrKey
		LEFT JOIN dbo.[Address] DT		ON DT.AddrKey=RT.DestinationAddrKey
		LEFT JOIN   dbo.Chassis CH		ON CH.chassisKey=RT.ChassisKey
		LEFT JOIN  dbo.Leg L			ON RT.LegKey=L.LegKey
		LEFT JOIN  dbo.LegType LT		ON LT.LegtypeKey=L.LegTypeKey
		LEFT JOIN DBO.ROUTESWITCH	RS	ON RT.RouteKey = RS.ToRouteKey
		WHERE RST.[Description]  IN ('DriverAssigned','Open') 
		AND ( RT.DriverKey= @DriverKey OR RT.DriverKey IS NULL)
		AND OD.OrderDetailKey <> @OrderDetailKey
		AND RS.ToRouteKey IS NULL

		--select * from #DriverAssignedLegs

		SELECT DISTINCT OrderDetailKey INTO #OrderDetail
		FROM #DriverAssignedLegs

		SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,
			A.OrderDetailKey,W.RouteKey INTO #RouteLegNo
		FROM #OrderDetail A 
		INNER JOIN dbo.Routes W ON W.OrderDetailKey=A.OrderDetailKey

		UPDATE A
		SET A.LegNo=R.LegNo
		FROM #DriverAssignedLegs A JOIN #RouteLegNo R ON R.RouteKey=A.RouteKey

		SELECT ContainerNo,OrderNo,PickupDateFrom,PickupDateTo,DeliveryDateFrom,DeliveryDateTo,SR_AddrName,SR_Address1
		,SR_City,SR_State,SR_ZipCode,SR_Country,DR_AddrName,DR_Address1,DR_City,DR_State,DR_ZipCode,DR_Country,ChassisID
		,ChassisType,DriverName,ActualPickup,ActualDelDate,LegNo,LegID,RouteKey, OrderDetailKey
		FROM #DriverAssignedLegs
		ORDER BY PickupDateFrom, LegNo


		FOR JSON PATH;

		SET @Status=1;
		SET @Reason='Success';
END