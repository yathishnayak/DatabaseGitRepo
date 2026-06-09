
CREATE PROCEDURE [dbo].[Update_ReScheduleDetail]
/*
UPdate leg data from Dispatch screen
*/
@OrderDetailKey INT,
@RouteKey		INT,
@SourceAddrKey	INT,
@DestAddrKey	INT,
@PickupDateFrom		DATETIME,
@PickupDateTo		DATETIME,
@DeliveyDateFrom	DATETIME,
@DeliveyDateTo		DATETIME,
@ConfirmationNo VARCHAR(50),
@LastFreeDay	DATETIME,
@CutOffDate		DATETIME,
@SwitchTo		VARCHAR(50),
@DriverComment	VARCHAR(500),
@SchedulerComment VARCHAR(500),
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
@LegNo			Smallint,
@TMFCheckOff	bit = 0,
@CTFCheckOff	bit = 0,
@SizeCheckOff   bit = 0,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @New_CommentKey INT;
	DECLARE @FromLocation VARCHAR(100);
	DECLARE @ToLocation VARCHAR(100);

	SET @ContainerType= LTRIM(RTRIM(@ContainerType))

	SET @FromLocation = ( SELECT AddrName FROM [Address] WHERE AddrKey=@SourceAddrKey );
	SET @ToLocation = ( SELECT AddrName FROM [Address] WHERE AddrKey=@DestAddrKey );

	UPDATE [Routes]
	SET SourceAddrKey= @SourceAddrKey,
	DestinationAddrKey = @DestAddrKey,
		PickupDateFrom=@PickupDateFrom,
		PickupDateTo=@PickupDateTo,
		DeliveryDateFrom=@DeliveyDateFrom,
		DeliveryDateTo=@DeliveyDateTo,
		ScheduledPickupDate=@PickupDateFrom,
		ScheduledArrival=@DeliveyDateFrom,
		ConfirmationNo=@ConfirmationNo,
		LastFreeDay=@LastFreeDay,
		FromLocation= @FromLocation,
		ToLocation=@ToLocation,
		CutOffDate=@CutOffDate,
		LastUpdateDate= GETDATE(),
		UpdateUserKey=@CreateUserKey,
		DelConfirmationNo = @DelConfirmationNo,
		LegNo = ISNULL( @LegNo,0)
	WHERE RouteKey=@RouteKey;

	UPDATE dbo.OrderDetail
	SET CutOffDate= @CutOffDate, LastFreeDay= @LastFreeDay,PickupTime=@PickupDateFrom,
		DropOffTime=@DeliveyDateFrom, IsTMF = @IsTMF, DriverNotes = @DriverComment, SchedulerNotes = @SchedulerComment,
		ContainerNo=@ContainerNo,ContainerSizeKey= @ContainerSize,SealNo  = @SealNo,[Weight] = @Weight,WeightUnit = @WeightUnit,
		TMFCheckOff = @TMFCheckOff,CTFCheckOff=@CTFCheckOff,SizeCheckOff = @SizeCheckOff
	WHERE OrderDetailKey=@OrderDetailKey

	--***********************Update Container Type items****************
	EXECUTE Update_ContainerTypeItem @OrderDetailKey=@OrderDetailKey,@ContType=@ContainerType,@CreateUserKey=@CreateUserKey
	--*****************************************************************

	IF ISNULL(@SchedulerComment,'')<>''
	BEGIN
		IF  (	
				SELECT COUNT(1) 
				FROM dbo.Comment CM
					INNER JOIN SchedulerComment OHC ON OHC.CommentKey=CM.CommentKey  
				WHERE [Description]= @SchedulerComment AND OHC.OrderDetailKey= @OrderDetailKey
			)=0
		BEGIN
			INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
			VALUES (@SchedulerComment, GETDATE(),@CreateUserKey);
		
			SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) ;

			INSERT INTO dbo.SchedulerComment(CommentKey,RouteKey)
			VALUES (@New_CommentKey, @RouteKey);
		END;
	END;

	IF ISNULL(@DriverComment,'')<>''
	BEGIN
		IF  (	
				SELECT COUNT(1) 
				FROM dbo.Comment CM
					INNER JOIN SchedulerDriverComment OHC ON OHC.CommentKey=CM.CommentKey  
				WHERE [Description]= @DriverComment AND OHC.OrderDetailKey= @OrderDetailKey
			 )=0
		BEGIN
			INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
			VALUES (@DriverComment, GETDATE(),@CreateUserKey);
		
			SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) ;

			INSERT INTO dbo.SchedulerDriverComment(CommentKey,RouteKey)
			VALUES (@New_CommentKey, @RouteKey);
		END;
	END;

	 exec UpdateContainerStatus @OrderDetailKey

	SET @OutPut=1;
END;



