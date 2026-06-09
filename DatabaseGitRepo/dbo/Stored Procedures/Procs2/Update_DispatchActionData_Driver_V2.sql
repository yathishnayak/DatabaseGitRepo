/*
Declare 
	@UserKey		INT=953,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey":727577, "DriverKey" : 1518 }'
	EXEC Update_DispatchActionData_Driver_V2 @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
    SELECT @Status, @Reason

*/

CREATE  PROCEDURE [dbo].[Update_DispatchActionData_Driver_V2]
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

			
	DECLARE @OrderDetailKey INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @DriverName varchar(50)
	DECLARE @IsReadyToComplete BIT
	DECLARE @StatusKey SMALLINT
	DECLARE @StatusDesc VARCHAR(200)
	DECLARE @LegNo SMALLINT
	DECLARE @NexLeg SMALLINT
	DECLARE @CurrLeg VARCHAR(50)
	DECLARE	@TruckType	VARCHAR(100)
	DECLARE @DriverSetDate DATETIME
	DECLARE @UserName VARCHAR(50)

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
							FROM dbo.[Routes] WITH (NOLOCK)  WHERE RouteKey= @RouteKey
						 )
	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Leg Completed')
	SET @TruckType = (SELECT TruckType FROM TruckType TT WITH (NOLOCK)
	LEFT JOIN Driver D WITH (NOLOCK) ON D.TruckTypeKey=TT.TruckTypeKey
	WHERE DriverKey=@DriverKey)
	SELECT @UserName = ISNULL(UserName, '') FROM [User] WHERE UserKey = @UserKey

	UPDATE dbo.[Routes]
	SET 		
		DriverKey		= @DriverKey,
		CarrierAssignedBy	=@UserKey,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE(),
		DriverSetBy		= @UserKey,
		DriverSetDate   = GETDATE()
	WHERE RouteKey= @RouteKey;

	IF @@ROWCOUNT > 0
	BEGIN
		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		SELECT GETDATE(), @UserName, 'Container', (SELECT ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey = @OrderDetailKey), @OrderDetailKey, NULL, 
		'Text' , 'Carrier updated to ' + (SELECT DriverID+ ':' + FirstName + '' + ISNULL(LastName, '')  FROM Driver WHERE DriverKey = @DriverKey) + ' by ' + @UserName
	END

	INSERT INTO DriverRouteAcceptance
			(RouteKey,Description,CreateDate,RejectReasonKey,RejectReasonDescr,CreateUserKey,DriverKey)
	SELECT		@RouteKey,'Pending',GETDATE(),NULL,NULL,@UserKey,@DriverKey
	--********************Container Status Update******************************
	IF (	SELECT COUNT(1) 
			FROM dbo.[Routes] RT WITH (NOLOCK)
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status] 
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
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NULL 
				  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Open' AND IsActive=1 )
		WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='DriverAssigned' AND IsActive=1 )
		WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT WITH (NOLOCK)
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.Description<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Delivery Pending' AND IsActive=1 )
		WHERE RouteKey= @RouteKey
	END;
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT WITH (NOLOCK)
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
				AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NOT NULL
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Ready To Complete' AND IsActive=1 )
		WHERE RouteKey= @RouteKey
	END;
	--******************************************************************************
	--SELECT OrderDetailKey FROM dbo.[Routes] WHERE RouteKey= @RouteKey 

	SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,A.OrderDetailKey,
		   W.RouteKey INTO #RouteLegNo
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey ) A 
		INNER JOIN dbo.Routes W WITH (NOLOCK) ON W.OrderDetailKey=A.OrderDetailKey		

	SET @StatusKey=( SELECT [Status] FROM [Routes] WITH (NOLOCK) WHERE RouteKey=@RouteKey)
	SET @StatusDesc=( SELECT [Description] FROM RouteStatus WITH (NOLOCK) WHERE [Status]=@StatusKey)
	SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey=@RouteKey )

	SET  @DriverName = (	
							SELECT ISNULL(FirstName,'') + ' ' + ISNULL(lastname,'') 
							FROM Driver WITH (NOLOCK)
							WHERE DriverKey = @DriverKey
					   )

	--*****************************************************************************

	SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey) A 
			LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
	GROUP BY A.OrderDetailKey

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey) A 
		INNER JOIN dbo.Routes RT	WITH (NOLOCK)	ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)	ON RTS.[Status]=RT.[Status]
	WHERE RTS.[Description]<>'Leg Completed'
	GROUP BY A.OrderDetailKey

	SELECT A.OrderDetailKey INTO #AllOrdCompLeg 
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey) A
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
		,  @CurrLeg =CAST(ISNULL(@LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50))
	FROM #RouteLegNo R 
		INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=R.OrderDetailKey
		INNER JOIN #LegCount L ON L.OrderDetailKey=Q.OrderDetailKey
		LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=R.OrderDetailKey
	--**************************************************************************
	--=================================================
	-- CODE ADDED FOR DRIVER NOTIFICATION
	Declare @DriverUserKey int = 0
	select @DriverUserKey = A.UserKey from [user] A
	inner join Driver D WITH (NOLOCK) on A.UserName = D.DriverID
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
		FROM ROUTES R WITH (NOLOCK)
		INNER JOIN OrderDetail OD  WITH (NOLOCK)ON R.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN Driver D WITH (NOLOCK) ON R.DriverKey = D.DriverKey
		INNER JOIN LEG L WITH (NOLOCK) ON R.LegKey = L.LegKey
		WHERE OD.OrderDetailKey =  @OrderDetailKey 
		AND R.RouteKey = @RouteKey
	end 
	--=================================================
	 SET @IsReadyToComplete = (SELECT dbo.FN_IsRouteComplete(@RouteKey))
	 SET @DriverSetDate=(SELECT DriverSetDate FROM [Routes]  WITH (NOLOCK) WHERE RouteKey=@RouteKey)

	 SELECT  @IsReadyToComplete AS ReadyToComplete,@DriverName AS DriverName,@StatusKey AS [StatusKey],@DriverSetDate AS DriverSetDate,
			 @StatusDesc AS StatusDesc , @LegNo AS LegNo,@NexLeg AS NextLeg,@CurrLeg AS CurLeg, @TruckType AS TruckType
			 FOR JSON PATH;

			 SET @Status=1;
			 SET @Reason='Success';

END