/**

DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"OrderKey":185581}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Delete_Order_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason

--{\"OrderKey\":185581}
**/
CREATE PROC [dbo].[Delete_Order_V2]
(
	@UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderKey INT=0;

	 -- Parse JSON input
	SELECT @OrderKey = ISNULL(OrderKey, 0)
	FROM OPENJSON(@JSONString)
	WITH (
		OrderKey INT '$.OrderKey'
	);

	SET @Status = 0;
	SET @Reason	= 'Failed';
	
	DECLARE @CNT INT = 0, @RouteCnt int = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader H
		LEFT JOIN OrderDetail D ON H.OrderKey = D.OrderKey
		WHERE  H.OrderKey = @OrderKey AND H.Status in (1, 12)

	SELECT @RouteCnt = COUNT(1) FROM OrderHeader H
		INNER JOIN OrderDetail D ON H.OrderKey = D.OrderKey
		INNER JOIN Routes RT ON D.OrderDetailKey = RT.OrderDetailKey
		WHERE  H.OrderKey = @OrderKey and RT.Status <> 1

	print '-----------------'
	print @cnt
	print @RouteCnt
	print '-----------------'

	IF(@RouteCnt > 0)
	BEGIN
		 --SELECT   
			--	0 AS ErrorNumber  
			--	,500 AS ErrorSeverity  
			--	,'' AS ErrorState  
			--	,'' AS ErrorProcedure  
			--	,'' AS ErrorLine  
			--	,'Orders with Leg actions in Progress/Completed can''t be deleted' AS ErrorMessage; 
		
		SET @Status = 0;
		SET @Reason	= 'Orders with Leg actions in Progress/Completed can''t be deleted';
		RETURN;
	END

	IF(@CNT > 0 AND @RouteCnt = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			SET IDENTITY_INSERT OrderHeader_Deleted ON
			INSERT INTO OrderHeader_Deleted (OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey, 
				DestinationAddrKey, ReturnAddrKey, SourceKey, OrderTypeKey, Status, StatusDate, HoldReasonKey, HoldDate, BrokerKey, BrokerRefNo, 
				PortoForiginKey, CarrierKey, VesselName, BillOfLading, BookingNo, IsHazardous, IsOverWeight, IsTriaxle, NeedsTobeScaled, 
				PriorityKey, CreateDate, Ach_Enabled, Ach_Amount, CreateUserKey, LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, 
				ConsigneeAddrKey, CompanyKey, CsrKey, CommentKey, ETADate, BaseRateAmount, SalesPersonKey, ReleaseNo, IntegrationWONo, 
				CSRManagerKey, OrderSource, MarketLocationKey, Consignee, SteamShipLinekey, SenderInfo, DropLive)
			SELECT OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey, 
				DestinationAddrKey, ReturnAddrKey, SourceKey, OrderTypeKey, Status, StatusDate, HoldReasonKey, HoldDate, BrokerKey, BrokerRefNo, 
				PortoForiginKey, CarrierKey, VesselName, BillOfLading, BookingNo, IsHazardous, IsOverWeight, IsTriaxle, NeedsTobeScaled, 
				PriorityKey, CreateDate, Ach_Enabled, Ach_Amount, CreateUserKey, LastUpdateDate, @UserKey, PortofDestinationKey, 
				ConsigneeAddrKey, CompanyKey, CsrKey, CommentKey, ETADate, BaseRateAmount, SalesPersonKey, ReleaseNo, IntegrationWONo, 
				CSRManagerKey, OrderSource, MarketLocationKey, Consignee, SteamShipLinekey, SenderInfo, DropLive
			FROM OrderHeader where OrderKey = @OrderKey
			SET IDENTITY_INSERT OrderHeader_Deleted OFF

			SET IDENTITY_INSERT OrderDetail_Deleted ON
			INSERT INTO OrderDetail_Deleted (OrderDetailKey, OrderKey, ContainerNo, ConfirmationNo, ContainerSizeKey, Chassis, SealNo, Weight, 
				ApptDateFrom, ApptDateTo, Status, StatusDate, HoldReasonKey, LastFreeDay, HoldDate, ReturnDate, ReturnTime, PickupTime, DropOffTime, 
				PickupDate, DropOffDate, CutOffDate, RouteKey, ActualPickupTime, ActualDropOffTime, ActualPickupDate, ActualDropOffDate, ContainerID, 
				IsHazardus, IsOverWeight, IsTriaxle, NeedtobeScaled, CommentKey, CreateUserKey, UpdateUserKey, SourceAddrKey, DestinationAddrKey, 
				CreateDate, LastUpdateDate, LegTypeKey, WeightUnit, IsEmpty, DriverNotes, SchedulerNotes, IsTMF, CompleteDate, VesselETA, isStreetTurn, 
				StreetTurnSetUser, StreetTurnSetDate, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, ContainerStatusKey, CurrentRouteKey, 
				TotalLegs, CurrentLegNo, OpenLegs, TMFCheckOff, CTFCheckOff, SizeCheckOff, MarkedNoEmptyAvailable, MarkedNoEmptyAvailableBY, 
				PUDelayedCodeKEy, PrepullDelayedCodeKEy, isWhseChargesConfirmed, WhseChargeApprovedby, WhseChargeApprovedDate, isCSChargeConfirmed, 
				CSChargeConfirmedBy, CSChargeConfirmedDate, isChargesSharedWithCust, ChargeSharedWithCustBy, ChargeSharedWithCustDate, 
				isCustApprovedCharges, IsTMFJCTPaid, IsTMFCustomerPaid, IsCTFJCTPaid, IsCTFCustomerPaid, TMFMarkDate, CTFMarkDate, ContainerNoSource, 
				ContainerNoDate, ContainerNoUser, Consignee, ReturnToStopKey, StopOffA_StopKey, OrderTypeKey, StopOffB_StopKey, CustRefNo, PriorityKey, 
				BookingNo, ShipFromStopKey, CSRKey, ShipToStopKey, JCTPaidDemurrage, DropOrLive, StopOffD_StopKey, StopOffC_StopKey, BillOfLadding, 
				AvailableT, AvailableTSetUserKey, AvailableTSetDateTime, ScheduleT, ScheduleTSetUserKey, ScheduleTSetDateTime, DemCheck, 
				DemCheckSetUserKey, DemCheckSetDateTime, Issues, IssuesSetUserKey, IssuesSetDateTime, SenderInfo)
			SELECT OrderDetailKey, OrderKey, ContainerNo, ConfirmationNo, ContainerSizeKey, Chassis, SealNo, Weight, 
				ApptDateFrom, ApptDateTo, Status, StatusDate, HoldReasonKey, LastFreeDay, HoldDate, ReturnDate, ReturnTime, PickupTime, DropOffTime, 
				PickupDate, DropOffDate, CutOffDate, RouteKey, ActualPickupTime, ActualDropOffTime, ActualPickupDate, ActualDropOffDate, ContainerID, 
				IsHazardus, IsOverWeight, IsTriaxle, NeedtobeScaled, CommentKey, CreateUserKey, @UserKey, SourceAddrKey, DestinationAddrKey, 
				CreateDate, LastUpdateDate, LegTypeKey, WeightUnit, IsEmpty, DriverNotes, SchedulerNotes, IsTMF, CompleteDate, VesselETA, isStreetTurn, 
				StreetTurnSetUser, StreetTurnSetDate, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, ContainerStatusKey, CurrentRouteKey, 
				TotalLegs, CurrentLegNo, OpenLegs, TMFCheckOff, CTFCheckOff, SizeCheckOff, MarkedNoEmptyAvailable, MarkedNoEmptyAvailableBY, 
				PUDelayedCodeKEy, PrepullDelayedCodeKEy, isWhseChargesConfirmed, WhseChargeApprovedby, WhseChargeApprovedDate, isCSChargeConfirmed, 
				CSChargeConfirmedBy, CSChargeConfirmedDate, isChargesSharedWithCust, ChargeSharedWithCustBy, ChargeSharedWithCustDate, 
				isCustApprovedCharges, IsTMFJCTPaid, IsTMFCustomerPaid, IsCTFJCTPaid, IsCTFCustomerPaid, TMFMarkDate, CTFMarkDate, ContainerNoSource, 
				ContainerNoDate, ContainerNoUser, Consignee, ReturnToStopKey, StopOffA_StopKey, OrderTypeKey, StopOffB_StopKey, CustRefNo, PriorityKey, 
				BookingNo, ShipFromStopKey, CSRKey, ShipToStopKey, JCTPaidDemurrage, DropOrLive, StopOffD_StopKey, StopOffC_StopKey, BillOfLadding, 
				AvailableT, AvailableTSetUserKey, AvailableTSetDateTime, ScheduleT, ScheduleTSetUserKey, ScheduleTSetDateTime, DemCheck, 
				DemCheckSetUserKey, DemCheckSetDateTime, Issues, IssuesSetUserKey, IssuesSetDateTime, SenderInfo
			FROM OrderDetail WHERE OrderKey = @OrderKey
			SET IDENTITY_INSERT OrderDetail_Deleted OFF

			SET IDENTITY_INSERT ROUTES_DELETED ON
			INSERT INTO ROUTES_DELETED (RouteKey, OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo, 
				CutOffDate, DeliveryDateFrom, DeliveryDateTo, AppointmentNo, ConfirmationNo, LastFreeDay, SwitchTo, PortWaitingTimeFrom, 
				PortWaitingTimeTo, CustomerWaitingTimeFrom, CustomerWaitingTimeTo, ChassisNo, ChassisType, TruckNo, FromLocation, ToLocation, 
				DestinationAddrKey, EstimatedDistanceInMiles, EstimatedTravelTime, Status, DriverKey, ScheduledPickupDate, ScheduledArrival, 
				ScheduledDeparture, ActualDeparture, ActualArrival, OdometerAtSource, OdometerAtDestination, DriverCommentKey, SchedulerCommentKey, 
				ChassisKey, CompanyKey, CreateUserKey, UpdateUserKey, CreateDate, LastUpdateDate, LocationKey, IsEmpty, IsAbandoned, IsDryRun, 
				IsBobtail, IsDocumentVerified, IsRateVerified, DocumentVerifiedDate, RateVerifiedDate, DocumentVerifiedUserKey, RateVerifiedUserKey, 
				DelConfirmationNo, isStreetTurn, StreetTurnSetUser, StreetTurnSetDate, IsChargesApproved, ChargesApprovedDate, ChargesApprovedBy, 
				DryRunType, YardCheckIn, YardCheckOut, ChassisCategoryKey, ActualDepartureUpdateMethod, ActualArrivalUpdateMethod, CarrierRate, 
				StreeTurnPrevStatusKey, EmptySetUser, EmptySetDate, BobtailSetUser, BobtailSetDate, DryRunSetUser, DryRunSetDate, 
				SFGYardDiffLogKeyPickup, SFGYardChangePickup, SFGYardChangePickupMessage, SFGYardDiffLogKeyDelivery, SFGYardChangeDelivery, 
				SFGYardChangeDeliveryMessage, YardIDPickupBeforeUpdate, YardIDDeliveryBeforeUpdate, PrevStatusKey, ChassisSource, ChassisChangedDate, 
				EmptySource, DryRunSource, BobTailSource, StreetTurnSource, ChassisChangedUser, ActualDepartureUpdateDate, ActualDepartureUpdateUser, 
				ActualArrivalUpdateDate, ActualArrivalUpdateUser, ChargeNotes, CompletionNotes, DriverInstructions, FromLocationWaitTimeFrom, 
				FromLocationWaitTimeTo, ToLocationWaitTimeFrom, ToLocationWaitTimeTo, CarrierAssignedBy, LinkedContainer, LinkedBy, LinkedDate, 
				ContainerNoSource, NoEmptyAvailableMarked, NoEmptyAvailableMarkedBY, NoEmptyAvailableMarkedDate, LegType, IsChassisSplit, 
				LinkedContainerSource, NoEmptyMarkedSource, ChassisSplitDate, NoWaitTIme, ChassisSplitBy, PickupNoWaitTIme, DeliveryNoWaitTime, 
				ToODStopKey, LegID, FromODStopKey, CWTFromTime, CWTToTime, CWTToTimeSetBy, CWTToTimeSetDate, PWTFromTime, PWTToTime, PWTToTimeSetBy, 
				PWTToTimeSetDate, DriverSetBy, DriverSetDate)
			SELECT RouteKey, OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo, 
				CutOffDate, DeliveryDateFrom, DeliveryDateTo, AppointmentNo, ConfirmationNo, LastFreeDay, SwitchTo, PortWaitingTimeFrom, 
				PortWaitingTimeTo, CustomerWaitingTimeFrom, CustomerWaitingTimeTo, ChassisNo, ChassisType, TruckNo, FromLocation, ToLocation, 
				DestinationAddrKey, EstimatedDistanceInMiles, EstimatedTravelTime, Status, DriverKey, ScheduledPickupDate, ScheduledArrival, 
				ScheduledDeparture, ActualDeparture, ActualArrival, OdometerAtSource, OdometerAtDestination, DriverCommentKey, SchedulerCommentKey, 
				ChassisKey, CompanyKey, CreateUserKey, @UserKey, CreateDate, LastUpdateDate, LocationKey, IsEmpty, IsAbandoned, IsDryRun, 
				IsBobtail, IsDocumentVerified, IsRateVerified, DocumentVerifiedDate, RateVerifiedDate, DocumentVerifiedUserKey, RateVerifiedUserKey, 
				DelConfirmationNo, isStreetTurn, StreetTurnSetUser, StreetTurnSetDate, IsChargesApproved, ChargesApprovedDate, ChargesApprovedBy, 
				DryRunType, YardCheckIn, YardCheckOut, ChassisCategoryKey, ActualDepartureUpdateMethod, ActualArrivalUpdateMethod, CarrierRate, 
				StreeTurnPrevStatusKey, EmptySetUser, EmptySetDate, BobtailSetUser, BobtailSetDate, DryRunSetUser, DryRunSetDate, 
				SFGYardDiffLogKeyPickup, SFGYardChangePickup, SFGYardChangePickupMessage, SFGYardDiffLogKeyDelivery, SFGYardChangeDelivery, 
				SFGYardChangeDeliveryMessage, YardIDPickupBeforeUpdate, YardIDDeliveryBeforeUpdate, PrevStatusKey, ChassisSource, ChassisChangedDate, 
				EmptySource, DryRunSource, BobTailSource, StreetTurnSource, ChassisChangedUser, ActualDepartureUpdateDate, ActualDepartureUpdateUser, 
				ActualArrivalUpdateDate, ActualArrivalUpdateUser, ChargeNotes, CompletionNotes, DriverInstructions, FromLocationWaitTimeFrom, 
				FromLocationWaitTimeTo, ToLocationWaitTimeFrom, ToLocationWaitTimeTo, CarrierAssignedBy, LinkedContainer, LinkedBy, LinkedDate, 
				ContainerNoSource, NoEmptyAvailableMarked, NoEmptyAvailableMarkedBY, NoEmptyAvailableMarkedDate, LegType, IsChassisSplit, 
				LinkedContainerSource, NoEmptyMarkedSource, ChassisSplitDate, NoWaitTIme, ChassisSplitBy, PickupNoWaitTIme, DeliveryNoWaitTime, 
				ToODStopKey, LegID, FromODStopKey, CWTFromTime, CWTToTime, CWTToTimeSetBy, CWTToTimeSetDate, PWTFromTime, PWTToTime, PWTToTimeSetBy, 
				PWTToTimeSetDate, DriverSetBy, DriverSetDate
			FROM routes WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail WHERE OrderKey = @OrderKey)
			SET IDENTITY_INSERT ROUTES_DELETED OFF

			SET IDENTITY_INSERT OrderStops_Deleted ON;
			INSERT INTO OrderStops_Deleted(OrderStopKey, OrderKey, StopTypeKey, StopName, StopAddrKey, StopNumber, LocationType, 
				StatusKey, CreateDate, CreateUserKey, UpdateDate, UpdateUserKey, IsDeleted, DeleteUserKey, DeleteDate)
			SELECT OrderStopKey, OrderKey, StopTypeKey, StopName, StopAddrKey, StopNumber, LocationType, 
				StatusKey, CreateDate, CreateUserKey, UpdateDate, @UserKey, IsDeleted, DeleteUserKey, DeleteDate
			FROM OrderStops WHERE OrderKey = @OrderKey
			SET IDENTITY_INSERT OrderStops_Deleted OFF;

			SET IDENTITY_INSERT OrderDetailStops_Deleted ON;
			INSERT INTO OrderDetailStops_Deleted(OrderDetailStopKey, OrderDetailKey, OrderStopKey, StopTypeKey, StopName, 
				StopNameSetUserKey, StopNameSetDateTime, StopAddrKey, StopNumber, LocationType, SchedulePickupDate, SchedulePickupUserKey, 
				SchedulePickupSetDateTime, SchedulePickupDateTo, SchedulePickupToUserKey, SchedulePickupToSetDateTime, ActualPickupDate, 
				ActualPickupUserKey, ActualPickupSetDateTime, ScheduleDeliveryDate, ScheduleDeliveryUserKey, ScheduleDeliverySetDateTime, 
				ScheduleDeliveryDateTo, ScheduleDeliveryToUserKey, ScheduleDeliveryToSetDateTime, ActualDeliveryDate, ActualDeliveryUserKey, 
				ActualDeliverySetDateTime, ToRouteKey, FromRouteKey, StatusKey, CreateDate, CreateUserKey, UpdateDate, UpdateUserKey, IsDryRunPort, 
				DryRunPortSetDateTime, DryRunPortSetUserKey, IsDryRunCustomer, DryRunCustomerSetDateTime, DryRunCustomerSetUserKey, RefNo, 
				IsTMFChecked, IsCTFChecked, TMFCheckUserKey, CTFCheckUserKey, TMFCheckDate, CTFCheckDate, ReasonCode, DropOrLive, DropOrLiveSetUserKey, 
				DropOrLiveSetDatetime, ExceptionReasonCode, ExceptionRCSetUserKey, ExceptionRCSetDateTime, IsDeleted, DeleteUserKey, DeleteDate, 
				IsBobTail, BobtailSetDateTime, BobtailSetUserKey, IsEmpty, EmptySetDateTime, EmptySetUserKey, IsStreetTurn, StreetSturnSetDateTime, 
				StreetSturnSetUserKey, IsChassisSplit, ChassisSplitSetDateTime, ChassisSplitSetUserKey, Is247Pickup, Is247PickupMarkedby, Is247PickupMarkedDate, 
				Is247Delivery, Is247DeliveryMarkedBy, Is247DeliveryMarkedDate)
			SELECT OrderDetailStopKey, OrderDetailKey, OrderStopKey, StopTypeKey, StopName, 
				StopNameSetUserKey, StopNameSetDateTime, StopAddrKey, StopNumber, LocationType, SchedulePickupDate, SchedulePickupUserKey, 
				SchedulePickupSetDateTime, SchedulePickupDateTo, SchedulePickupToUserKey, SchedulePickupToSetDateTime, ActualPickupDate, 
				ActualPickupUserKey, ActualPickupSetDateTime, ScheduleDeliveryDate, ScheduleDeliveryUserKey, ScheduleDeliverySetDateTime, 
				ScheduleDeliveryDateTo, ScheduleDeliveryToUserKey, ScheduleDeliveryToSetDateTime, ActualDeliveryDate, ActualDeliveryUserKey, 
				ActualDeliverySetDateTime, ToRouteKey, FromRouteKey, StatusKey, CreateDate, CreateUserKey, UpdateDate, @UserKey, IsDryRunPort, 
				DryRunPortSetDateTime, DryRunPortSetUserKey, IsDryRunCustomer, DryRunCustomerSetDateTime, DryRunCustomerSetUserKey, RefNo, 
				IsTMFChecked, IsCTFChecked, TMFCheckUserKey, CTFCheckUserKey, TMFCheckDate, CTFCheckDate, ReasonCode, DropOrLive, DropOrLiveSetUserKey, 
				DropOrLiveSetDatetime, ExceptionReasonCode, ExceptionRCSetUserKey, ExceptionRCSetDateTime, IsDeleted, DeleteUserKey, DeleteDate, 
				IsBobTail, BobtailSetDateTime, BobtailSetUserKey, IsEmpty, EmptySetDateTime, EmptySetUserKey, IsStreetTurn, StreetSturnSetDateTime, 
				StreetSturnSetUserKey, IsChassisSplit, ChassisSplitSetDateTime, ChassisSplitSetUserKey, Is247Pickup, Is247PickupMarkedby, Is247PickupMarkedDate, 
				Is247Delivery, Is247DeliveryMarkedBy, Is247DeliveryMarkedDate
			FROM OrderDetailStops WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail WHERE OrderKey = @OrderKey)
			SET IDENTITY_INSERT OrderDetailStops_Deleted OFF;

			INSERT INTO OrderHeaderComments_Deleted (OrderKey,CommentKey)
			SELECT OrderKey,CommentKey FROM OrderHeaderComments WHERE OrderKey = @OrderKey

			INSERT INTO OrderheaderDocuments_Deleted(DocumentKey, OrderKey)
			SELECT DocumentKey, OrderKey FROM OrderheaderDocuments WHERE OrderKey = @OrderKey

			INSERT INTO OrderDetailComments_Deleted (OrderDetailKey, CommentKey)
			SELECT C.OrderDetailKey, C.CommentKey FROM OrderDetailComments C
			INNER JOIN OrderDetail D ON D.OrderDetailKey = C.OrderDetailKey
			WHERE ORDERKEY = @OrderKey

			INSERT INTO OrderDetailDocuments_Deleted(OrderDetailKey, DocumentKey)
			SELECT C.OrderDetailKey, C.DocumentKey FROM OrderDetailDocuments C
			INNER JOIN OrderDetail D ON D.OrderDetailKey = C.OrderDetailKey
			WHERE ORDERKEY = @OrderKey

			INSERT INTO Order_Delete
			SELECT @OrderKey, GETDATE(), @UserKey

			DELETE FROM OrderDetailComments
			WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail WHERE OrderKey = @OrderKey)

			DELETE FROM OrderDetailDocuments
			WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail WHERE OrderKey = @OrderKey)
			
			DELETE FROM Routes   WHERE 
			OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail WHERE OrderKey = @OrderKey)

			Delete From OrderDetailStops
			Where OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail WHERE OrderKey = @OrderKey)

			DELETE FROM OrderStops
			WHERE OrderKey = @OrderKey

			DELETE FROM OrderHeaderComments
			WHERE OrderKey = @OrderKey

			DELETE FROM OrderheaderDocuments
			WHERE OrderKey = @OrderKey
						
			DELETE FROM OrderDetail
			WHERE OrderKey = @OrderKey
			--Changes done
			
			DECLARE @UserName NVARCHAR(100)='',@OrderNo NVARCHAR(100)=''
			SELECT @UserName=UserName FROM [User] WITH (NOLOCK) WHERE UserKey=@UserKey;
			SELECT @OrderNo=OrderNo FROM OrderHeader WITH (NOLOCK) WHERE OrderKey=@OrderKey;

			DELETE FROM OrderHeader
			WHERE OrderKey = @OrderKey

			INSERT INTO AuditLogDetail
			(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Order',@OrderNo,@OrderKey,null,'Text','Order ' + @OrderNo + ' deleted'
			
			COMMIT TRANSACTION
			Print 'Committed'

			SET @Status = 1;
			SET @Reason	= 'Success';

		END TRY
		BEGIN CATCH
			 --SELECT   
				--ERROR_NUMBER() AS ErrorNumber  
				--,ERROR_SEVERITY() AS ErrorSeverity  
				--,ERROR_STATE() AS ErrorState  
				--,ERROR_PROCEDURE() AS ErrorProcedure  
				--,ERROR_LINE() AS ErrorLine  
				--,ERROR_MESSAGE() AS ErrorMessage;  
			ROLLBACK TRANSACTION
			
			SET @Status = 0;
			SET @Reason	= ERROR_MESSAGE();

			Print 'Rolled Back'
			SET IDENTITY_INSERT OrderHeader_Deleted OFF
			SET IDENTITY_INSERT OrderDetail_Deleted OFF
			SET IDENTITY_INSERT routes_deleted OFF
	END CATCH
	END
END

