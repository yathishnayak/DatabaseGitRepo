/*    

 declare @UserKey  INT=512,    
 --@JsonString  VARCHAR(MAX)='{"OrderDetailKey":226476,"PrevOrderDetailStopKey":678682,"NextOrderDetailStopKey":678683}',    
 --@JsonString  VARCHAR(MAX)='{"OrderDetailKey":226464,"PrevOrderDetailStopKey":678598,"NextOrderDetailStopKey":678599}',    
 @JsonString  VARCHAR(MAX)='{"OrderDetailKey":248071,"PrevOrderDetailStopKey":761149,"NextOrderDetailStopKey":761150,"StopTypeKey":2,"LocationType":"Yard","StopAddrKey":32021}',    
 @IsDebug  BIT = 1,     @Status   BIT = 0 ,     @Reason   NVARCHAR(1000) = ''     
    
 exec [Stops_SaveForceData] @UserKey,@JsonString,@IsDebug,@Status output, @Reason output    
 select @Reason,@Status    
    
 */    
CREATE proc [dbo].[Stops_SaveForceData]
(
	@UserKey  INT=512,  
	@JsonString  VARCHAR(MAX)='',  
	@IsDebug  BIT = 0,  
	@Status   BIT = 0 OUTPUT,  
	@Reason   NVARCHAR(1000) = '' OUTPUT  
)
as
begin
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	IF(ISNULL(@JsonString,'')='')  
	BEGIN  
		SET @Status=0;  
		SET @Reason='Parameter not found';  
		RETURN;  
	END  

	Declare @OrderDetailKey				int = 0,
			@PrevOrderDetailStopKey		int = 0 ,
			@NextOrderDetailStopKey		int = 0,
			@StopTypeKey				int = 0,
			@LocationType				VARCHAR(50) = '',
			@StopAddrKey				INT	= 0

	SELECT  @OrderDetailKey			=	OrderDetailKey ,
			@PrevOrderDetailStopKey =	PrevOrderDetailStopKey,
			@NextOrderDetailStopKey =	NextOrderDetailStopKey,
			@StopTypeKey			=	StopTypeKey,
			@LocationType			=	LocationType,
			@StopAddrKey			=	StopAddrKey
	FROM OPENJSON(@JsonString, '$')  
	WITH(   
		OrderDetailKey			INT			'$.OrderDetailKey'  ,
		PrevOrderDetailStopKey  INT			'$.PrevOrderDetailStopKey'  ,
		NextOrderDetailStopKey	INT			'$.NextOrderDetailStopKey'  ,
		StopTypeKey				INT			'$.StopTypeKey',
		LocationType			VARCHAR(50)	'$.LocationType',
		StopAddrKey				INT			'$.StopAddrKey'
	)

	IF(@IsDebug = 1)
	BEGIN
		SELECT @OrderDetailKey AS  OrderDetailKey,
				@PrevOrderDetailStopKey AS PrevOrderDetailStopKey,
				@NextOrderDetailStopKey AS NextOrderDetailStopKey,
				@StopTypeKey AS StopTypeKey,
				@StopAddrKey AS StopAddrKey,
				@LocationType	AS LocationType
	END

	/* validate the request data again */
	DECLARE @ROUTEKEY	INT = 0,
			@STATUSKEY	INT = 0,
			@STATUSNAME	VARCHAR(50) = '',
			@EXPENCECOUNT	INT = 0,
			@IsVoucherCreated	BIT = 0,
			@VOUCHERNO		VARCHAR(50),
			@VOUCHERDATE	DATE,
			@IsInvoiceCreated	BIT = 0,
			@INVOICENO			VARCHAR(50),
			@INVOICEDATE		DATE,
			@NextStopNumber		int

	SELECT @ROUTEKEY = RouteKey, @STATUSKEY = RT.Status, @STATUSNAME = RS.Description
	FROM ROUTES RT WITH (NOLOCK) 
	INNER JOIN RouteStatus RS WITH (NOLOCK)  ON RT.Status = RS.Status
	WHERE FromODStopKey = @PrevOrderDetailStopKey AND ToODStopKey = @NextOrderDetailStopKey

	SELECT @IsVoucherCreated = 1, @VOUCHERNO = VH.VoucherNo, @VOUCHERDATE = VH.VoucherDate
	FROM RouteVouchers RV WITH (NOLOCK) 
	INNER JOIN VoucherHeader VH WITH (NOLOCK)  ON RV.VoucherKey = VH.VoucherKey
	WHERE RV.RouteKey = @ROUTEKEY

	SELECT  @IsInvoiceCreated = 1, @INVOICENO = IH.InvoiceNo, @INVOICEDATE = InvoiceDate
	FROM InvoiceContainers  IC WITH (NOLOCK) 
	INNER JOIN InvoiceHeader IH WITH (NOLOCK)  ON IC.InvoiceKey = IH.InvoiceKey
	WHERE IC.OrderDetailsKey = @OrderDetailKey
	
	Set @Status = case when @IsVoucherCreated = 1 OR @IsInvoiceCreated = 1 then 0 else 1 end
	set @Reason = case when @IsVoucherCreated = 1 then 'Voucher Created already (No. ' + @VOUCHERNO + ', dated: ' + convert(varchar,@VOUCHERDATE,101) +') \n' else '' end +
		Case when @IsInvoiceCreated = 1 then 'Invoice Created already (No. ' + @INVOICENO + ', dated: ' + convert(varchar,@INVOICEDATE,101) +') \n' else '' end
	
	if(@IsDebug = 1)
	Begin
		SELECT @ROUTEKEY AS RouteKey,
			@STATUSKEY as StatusKey,
			@STATUSNAME as StatusName,
			@IsVoucherCreated as IsVoucherCreated,
			@VOUCHERNO as VoucherNo,
			@VOUCHERDATE as VoucherDate,
			@IsInvoiceCreated as IsInvoiceCreated,
			@INVOICENO as InvoiceNo,
			@INVOICEDATE as InvoiceDate,
			IsAllowChanges = @status,
			@Reason as Reason
		
	end
	if(@IsInvoiceCreated = 1 OR @IsVoucherCreated = 1)
	Begin
		return
	End

	/* end of validate the request data again */

	Select * into #routes_old from Routes WITH (NOLOCK) WHERE (ToODStopKey = @PrevOrderDetailStopKey AND fromODStopKey = @NextOrderDetailStopKey) OR Routekey = @ROUTEKEY
	select * into #ODS_old from orderdetailstops with (nolock) where orderdetailstopkey in (@PrevOrderDetailStopKey, @NextOrderDetailStopKey)
	select @NextStopNumber = Stopnumber from Orderdetailstops WITH (NOLOCK) where Orderdetailstopkey =@NextOrderDetailStopKey

	if(@IsDebug = 1)
	Begin
		select '#routes_old',* from #routes_old
		SElect '#ODS_old', * from #ODS_old order by StopTypeKey
	End


	BEGIN TRY
		print '1'
		print Getdate()
		BEGIN TRANSACTION FORCEDATA
		/* Create the New STOPS data  */
		Declare @StopName				varchar(100),
				@ODStopKey_inserted		int = 0	
		SELECT @StopName =AddrName FROM ADDRESS WITH (NOLOCK) WHERE ADDRKEY = @StopAddrKey

		print '2'
		print Getdate()
		UPDATE OrderDetailStops SET StopNumber = StopNumber + 1 WHERE OrderDetailkey = @OrderDetailKey and Stopnumber >= @NextStopNumber

		INSERT INTO OrderDetailStops( OrderDetailKey, StopTypeKey, StopName, StopNameSetUserKey, StopNameSetDateTime,
			StopAddrKey, StopNumber, LocationType,StatusKey, CreateDate, CreateUserKey)
		Select  OrderDetailKey, Case when @StopTypeKey = 3 then 2 when @StopTypeKey = 5 then 4 else @StopTypeKey end,@StopName, @UserKey, GETDATE(), 
			@StopAddrKey, StopNumber + 1, @LocationType, 1, GETDATE(), @UserKey 
			from #ODS_old WHERE OrderDetailStopKey = @PrevOrderDetailStopKey
		set @ODStopKey_inserted = SCOPE_IDENTITY()

		


		

		--update A set StopNumber = B.NewStopNumber   
		-- from OrderDetailStops A      
		-- inner join (      
		--  select ROW_NUMBER() Over (Order by OrderDetailKey, SM.StoptypeKey,ODS.SchedulePickupDate) as NewStopNumber, SM.StopTypeShortcode, OrderDetailStopKey      
		--  from OrderDetailStops ODS      
		--  inner join StopsMaster SM on ODS.StopTypeKey = SM.StopTypeKey      
		--  where ODs.orderdetailkey = @OrderDetailKey      
		-- ) B on A.OrderDetailStopKey = B.OrderDetailStopKey 

		print '3'
		print Getdate()
		/* End of Create the New STOPS data  */


		/* Create the New ROUTES data  */
		Declare @RouteKey_inserted		int,
				@ExpenseCount			int,
				@PRevLegKey				int,
				@PRevFromLocation			varchar(50),
				@PRevToLocation				varchar(50),
				@PRevLegID					varchar(100),
				@NewLegKey_forPreviousRoute	int,
				@LegKey_ForNewRoute			int,
				@NewLegID_ForPreviousRoute	varchar(100),
				@LegID_ForNewRoute			varchar(100)

		print '4'
		print Getdate()
		Delete from OrderExpense where routekey = @ROUTEKEY and ChargeSource = 'Auto'

		print '5'
		print Getdate()
		select @PRevLegKey = A.Legkey , @PRevFromLocation = L.FromLocation, @PRevToLocation = L.ToLocation, @PRevLegID = L.LegID
		from #routes_old A
		inner join Leg L WITH (NOLOCK) on A.legkey = L.legkey

		print '6'
		print Getdate()
		select top 1 @NewLegKey_forPreviousRoute = Legkey, @NewLegID_ForPreviousRoute = Legid 
			from LegFiltered LF WITH (NOLOCK) 
			INNER JOIN LocationConversion LCT WITH (NOLOCK) ON LF.ToLocation=LCT.LocationConvert
			INNER JOIN LocationConversion LCF WITH (NOLOCK) ON LF.FromLocation=LCF.LocationConvert
			where LCF.Location = @PRevFromLocation and LCT.Location =  @LocationType  --and StatusKey = 1
		select top 1 @LegKey_ForNewRoute = Legkey, @LegID_ForNewRoute = Legid 
			from LegFiltered LF WITH (NOLOCK) 
			INNER JOIN LocationConversion LCT WITH (NOLOCK) ON LF.ToLocation=LCT.LocationConvert
			INNER JOIN LocationConversion LCF WITH (NOLOCK) ON LF.FromLocation=LCF.LocationConvert
			where LCF.Location = @LocationType and LCT.Location =  @PRevToLocation --and StatusKey = 1

		if(@IsDebug = 1)
		Begin
			Select  @PRevLegKey as PRevLegKey, @PRevFromLocation as PRevFromLocation, @PRevToLocation as PRevToLocation,
					@PRevLegID as PRevLegID, @ODStopKey_inserted as ODStopKey_inserted,
					@NewLegKey_forPreviousRoute as NewLegKey_forPreviousRoute, @LegKey_ForNewRoute as LegKey_ForNewRoute,
					@NewLegID_ForPreviousRoute as NewLegID_ForPreviousRoute, @LegID_ForNewRoute as LegID_ForNewRoute
		End

		print '7'
		print Getdate()
		update Routes Set
			LegKey = @NewLegKey_forPreviousRoute,
			ToODStopKey = @ODStopKey_inserted,
			DestinationAddrKey = @StopAddrKey,
			ActualArrival = null,
			ActualArrivalUpdateDate = null,
			ActualArrivalUpdateMethod = null, 
			ActualArrivalUpdateUser = null,
			LegType = null,
			IsEmpty = null,
			EmptySetDate = null,
			EmptySetUser = null,
			EmptySource = null,
			NoEmptyAvailableMarked = null,
			NoEmptyAvailableMarkedBY = null,
			NoEmptyMarkedSource = null,
			NoEmptyAvailableMarkedDate = null,
			isStreetTurn = null,
			StreetTurnSetDate = null,
			StreetTurnSetUser = null,
			StreetTurnSource = null
		where routekey = @RouteKey

		print '8'
		print Getdate()
		insert into Routes (OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo, CutOffDate, 
			DeliveryDateFrom, DeliveryDateTo, AppointmentNo, ConfirmationNo, LastFreeDay, SwitchTo, ChassisNo, ChassisType, 
			DestinationAddrKey,Status, DriverKey, ScheduledPickupDate, ScheduledArrival, ScheduledDeparture, ActualDeparture, 
			ActualArrival,ChassisKey, CompanyKey, CreateUserKey, CreateDate, LocationKey, IsEmpty, IsBobtail, DelConfirmationNo, 
			isStreetTurn, StreetTurnSetUser, StreetTurnSetDate, ChassisCategoryKey, ActualDepartureUpdateMethod, 
			ActualArrivalUpdateMethod, CarrierRate, StreeTurnPrevStatusKey, EmptySetUser, EmptySetDate, BobtailSetUser, BobtailSetDate, 
			SFGYardDiffLogKeyPickup, SFGYardChangePickup, SFGYardChangePickupMessage, SFGYardDiffLogKeyDelivery, SFGYardChangeDelivery, 
			SFGYardChangeDeliveryMessage, YardIDPickupBeforeUpdate, YardIDDeliveryBeforeUpdate, PrevStatusKey, ChassisSource, 
			ChassisChangedDate, EmptySource, BobTailSource, StreetTurnSource, ChassisChangedUser, ActualDepartureUpdateDate, 
			ActualDepartureUpdateUser, ActualArrivalUpdateDate, ActualArrivalUpdateUser, ChargeNotes, CompletionNotes, DriverInstructions, 
			FromLocationWaitTimeFrom, FromLocationWaitTimeTo, ToLocationWaitTimeFrom, ToLocationWaitTimeTo, CarrierAssignedBy, 
			LinkedContainer, LinkedBy, LinkedDate, ContainerNoSource, NoEmptyAvailableMarked, NoEmptyAvailableMarkedBY, NoEmptyAvailableMarkedDate, 
			LegType, IsChassisSplit, LinkedContainerSource, NoEmptyMarkedSource, ChassisSplitDate, NoWaitTIme, ChassisSplitBy, PickupNoWaitTIme, 
			DeliveryNoWaitTime, ToODStopKey, LegID, FromODStopKey, CWTFromTime ,CWTToTime, CWTToTimeSetBy, CWTToTimeSetDate, PWTFromTime, PWTToTime, 
			PWTToTimeSetBy, PWTToTimeSetDate, DriverSetBy, DriverSetDate, IsManual, ManualRouteUser, ManualRouteAddedDate, MiscReason, MiscSetBy, 
			MiscSetDate, LinkedContainerType)
		SELECT OrderDetailKey, OrderKey, @LegKey_ForNewRoute, LegNo+1, @StopAddrKey, DeliveryDateFrom AS PickupDateFrom,
			DeliveryDateTo AS PickupDateTo, NULL AS CutOffDate, 
			DeliveryDateFrom, DeliveryDateTo, AppointmentNo, NULL AS ConfirmationNo, LastFreeDay, SwitchTo, ChassisNo, ChassisType, 
			DestinationAddrKey,1 AS Status, DriverKey, DeliveryDateFrom ScheduledPickupDate,DeliveryDateFrom ScheduledArrival, 
			ScheduledDeparture, NULL AS ActualDeparture, 
			ActualArrival,ChassisKey, CompanyKey, @UserKey, GETDATE(), LocationKey, IsEmpty, IsBobtail, DelConfirmationNo, 
			isStreetTurn, StreetTurnSetUser, StreetTurnSetDate, ChassisCategoryKey, NULL AS ActualDepartureUpdateMethod, 
			ActualArrivalUpdateMethod, CarrierRate, StreeTurnPrevStatusKey, EmptySetUser, EmptySetDate, BobtailSetUser, BobtailSetDate, 
			SFGYardDiffLogKeyPickup, SFGYardChangePickup, SFGYardChangePickupMessage, SFGYardDiffLogKeyDelivery, SFGYardChangeDelivery, 
			SFGYardChangeDeliveryMessage, YardIDPickupBeforeUpdate, YardIDDeliveryBeforeUpdate, PrevStatusKey, ChassisSource, 
			ChassisChangedDate, EmptySource, BobTailSource, StreetTurnSource, ChassisChangedUser, NULL AS ActualDepartureUpdateDate, 
			NULL AS ActualDepartureUpdateUser, ActualArrivalUpdateDate, ActualArrivalUpdateUser, ChargeNotes, CompletionNotes, DriverInstructions, 
			NULL AS FromLocationWaitTimeFrom, NULL AS FromLocationWaitTimeTo, ToLocationWaitTimeFrom, ToLocationWaitTimeTo, CarrierAssignedBy, 
			LinkedContainer, LinkedBy, LinkedDate, ContainerNoSource, NoEmptyAvailableMarked, NoEmptyAvailableMarkedBY, NoEmptyAvailableMarkedDate, 
			LegType, IsChassisSplit, LinkedContainerSource, NoEmptyMarkedSource, ChassisSplitDate, NoWaitTIme, ChassisSplitBy, PickupNoWaitTIme, 
			DeliveryNoWaitTime, ToODStopKey, LegID, @ODStopKey_inserted FromODStopKey, CWTFromTime ,CWTToTime, CWTToTimeSetBy, 
			CWTToTimeSetDate, PWTFromTime, PWTToTime, 
			PWTToTimeSetBy, PWTToTimeSetDate, DriverSetBy, DriverSetDate, IsManual, ManualRouteUser, ManualRouteAddedDate, MiscReason, MiscSetBy, 
			MiscSetDate, LinkedContainerType FROM #routes_old

		SET @RouteKey_inserted = SCOPE_IDENTITY()

		update RT Set Legno = Rt.Legno +1 
		From Routes RT  
		inner join #routes_old O on RT.OrderDetailKey = O.OrderDetailKey
		where Rt.Legno  >= O.LegNo + 1

		/*END OF  Create the New ROUTES data  */

		print '9'
		print Getdate()
		Update OrderDetailStops set 
			ToRouteKey = @RouteKey_inserted
		where OrderDetailStopKey = @NextOrderDetailStopKey

		print '10'
		print Getdate()
		update OrderDetailStops Set
			FromRouteKey = @RouteKey_inserted,
			ToRouteKey = @ROUTEKEY
		where OrderDetailStopKey = @ODStopKey_inserted

		COMMIT TRANSACTION FORCEDATA
		print '11'
		print Getdate()
		SET @Status = 1
		SET @Reason = 'Success'
	END TRY
	BEGIN CATCH
		SET @Status = 0
		SET @Reason = 'ERROR'
		PRINT ERROR_LINE()
		PRINT ERROR_MESSAGE()
		PRINT ERROR_NUMBER()
		ROLLBACK TRANSACTION FORCEDATA
	END CATCH
END
