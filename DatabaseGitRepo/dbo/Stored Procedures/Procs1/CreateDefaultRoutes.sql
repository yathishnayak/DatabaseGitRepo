
CREATE Procedure [dbo].[CreateDefaultRoutes]
(	
	@OrderKey as int,
	@OrderDetailKey as int,
	@CreateUserKey as int =287
)
As
Begin
	--** Procedure to create the Default Routes ** --
	declare	@LegKey	int
	declare	@LegTypeKey	int
	declare	@SourceAddrKey	int
	declare	@DestAddrKey	int
	declare	@PickupDateFrom	datetime  
	declare	@PickupDateTo	datetime  
	declare	@DeliveyDateFrom	datetime  
	declare	@DeliveyDateTo	datetime  
	declare	@Status	smallint
	declare	@IsSuccess bit
	set @IsSuccess=0
	
	select @SourceAddrKey = SourceAddrKey,  @DestAddrKey= DestinationAddrKey  
	from OrderHeader where OrderKey = @OrderKey
	
	--Add Port to Consignee
	select @LegKey =LegKey, @LegTypeKey=LegTypeKey from Leg where LegID='Port To Consignee'

	INSERT INTO [Routes]
	(	[OrderDetailKey], [OrderKey], [LegKey],LegNo, [SourceAddrKey], [PickupDateFrom], [PickupDateTo],
		[DeliveryDateFrom],[DeliveryDateTo], [AppointmentNo], [ConfirmationNo], [LastFreeDay],CutOffDate, 
		[SwitchTo], 
		[PortWaitingTimeFrom], [PortWaitingTimeTo], [CustomerWaitingTimeFrom], [CustomerWaitingTimeTo], 
		[FromLocation], [ToLocation], [DestinationAddrKey], [EstimatedDistanceInMiles], [EstimatedTravelTime], 
		[Status], [DriverKey], [ScheduledPickupDate], [ScheduledArrival], [ActualDeparture], [ActualArrival], 
		[OdometerAtSource], [OdometerAtDestination], CreateUserKey,CreateDate,ChassisKey
	)
	VALUES (
			 @OrderDetailKey,@OrderKey,@LegKey,1,@SourceAddrKey,@PickupDateFrom,@PickupDateTo,
			 @DeliveyDateFrom,@DeliveyDateTo,NULL,null,null,null,
			 null,
			 NULL,NULL,NULL,NULL,
			 NULL,NULL,@DestAddrKey,null,null,1,null,@PickupDateFrom,@DeliveyDateFrom,NULL,NULL,NULL,NULL,
			 @CreateUserKey,GETDATE(),NULL
			);

	--Add Consignee to Port
	select @LegKey =LegKey, @LegTypeKey=LegTypeKey from Leg where LegID='Consignee To Port'

	INSERT INTO [Routes]
	(	[OrderDetailKey], [OrderKey], [LegKey],LegNo, [SourceAddrKey], [PickupDateFrom], [PickupDateTo],
		[DeliveryDateFrom],[DeliveryDateTo], [AppointmentNo], [ConfirmationNo], [LastFreeDay],CutOffDate, 
		[SwitchTo], 
		[PortWaitingTimeFrom], [PortWaitingTimeTo], [CustomerWaitingTimeFrom], [CustomerWaitingTimeTo], 
		[FromLocation], [ToLocation], [DestinationAddrKey], [EstimatedDistanceInMiles], [EstimatedTravelTime], 
		[Status], [DriverKey], [ScheduledPickupDate], [ScheduledArrival], [ActualDeparture], [ActualArrival], 
		[OdometerAtSource], [OdometerAtDestination], CreateUserKey,CreateDate,ChassisKey
	)
	VALUES (
			 @OrderDetailKey,@OrderKey,@LegKey,2,@DestAddrKey,@PickupDateFrom,@PickupDateTo,
			 @DeliveyDateFrom,@DeliveyDateTo,NULL, null,null,null,
			 null,
			 NULL,NULL,NULL,NULL,
			 NULL,NULL, @SourceAddrKey  ,null,null,1,null,@PickupDateFrom,@DeliveyDateFrom,NULL,NULL,NULL,NULL,
			 @CreateUserKey,GETDATE(),NULL
			);

	 set @IsSuccess=1

End
