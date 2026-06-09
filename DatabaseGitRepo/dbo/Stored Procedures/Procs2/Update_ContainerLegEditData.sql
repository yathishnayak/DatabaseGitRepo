
/*
declare @out bit = 0, @OrderDetailKey INT = 292, @RouteKey INT = 474, @LegKey 	INT=0, @FromLocationKey	INT = 0,@ToLocationKey INT = 0,@ScheduledPickupDateFrom	DateTime  = null,
		@ScheduledPickupDateTo		DateTime  = null,@ScheduledDeliveryDateFrom	DateTime  = null, @ScheduledDeliveryDateTo	DateTime  = null, @DriverKey INT = 0,
		@ChassisKey	INT = 15, @ChassisNo	VARCHAR(30) = '100015', @ChassisType	VARCHAR(30) = '20 SL RMK', @ActualPickUpTime	DATETIME= NULL, @ActualDeliveryTime	DATETIME= NULL, @UpdateUserKey	INT = 29,
		@Type	CHAR(1)  = 'C'
exec [Update_ContainerLegEditData] @OrderDetailKey, @RouteKey , 
		@LegKey, @FromLocationKey, @ToLocationKey, @ScheduledPickupDateFrom,
		@ScheduledPickupDateTo,	@ScheduledDeliveryDateFrom, @ScheduledDeliveryDateTo,	
		@DriverKey ,	@ChassisKey , @ChassisNo , @ChassisType,@ActualPickUpTime, @ActualDeliveryTime,
		 @UpdateUserKey , @Type , @out   OUTPUT
SELECT @OUT
*/
CREATE PROCEDURE [dbo].[Update_ContainerLegEditData]
@OrderDetailKey				INT = 0,
@RouteKey					INT = 0,
@LegKey						INT=0,
@FromLocationKey			INT = 0,
@ToLocationKey				INT = 0,
@ScheduledPickupDateFrom	DateTime  = null,
@ScheduledPickupDateTo		DateTime  = null,
@ScheduledDeliveryDateFrom	DateTime  = null,
@ScheduledDeliveryDateTo	DateTime  = null,
@DriverKey					INT = 0,
@ChassisKey					INT = 0,
@ChassisNo					VARCHAR(30) = '',
@ChassisType				VARCHAR(30) = '',
@ActualPickUpTime			DATETIME= NULL,
@ActualDeliveryTime			DATETIME= NULL,
@UpdateUserKey				INT = 0,
@Type						CHAR(1), -- D: Driver, C: Chassis, P: Pickup, L: Delivery, U: Scheduled Pickup, R : Scheduled Delivery, S: Switch To, O: Route Detail , A: All
@OutPut						BIT = 0 OUTPUT

AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @USERNAME VARCHAR(100) = '',
			@Leg		VARCHAR(100) = '',
			@ContainerNo	varchar(50) = '',
			@CommentKey		int = 0,
			@Comment		varchar(500) = ''

	SELECT @USERNAME = A.UserName FROM [User] A WHERE UserKey = @UpdateUserKey
	SELECT @ContainerNo = ContainerNo FROM OrderDetail WHERE OrderDetailKey = @OrderDetailKey
	SELECT @Leg = L.LegID 
			FROM Routes R
			INNER JOIN Leg L ON R.LegKey = L.LegKey
			WHERE RouteKey = @RouteKey

	DECLARE @IsRouteComplete BIT
	DECLARE @DriverAsgStatusKey SMALLINT

	if(@Type = 'D')
	BEGIN
		DECLARE @PrevDriver varchar(100) = '',
				@CurrentDriver varchar(100) = ''

		select @PrevDriver = D.DriverID + ' ' + ISNULL(D.FirstName,'') + ' ' + ISNULL(D.LastName,'')  
			from ROUTES R
			INNER JOIN Driver D ON R.DriverKey = D.DriverKey 
			where R.RouteKey = @RouteKey

		select @CurrentDriver = D.DriverID + ' ' + ISNULL(D.FirstName,'') + ' ' + ISNULL(D.LastName,'')  
			from Driver D
			where DriverKey = @DriverKey

		UPDATE dbo.[Routes] 
		SET 
			DriverKey=  @DriverKey ,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey=@RouteKey
		
		SET @Comment =isnull(@Leg,'') + ' : ' + 'Driver changed from ' + isnull(@PrevDriver,'') + ' to ' + isnull(@CurrentDriver,'')
		Exec dbo.Insert_Comment @Comment, '', @UpdateUserKey,0, 0, @CommentKey Output
		
		if(@CommentKey > 0)
		begin
			exec dbo.Insert_OrderDetailComment @OrderDetailKey, @CommentKey
		end
		
		SET @OutPut=1;
	END

	if(@Type = 'C')
	BEGIN

		DECLARE @PrevChassis varchar(100) = '',
				@CurrentChassis varchar(100) = ''

		select @PrevChassis = R.ChassisNo + ' [' + R.ChassisType + '] '
			from ROUTES R
			where R.RouteKey = @RouteKey

		select @CurrentChassis =@ChassisNo + ' [' + @ChassisType + '] '

		UPDATE dbo.[Routes]
		SET 
			ChassisNo		= @ChassisNo ,
			ChassisKey		= @ChassisKey,
			ChassisType		= @ChassisType	
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		SET @Comment =isnull(@Leg,'') + ' : ' + 'Chassis changed from ' + isnull(@PrevChassis,'') + ' to ' + isnull(@CurrentChassis,'')
		Exec dbo.Insert_Comment @Comment, '', @UpdateUserKey,0,0, @CommentKey Output
		
		if(@CommentKey > 0)
		begin
			exec dbo.Insert_OrderDetailComment @OrderDetailKey, @CommentKey
		end
		
		SET @OutPut=1;
		
	END

	if(@Type = 'P')
	BEGIN

		DECLARE @PrevPicckup varchar(100) = '',
				@CurrentPickup varchar(100) = ''

		select @PrevPicckup =  convert(varchar, ActualDeparture,102) + ' ' + left(convert(varchar, ActualDeparture,108),5)
			from ROUTES R
			where R.RouteKey = @RouteKey

		select @CurrentPickup = convert(varchar, @ActualPickUpTime,102) + ' ' + left(convert(varchar, @ActualPickUpTime,108),5)
		UPDATE dbo.[Routes]
		SET 
			UpdateUserKey	= @UpdateUserKey,
			ActualDeparture	= @ActualPickUpTime
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		SET @Comment =isnull(@Leg,'') + ' : ' + 'Actual Pickup changed from ' + isnull(@PrevPicckup,'') + ' to ' + isnull(@CurrentPickup,'')
		Exec dbo.Insert_Comment @Comment, '', @UpdateUserKey,0,0, @CommentKey Output
		
		if(@CommentKey > 0)
		begin
			exec dbo.Insert_OrderDetailComment @OrderDetailKey, @CommentKey
		end
		
		SET @OutPut=1;

	END

	if(@Type = 'L')
	BEGIN
		DECLARE @PrevDelivery varchar(100) = '',
				@CurrentDelivery varchar(100) = ''

		select @PrevDelivery =  convert(varchar, ActualArrival,102) + ' ' + left(convert(varchar, ActualArrival,108),5)
			from ROUTES R
			where R.RouteKey = @RouteKey

		select @PrevPicckup = convert(varchar, @ActualDeliveryTime,102) + ' ' + left(convert(varchar, @ActualDeliveryTime,108),5)
		UPDATE dbo.[Routes]
		SET 
			ActualArrival	= @ActualDeliveryTime	
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		UPDATE dbo.[Routes] 
		SET 
			ActualArrival = CASE WHEN ISNULL(ActualArrival,'') = '' THEN @ActualDeliveryTime ELSE ActualArrival END,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey<>@RouteKey

		
		SET @Comment =isnull(@Leg,'') + ' : ' + 'Actual Delivery changed from ' + isnull(@PrevDelivery,'') + ' to ' + isnull(@CurrentDelivery,'')
		Exec dbo.Insert_Comment @Comment, '', @UpdateUserKey,0,0, @CommentKey Output
		
		if(@CommentKey > 0)
		begin
			exec dbo.Insert_OrderDetailComment @OrderDetailKey, @CommentKey
		end
		
		SET @OutPut=1;
	END

	if(@Type = 'U')
	BEGIN

		DECLARE @PrevSPicckup varchar(100) = '',
				@CurrentSPickup varchar(100) = ''

		select @PrevSPicckup =  isnull(convert(varchar, PickupDateFrom,102),'') + ' ' + left(isnull(convert(varchar, PickupDateFrom,108),''),5) + ' - ' 
				+ isnull( convert(varchar, PickupDateTo,102),'') + ' ' +  left(isnull(convert(varchar, PickupDateTo,108),''),5)
			from ROUTES R
			where R.RouteKey = @RouteKey

		Set @CurrentPickup = convert(varchar, @ScheduledPickupDateFrom,102) + ' ' + left(convert(varchar, @ScheduledPickupDateFrom,108),5) + ' - ' 
				+ convert(varchar, @ScheduledPickupDateTo,102) + ' ' + left(convert(varchar, @ScheduledPickupDateTo,108),5)

		UPDATE dbo.[Routes]
		SET 
			UpdateUserKey	= @UpdateUserKey,
			PickupDateFrom	= @ScheduledPickupDateFrom,
			PickupDateTo = @ScheduledPickupDateTo,
			ScheduledDeparture = @ScheduledPickupDateFrom
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		SET @Comment =isnull(@Leg,'') + ' : ' + 'Scheduled Pickup changed from ' + isnull(@PrevPicckup,'') + ' to ' + isnull(@CurrentPickup,'')
		Exec dbo.Insert_Comment @Comment, '', @UpdateUserKey,0,0, @CommentKey Output
		
		if(@CommentKey > 0)
		begin
			exec dbo.Insert_OrderDetailComment @OrderDetailKey, @CommentKey
		end
		
		SET @OutPut=1;

	END

	if(@Type = 'R')
	BEGIN

		DECLARE @PrevSDelivery varchar(100) = '',
				@CurrentSDelivery varchar(100) = ''

		select @PrevSDelivery =  isnull(convert(varchar, DeliveryDateFrom,102),'') + ' ' + left(isnull(convert(varchar, DeliveryDateFrom,108),''),5) + ' - ' 
				+  isnull(convert(varchar, DeliveryDateTo,102),'') + ' ' + left(isnull(convert(varchar, DeliveryDateTo,108),''),5)
			from ROUTES R
			where R.RouteKey = @RouteKey

		Set @CurrentSDelivery = convert(varchar, @ScheduledDeliveryDateFrom,102) + ' ' + left(convert(varchar, @ScheduledDeliveryDateFrom,108),5) + ' - ' 
				+ convert(varchar, @ScheduledDeliveryDateTo,102) + ' ' + left(convert(varchar, @ScheduledDeliveryDateTo,108),5)

		UPDATE dbo.[Routes]
		SET 
			UpdateUserKey	= @UpdateUserKey,
			DeliveryDateFrom	= @ScheduledDeliveryDateFrom,
			DeliveryDateTo = @ScheduledDeliveryDateTo,
			ScheduledArrival = @ScheduledDeliveryDateFrom
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey= @RouteKey;

		SET @Comment =isnull(@Leg,'') + ' : ' + 'Scheduled Delivery changed from ' + isnull(@PrevSDelivery,'') + ' to ' + isnull(@CurrentSDelivery,'')
		Exec dbo.Insert_Comment @Comment, '', @UpdateUserKey,0,0, @CommentKey Output
		
		if(@CommentKey > 0)
		begin
			exec dbo.Insert_OrderDetailComment @OrderDetailKey, @CommentKey
		end
		
		SET @OutPut=1;

	END

	if(@Type = 'O')
	BEGIN
		DECLARE @PrevLeg varchar(100) = '',
				@prevFromLocation varchar(255) = '',
				@PrevToLocation varchar(255) = '',
				@CurrentLeg varchar(100) = '',
				@FromLocation varchar(255) = '',
				@Tolocation varchar(255) = ''

		select @FromLocation = A.AddrName
		from Address A where AddrKey = @FromLocationKey

		select @Tolocation = A.AddrName
		from Address A where AddrKey = @ToLocationKey

		select @PrevLeg = ' [ ' + D.LegID + ' ] ',
			@prevFromLocation = 'From : ' + R.FromLocation ,
			@PrevToLocation = ' To: '  + R.ToLocation
			from ROUTES R
			INNER JOIN Leg D ON R.LegKey = D.LegKey 
			where R.RouteKey = @RouteKey

		select @CurrentLeg =' [ ' + D.LegID + ' ] '  
			from Leg D
			where LegKey = @LegKey

		UPDATE dbo.[Routes] 
		SET 
			LegKey=  @LegKey , 
			FromLocation = @FromLocation, SourceAddrKey = @FromLocationKey,
			ToLocation = @Tolocation, DestinationAddrKey = @ToLocationKey,
			UpdateUserKey=  @UpdateUserKey
		WHERE OrderDetailKey=@OrderDetailKey AND RouteKey=@RouteKey
		
		SET @Comment =isnull(@Leg,'') + ' : ' + 'LEG ID changed From Leg: ' + isnull(@PrevLeg,'') + ' (' + @prevFromLocation + ' ' + @PrevToLocation + ') ' + ' To Leg: ' + isnull(@CurrentLeg,'')
		Exec dbo.Insert_Comment @Comment, '', @UpdateUserKey,0,0, @CommentKey Output
		
		if(@CommentKey > 0)
		begin
			exec dbo.Insert_OrderDetailComment @OrderDetailKey, @CommentKey
		end
		
		SET @OutPut=1;
	END

	exec UpdateContainerStatus @OrderDetailKey
	
END;
