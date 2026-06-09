CREATE PROCEDURE [dbo].[Update_DispatchActionDataContainer_Driver]
/*Dispatch Screen Container Row Driver update*/
@RouteKey	INT,
@DriverKey	INT,
@UserKey	INT,
@DriverName varchar(50) OUTPUT
--@OutPut		BIT OUTPUT,
--@IsReadyToComplete BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @IsReadyToComplete  BIT
	DECLARE @StatusKey	SMALLINT
	DECLARE @StatusDesc VARCHAR(200)
	DECLARE @LegNo		SMALLINT
	DECLARE @NexLeg SMALLINT
	DECLARE @CurrLeg VARCHAR(50)
	--DECLARE @DriverName VARCHAR(100)

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
							FROM dbo.[Routes] WHERE RouteKey= @RouteKey
						 )
	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned')

	UPDATE dbo.[Routes]
	SET 		
		DriverKey		= @DriverKey,
		UpdateUserKey	= @UserKey,
		CarrierAssignedBy=@UserKey,
		LastUpdateDate	= GETDATE()
	WHERE OrderDetailKey = @OrderDetailKey and DriverKey is null;

	--********************Container Status Update******************************
	IF (	SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status] 
			WHERE RT.OrderDetailKey= @OrderDetailKey AND RTS.[Description]<>'Completed'
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
	--IF  (	
	--		SELECT COUNT(1) 
	--		FROM dbo.[Routes] RT 
	--			INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
	--		WHERE RouteKey= @RouteKey AND RTS.Description<>'Completed'
	--	)>0
	--BEGIN
	--	UPDATE dbo.[Routes]
	--	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned' )
	--	WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	--END
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Completed' AND RT.DriverKey IS NULL 
				  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' AND IsActive=1 )
		WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Completed' AND RT.DriverKey IS NOT NULL 
				  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned' AND IsActive=1 )
		WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.Description<>'Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='InProgress' AND IsActive=1 )
		WHERE RouteKey= @RouteKey
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NOT NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Ready To Complete' AND IsActive=1 )
		WHERE RouteKey= @RouteKey
	END;

	SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,A.OrderDetailKey,
		   W.RouteKey INTO #RouteLegNo
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey ) A 
		INNER JOIN dbo.Routes W ON W.OrderDetailKey=A.OrderDetailKey		

	SET @StatusKey=( SELECT [Status] FROM [Routes] WHERE RouteKey=@RouteKey)
	SET @StatusDesc=( SELECT [Description] FROM RouteStatus WHERE [Status]=@StatusKey)
	SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey=@RouteKey )

	SET @DriverName = ( 
						SELECT ISNULL(FirstName,'') + ' ' + ISNULL(lastname,'') 
						FROM Driver 
						WHERE DriverKey = @DriverKey
					  )
	--*****************************************************************************

	SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey) A 
			LEFT JOIN dbo.Routes RT ON RT.OrderDetailKey=A.OrderDetailKey
	GROUP BY A.OrderDetailKey

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey) A 
		INNER JOIN dbo.Routes RT		ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=RT.[Status]
	WHERE RTS.[Description]<>'Completed'
	GROUP BY A.OrderDetailKey

	SELECT A.OrderDetailKey INTO #AllOrdCompLeg 
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey) A
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

	--=================================================
	-- CODE ADDED FOR DRIVER NOTIFICATION
	Declare @DriverUserKey int = 0
	select @DriverUserKey = A.UserKey from [user] A
	inner join Driver D on A.UserName = D.DriverID
	where D.DriverKey = @DriverKey

	if(@DriverUserKey > 0)
	begin
		insert into notifications (UserKey, HeadText, DetailText, CreateDate, IsRead, 
		ReadDateTime, isActive, SentUserKey, RelatedTranType, RelatedTranKey)
		SELECT @DriverUserKey,'Container Leg Assigned', 
		'Leg: ' + L.[LegID] + ' of Container No: ' + OD.ContainerNo +  ' is assigned to "' 
		+  D.DriverID + '" - ' +  D.FirstName + ' ' + isnull(D.LastName, '')
		+ ', pickup: '+ 
		 convert(varchar, R.PickupDateFrom, 107) + ' ' + convert(varchar, R.PickupDateFrom, 108) + ' - ' 
		 + convert(varchar, isnull(R.PickupDateFrom,''), 107) + ' ' +  convert(varchar, isnull(R.PickupDateFrom,''), 108)  ,
		getdate(), 0, null, 1, @UserKey,'Dispatch', @OrderDetailKey
		FROM ROUTES R
		INNER JOIN OrderDetail OD ON R.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN Driver D ON R.DriverKey = D.DriverKey
		INNER JOIN LEG L ON R.LegKey = L.LegKey
		WHERE OD.OrderDetailKey =  @OrderDetailKey 
		AND R.RouteKey = @RouteKey
	end 
	--=================================================

	SELECT @IsReadyToComplete = dbo.FN_IsOrderDetailComplete(@OrderDetailKey)
	
	--added by shiva
	SELECT  @IsReadyToComplete AS ReadyToComplete,@StatusKey AS [StatusKey],
			 @StatusDesc AS StatusDesc , @LegNo AS LegNo, @NexLeg AS NextLeg,@CurrLeg AS CurLeg;
END
