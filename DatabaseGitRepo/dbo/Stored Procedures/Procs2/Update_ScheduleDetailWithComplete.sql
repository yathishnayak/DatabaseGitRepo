
CREATE PROCEDURE [dbo].[Update_ScheduleDetailWithComplete]
@OrderDetailKey INT,
@RouteKey		INT,
@SourceAddrKey	INT,
@DestAddrKey	INT,
@PickupDateFrom		DATETIME,
@PickupDateTo	DATETIME,
@DeliveyDateFrom	DATETIME,
@DeliveyDateTo	DATETIME,
@ConfirmationNo VARCHAR(50),
@LastFreeDay	DATETIME,
@CutOffDate		DATETIME,
@SwitchTo		VARCHAR(50),
@DriverComment	VARCHAR(500),
@SchedulerComment VARCHAR(500),
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
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @New_CommentKey INT;
	DECLARE @FromLocation VARCHAR(10);
	DECLARE @ToLocation VARCHAR(10);

	SET @ContainerType= LTRIM(RTRIM(@ContainerType))

	SET @FromLocation = ( SELECT AddrName FROM [Address] WHERE AddrKey=@SourceAddrKey );
	SET @ToLocation = ( SELECT AddrName FROM [Address] WHERE AddrKey=@DestAddrKey );

	UPDATE [Routes]
	SET SourceAddrKey= @SourceAddrKey,
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
		LegNo = @LegNo
	WHERE RouteKey=@RouteKey;

	if(isnull(@ContainerNo ,'') <> '')
	begin
		UPDATE dbo.OrderDetail
		SET CutOffDate= @CutOffDate, LastFreeDay= @LastFreeDay,PickupTime=@PickupDateFrom,
			DropOffTime=@DeliveyDateFrom,
			ContainerNo=@ContainerNo,ContainerSizeKey= @ContainerSize,SealNo  = @SealNo,[Weight] = @Weight,WeightUnit = @WeightUnit
		WHERE OrderDetailKey=@OrderDetailKey
	
		--***********************Update Container Type items****************
		EXECUTE Update_ContainerTypeItem @OrderDetailKey=@OrderDetailKey,@ContType=@ContainerType,@CreateUserKey=@CreateUserKey
		--*****************************************************************
	End

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

	IF (	
		SELECT COUNT(1) 
		FROM dbo.[Routes] 
		WHERE RouteKey=@RouteKey AND SourceAddrKey IS NOT NULL AND PickupDateFrom IS NOT NULL --AND PickupDateTo IS NOT NULL
			AND  DeliveryDateFrom IS NOT NULL AND ISNULL(ConfirmationNo,'')<>'' AND ISNULL(FromLocation,'')<>'' 
			AND CutOffDate IS NOT NULL AND ISNULL(ToLocation,'')<>''
		)>0
		BEGIN
			UPDATE dbo.OrderDetail
			SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Schedule Complete' AND IsActive=1 ),
				StatusDate=GETDATE()
			WHERE OrderDetailKey=@OrderDetailKey		
		END;

	exec UpdateContainerStatus @OrderDetailKey
	SET @OutPut=1;
END;
