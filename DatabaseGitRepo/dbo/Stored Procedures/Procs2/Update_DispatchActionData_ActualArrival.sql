

CREATE PROCEDURE [dbo].[Update_DispatchActionData_ActualArrival] -- [Update_DispatchActionData_ActualArrival] 678304, null, 29, 'JCB'
/*Dispatch Screen*/
@RouteKey		INT,
@ActualArrival	DATETIME,
@UserKey		INT,
@UpdateType		VARCHAR(10)=''
--@OutPut			BIT OUTPUT,
--@IsReadyToComplete BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey		INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @IsReadyToComplete	BIT
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

	if(@ActualArrival is null)
	Begin
		SELECT  0 AS ReadyToComplete,RT.Status AS [StatusKey],
			 RTS.Description AS StatusDesc , OD.CurrentLegNo AS LegNo,OD.CurrentLegNo + 1 AS NextLeg,
				CAST(ISNULL(OD.CurrentLegNo,0) AS VARCHAR(50))+' of '+CAST(od.TotalLegs AS VARCHAR(50))  AS CurLeg
		from OrderDetail OD WITH (NOLOCK) 
		INNER JOIN ROUTES RT WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
		INNER JOIN RouteStatus RTS WITH (NOLOCK) ON RT.Status = RTS.Status
		where RT.RouteKey = @RouteKey
		RETURN;
	End
	--SET @OutPut=0;
	SET @OrderDetailKey= (
							SELECT DISTINCT OrderDetailKey 
							FROM dbo.[Routes] WHERE RouteKey= @RouteKey
						 )
	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned')

	UPDATE dbo.[Routes]
	SET 		
		ActualArrival	= @ActualArrival,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE(),
		ActualArrivalUpdateMethod=@UpdateType,
		ActualArrivalUpdateDate=GETDATE()
	WHERE RouteKey= @RouteKey and @ActualArrival is not null;

		update ODS SET 
		ActualDeliveryDate = @ActualArrival,
		ActualDeliveryUserKey = @UserKey,
		ActualDeliverySetDateTime = GetDate()
	from ORderDetailStops ODS
	where ToRouteKey = @RouteKey and @ActualArrival is not null
	/*
	declare @cnt smallint,
		@driverKey int
	select @cnt= count(1) , @driverKey = R.DriverKey
	from Routes R 
	inner join DriverRoute DR on DR.RouteKey = R.RouteKey and Dr.driverKey = R.DriverKey
	where R.RouteKey = @RouteKey 
	group by R.DriverKey
	
	if(@cnt > 0 )
	begin
		update DriverRoute set DriverCompleteDate = @ActualArrival
		where RouteKey = @RouteKey and DriverKey = @driverKey
	end
	else
	Begin
		insert into DriverRoute (RouteKey, DriverKey, DriverStartDate, DriverCompleteDate)
		select RouteKey, DriverKey, ActualDeparture, @ActualArrival from routes where RouteKey = @RouteKey
	End
	*/

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
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NULL 
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
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
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
			WHERE RouteKey= @RouteKey AND RTS.Description<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Delivery Pending' AND IsActive=1 )
		WHERE RouteKey= @RouteKey
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NOT NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Ready To Complete' AND IsActive=1 )
		WHERE RouteKey= @RouteKey
	END;
	--*********************************************************************
	SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,A.OrderDetailKey,
		   W.RouteKey INTO #RouteLegNo
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey ) A 
		INNER JOIN dbo.Routes W ON W.OrderDetailKey=A.OrderDetailKey		

	SET @StatusKey=( SELECT [Status] FROM [Routes] WHERE RouteKey=@RouteKey)
	SET @StatusDesc=( SELECT [Description] FROM RouteStatus WHERE [Status]=@StatusKey)
	SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey=@RouteKey )

	--*************************************************************************
	SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey) A 
			LEFT JOIN dbo.Routes RT ON RT.OrderDetailKey=A.OrderDetailKey
	GROUP BY A.OrderDetailKey

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey) A 
		INNER JOIN dbo.Routes RT		ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=RT.[Status]
	WHERE RTS.[Description]<>'Leg Completed'
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
		,  @CurrLeg =CAST(ISNULL(@LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50))
	FROM #RouteLegNo R 
		INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=R.OrderDetailKey
		INNER JOIN #LegCount L ON L.OrderDetailKey=Q.OrderDetailKey
		LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=R.OrderDetailKey
		
	--*************************************************************************
	 SET @IsReadyToComplete = ( SELECT dbo.FN_IsRouteComplete(@RouteKey));
	 
	 SELECT  @IsReadyToComplete AS ReadyToComplete,@StatusKey AS [StatusKey],
			 @StatusDesc AS StatusDesc , @LegNo AS LegNo,@NexLeg AS NextLeg,@CurrLeg AS CurLeg;	
END
