CREATE PROCEDURE [dbo].[Update_ScheduleDetail]
@OrderDetailKey INT,
@RouteKey		INT,
@LegKey         INT,
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
@LegNo			smallint,
@TMFCheckOff	bit = 0,
@CTFCheckOff	bit = 0,
@SizeCheckOff   bit = 0,
@CaptureLog     bit = 0,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @New_CommentKey INT;
	DECLARE @FromLocation VARCHAR(255);
	DECLARE @ToLocation VARCHAR(255);

	SET @FromLocation = ( SELECT AddrName FROM [Address] WHERE AddrKey=@SourceAddrKey );
	SET @ToLocation = ( SELECT AddrName FROM [Address] WHERE AddrKey=@DestAddrKey );

	SET @ContainerType= LTRIM(RTRIM(@ContainerType))
	SET @OrderDetailKey= LTRIM(RTRIM(@OrderDetailKey))

	--DECLARE @UserName varchar(100),
	--		@CommentKey int,
	--		@Comment varchar(500);

 --  SELECT @UserName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @CreateUserKey;

	--if(isnull(@ContainerType,'')='')
	--begin
	--	exec [Container_TypeInsert] @OrderdetailKey, 0
	--end
	Update OrderHeader  set Status=1 where OrderKey in (select OrderKey from  OrderDetail where OrderDetailKey = @OrderDetailKey) and Status=12

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
		LegNo = isnull(@LegNo,0),
		LegKey = @LegKey
	WHERE RouteKey=@RouteKey;

	UPDATE dbo.OrderDetail
	SET CutOffDate= @CutOffDate, LastFreeDay= @LastFreeDay,PickupTime=@PickupDateFrom,
		DropOffTime=@DeliveyDateFrom, IsTMF = @IsTMF, DriverNotes = @DriverComment, SchedulerNotes = @SchedulerComment,
		ContainerNo=@ContainerNo,ContainerSizeKey= @ContainerSize,SealNo  = @SealNo,[Weight] = @Weight,WeightUnit = @WeightUnit,
		TMFCheckOff = @TMFCheckOff,CTFCheckOff=@CTFCheckOff,SizeCheckOff = @SizeCheckOff
	WHERE OrderDetailKey=@OrderDetailKey

	--EXECUTE Update_ContainerTypeItem @OrderDetailKey,@ContainerType,@CreateUserKey

	--SET @Comment = 'TMF AND CTF Check Off '

	--Exec Insert_Comment @Comment,'', @CreateUserKey,0, @CommentKey OUTPUT
	--Exec insert_OrderDetailComment @OrderDetailKey, @CommentKey

	--INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
	--VALUES(GETDATE(),@UserName,'Container',(SELECT ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey),NULL,'Text',@Comment,@OrderDetailKey)



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

	SET @OutPut=1;
END;
