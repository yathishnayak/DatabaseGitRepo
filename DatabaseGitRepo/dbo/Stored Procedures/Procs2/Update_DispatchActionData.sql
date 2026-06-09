CREATE PROCEDURE [dbo].[Update_DispatchActionData]
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
@Type			CHAR(1), -- D: Driver, C: Chassi, P: Pickup, L: Delivery, S: SwitchTo, A: All
@OutPut			BIT OUTPUT,
@IsReadyToComplete BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @IsRouteComplete BIT
	DECLARE @DriverAsgStatusKey SMALLINT

	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned')

	SET @OutPut=0;
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
			SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned' ) 
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
				FROM dbo.[Routes] RT 
					INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
				WHERE RouteKey= @RouteKey AND RTS.Description<>'Completed' AND RT.DriverKey IS NOT NULL 
					AND ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
			)>0
		BEGIN
			UPDATE dbo.[Routes]
			SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Delivery Pending' )
			WHERE RouteKey= @RouteKey
		END;
		IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.Description<>'Completed' AND RT.DriverKey IS NOT NULL 
				  AND ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000'
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned' )
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
	SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Dispatch InProgress' AND IsActive=1 ),
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
    FROM dbo.Routes RT
    WHERE RT.RouteKey = @RouteKey and Rt.Status <> 5

	IF ISNULL(@IsRouteComplete,0)=1
	BEGIN
		UPDATE dbo.Routes
		SET Status= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Ready to Complete')
		WHERE RouteKey=@RouteKey and Status <> 5
	END

	SELECT @IsReadyToComplete = dbo.FN_IsRouteComplete(@RouteKey)

	exec UpdateContainerStatus @OrderDetailKey
	SET @OutPut=1;
END;
