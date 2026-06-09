/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey": 177973, "Description":"Leg Completed", "ReasonKey" : 1, "ReasonText" : "123"}'
	EXEC [Update_CancelRouteStatus_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason 
**/
--drop proc [Update_CancelRouteStatus]
CREATE PROCEDURE [dbo].[Update_CancelRouteStatus_V2] -- [Update_CancelRouteStatus] null, null, null, null, null
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
		@RouteKey	 INT = 115,
		@Description VARCHAR(50),
		@ReasonKey	 SMALLINT,
		@ReasonText  VARCHAR(50)

	SELECT 
		@RouteKey		= RouteKey,	
		@Description	= Description,
		@ReasonKey		= ReasonKey,	
		@ReasonText		= ReasonText
	FROM OPENJSON(@JSONString)
	WITH
	(
		RouteKey			INT					'$.RouteKey',	
		Description			VARCHAR(50)			'$.Description',
		ReasonKey			SMALLINT			'$.ReasonKey',	
		ReasonText 			VARCHAR(50)			'$.ReasonText'
	)


	DECLARE @CompleteStatusKey SMALLINT;
	DECLARE @OrderDetailKey INT;
	DECLARE @StatusKey		SMALLINT
	DECLARE @StatusDesc		VARCHAR(200)
	DECLARE @IsContainerReadyToComplete BIT
	DECLARE @LegNo		SMALLINT
	DECLARE @NexLeg		SMALLINT
	DECLARE @CurrLeg	VARCHAR(50)	
	DECLARE @DriverKey INT

	SET @DriverKey=( SELECT DriverKey FROM dbo.[routes] WITH (NOLOCK) WHERE RouteKey=@RouteKey)

	BEGIN TRY
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

		SET @CompleteStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Leg Completed' );

		--IF ( SELECT COUNT(1) FROM DriverRouteAcceptance WHERE [Description]= @Description AND RouteKey = @RouteKey )<>0
		--BEGIN
			INSERT INTO DriverRouteAcceptance (RouteKey,[Description],CreateUserKey,RejectReasonKey, RejectReasonDescr,DriverKey)
			SELECT @RouteKey,@Description,@UserKey,@ReasonKey,@ReasonText,@DriverKey;

			--UPDATE dbo.Routes
			--SET [Status]= @CompleteStatusKey
			--WHERE RouteKey= @RouteKey;

			UPDATE dbo.[routes]
			SET DriverKey= NULL
			WHERE RouteKey=@RouteKey

			UPDATE dbo.[Routes]
			SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Open' AND IsActive=1 )
			WHERE RouteKey= @RouteKey
		--END
		--***************************************************	

		SET @OrderDetailKey= (	
								SELECT OrderDetailKey 
								FROM dbo.Routes 
								WHERE  RouteKey = @RouteKey							
							 )
		SELECT MIN(RT.Routekey) AS RouteKey,RT.OrderDetailKey INTO #NextOPenLeg
		FRom dbo.Routes RT WITH (NOLOCK) 
			INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.Status=RT.Status
		WHERE RTS.[Description]<>'Leg Completed' AND RT.OrderDetailKey = @OrderDetailKey							
		GROUP BY RT.OrderDetailKey

		IF (SELECT COUNT(1) FROM #NextOPenLeg)<>0
		BEGIN
			UPDATE dbo.[Routes] 
			SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned' ), 
					LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
			WHERE RouteKey IN (	SELECT RouteKey FROM #NextOPenLeg )	AND ActualArrival IS NULL 
				  AND DriverKey IS NOT NULL AND ActualDeparture IS NULL

			UPDATE dbo.[Routes] 
			SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Delivery Pending' ), 
					LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
			WHERE RouteKey IN (	SELECT RouteKey FROM #NextOPenLeg )	AND ActualArrival IS NOT NULL 
				  AND DriverKey IS NOT NULL AND ActualDeparture IS NULL

			UPDATE dbo.[Routes] 
			SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' ), 
					LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
			WHERE RouteKey IN (	SELECT RouteKey FROM #NextOPenLeg )	AND ActualArrival IS NULL
				  AND DriverKey IS NULL AND ActualDeparture IS NULL

			UPDATE dbo.[Routes] 
			SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Ready To Complete' ), 
					LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
			WHERE RouteKey IN (	SELECT RouteKey FROM #NextOPenLeg )	AND ActualArrival IS NOT NULL
				  AND DriverKey IS NOT NULL AND ActualDeparture IS NOT NULL
		END
		--***************LegNo and Status ( Next Open leg ) 02162021***************
		SELECT ROW_NUMBER() OVER ( PARTITION BY RT.Orderdetailkey ORDER BY Routekey) AS LegNo,RT.OrderDetailKey,
			   RT.RouteKey INTO #RouteLegNo
		FROM dbo.Routes RT WITH (NOLOCK)
		WHERE RT.OrderDetailKey=@OrderDetailKey
		--*****************************************************************************
		SELECT RT.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
		FROM dbo.Routes RT  WITH (NOLOCK)
		WHERE RT.OrderDetailKey=@OrderDetailKey
		GROUP BY RT.OrderDetailKey

		INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
		SELECT RT.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
		FROM dbo.Routes RT WITH (NOLOCK)	
			INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)	ON RTS.[Status]=RT.[Status]
		WHERE RTS.[Description]<>'Leg Completed'AND RT.OrderDetailKey=@OrderDetailKey
		GROUP BY RT.OrderDetailKey

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
			,  @CurrLeg =CAST(ISNULL(R.LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50))
		FROM #RouteLegNo R 
			INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=R.OrderDetailKey
			INNER JOIN #LegCount L ON L.OrderDetailKey=Q.OrderDetailKey
			LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=R.OrderDetailKey

		SET @StatusKey=( SELECT [Status] FROM [Routes] WITH (NOLOCK) WHERE RouteKey= ( SELECT CurrOPenRoutekey FROM #CurrLeg) )
		SET @StatusDesc=( SELECT [Description] FROM RouteStatus WITH (NOLOCK) WHERE [Status]=@StatusKey)
		SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey= ( SELECT CurrOPenRoutekey FROM #CurrLeg) )
		--**************************************************************************
		--SET @OutPut=1;	
		 SELECT @IsContainerReadyToComplete = dbo.FN_IsOrderDetailComplete(@OrderDetailKey)
	 END TRY
	 BEGIN CATCH
	 --
	 END CATCH
	 SELECT   @IsContainerReadyToComplete AS IsContainerReadyToComplete,@StatusKey AS [StatusKey],
			 @StatusDesc AS StatusDesc , @LegNo AS LegNo,@NexLeg AS NextLeg ,@CurrLeg AS CurLeg
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END