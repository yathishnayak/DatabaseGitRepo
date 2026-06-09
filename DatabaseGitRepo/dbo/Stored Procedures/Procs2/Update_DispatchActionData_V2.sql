/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverKey" : 1404, "ChassisKey" : 7, "ChassisNo": "JCTD100007", "ChassisType": "40/45", "OrderDetailKey" : 223754, "RouteKey": 727577, "UpdateUserKey": 953,"PickUpTime": null, 
	"DeliveryTime" : null, "SwitchTo" : "" , "Type" : "A" }
	}'
	EXEC [Update_DispatchActionData_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Update_DispatchActionData_V2]
(
	@UserKey		INT = 714,
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
	@DriverKey		INT,
	@ChassisKey		INT,
	@ChassisNo		VARCHAR(30),
	@ChassisType	VARCHAR(30),
	@OrderDetailKey INT,
	@RouteKey		INT,
	@UpdateUserKey	INT,
	@ActualPickUpTime		DATETIME= NULL,
	@ActualDeliveryTime		DATETIME= NULL,
	@SwitchTo		VARCHAR(30),
	@Type			CHAR(1),
		@IsReadyToComplete BIT-- D: Driver, C: Chassi, P: Pickup, L: Delivery, S: SwitchTo, A: All
	-- @Status			BIT OUTPUT,


	SELECT 
		@DriverKey = DriverKey,
		@ChassisKey = ChassiKey,
		@ChassisNo	= ChassisNo,
		@ChassisType = ChassisType,
		@OrderDetailKey = OrderDetailKey,
		@RouteKey = RouteKey,
		@UpdateUserKey = UpdateUserKey,
		@ActualPickUpTime = ActualPickUpTime,
		@ActualDeliveryTime = ActualDeliveryTime,
		@SwitchTo = SwitchTo,
		@Type = Type
	FROM OPENJSON(@JSONString)
	WITH
	(
		DriverKey		INT		'$.DriverKey',
		ChassiKey		INT		'$.ChassiKey',
		ChassisNo		VARCHAR(30)		'$.ChassisNo',
		ChassisType		VARCHAR(30)		'$.ChassisType',
		OrderDetailKey	INT				'$.OrderDetailKey',
		RouteKey		INT				'$.RouteKey',
		UpdateUserKey	INT				'$.UpdateUserKey',
		ActualPickUpTime	DATETIME	'$.PickUpTime',
		ActualDeliveryTime	DATETIME	'$.DeliveryTime',
		SwitchTo			VARCHAR(30)	'$.SwitchTo',
		Type				CHAR(1)		'$.Type'
		
	)

	DECLARE @IsRouteComplete BIT
	DECLARE @DriverAsgStatusKey SMALLINT

	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='DriverAssigned')

	SET @Status=0;
	if(@Type = 'A')
	BEGIN
		UPDATE dbo.[Routes]
		SET 
			ChassisNo		= @ChassisNo ,
			ChassisKey		= @ChassisKey,
			ChassisType		= @ChassisType,		
			DriverKey		= @DriverKey,
			UpdateUserKey	= @UpdateUserKey,
			--ActualDeparture	= @ActualPickUpTime,
			--ActualArrival	= @ActualDeliveryTime,	
			SwitchTo		=  @SwitchTo		
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		UPDATE dbo.[Routes] 
		SET 
			ChassisNo=  CASE WHEN ISNULL(ChassisNo,'')='' THEN @ChassisNo  ELSE ChassisNo  END,
			ChassisKey= CASE WHEN ISNULL(ChassisKey,0)= 0 THEN @ChassisKey ELSE ChassisKey END,
			ChassisType=  CASE WHEN ISNULL(ChassisType,'')='' THEN @ChassisType ELSE ChassisType END,
			DriverKey=  CASE WHEN ISNULL(DriverKey,0)=0 THEN @DriverKey ELSE DriverKey END,
			ActualDeparture = CASE WHEN isnull(ActualDeparture,'')= '' THEN @ActualPickUpTime ELSE ActualDeparture END,
			ActualArrival = CASE WHEN ISNULL(ActualArrival,'') = '' THEN @ActualDeliveryTime ELSE ActualArrival END,
			SwitchTo = CASE WHEN ISNULL(SwitchTo,'') = '' THEN @SwitchTo ELSE SwitchTo END,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey<>@RouteKey
	END

	--UPDATE dbo.DriverRoute
	--SET DriverKey= ( 
	--				 SELECT DriverKey 
	--				 FROM dbo.[Routes] 
	--				 WHERE RouteKey=@RouteKey
	--			   )
	--WHERE RouteKey=@RouteKey

	if(@Type = 'D')
	BEGIN
		UPDATE dbo.[Routes]
		SET 
			DriverKey = @DriverKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;		

		UPDATE dbo.[Routes]
		SET [Status]= CASE WHEN ISNULL(DriverKey,0) <>0 THEN ( 
			SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='DriverAssigned' ) 
			ELSE [Status] END
		WHERE RouteKey= @RouteKey and Status <> 5

		UPDATE dbo.[Routes] 
		SET 
			DriverKey=  CASE WHEN ISNULL(DriverKey,0)=0 THEN @DriverKey ELSE DriverKey END,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey<>@RouteKey

		--UPDATE dbo.DriverRoute
		--SET DriverKey=	( 
		--				 SELECT DriverKey 
		--				 FROM dbo.[Routes] 
		--				 WHERE RouteKey=@RouteKey
		--				)
		--WHERE RouteKey=@RouteKey
	END

	if(@Type = 'C')
	BEGIN
		UPDATE dbo.[Routes]
		SET 
			ChassisNo		= @ChassisNo ,
			ChassisKey		= @ChassisKey,
			ChassisType		= @ChassisType	
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		UPDATE dbo.[Routes] 
		SET 
			ChassisNo=  CASE WHEN ISNULL(ChassisNo,'')='' THEN @ChassisNo  ELSE ChassisNo  END,
			ChassisKey= CASE WHEN ISNULL(ChassisKey,0)= 0 THEN @ChassisKey ELSE ChassisKey END,
			ChassisType=  CASE WHEN ISNULL(ChassisType,'')='' THEN @ChassisType ELSE ChassisType END,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey<>@RouteKey
	END

	if(@Type = 'P')
	BEGIN
		UPDATE dbo.[Routes]
		SET 
			UpdateUserKey	= @UpdateUserKey,
			ActualDeparture	= @ActualPickUpTime
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		UPDATE dbo.[Routes] 
		SET 
			ActualDeparture = CASE WHEN isnull(ActualDeparture,'')= '' THEN @ActualPickUpTime ELSE ActualDeparture END,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey<>@RouteKey

		IF  (	
				SELECT COUNT(1) 
				FROM dbo.[Routes] RT WITH (NOLOCK)
					INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
				WHERE RouteKey= @RouteKey AND RTS.Description<>'Completed' AND RT.DriverKey IS NOT NULL 
					AND ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
			)>0
		BEGIN
			UPDATE dbo.[Routes]
			SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Delivery Pending' )
			WHERE RouteKey= @RouteKey
		END;
		IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT WITH (NOLOCK)
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.Description<>'Completed' AND RT.DriverKey IS NOT NULL 
				  AND ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000'
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='DriverAssigned' )
		WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	END;
	END

	if(@Type = 'L')
	BEGIN
		UPDATE dbo.[Routes]
		SET 
			ActualArrival	= @ActualDeliveryTime	
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		UPDATE dbo.[Routes] 
		SET 
			ActualArrival = CASE WHEN ISNULL(ActualArrival,'') = '' THEN @ActualDeliveryTime ELSE ActualArrival END,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey<>@RouteKey
	END

	if(@Type = 'S')
	BEGIN
		UPDATE dbo.[Routes]
		SET 
			UpdateUserKey	= @UpdateUserKey,
			SwitchTo		=  @SwitchTo		
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		UPDATE dbo.[Routes] 
		SET 
			SwitchTo = CASE WHEN ISNULL(SwitchTo,'') = '' THEN @SwitchTo ELSE SwitchTo END,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey<>@RouteKey
	END

	UPDATE dbo.OrderDetail
	SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WITH (NOLOCK) WHERE [Description]='Dispatch InProgress' AND IsActive=1 ),
		StatusDate=GETDATE()
	WHERE OrderDetailKey=@OrderDetailKey

	--IF ( 
	--	SELECT COUNT(1) 
	--	FROM dbo.[Routes]
	--	WHERE OrderDetailKey=@OrderDetailKey AND ISNULL(ChassisKey,0)<>0 
	--		AND ISNULL(DriverKey,0)<>0 AND ActualDeparture IS NOT NULL AND ActualArrival IS NOT NULL
	--   )>1
	--BEGIN
	--	UPDATE dbo.OrderDetail
	--	SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Dispatch Complete' AND IsActive=1 ),
	--		StatusDate=GETDATE()
	--	WHERE OrderDetailKey=@OrderDetailKey

	--	SELECT DISTINCT OrderKey INTO #TempOrder
	--	FROM dbo.OrderDetail 
	--	WHERE OrderDetailKey=@OrderDetailKey

		--SELECT COUNT(1)
		--FROM dbo.OrderDetail OD INNER JOIN Dbo.OrderDetailStatus ODS ON ODS.[Status]=OD.[Status]
		--WHERE OrderKey IN ( SELECT OrderKey FROM #TempOrder ) AND ODS.[Description] <>''

		--UPDATE dbo.OrderHeader
		--SET Status= ()
		--WHERE OrderKey
	--END;

	 SELECT @IsRouteComplete = CASE WHEN ISNULL(RT.driverKey ,0) > 0 AND ISNULL(RT.ChassisNo,'') <> '' 
		AND ISNULL(RT.chassistype,'') <> '' AND 
				ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' AND
				ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
			THEN 1 ELSE 0 END 
    FROM dbo.Routes RT WITH (NOLOCK)
    WHERE RT.RouteKey = @RouteKey and Rt.Status <> 5

	IF ISNULL(@IsRouteComplete,0)=1
	BEGIN
		UPDATE dbo.Routes
		SET Status= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Ready to Complete')
		WHERE RouteKey=@RouteKey and Status <> 5
	END

	SELECT @IsReadyToComplete = dbo.FN_IsRouteComplete(@RouteKey)

	--SELECT @IsReadyToComplete AS IsReadyToComplete;

	SELECT 
    CAST(@IsReadyToComplete AS VARCHAR(5)) AS IsReadyToComplete
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;



	exec UpdateContainerStatus @OrderDetailKey
	SET @Status=1
	SET @Reason = 'Success'
END;