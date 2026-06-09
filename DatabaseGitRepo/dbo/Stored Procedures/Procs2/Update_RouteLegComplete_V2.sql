/** 
Declare 
	@UserKey		INT=953,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey":726819}'
	EXEC [Update_RouteLegComplete_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Update_RouteLegComplete_V2]
(    
    @UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)

AS
BEGIN

	SET NOCOUNT ON;
	SET FMTONLY OFF;  
	SET ARITHABORT ON;  

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	 DECLARE @Routekey INT=0;

	 SELECT @Routekey=RouteKey
	 FROM OPENJSON(@JSONString, '$')
		WITH (
			   RouteKey         INT      '$.RouteKey'
			  )

DECLARE @OrderDetailKey INT
		,@StatusKey		SMALLINT
		,@StatusDesc		VARCHAR(200)
		,@IsContainerReadyToComplete BIT
		,@LegNo			SMALLINT
		,@NexLeg			SMALLINT
		,@CurrLeg		VARCHAR(50)
		,@PickupDateFrom	dateTime
		,@PickupDateTo	dateTime
		,@OutPut	BIT=1
		,@PTTExist  BIT


	DECLARE  @documentTypeKey INT =0, @LegKey INT=0, @OMessage VARCHAR(300)='',@IMessage VARCHAR(300)='',@PMessage VARCHAR(300)='',@Message VARCHAR(300)='',@PTTMessage VARCHAR(300)='',
			 @OCounter INT=0, @ICounter INT=0, @PCounter INT=0,@Counter INT=1,@PTTCounter INT=0, @OrderTypeKey INT=0,@MarketLocationKey INT=0,@OrderKey INT=0;

	SELECT @LegKey=LegKey,@OrderDetailKey=OrderDetailKey FROm Routes WITH (NOLOCK) WHERE RouteKey=@Routekey
	--print 'LegKey'
	--print @LegKey
	--SELECT @OrderTypeKey = ISNULL(OrderTypeKey,0) FROM OrderDetail OH WHERE OrderDetailKey= @OrderDetailKey
	
	SELECT @OrderTypeKey  = ISNULL(OD.OrderTypeKey, OH.OrderTypeKey),@MarketLocationKey = ISNULL(OH.MarketLocationKey, 0)
	FROM OrderDetail OD WITH(NOLOCK) 
	INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = OD.OrderKey WHERE OD.OrderDetailKey = @OrderDetailKey;

	SELECT @PTTExist = isnull(PTTChecked,0) from orderdetail where OrderDetailKey= @OrderDetailKey	
	--print '@PTTExist'
	--print @PTTExist
	--Added for PTT document
	If(@LegKey in (1,2,3,5,34,35,40,41,42,43,45,46,51,52,60) AND @PTTExist =1)
	BEGIN
		SET @documentTypeKey=(SELECT DocumentTypeKey FROM DocumenType WHERE Shortcode='PTT')--16
		SET @PTTMessage='PTT document required'
		SELECT @PTTCounter =COUNT(1) FROM ContainerLegDocuments CDL WITH(NOLOCK)
		INNER JOIN Document D WITH(NOLOCK) ON (D.DocumentKey=CDL.DocumentKey)
		WHERE CDL.RouteKey=@RouteKey and DocumentType=@documentTypeKey
		IF(@PTTCounter>0)
		BEGIN
			SET @PTTMessage='';
		END
	END
	 --ADDED 5 in LEGKEY
	If(@LegKey in (3,5, 34,40,41,1,45,35,2,46,42,43) AND @OrderTypeKey <> 3 AND @MarketLocationKey IN (2,3))
	BEGIN
		SET @documentTypeKey=(SELECT DocumentTypeKey FROM DocumenType WHERE Shortcode='OTG')--16
		SET @OMessage='Outgate document required'
		SELECT @OCounter =COUNT(1) FROM ContainerLegDocuments CDL WITH(NOLOCK)
		INNER JOIN Document D WITH(NOLOCK) ON (D.DocumentKey=CDL.DocumentKey)
		WHERE CDL.RouteKey=@RouteKey and DocumentType=@documentTypeKey
		IF(@OCounter>0)
		BEGIN
			SET @OMessage='';
		END
	END
	If(@LegKey in (34,35,1,45,9,36,37,55,56,32,27,30,32,38,39,55,56))
	BEGIN
		SET @documentTypeKey=(SELECT DocumentTypeKey FROM DocumenType WHERE Shortcode='POD')--2
		if(@OMessage<>'')
		BEGIN
			SET @PMessage='Outgate and POD documents are required'
		END
		ELSE
		BEGIN
			SET @PMessage='POD document required'
		END
		SELECT @PCounter =COUNT(1) FROM ContainerLegDocuments CDL WITH(NOLOCK)
		INNER JOIN Document D WITH(NOLOCK) ON (D.DocumentKey=CDL.DocumentKey)
		WHERE CDL.RouteKey=@RouteKey and DocumentType=@documentTypeKey
		IF(@PCounter>0)
		BEGIN
			SET @PMessage='';
		END
	END
	--If(@LegKey in (7,11,58,47,19,13,40,41) AND @OrderTypeKey <> 3)

	---ADD 48
	 -- ADD 37   54
	If(@LegKey in (7,11,58,47,48,19,13,40,41,8,37,54) AND @OrderTypeKey <> 3  AND @MarketLocationKey  IN (2,3))
	BEGIN
		SET @documentTypeKey=(SELECT DocumentTypeKey FROM DocumenType WITH(NOLOCK) WHERE Shortcode='ING')--15
		if(@PMessage<>'')
		BEGIN
			SET @IMessage='POD and Ingate documents are required'
		END
		ELSE if(@OMessage<>'')
		BEGIN
			SET @IMessage='Outgate and Ingate documents are required'
		END
		ELSE
		BEGIN
			SET @IMessage='Ingate document required'
		END
		SELECT @ICounter =COUNT(1) FROM ContainerLegDocuments CDL WITH(NOLOCK)
		INNER JOIN Document D WITH(NOLOCK) ON (D.DocumentKey=CDL.DocumentKey)
		WHERE CDL.RouteKey=@RouteKey and DocumentType=@documentTypeKey
		IF(@ICounter>0)
		BEGIN
			SET @IMessage='';
		END
	END
	--select @IMessage AS IMessage
	--select @OMessage AS OMessage
	--select @PMessage AS PMessage
	--SELECT @Counter =COUNT(1) FROM ContainerLegDocuments CDL
	--INNER JOIN Document D ON (D.DocumentKey=CDL.DocumentKey)
	--WHERE CDL.RouteKey=@RouteKey and DocumentType=@documentTypeKey
	--SET @Counter=@PCounter+@OCounter+@ICounter;
	
	SET @Message=(CASE WHEN ISNULL(@OMessage,'')<>'' AND ISNULL(@PMessage,'')<>'' THEN  ISNULL(@PMessage,'')
				  WHEN ISNULL(@PMessage,'')<>'' AND ISNULL(@IMessage,'')<>'' THEN  ISNULL(@IMessage,'')
				  WHEN ISNULL(@OMessage,'')<>'' AND ISNULL(@IMessage,'')<>'' THEN  ISNULL(@IMessage,'')
				  WHEN ISNULL(@PTTMessage,'')<>'' AND ISNULL(@OMessage,'')<>'' THEN  ISNULL(@PTTMessage,'')
				  WHEN ISNULL(@PTTMessage,'')<>'' AND ISNULL(@PMessage,'')<>'' THEN  ISNULL(@PTTMessage,'')
				  WHEN ISNULL(@PTTMessage,'')<>'' AND ISNULL(@IMessage,'')<>'' THEN  ISNULL(@PTTMessage,'')
				  WHEN ISNULL(@OMessage,'')<>'' AND ISNULL(@IMessage,'')='' AND ISNULL(@PMessage,'')='' AND ISNULL(@PTTMessage,'')='' THEN ISNULL(@OMessage,'')
				  WHEN ISNULL(@PMessage,'')<>'' AND ISNULL(@IMessage,'')='' AND ISNULL(@OMessage,'')='' AND ISNULL(@PTTMessage,'')='' THEN  ISNULL(@PMessage,'')
				  WHEN ISNULL(@IMessage,'')<>'' AND ISNULL(@PMessage,'')='' AND ISNULL(@OMessage,'')='' AND ISNULL(@PTTMessage,'')='' THEN  ISNULL(@IMessage,'')
				  WHEN ISNULL(@PTTMessage,'')<>'' AND ISNULL(@IMessage,'')='' AND ISNULL(@PMessage,'')='' AND ISNULL(@OMessage,'')='' THEN ISNULL(@PTTMessage,'')
				  ELSE @OMessage END
				 )

	--print @counter
	--select @Message

	IF(ISNULL(@Message,'')<>'')
	BEGIN
		SET @Counter=0
	END
	if(@Counter=0)
	BEGIN
		SET @Message=@Message
		SET @OutPut=0
	END
	ELSE
	BEGIN
		SET @Message=''
	END
	print 'Message'
	print @Message
	IF(@Counter=0)
	BEGIN
	SELECT  CAST(0 AS bit) AS IsContainerReadyToComplete,ISNULL(@StatusKey,0) AS [StatusKey],
				 @Message AS StatusDesc , ISNULL(@LegNo,0) AS LegNo,ISNULL(@NexLeg,0) AS NextLeg ,ISNULL(@CurrLeg,0) as CurLeg,
				 ISNULL(@PickupDateFrom,GETDATE()) as PickupDateFrom, ISNULL(@PickupDateTo,GETDATE()) as PickupDateTo, @OutPut AS OutPutVal
				 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	END
	ELSE
	BEGIN
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

	CREATE TABLE #TempData
	(
		RouteKey INT
	);
		
	CREATE TABLE #TempOrderDetail
	(
		OrderDetailKey INT
	);

	INSERT INTO #TempData (RouteKey)
	SELECT * FROM Fn_SplitParamCol (@Routekey);

	DELETE FROM #TempData WHERE RouteKey IS NULL OR RouteKey=0

	INSERT INTO #TempOrderDetail
	SELECT DISTINCT RT.OrderDetailKey
	FROM #TempData A 
		INNER JOIN Dbo.[Routes] RT WITH(NOLOCK) ON RT.RouteKey=A.RouteKey

	SELECT A.RouteKey INTO #IncomplCont
	FROM dbo.[Routes] A WITH(NOLOCK) 
		INNER JOIN dbo.RouteStatus RS WITH(NOLOCK) ON RS.[Status]=A.[Status]
	WHERE RouteKey IN ( SELECT RouteKey FROM dbo.#TempData ) 
	AND (-- ISNULL(ChassisNo ,'')= '' OR 
	ISNULL(DriverKey,'')='' OR ActualArrival IS NULL);

	DELETE FROM #TempData 
	WHERE RouteKey IN ( SELECT RouteKey FROM #IncomplCont );
	--**************Routes Status to Complete****************************
	UPDATE dbo.[Routes] 
	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH(NOLOCK) WHERE [Description]='Leg Completed' ), 
			LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
	WHERE RouteKey IN ( SELECT RouteKey FROM dbo.#TempData );

	--********OrderDetail Status to Dispatch Confirmed if all legs are Completed*******

	--SELECT RT.OrderDetailKey,RT.RouteKey,RT.[Status] INTO #Tempdb2
	--FROM dbo.Routes RT 
	--	INNER JOIN Dbo.#TempOrderDetail D ON D.OrderDetailKey=RT.OrderDetailKey

	--SELECT DISTINCT OrderDetailKey INTO #IncompCont
	--FROM #Tempdb2 WHERE ISNULL([Status],0)<>3

	--DELETE FROM #Tempdb2 WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #IncompCont)

	/*  THIS CODE WAS MARKING CONTAINER AS COMPLETED AUTOMATICALLY. HENCE, COMMENTED.
	IF ( SELECT COUNT(1) FROM #Tempdb2)>0
	BEGIN		
		UPDATE dbo.OrderDetail
		SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Dispatch Confirmed' )
		where OrderDetailKey IN
		(	
			 SELECT DISTINCT OrderDetailKey FROM dbo.#Tempdb2
		)
	END
	*/
	--*************************************************************************
	Declare @ContainerNo varchar(50),
			@LegID		varchar(100),
			@UserName	varchar(100)

   	select @ContainerNo = ContainerNo, @LegID = L.LegID, @OrderDetailKey = OD.OrderDetailKey
	from OrderDetail OD WITH(NOLOCK)
	inner join Routes RT WITH(NOLOCK) on OD.OrderDetailKey = RT.OrderDetailKey
	LEft join Leg L WITH(NOLOCK) on RT.LegKey = L.LegKey
	where RT.RouteKey = @Routekey

	SET @OrderDetailKey = ( SELECT  TOP 1 OrderDetailKey FROM #TempOrderDetail )
	SET @IsContainerReadyToComplete = dbo.FN_IsOrderDetailComplete(@OrderDetailKey) 

	SELECT OrderDetailKey INTO #OrderDetailKey
	FROM dbo.Routes WITH(NOLOCK) 
	WHERE  RouteKey IN (
						SELECT RouteKey 
						FROM dbo.#TempData
						)

	SELECT MIN(RT.Routekey) AS RouteKey,RT.OrderDetailKey INTO #NextOPenLeg
	FRom dbo.Routes RT  WITH(NOLOCK)
		INNER JOIN dbo.RouteStatus RTS WITH(NOLOCK) ON RTS.Status=RT.Status
	WHERE RTS.[Description]<>'Leg Completed' AND RT.OrderDetailKey IN 
							( 
							  SELECT OrderDetailKey 
							  FROM #OrderDetailKey 
							)
	GROUP BY RT.OrderDetailKey
	
	IF (SELECT COUNT(1) FROM #NextOPenLeg)<>0  --AND @IsContainerReadyToComplete=1
	--BEGIN
	--	UPDATE dbo.[Routes] 
	--	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Ready To Complete' ), 
	--			LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
	--	WHERE RouteKey IN ( SELECT RouteKey FROM dbo.#TempData )		
	--END
	--ELSE
	BEGIN
		UPDATE dbo.[Routes] 
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH(NOLOCK) WHERE [Description]='DriverAssigned' ), 
				LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
		WHERE RouteKey IN (	SELECT RouteKey FROM #NextOPenLeg )	AND ActualArrival IS NULL 
			  AND DriverKey IS NOT NULL AND ActualDeparture IS NULL

		UPDATE dbo.[Routes] 
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH(NOLOCK) WHERE [Description]='Delivery Pending' ), 
				LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
		WHERE RouteKey IN (	SELECT RouteKey FROM #NextOPenLeg )	AND ActualArrival IS NOT NULL 
			  AND DriverKey IS NOT NULL AND ActualDeparture IS NULL

		UPDATE dbo.[Routes] 
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH(NOLOCK) WHERE [Description]='Open' ), 
				LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
		WHERE RouteKey IN (	SELECT RouteKey FROM #NextOPenLeg )	AND ActualArrival IS NULL
			  AND DriverKey IS NULL AND ActualDeparture IS NULL

		UPDATE dbo.[Routes] 
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH(NOLOCK) WHERE [Description]='Ready To Complete' ), 
				LastUpdateDate = GETDATE(),UpdateUserKey=@UserKey 
		WHERE RouteKey IN (	SELECT RouteKey FROM #NextOPenLeg )	AND ActualArrival IS NOT NULL
			  AND DriverKey IS NOT NULL AND ActualDeparture IS NOT NULL
	END

	--***************LegNo and Status ( Next Open leg ) 02162021***************

	SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,A.OrderDetailKey,
		   W.RouteKey INTO #RouteLegNo
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH(NOLOCK) WHERE RouteKey= @RouteKey ) A 
		INNER JOIN dbo.Routes W ON W.OrderDetailKey=A.OrderDetailKey		

	--SET @StatusKey=( SELECT [Status] FROM [Routes] WHERE RouteKey=@RouteKey)
	--SET @StatusDesc=( SELECT [Description] FROM RouteStatus WHERE [Status]=@StatusKey)
	--SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey=@RouteKey )	

	--*****************************************************************************
	SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH(NOLOCK) WHERE RouteKey= @RouteKey) A 
			LEFT JOIN dbo.Routes RT WITH(NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
	GROUP BY A.OrderDetailKey

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH(NOLOCK) WHERE RouteKey= @RouteKey) A 
		INNER JOIN dbo.Routes RT WITH(NOLOCK)		ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS WITH(NOLOCK)	ON RTS.[Status]=RT.[Status]
	WHERE RTS.[Description]<>'Leg Completed'
	GROUP BY A.OrderDetailKey

	SELECT A.OrderDetailKey INTO #AllOrdCompLeg 
	FROM (SELECT OrderDetailKey FROM dbo.[Routes] WITH(NOLOCK) WHERE RouteKey= @RouteKey) A
	WHERE A.OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CurrLeg)

	INSERT INTO #AllOrdComplLeg (OrderDetailKey,LastRoutekey)
	SELECT OrderDetailKey,CurrOPenRoutekey 
	FROM #CurrLeg

	INSERT INTO #CurrLeg (OrderDetailKey,CurrOPenRoutekey)
	SELECT A.OrderDetailKey,ISNULL(MAX(RT.RouteKey),0) AS CurrOPenRoutekey
	FROM #AllOrdCompLeg A 
		INNER JOIN dbo.Routes RT WITH(NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey		
	GROUP BY A.OrderDetailKey
	declare @CurrOPenRoutekey int = 0
	  SELECT @CurrOPenRoutekey = CurrOPenRoutekey FROM #CurrLeg
	SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey= @CurrOPenRoutekey)

	SELECT @NexLeg=CASE WHEN C.LastRoutekey IS NULL THEN 0 ELSE ISNULL(R.LegNo,0) END 
		,  @CurrLeg =CAST(ISNULL(@LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50))
	FROM #RouteLegNo R 
		INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=R.OrderDetailKey
		INNER JOIN #LegCount L ON L.OrderDetailKey=Q.OrderDetailKey
		LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=R.OrderDetailKey

	SELECT @StatusKey = [Status], @PickupDateFrom = PickupDateFrom, @PickupDateTo = PickupDateTo 
		FROM [Routes] WHERE RouteKey= @CurrOPenRoutekey 

	SET @StatusDesc=( SELECT [Description] FROM RouteStatus WITH(NOLOCK) WHERE [Status]=@StatusKey)
	--SET @LegNo= ( SELECT LegNo FROM #RouteLegNo WHERE RouteKey= @CurrOPenRoutekey)
	--**************************************************************************
	--SET @OutPut=1;	
	exec UpdateContainerStatus @OrderDetailKey

	 SELECT  @IsContainerReadyToComplete AS IsContainerReadyToComplete,@StatusKey AS [StatusKey],
			 @StatusDesc AS StatusDesc , @LegNo AS LegNo,@NexLeg AS NextLeg ,@CurrLeg as CurLeg,
			 @PickupDateFrom as PickupDateFrom, @PickupDateTo as PickupDateTo, @OutPut AS OutPutVal
			 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Leg ' + @LegID + ' marked as Complete by ' +@UserName
	END

	SET @Status = 1
	SET @Reason = 'Success'

END