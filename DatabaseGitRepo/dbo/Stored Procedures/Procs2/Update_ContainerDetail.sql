CREATE PROCEDURE [dbo].[Update_ContainerDetail]
/*
Update from Container Screen
*/
@OrderKey		INT,
@OrderDetailKey INT,
@UpdateUserKey	INT,
@SourceAddrKey  INT,
@DeliveryAddrkey INT,
@ConfimationNo  VARCHAR(30),
@ApptDateFrom	DATETIME,
@ApptDateTo		DATETIME,
@PickupDate		DATETIME,
@DeliveryDate   DATETIME,
@LastFreeDay	DATETIME,
@CutOffDate		DATETIME,
@DriverNotes	VARCHAR(500),
@SchedulerNotes VARCHAR(500),
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE   
		 @New_CommentKey INT,
		 @RouteKey		 INT;

	SET @OutPut=0;

	SET @RouteKey= ( SELECT RouteKey FROM OrderDetail WHERE OrderDetailKey= @OrderDetailKey AND OrderKey=@OrderKey );

	UPDATE dbo.OrderDetail  
	SET 		
		ApptDateFrom =	@ApptDateFrom,
		ApptDateTo  =	@ApptDateTo,
		PickupDate  =	@PickupDate,
		DropOffDate =	@DeliveryDate,
		LastFreeDay	=	@LastFreeDay,
		CutOffDate=		@CutOffDate,
		ConfirmationNo= @ConfimationNo,
		UpdateUserKey=	@UpdateUserKey,
		SourceAddrKey=	@SourceAddrKey,
		DestinationAddrKey= @DeliveryAddrkey
	WHERE OrderDetailKey =  @OrderDetailKey and OrderKey = @OrderKey;
	
	exec UpdateContainerStatus @OrderDetailKey

	IF ISNULL(LTRIM(RTRIM(@SchedulerNotes)),'')<>''
	BEGIN
		IF  (	
				SELECT COUNT(1) 
				FROM dbo.Comment CM
					INNER JOIN SchedulerComment OHC ON OHC.CommentKey=CM.CommentKey  
				WHERE [Description]= @SchedulerNotes AND OHC.OrderDetailKey= @OrderDetailKey
			 )=0
		BEGIN
			INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
			VALUES (@SchedulerNotes, GETDATE(),@UpdateUserKey);
		
			SET @New_CommentKey=0;
			SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) ;

			INSERT INTO dbo.SchedulerComment(CommentKey,RouteKey,OrderDetailKey)
			VALUES (@New_CommentKey, @RouteKey,@OrderDetailKey);
		END
	END
 
	IF  ISNULL(LTRIM(RTRIM(@DriverNotes)),'')<>'' 
	BEGIN
		IF  (	
				SELECT COUNT(1) 
				FROM dbo.Comment CM
					INNER JOIN SchedulerDriverComment OHC ON OHC.CommentKey=CM.CommentKey  
				WHERE [Description]= @DriverNotes AND OHC.OrderDetailKey= @OrderDetailKey
			 )=0
		BEGIN
			INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
			VALUES (@DriverNotes, GETDATE(),@UpdateUserKey);

			SET @New_CommentKey=0;
			SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) ;

			INSERT INTO dbo.SchedulerDriverComment(CommentKey,RouteKey,OrderDetailKey)
			VALUES (@New_CommentKey, @RouteKey,@OrderDetailKey);
		END;
	END;

	SET @OutPut=1;	
END;
