
CREATE PROCEDURE [dbo].[Insert_ScheduleDetailAndConfirm]
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
@ContainerNo	VARCHAR(30),
@ContainerSize	SMALLINT,
@SealNo			VARCHAR(20),
@Weight			DECIMAL(18,2),
@WeightUnit		SMALLINT,
@ContainerType	VARCHAR(500),
@DelConfirmationNo VARCHAR(50),
@LegNo			int,
@OutPut			INT OUTPUT
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

	SET @ContainerType= LTRIM(RTRIM(@ContainerType))

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
			 @OrderDetailKey,@OrderKey,@LegKey,0,@SourceAddrKey,@PickupDate,@PickupDateTo,
			 @DeliveyDateFrom,@DeliveyDateTo,NULL,@ConfirmationNo,@LastFreeDay,@SwitchTo,
			 NULL,NULL,NULL,NULL,
			 NULL,NULL, @DestAddrKey,null,null,
			 @Status,null,@PickupDate,@DeliveyDateFrom,NULL,NULL,
			 NULL,NULL, @CreateUserKey,GETDATE(),@ChassisKey, @ChassisNo, @ChassisType,
			 @DelConfirmationNo
			);

	SET @New_RouteKey= ( SELECT SCOPE_IDENTITY() );

	--drop table #ExpenseItem

	--***********************Update Container Type items****************
	EXECUTE Update_ContainerTypeItem @OrderDetailKey=@OrderDetailKey,@ContType=@ContainerType,@CreateUserKey=@CreateUserKey
	--*****************************************************************

	--****************Insert Expense already selected at Conainer Level*************
	--SELECT OD.OrderDetailKey,C.[Description] INTO #ExpenseItemList
	--FROM dbo.OrderDetail OD 
	--	INNER JOIN dbo.OrderDetailComments ODC ON ODC.OrderDetailKey=OD.OrderDetailKey
	--	INNER JOIN dbo.Comment C ON C.CommentKey=ODC.CommentKey
	--WHERE OD.OrderDetailKey=@OrderDetailKey AND C.[Description] IS NOT NULL AND C.[Description]<>''

	--IF ( SELECT COUNT(1) FROM #ExpenseItemList)>0
	--BEGIN
	--	SET @ExpenseDesc= (SELECT DISTINCT TOP 1 ISNULL([Description],'') FROM #ExpenseItemList)
	--	IF @ExpenseDesc<>''
	--	BEGIN
	--		INSERT INTO #ExpenseItem (ExpenseItem,OrderDetailKey)
	--		SELECT [Value],@OrderDetailKey FROM Fn_SplitParam (@ExpenseDesc);

	--	UPDATE #ExpenseItem
	--	SET ItemID= CASE WHEN ExpenseItem='Hazard' THEN 'HAZMAT' 
	--					 WHEN ExpenseItem='Over Weight' THEN 'Overweight'
	--					 WHEN ExpenseItem='Triaxle' THEN 'Triaxle'
	--					 WHEN ExpenseItem='Needs to be scaled' THEN 'Scale' 
	--					 WHEN ExpenseItem='Weekend delivery' THEN 'Weekend delivery'
	--					 WHEN ExpenseItem='Transload' THEN 'Transload'
	--					 WHEN ExpenseItem='Permits' THEN 'Permits'
	--					 WHEN ExpenseItem='Genset' THEN 'Genset'	  END

	--		SELECT OE.Itemkey INTO #ItemExist 
	--		FROM dbo.[Routes] RT 
	--			INNER JOIN dbo.OrderExpense OE ON OE.RouteKey=RT.RouteKey
	--		WHERE OrderDetailKey=@OrderDetailKey

	--		UPDATE A
	--		SET A.ItemKey=I.ItemKey
	--		FROM #ExpenseItem A 
	--		INNER JOIN dbo.Item I ON I.ItemID=A.ItemID

	--		DELETE FROM #ExpenseItem WHERE ItemKey IS NULL
	
	--		SELECT DISTINCT ET.ItemKey INTO #TempData
	--		FROM #ExpenseItem ET 
	--		WHERE OrderDetailKey=@OrderDetailKey AND ET.ItemKey NOT IN ( SELECT Itemkey FROM #ItemExist )				 

	--		INSERT INTO [dbo].[OrderExpense]([Itemkey],[RouteKey],[UnitCost],Qty,NewUnitCost,[CreateDate],[CreateUserKey])
	--		SELECT	I.ItemKey,@New_RouteKey,ISNULL(IT.UnitCost,0) AS UnitCost,1,NULL AS NewUnitCost,
	--			GETDATE() AS CreateDate,@CreateUserKey 
	--		FROM #TempData I 
	--		INNER JOIN dbo.Item IT ON I.Itemkey=IT.ItemKey	
	--	END
	--END
	--*****************************************************************

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
	--    LegTypeKey= CASE WHEN ISNULL(@LegTypeKey,0)=0 THEN LegTypeKey ELSE @LegTypeKey END ,LastFreeDay=@LastFreeDay,CutOffDate=@CutOffDate,StatusDate=GETDATE(),
	--	PickupTime=@PickupDate,	ContainerNo=@ContainerNo,ContainerSizeKey= @ContainerSize,SealNo  = @SealNo,[Weight] = @Weight,WeightUnit = @WeightUnit,
	--	DropOffTime=@DeliveyDateFrom
	--WHERE OrderDetailKey=@OrderDetailKey

	UPDATE dbo.OrderHeader
	SET [Status]= ( SELECT [Status] FROM dbo.OrderStatus WHERE [Description]='In Progress' AND IsActive=1 ),
		StatusDate=GETDATE()
	WHERE OrderKey= @OrderKey

	UPDATE dbo.[Routes]
	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' )
	WHERE RouteKey= @New_RouteKey

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
	END;	

	exec UpdateContainerStatus @OrderDetailKey
	SET @OutPut= ISNULL(@New_RouteKey,0)
END
