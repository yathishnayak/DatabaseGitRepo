--select * from RouteSwitch
--select driverkey, * from Routes where RouteKey = 192 and Status <> 5
/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKeyFrom" : 722138, "DriverKey" : 1401}'
	EXEC [Update_UnSwitchRoute_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_UnSwitchRoute_V2]
/*Un-switch Route - Dispatch Screen*/
(
	@UserKey		INT = 1144,
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


	DECLARE 
	@RouteKeyFrom	INT=192,
	@DriverKey		INT=11

	SELECT 
	@RouteKeyFrom	= RouteKeyFrom,
	@DriverKey		= DriverKey
	FROM OPENJSON(@JSONString)
	WITH
	(
	RouteKeyFrom		INT			'$.RouteKeyFrom',
	DriverKey			INT			'$.DriverKey'
	)

	DECLARE @OrderDetailKey INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @DriverName varchar(50)
	DECLARE @IsReadyToComplete BIT
	DECLARE @StatusKey SMALLINT
	DECLARE @StatusDesc VARCHAR(200)
	DECLARE @LegNo SMALLINT
	DECLARE @NexLeg SMALLINT
	DECLARE @CurrLeg VARCHAR(50)
	DECLARE @RouteKeyTo		INT

	SET @RouteKeyTo= ( SELECT top 1 ToRouteKey FROM RouteSwitch WITH (NOLOCK) WHERE FromRouteKey=@RouteKeyFrom )
	IF @RouteKeyTo IS NULL
	BEGIN
		SELECT  @IsReadyToComplete AS ReadyToComplete,@DriverName AS DriverName,@StatusKey AS [StatusKey],
			 @StatusDesc AS StatusDesc , @LegNo AS LegNo,@NexLeg AS NextLeg,@CurrLeg AS CurLeg,
			 0 as SWR_LegKey, @RouteKeyFrom as SWR_RouteKey ,
			 0 as SWR_OrderDetailKey,'' as SWR_ContainerNo,
			 '' as SWR_OrderNo, '' SWR_LegID, 0 as SWR_LegNo
		RETURN
	END

	CREATE TABLE #CurrLeg
	(
		OrderDetailKey INT,
		CurrOPenRoutekey INT,
	)

	CREATE TABLE #AllOrdComplLeg
	(
		OrderDetailKey INT,
		LastRoutekey   INT,
	)

	--SET @OutPut=0;	
	SET @OrderDetailKey= (
							SELECT DISTINCT OrderDetailKey 
							FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKeyTo
						 )
	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Leg Completed')

	UPDATE dbo.[Routes]
	SET 		
		DriverKey		= @DriverKey,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE()
	WHERE RouteKey= @RouteKeyTo;
	--********************Container Status Update******************************
	IF (	SELECT COUNT(1) 
			FROM dbo.[Routes] RT WITH (NOLOCK)
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)  ON RTS.[Status]=RT.[Status] 
			WHERE RT.OrderDetailKey= @OrderDetailKey AND RTS.[Description]<>'Leg Completed'
				AND (
						ISNULL(RT.driverKey ,0) > 0 OR ISNULL(RT.ChassisNo,'') <> ''  OR 
						ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' OR
						ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
					)
	   )>0
	BEGIN
		UPDATE dbo.OrderDetail
		SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WITH (NOLOCK) WHERE [Description]='Dispatch InProgress' AND IsActive=1 ),
			StatusDate=GETDATE()
		WHERE OrderDetailKey= @OrderDetailKey;
	END;
	--**************************Container Leg Status****************************
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT WITH (NOLOCK) 
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKeyTo AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NULL 
				  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Open' AND IsActive=1 )
		WHERE RouteKey= @RouteKeyTo AND [Status]<>@DriverAsgStatusKey;
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT WITH (NOLOCK)
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKeyTo AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='DriverAssigned' AND IsActive=1 )
		WHERE RouteKey= @RouteKeyTo AND [Status]<>@DriverAsgStatusKey;
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT WITH (NOLOCK) 
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKeyTo AND RTS.Description<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Delivery Pending' AND IsActive=1 )
		WHERE RouteKey= @RouteKeyTo
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT  WITH (NOLOCK)
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKeyTo AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NOT NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Ready To Complete' AND IsActive=1 )
		WHERE RouteKey= @RouteKeyTo
	END;
	--******************************************************************************
	--SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey 

	SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,A.OrderDetailKey,
		   W.RouteKey INTO #RouteLegNo
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKeyTo ) A 
		INNER JOIN dbo.Routes W WITH (NOLOCK) ON W.OrderDetailKey=A.OrderDetailKey		

	SET @StatusKey=( SELECT [Status] FROM [Routes] WITH (NOLOCK) WHERE RouteKey=@RouteKeyTo)
	SET @StatusDesc=( SELECT [Description] FROM RouteStatus WITH (NOLOCK) WHERE [Status]=@StatusKey)
	SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey=@RouteKeyTo )

	SET  @DriverName = (	
							SELECT ISNULL(FirstName,'') + ' ' + ISNULL(lastname,'') 
							FROM Driver 
							WHERE DriverKey = @DriverKey
					   )

	--*****************************************************************************

	SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKeyTo) A 
			LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
	GROUP BY A.OrderDetailKey

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKeyTo) A 
		INNER JOIN dbo.Routes RT WITH (NOLOCK)		ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)	ON RTS.[Status]=RT.[Status]
	WHERE RTS.[Description]<>'Leg Completed'
	GROUP BY A.OrderDetailKey

	SELECT A.OrderDetailKey INTO #AllOrdCompLeg 
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKeyTo) A
	WHERE A.OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CurrLeg)

	INSERT INTO #AllOrdComplLeg (OrderDetailKey,LastRoutekey)
	SELECT OrderDetailKey,CurrOPenRoutekey 
	FROM #CurrLeg

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MAX(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM #AllOrdCompLeg A 
		INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey		
	GROUP BY A.OrderDetailKey

	SELECT @NexLeg=CASE WHEN C.LastRoutekey IS NULL THEN 0 ELSE ISNULL(R.LegNo,0) END 
		,  @CurrLeg =CAST(ISNULL(R.LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50))
	FROM #RouteLegNo R 
		INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=R.OrderDetailKey
		INNER JOIN #LegCount L ON L.OrderDetailKey=Q.OrderDetailKey
		LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=R.OrderDetailKey
	--**************************************************************************

	 DELETE FROM RouteSwitch WHERE ToRouteKey=@RouteKeyTo

	 SET @IsReadyToComplete = (SELECT dbo.FN_IsRouteComplete(@RouteKeyTo))

	 SELECT  @IsReadyToComplete AS ReadyToComplete,@DriverName AS DriverName,@StatusKey AS [StatusKey],
			 @StatusDesc AS StatusDesc , @LegNo AS LegNo,@NexLeg AS NextLeg,@CurrLeg AS CurLeg,
			 RT.LegKey as SWR_LegKey, RT.RouteKey as SWR_RouteKey ,
			 OD.OrderDetailKey as SWR_OrderDetailKey,OD.ContainerNo as SWR_ContainerNo,
			 OH.OrderNo as SWR_OrderNo, L.LegID SWR_LegID, L.LegNo as SWR_LegNo
		FROM dbo.Routes RT WITH (NOLOCK) 
			LEft JOIN dbo.Routeswitch SWC WITH (NOLOCK) ON SWC.ToRouteKey=RT.RouteKey
			LEFT JOIN dbo.OrderDetail OD WITH (NOLOCK)  ON OD.OrderDetailKey=RT.OrderDetailKey
			LEFT JOIN dbo.OrderHeader OH WITH (NOLOCK)  ON OH.OrderKey=OD.OrderKey
			Left join dbo.Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
		where RT.RouteKey = @RouteKeyFrom
	FOR JSON PATH
		
	SET @Status = 1
	SET @Reason = 'Success'
END