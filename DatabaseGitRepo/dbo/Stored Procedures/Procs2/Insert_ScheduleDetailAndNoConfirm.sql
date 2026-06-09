CREATE PROCEDURE [dbo].[Insert_ScheduleDetailAndNoConfirm]
/*
Scheduler Screen
*/
@OrderKey		INT,
@OrderDetailKey INT,
@LegKey			INT,
@LegTypeKey		INT,
@SourceAddrKey	INT,
@DestAddrKey	INT,
@PickupDate		DATETIME,
@PickupDateTo		DATETIME,
@DeliveyDateFrom	DATETIME,
@DeliveyDateTo	DATETIME,
@ConfirmationNo VARCHAR(50),
@LastFreeDay	DATETIME,
@CutOffDate		DATETIME,
@SwitchTo		VARCHAR(50),
@DriverNotes	VARCHAR(500),
@SchedulerNotes VARCHAR(500),
@Status			SMALLINT=1,
@DriverKey		INT,
@CreateUserKey	INT,
@DelConfirmationNo VARCHAR(50),
@LegNo			smallint,
@OutPut			INT OUTPUT,
@TMFCheckOff    BIT,
@CTFCheckOff    BIT,
@SizeCheckOff	BIT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @New_CommentKey INT;
	DECLARE @New_RouteKey INT;
	DECLARE @ExpenseDesc VARCHAR(200);
	DECLARE @Itemkey VARCHAR(100);
	DECLARE @Output1 BIT;
	--DECLARE @LegFromLocation VARCHAR(100)='';
	--DECLARE @LegToLocation VARCHAR(100)='';
	--DECLARE @CustKey INT=0;

	IF ISNULL(@OrderKey,0)=0
	BEGIN
		SET @OrderKey= (SELECT DISTINCT OrderKey FROM dbo.OrderDetail WHERE OrderDetailKey=@OrderDetailKey );
	END;

	CREATE TABLE #ExpenseItem
	(
		ExpenseItem VARCHAR(50),
		OrderDetailKey INT,
		ItemID VARCHAR(50),
		ItemKey INT
	);	

	SET @Status= CASE WHEN @Status=0 THEN 1 WHEN @Status IS NULL THEN 1 ELSE @Status END

	declare @ChassisKey int, @ChassisNo varchar(50), @ChassisType varchar(50)
	select top 1 @ChassisKey = ChassisKey, @ChassisNo = ChassisNo, @ChassisType= ChassisType
	from Routes R
	where OrderDetailKey = @OrderDetailKey and isnull(ChassisKey ,0) > 0

	INSERT INTO [Routes]
	(	[OrderDetailKey], [OrderKey], [LegKey],LegNo, [SourceAddrKey], [PickupDateFrom], [PickupDateTo], 
		[DeliveryDateFrom],[DeliveryDateTo], [AppointmentNo], [ConfirmationNo], [LastFreeDay], [SwitchTo], 
		[PortWaitingTimeFrom], [PortWaitingTimeTo], [CustomerWaitingTimeFrom], [CustomerWaitingTimeTo], 
		[FromLocation], [ToLocation], [DestinationAddrKey], [EstimatedDistanceInMiles], [EstimatedTravelTime], 
		[Status], [DriverKey], [ScheduledPickupDate], [ScheduledArrival], [ActualDeparture], [ActualArrival], 
		[OdometerAtSource], [OdometerAtDestination], CreateUserKey,CreateDate,ChassisKey, ChassisNo, ChassisType,
		DelConfirmationNo
	)
	VALUES (
			 @OrderDetailKey,@OrderKey,@LegKey,isnull(@LegNo,1),@SourceAddrKey,@PickupDate,@PickupDateTo,
			 @DeliveyDateFrom,@DeliveyDateTo,NULL,@ConfirmationNo,@LastFreeDay,@SwitchTo,
			 NULL,NULL,NULL,NULL,
			 NULL,NULL, @DestAddrKey,null,null,
			 @Status,null,@PickupDate,@DeliveyDateFrom,NULL,NULL,
			 NULL,NULL, @CreateUserKey,GETDATE(),@ChassisKey, @ChassisNo, @ChassisType,
			 @DelConfirmationNo
			);

	SET @New_RouteKey= ( SELECT SCOPE_IDENTITY() );

	---***** chassis split auto for century ****---
	--SELECT @LegFromLocation=FromLocation FROM Leg where LegKey=@LegKey
	--SELECT @LegToLocation=ToLocation FROM Leg where LegKey=@LegKey
	--SELECT @CustKey=CustKey FROM OrderHeader WHERE OrderKey=@OrderKey
	--IF((@LegFromLocation = 'Port' OR @LegToLocation = 'Port') AND @CustKey=3402)
	--BEGIN
	--	DECLARE @JasonString NVARCHAR(MAX)='{"RouteKey":'+CAST(@New_RouteKey AS VARCHAR)+',"IsChassisSplit":true,"OrderDetailKey":'+CAST(@OrderDetailKey AS VARCHAR)+'}'
	--	EXEC Container_IsChassisSplit @CreateUserKey,@JasonString,'',0,''
	--	UPDATE Routes SET IsChassisSplit=1, ChassisSplitBy=1,ChassisSplitDate=GETDATE() WHERE RouteKey=@New_RouteKey
	--END
	---**** end ****---
	
	/*
	UPDATE A
	SET A.LegNo=L.LegNo
	FROM [Routes] A 
	INNER JOIN Leg L ON L.LegKey=A.LegKey
	WHERE L.legkey=@LegKey and A.RouteKey = @New_RouteKey;
	*/

	IF ISNULL(@SchedulerNotes,'')<>''
	BEGIN
		INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
		VALUES (@SchedulerNotes, GETDATE(),@CreateUserKey);
		
		SET @New_CommentKey=0;
		SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) ;

		INSERT INTO dbo.SchedulerComment(CommentKey,RouteKey,OrderDetailKey)
		VALUES (@New_CommentKey, @New_RouteKey,@OrderDetailKey);
	END;

	IF ISNULL(@DriverNotes,'')<>''
	BEGIN 
		INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
		VALUES (@DriverNotes, GETDATE(),@CreateUserKey);
		
		SET @New_CommentKey=0;
		SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) ;

		INSERT INTO dbo.SchedulerDriverComment(CommentKey,RouteKey,OrderDetailKey)
		VALUES (@New_CommentKey, @New_RouteKey,@OrderDetailKey);
	END;

	--UPDATE dbo.OrderDetail
	--SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Schedule InProgress' AND IsActive=1 ),
	--    LegTypeKey= CASE WHEN ISNULL(@LegTypeKey,0)=0 THEN LegTypeKey ELSE @LegTypeKey END ,LastFreeDay=@LastFreeDay,CutOffDate=@CutOffDate,StatusDate=GETDATE(),PickupTime=@PickupDate,
	--	DropOffTime=@DeliveyDateFrom
	--WHERE OrderDetailKey=@OrderDetailKey

	UPDATE dbo.OrderHeader
	SET [Status]= ( SELECT [Status] FROM dbo.OrderStatus WHERE [Description]='In Progress' AND IsActive=1 ),
		StatusDate=GETDATE()
	WHERE OrderKey= @OrderKey

	UPDATE dbo.[Routes]
	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' )
	WHERE RouteKey= @New_RouteKey

	UPDATE dbo.OrderDetail
	SET TMFCheckOff = @TMFCheckOff,CTFCheckOff=@CTFCheckOff, SizeCheckOff=@SizeCheckOff
	WHERE OrderDetailKey=@OrderDetailKey

	exec UpdateContainerStatus @OrderDetailKey


	SET @OutPut= ISNULL(@New_RouteKey,0)
END