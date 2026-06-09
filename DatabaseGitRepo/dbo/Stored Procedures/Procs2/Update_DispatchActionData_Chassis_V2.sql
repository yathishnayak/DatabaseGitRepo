/*
DECLARE 
    @UserKey        INT = 953,
    @Status         BIT = 0,
    @Reason         VARCHAR(1000) = '',
    @IsDebug        BIT = 0,
    @JSONString     NVARCHAR(MAX) = '{"RouteKey": 722138, "ChassisKey": 3, "CategoryKey": 1,"ChassisNo": "JCTD100003", "ChassisType": "40/45"}'

EXEC [dbo].[Update_DispatchActionData_Chassis_V2]   @UserKey,@JSONString, @Status OUTPUT,  @Reason OUTPUT,@IsDebug
SELECT @Status AS Status, @Reason AS Reason;


DECLARE 
    @UserKey        INT = 1144,
    @Status         BIT = 0,
    @Reason         VARCHAR(1000) = '',
    @IsDebug        BIT = 0,
    @JSONString     NVARCHAR(MAX) = '{"RouteKey": 725671, "ChassisKey": 1845, "CategoryKey": 1,"ChassisNo": "JCTD100001", "ChassisType": "40/45"}'

EXEC [dbo].[Update_DispatchActionData_Chassis_V2]   @UserKey,@JSONString, @Status OUTPUT,  @Reason OUTPUT,@IsDebug
SELECT @Status AS Status, @Reason AS Reason;

*/


CREATE PROCEDURE [dbo].[Update_DispatchActionData_Chassis_V2] 
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
		
 IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	


	DECLARE @Routekey INT=0,@ChassisKey INT =0,@CategoryKey Int=0,@ChassisNo VARCHAR(30),@ChassisType  VARCHAR(30),@IsReadyToComplete  BIt ;




	 SELECT @Routekey=RouteKey,@ChassisKey=ChassisKey,@CategoryKey=CategoryKey,@ChassisNo=ChassisNo,@ChassisType=ChassisType
	 FROM OPENJSON(@JSONString, '$')
		WITH (
			   RouteKey         INT							'$.RouteKey',
			   ChassisKey       INT							'$.ChassisKey',
			   CategoryKey      INT							'$.CategoryKey',
			   ChassisNo         VARCHAR(30)				 '$.ChassisNo',
			   ChassisType        VARCHAR(30)				'$.ChassisType'
			   )
  
	DECLARE @OrderDetailKey INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @LegFromLocation VARCHAR(100)='';
	DECLARE @LegToLocation VARCHAR(100)='';
	DECLARE @CustKey INT=0;
	DECLARE @LegKey INT =0;
	DECLARE @OrderKey INT=0;
	DECLARE @OtherRouteKey INT=0;
	DECLARE @UserName VARCHAR(20)=''

	--SET @OutPut=0;
	SET @Status=0;
	SET @OrderDetailKey= (
							SELECT DISTINCT OrderDetailKey 
							FROM dbo.[Routes] WITH (NOLOCK) WHERE RouteKey= @RouteKey
						 )
	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='DriverAssigned')
	SELECT @UserName = ISNULL(UserName, '') FROM [User] WHERE UserKey = @UserKey

	UPDATE dbo.[Routes]
	SET 		
		ChassisNo		= @ChassisNo,
		ChassisType		= @ChassisType,
		ChassisKey		= @ChassisKey,
		ChassisCategoryKey  = @CategoryKey,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE()
	WHERE RouteKey= @RouteKey;

	IF @@ROWCOUNT > 0
	BEGIN
		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		SELECT GETDATE(), @UserName, 'Container', (SELECT ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey), @OrderDetailKey, NULL, 
		'Text' , 'Chassis updated to ' + @ChassisNo + ' by ' + @UserName
	END

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
								FROM dbo.RouteStatus WITH (NOLOCK)
								WHERE [Description]='Leg Completed'
							 )

	---***** chassis split auto for century for other legs ****---
	CREATE TABLE #TempTable
	(
		ROWID int identity(1,1) primary key,
		RouteKey int,
	)
	INSERT INTO #TempTable
	SELECT RouteKey FROM Routes WITH (NOLOCK) WHERE OrderDetailKey= @OrderDetailKey AND RouteKey<>@RouteKey
		AND  [Status] NOT IN (  
								SELECT [Status] 
								FROM dbo.RouteStatus WITH (NOLOCK)
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
				INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.[Description]<>'Leg Completed'
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE [Description]='Delivery Pending' )
		WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	END;
	IF (@CategoryKey = 4 AND ISNULL(@ChassisNo, '') = '')
BEGIN
    UPDATE R
    SET 
        R.ChassisNo = NULL,
        R.ChassisType = NULL,
        R.ChassisKey = 0,
        R.ChassisCategoryKey = NULL,
        R.LastUpdateDate = GETDATE(),
        R.UpdateUserKey = @UserKey
    FROM dbo.Routes R
    INNER JOIN dbo.Routes PR ON PR.OrderDetailKey = R.OrderDetailKey
    WHERE PR.RouteKey = @RouteKey;
END
	--**************************************************************************
	SELECT @IsReadyToComplete = dbo.FN_IsRouteComplete(@RouteKey)

	SET @Status=1

	SELECT @Status AS Output, @IsReadyToComplete as IsReadyToComplete FOR JSON PATH;
	PRINT @IsReadyToComplete
	
	SET @reason='Success'

END