CREATE PROCEDURE [dbo].[Update_SwitchToDriver]
/*Update Driver in SwitchTO Leg - Dispatch Screen*/
@RouteKeyFrom	INT,
@RouteKeyTo		INT,
@DriverKey		INT,
@UserKey		INT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @DriverName varchar(50)
	DECLARE @IsReadyToComplete BIT
	DECLARE @StatusKey SMALLINT
	DECLARE @StatusDesc VARCHAR(200)
	DECLARE @LegNo SMALLINT
	DECLARE @NexLeg SMALLINT
	DECLARE @CurrLeg VARCHAR(50)

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
							FROM dbo.[Routes] WHERE RouteKey= @RouteKeyTo
						 )
	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Leg Completed')

	UPDATE dbo.[Routes]
	SET 		
		DriverKey		= @DriverKey,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE()
	WHERE RouteKey= @RouteKeyTo;
	--********************Container Status Update******************************
	IF (	SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status] 
			WHERE RT.OrderDetailKey= @OrderDetailKey AND RTS.[Description]<>'Leg Completed'
				AND (
						ISNULL(RT.driverKey ,0) > 0 OR ISNULL(RT.ChassisNo,'') <> ''  OR 
						ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' OR
						ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
					)
	   )>0
	BEGIN
		UPDATE dbo.OrderDetail
		SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Dispatch InProgress' AND IsActive=1 ),
			StatusDate=GETDATE()
		WHERE OrderDetailKey= @OrderDetailKey;
	END;
	--**************************Container Leg Status****************************
IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKeyTo AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NULL 
				  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' AND IsActive=1 )
		WHERE RouteKey= @RouteKeyTo AND [Status]<>@DriverAsgStatusKey;
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKeyTo AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned' AND IsActive=1 )
		WHERE RouteKey= @RouteKeyTo AND [Status]<>@DriverAsgStatusKey;
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKeyTo AND RTS.Description<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Delivery Pending' AND IsActive=1 )
		WHERE RouteKey= @RouteKeyTo
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKeyTo AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NOT NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Ready To Complete' AND IsActive=1 )
		WHERE RouteKey= @RouteKeyTo
	END;
	--******************************************************************************
	--SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey 

	SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,A.OrderDetailKey,
		   W.RouteKey INTO #RouteLegNo
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKeyTo ) A 
		INNER JOIN dbo.Routes W ON W.OrderDetailKey=A.OrderDetailKey		

	SET @StatusKey=( SELECT [Status] FROM [Routes] WHERE RouteKey=@RouteKeyTo)
	SET @StatusDesc=( SELECT [Description] FROM RouteStatus WHERE [Status]=@StatusKey)
	SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey=@RouteKeyTo )

	SET  @DriverName = (	
							SELECT ISNULL(FirstName,'') + ' ' + ISNULL(lastname,'') 
							FROM Driver 
							WHERE DriverKey = @DriverKey
					   )

	--*****************************************************************************

	SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKeyTo) A 
			LEFT JOIN dbo.Routes RT ON RT.OrderDetailKey=A.OrderDetailKey
	GROUP BY A.OrderDetailKey

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKeyTo) A 
		INNER JOIN dbo.Routes RT		ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=RT.[Status]
	WHERE RTS.[Description]<>'Leg Completed'
	GROUP BY A.OrderDetailKey

	SELECT A.OrderDetailKey INTO #AllOrdCompLeg 
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKeyTo) A
	WHERE A.OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CurrLeg)

	INSERT INTO #AllOrdComplLeg (OrderDetailKey,LastRoutekey)
	SELECT OrderDetailKey,CurrOPenRoutekey 
	FROM #CurrLeg

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MAX(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM #AllOrdCompLeg A 
		INNER JOIN dbo.Routes RT ON RT.OrderDetailKey=A.OrderDetailKey		
	GROUP BY A.OrderDetailKey

	SELECT @NexLeg=CASE WHEN C.LastRoutekey IS NULL THEN 0 ELSE ISNULL(R.LegNo,0) END 
		,  @CurrLeg =CAST(ISNULL(R.LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50))
	FROM #RouteLegNo R 
		INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=R.OrderDetailKey
		INNER JOIN #LegCount L ON L.OrderDetailKey=Q.OrderDetailKey
		LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=R.OrderDetailKey
	--**************************************************************************

	INSERT INTO RouteSwitch(FromRouteKey,ToRouteKey,CreateDate,CreateUserKey)
	VALUES( @RouteKeyFrom,@RouteKeyTo,GETDATE(),@UserKey )

	 SET @IsReadyToComplete = (SELECT dbo.FN_IsRouteComplete(@RouteKeyTo))

	 SELECT  @IsReadyToComplete AS ReadyToComplete,@DriverName AS DriverName,@StatusKey AS [StatusKey],
			 @StatusDesc AS StatusDesc , @LegNo AS LegNo,@NexLeg AS NextLeg,@CurrLeg AS CurLeg,
			 RT.LegKey as SWR_LegKey, RT.RouteKey as SWR_RouteKey ,
			 OD.OrderDetailKey as SWR_OrderDetailKey,OD.ContainerNo as SWR_ContainerNo,
			 OH.OrderNo as SWR_OrderNo, L.LegID SWR_LegID, L.LegNo as SWR_LegNo
		FROM dbo.Routes RT 
			INNER JOIN dbo.Routeswitch SWC ON SWC.ToRouteKey=RT.RouteKey
			INNER JOIN dbo.OrderDetail OD  ON OD.OrderDetailKey=RT.OrderDetailKey
			INNER JOIN dbo.OrderHeader OH  ON OH.OrderKey=OD.OrderKey
			Left join dbo.Leg L on RT.LegKey = L.LegKey
		where RT.RouteKey = @RouteKeyTo
END
