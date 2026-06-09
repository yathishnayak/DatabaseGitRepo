CREATE PROCEDURE [dbo].[Insert_BulkScheduleDetail]
(
	@OrderKey		INT,
@OrderDetailKey INT,
@LegKey			INT,
@LegTypeKey		INT,
@SourceAddrKey	INT,
@DestAddrKey	INT,
@PickupDateFrom		DATETIME,
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
@IsTMF			BIT,
@ContainerNo	VARCHAR(30),
@ContainerSize	SMALLINT,
@SealNo			VARCHAR(20),
@Weight			DECIMAL(18,2),
@WeightUnit		SMALLINT,
@ContainerType	VARCHAR(500),
@DelConfirmationNo VARCHAR(50),
@LegNo			smallint,
@TMFCheckOff	bit = 0,
@CTFCheckOff	bit = 0,
@SizeCheckOff   bit = 0,
@OutPut			INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @New_CommentKey INT;
	DECLARE @New_RouteKey INT;
	DECLARE @ExpenseDesc VARCHAR(200)
	DECLARE @Itemkey VARCHAR(100)
	DECLARE @Output1 BIT
	DECLARE @FromLocation VARCHAR(255);
	DECLARE @ToLocation   VARCHAR(255);
	--DECLARE @LegFromLocation VARCHAR(100)='';
	--DECLARE @LegToLocation VARCHAR(100)='';
	--DECLARE @CustKey INT=0;

	SET @ContainerType= LTRIM(RTRIM(@ContainerType))

	IF ISNULL(@OrderKey,0)=0
	BEGIN
		SET @OrderKey= (SELECT DISTINCT OrderKey FROM dbo.OrderDetail WHERE OrderDetailKey=@OrderDetailKey );
	END;

	CREATE TABLE #ExpenseItem
	(
		ExpenseItem		VARCHAR(50),
		OrderDetailKey	INT,
		ItemID			VARCHAR(50),
		ItemKey			INT
	);	

	SET @Status= CASE WHEN @Status=0 THEN 1 WHEN @Status IS NULL THEN 1 ELSE @Status END

	INSERT INTO [Routes]
	(	[OrderDetailKey], [OrderKey], [LegKey],LegNo, [SourceAddrKey], [PickupDateFrom], [PickupDateTo],
		[DeliveryDateFrom],[DeliveryDateTo], [AppointmentNo], [ConfirmationNo], [LastFreeDay],CutOffDate, [SwitchTo], 
		[PortWaitingTimeFrom], [PortWaitingTimeTo], [CustomerWaitingTimeFrom], [CustomerWaitingTimeTo], 
		[FromLocation], [ToLocation], [DestinationAddrKey], [EstimatedDistanceInMiles], [EstimatedTravelTime], 
		[Status], [DriverKey], [ScheduledPickupDate], [ScheduledArrival], [ActualDeparture], [ActualArrival], 
		[OdometerAtSource], [OdometerAtDestination], CreateUserKey,CreateDate,ChassisKey, DelConfirmationNo
	)
	VALUES (
			 @OrderDetailKey,@OrderKey,@LegKey,isnull(@LegNo,0),@SourceAddrKey,@PickupDateFrom,@PickupDateTo,@DeliveyDateFrom,@DeliveyDateTo,NULL,
			 @ConfirmationNo,@LastFreeDay,@CutOffDate,@SwitchTo,NULL,NULL,NULL,NULL,NULL,NULL,
			 @DestAddrKey,null,null,@Status,null,@PickupDateFrom,@DeliveyDateFrom,NULL,NULL,NULL,NULL,
			 @CreateUserKey,GETDATE(),NULL, @DelConfirmationNo
			);

	SET @New_RouteKey= ( SELECT SCOPE_IDENTITY() );

	---***** chassis split auto for century ****---
	--SELECT @LegFromLocation=FromLocation FROM Leg where LegKey=@LegKey
	--SELECT @LegToLocation=ToLocation FROM Leg where LegKey=@LegKey
	--SELECT @CustKey=CustKey FROM OrderHeader WHERE OrderKey=@OrderKey
	--IF((@LegFromLocation = 'Port' OR @LegToLocation = 'Port') AND @CustKey=3402)
	--BEGIN
	--	DECLARE @JasonString NVARCHAR(MAX)='{"RouteKey":'+CAST(@New_RouteKey AS VARCHAR)+',"IsChassisSplit":1,"OrderDetailKey":'+CAST(@OrderDetailKey AS VARCHAR)+'}'
	--	EXEC Container_IsChassisSplit @CreateUserKey,@JasonString,'',0,''
	--	UPDATE Routes SET IsChassisSplit=1, ChassisSplitBy=1,ChassisSplitDate=GETDATE() WHERE RouteKey=@New_RouteKey
	--END
	---**** end ****---

	--***********************Update Container Type items****************
	EXECUTE Update_ContainerTypeItem @OrderDetailKey=@OrderDetailKey,@ContType=@ContainerType,@CreateUserKey=@CreateUserKey
	

	
	SET @FromLocation = ( SELECT AddrName FROM [Address] WHERE AddrKey=@SourceAddrKey );
	SET @ToLocation = ( SELECT AddrName FROM [Address] WHERE AddrKey=@DestAddrKey );

	
	/*
	UPDATE A
	SET A.LegNo=L.LegNo
	FROM [Routes] A 
	INNER JOIN Leg L ON L.LegKey=A.LegKey
	WHERE L.legkey=@LegKey and a.RouteKey=@New_RouteKey;
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

	UPDATE ORDERDETAIL 
	SET IsTMF = @IsTMF, DriverNotes = @DriverNotes, SchedulerNotes = @SchedulerNotes,
		ContainerNo=@ContainerNo,ContainerSizeKey= @ContainerSize,SealNo  = @SealNo,[Weight] = @Weight,WeightUnit = @WeightUnit,
		TMFCheckOff = @TMFCheckOff,CTFCheckOff=@CTFCheckOff,SizeCheckOff = @SizeCheckOff
	WHERE OrderDetailKey = @OrderDetailKey

	UPDATE dbo.OrderHeader
	SET [Status]= ( SELECT [Status] FROM dbo.OrderStatus WHERE [Description]='In Progress' AND IsActive=1 ),
		StatusDate=GETDATE()
	WHERE OrderKey= @OrderKey

	UPDATE dbo.[Routes]
	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' ),
		FromLocation=LTRIM(RTRIM(@FromLocation)),ToLocation=LTRIM(RTRIM(@ToLocation))
	WHERE RouteKey= @New_RouteKey

	exec UpdateContainerStatus @OrderDetailKey
	

	IF(
		SELECT COUNT(1) 
		FROM dbo.[Routes] 
		WHERE OrderDetailKey=@OrderDetailKey AND PickupDateFrom IS NOT NULL AND 
				DeliveryDateFrom IS NOT NULL AND SourceAddrKey IS NOT NULL AND DestinationAddrKey IS NOT NULL			
	)>0		
	BEGIN
		UPDATE dbo.OrderDetail 
		SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Schedule Confirmed' ), 
			LastUpdateDate = GETDATE(),StatusDate=GETDATE(), UpdateUserKey=@CreateUserKey 
		WHERE OrderDetailKey= @OrderDetailKey ;	
	END
	SET @OutPut= ISNULL(@New_RouteKey,0)
END
