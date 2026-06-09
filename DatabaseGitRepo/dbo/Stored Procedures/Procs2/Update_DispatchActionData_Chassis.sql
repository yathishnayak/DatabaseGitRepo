
CREATE PROCEDURE [dbo].[Update_DispatchActionData_Chassis]
/*Dispatch Screen*/
@RouteKey		INT,
@ChassisNo		VARCHAR(30),
@ChassisType	VARCHAR(30),
@ChassisKey		INT,
@CategoryKey	INT,
@UserKey		INT,
@OutPut			BIT OUTPUT,
@IsReadyToComplete BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @LegFromLocation VARCHAR(100)='';
	DECLARE @LegToLocation VARCHAR(100)='';
	DECLARE @CustKey INT=0;
	DECLARE @LegKey INT =0;
	DECLARE @OrderKey INT=0;
	DECLARE @OtherRouteKey INT=0;

	SET @OutPut=0;
	SET @OrderDetailKey= (
							SELECT DISTINCT OrderDetailKey 
							FROM dbo.[Routes] WHERE RouteKey= @RouteKey
						 )
	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned')

	UPDATE dbo.[Routes]
	SET 		
		ChassisNo		= @ChassisNo,
		ChassisType		= @ChassisType,
		ChassisKey		= @ChassisKey,
		ChassisCategoryKey  = @CategoryKey,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE()
	WHERE RouteKey= @RouteKey;

	---***** chassis split auto for century ****---
	SELECT @LegKey=L.LegKey,@OrderKey=OH.OrderKey,@LegFromLocation=L.FromLocation,
		   @LegToLocation=L.ToLocation,@CustKey=OH.CustKey
	FROM Routes  RT WITH (NOLOCK)
	INNER JOIN LEG L WITH (NOLOCK) ON L.LegKey=RT.LegKey
	INNER JOIN OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey
	INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
	WHERE RT.RouteKey=@RouteKey
	--SELECT @LegKey=LegKey FROM Routes where RouteKey=@RouteKey
	--SELECT @OrderKey=OrderKey FROM Routes where RouteKey=@RouteKey
	--SELECT @LegFromLocation=FromLocation FROM Leg where LegKey=@LegKey
	--SELECT @LegToLocation=ToLocation FROM Leg where LegKey=@LegKey
	--SELECT @CustKey=CustKey FROM OrderHeader WHERE OrderKey=@OrderKey
	IF((@LegFromLocation = 'Port' OR @LegToLocation = 'Port') AND @CustKey=3402 AND @CategoryKey in (2,3))
	BEGIN
		DECLARE @JasonString NVARCHAR(MAX)='{"RouteKey":'+CAST(@RouteKey AS VARCHAR)+',"IsChassisSplit":1,"OrderDetailKey":'+CAST(@OrderDetailKey AS VARCHAR)+'}'
		--SELECT @JasonString AS Request,@New_RouteKey as RouteKey INTO Temp_ChassiSplit
		EXEC Container_IsChassisSplit @UserKey,@JasonString,'',0,''
		UPDATE Routes SET IsChassisSplit=1, ChassisSplitBy=@UserKey,ChassisSplitDate=GETDATE() WHERE RouteKey=@RouteKey
	END
	---**** end ****---

	--**********************Copy Chassis Data to other Legs*********************
	UPDATE dbo.[Routes]
	SET ChassisNo=   CASE WHEN ISNULL(ChassisNo,'')<>'' THEN ChassisNo ELSE @ChassisNo END,
		ChassisType= CASE WHEN ISNULL(ChassisType,'')<>'' THEN ChassisType ELSE @ChassisType END,
		ChassisKey=  CASE WHEN ISNULL(ChassisKey,0)<>0 THEN ChassisKey ELSE @ChassisKey END,
		ChassisCategoryKey= CASE WHEN ISNULL(ChassisCategoryKey,0)<>0 THEN ChassisCategoryKey ELSE @CategoryKey END
	WHERE OrderDetailKey= @OrderDetailKey AND RouteKey<>@RouteKey
		AND  [Status] NOT IN (  
								SELECT [Status] 
								FROM dbo.RouteStatus 
								WHERE [Description]='Leg Completed'
							 )

	---***** chassis split auto for century for other legs ****---
	CREATE TABLE #TempTable
	(
		ROWID int identity(1,1) primary key,
		RouteKey int,
	)
	INSERT INTO #TempTable
	SELECT RouteKey FROM Routes WHERE OrderDetailKey= @OrderDetailKey AND RouteKey<>@RouteKey
		AND  [Status] NOT IN (  
								SELECT [Status] 
								FROM dbo.RouteStatus 
								WHERE [Description]='Leg Completed'
							 )

	DECLARE @MAXID INT, @Counter INT, @OtherCategoryKey INT=0

	SET @COUNTER = 1
	SELECT @MAXID = COUNT(*) FROM #TempTable

	WHILE (@COUNTER <= @MAXID)
	BEGIN
		SELECT @OtherRouteKey =RouteKey FROM #TempTable AS PT
								WHERE ROWID = @COUNTER
		
		SELECT @LegKey=RT.LegKey,@OrderKey=OH.OrderKey,@LegFromLocation=L.FromLocation,
			   @LegToLocation=L.ToLocation,@CustKey=OH.CustKey,@OtherCategoryKey = RT.ChassisCategoryKey		
		FROM Routes RT WITH (NOLOCK) 
		INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey
		INNER JOIN OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
		where RT.RouteKey=@OtherRouteKey
		--SELECT @LegKey=LegKey FROM Routes where RouteKey=@OtherRouteKey
	 --   SELECT @OrderKey=OrderKey FROM Routes where RouteKey=@OtherRouteKey
		--SELECT @LegFromLocation=FromLocation FROM Leg where LegKey=@LegKey
		--SELECT @LegToLocation=ToLocation FROM Leg where LegKey=@LegKey
		--SELECT @CustKey=CustKey FROM OrderHeader WHERE OrderKey=@OrderKey
		--SELECT @OtherCategoryKey = ChassisCategoryKey FROM Routes WHERE RouteKey=@OtherRouteKey
		IF((@LegFromLocation = 'Port' OR @LegToLocation = 'Port') AND @CustKey=3402 AND @OtherCategoryKey IN (2,3))
		BEGIN
			SET @JasonString ='{"RouteKey":'+CAST(@OtherRouteKey AS VARCHAR)+',"IsChassisSplit":1,"OrderDetailKey":'+CAST(@OrderDetailKey AS VARCHAR)+'}'
			--SELECT @JasonString AS Request,@New_RouteKey as RouteKey INTO Temp_ChassiSplit
			EXEC Container_IsChassisSplit @UserKey,@JasonString,'',0,''
			UPDATE Routes SET IsChassisSplit=1, ChassisSplitBy=@UserKey,ChassisSplitDate=GETDATE() WHERE RouteKey=@OtherRouteKey
		END
		SET @COUNTER = @COUNTER + 1
	END
	IF (OBJECT_ID('tempdb..#TempTable') IS NOT NULL)
	BEGIN
		DROP TABLE #TempTable
	END
	--***********End***********--

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
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed'
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Delivery Pending' )
		WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	END;
	--**************************************************************************
	SELECT @IsReadyToComplete = dbo.FN_IsRouteComplete(@RouteKey)
	SET @OutPut=1;
END
