CREATE PROC [dbo].[Retrieve_ORDER] -- EXEC Retrieve_ORDER 123273, 512
(
	@OrderKey	int,
	@UserKey	int,
	@Output		bit =0 OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET @Output = 0


	DECLARE @CNT INT = 0, @RouteCnt int = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader_Deleted H
		INNER JOIN OrderDetail_Deleted D ON H.OrderKey = D.OrderKey
		WHERE  H.OrderKey = @OrderKey AND H.Status in (1, 12)

	SELECT @RouteCnt = COUNT(1) FROM OrderHeader_Deleted H
		INNER JOIN OrderDetail_Deleted D ON H.OrderKey = D.OrderKey
		INNER JOIN Routes_Deleted RT ON D.OrderDetailKey = RT.OrderDetailKey
		WHERE  H.OrderKey = @OrderKey and RT.Status <> 1

	print '-----------------'
	print @cnt
	print @RouteCnt
	print '-----------------'
	if(@RouteCnt > 0)
	begin
	
		 SELECT   
				0 AS ErrorNumber  
				,500 AS ErrorSeverity  
				,'' AS ErrorState  
				,'' AS ErrorProcedure  
				,'' AS ErrorLine  
				,'Orders with Leg actions in Progress/Completed can''t be deleted' AS ErrorMessage; 
		set @Output = 0
		--return;
	end

	IF(@CNT > 0 )--AND @RouteCnt = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			SET IDENTITY_INSERT OrderHeader ON
			INSERT INTO OrderHeader (OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey,
				DestinationAddrKey, ReturnAddrKey, SourceKey, OrderTypeKey, Status, StatusDate, HoldReasonKey, HoldDate, 
				BrokerKey, BrokerRefNo, PortoForiginKey, CarrierKey, VesselName, BillOfLading, BookingNo, IsHazardous, 
				IsOverWeight, IsTriaxle, NeedsTobeScaled, PriorityKey, CreateDate, Ach_Enabled, Ach_Amount, CreateUserKey, 
				LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, ConsigneeAddrKey, CompanyKey, CsrKey, CommentKey, 
				ETADate, BaseRateAmount)
			SELECT OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey,
				DestinationAddrKey, ReturnAddrKey, SourceKey, OrderTypeKey, Status, StatusDate, HoldReasonKey, HoldDate, 
				BrokerKey, BrokerRefNo, PortoForiginKey, CarrierKey, VesselName, BillOfLading, BookingNo, IsHazardous, 
				IsOverWeight, IsTriaxle, NeedsTobeScaled, PriorityKey, CreateDate, Ach_Enabled, Ach_Amount, CreateUserKey, 
				LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, ConsigneeAddrKey, CompanyKey, CsrKey, CommentKey, 
				ETADate, BaseRateAmount FROM OrderHeader_Deleted where OrderKey = @OrderKey
			SET IDENTITY_INSERT OrderHeader OFF

			SET IDENTITY_INSERT OrderDetail ON
			INSERT INTO OrderDetail (OrderDetailKey, OrderKey, ContainerNo, ConfirmationNo, ContainerSizeKey, Chassis, 
				SealNo, Weight, ApptDateFrom, ApptDateTo, Status, StatusDate, HoldReasonKey, LastFreeDay, HoldDate, ReturnDate,
				ReturnTime, PickupTime, DropOffTime, PickupDate, DropOffDate, CutOffDate, RouteKey, ActualPickupTime, 
				ActualDropOffTime, ActualPickupDate, ActualDropOffDate, ContainerID, IsHazardus, IsOverWeight, IsTriaxle, 
				NeedtobeScaled, CommentKey, CreateUserKey, UpdateUserKey, SourceAddrKey, DestinationAddrKey, CreateDate,
				LastUpdateDate, LegTypeKey, WeightUnit, IsEmpty, DriverNotes, SchedulerNotes, IsTMF, CompleteDate, VesselETA)
			SELECT OrderDetailKey, OrderKey, ContainerNo, ConfirmationNo, ContainerSizeKey, Chassis, 
				SealNo, Weight, ApptDateFrom, ApptDateTo, Status, StatusDate, HoldReasonKey, LastFreeDay, HoldDate, ReturnDate, 
				ReturnTime, PickupTime, DropOffTime, PickupDate, DropOffDate, CutOffDate, RouteKey, ActualPickupTime, 
				ActualDropOffTime, ActualPickupDate, ActualDropOffDate, ContainerID, IsHazardus, IsOverWeight, IsTriaxle, 
				NeedtobeScaled, CommentKey, CreateUserKey, UpdateUserKey, SourceAddrKey, DestinationAddrKey, CreateDate, 
				LastUpdateDate, LegTypeKey, WeightUnit, IsEmpty, DriverNotes, SchedulerNotes, IsTMF, CompleteDate, VesselETA 
			FROM OrderDetail_Deleted WHERE OrderKey = @OrderKey
			SET IDENTITY_INSERT OrderDetail OFF

			SET IDENTITY_INSERT routes ON
			INSERT INTO routes (RouteKey, OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, 
			    PickupDateTo, CutOffDate, DeliveryDateFrom, DeliveryDateTo, AppointmentNo, ConfirmationNo, LastFreeDay, 
				SwitchTo, PortWaitingTimeFrom, PortWaitingTimeTo, CustomerWaitingTimeFrom, CustomerWaitingTimeTo, ChassisNo, 
				ChassisType, TruckNo, FromLocation, ToLocation, DestinationAddrKey, EstimatedDistanceInMiles, EstimatedTravelTime, 
				Status, DriverKey, ScheduledPickupDate, ScheduledArrival, ScheduledDeparture, ActualDeparture, ActualArrival, 
				OdometerAtSource, OdometerAtDestination, DriverCommentKey, SchedulerCommentKey, ChassisKey, CompanyKey, 
				CreateUserKey, UpdateUserKey, CreateDate, LastUpdateDate, LocationKey, IsEmpty, IsAbandoned, IsDryRun, IsBobtail, 
				IsDocumentVerified, IsRateVerified, DocumentVerifiedDate, RateVerifiedDate, DocumentVerifiedUserKey, 
				RateVerifiedUserKey, DelConfirmationNo, isStreetTurn, StreetTurnSetUser, StreetTurnSetDate)
			SELECT RouteKey, OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, 
				PickupDateTo, CutOffDate, DeliveryDateFrom, DeliveryDateTo, AppointmentNo, ConfirmationNo, LastFreeDay, 
				SwitchTo, PortWaitingTimeFrom, PortWaitingTimeTo, CustomerWaitingTimeFrom, CustomerWaitingTimeTo, ChassisNo, 
				ChassisType, TruckNo, FromLocation, ToLocation, DestinationAddrKey, EstimatedDistanceInMiles, EstimatedTravelTime, 
				Status, DriverKey, ScheduledPickupDate, ScheduledArrival, ScheduledDeparture, ActualDeparture, ActualArrival, 
				OdometerAtSource, OdometerAtDestination, DriverCommentKey, SchedulerCommentKey, ChassisKey, CompanyKey, 
				CreateUserKey, UpdateUserKey, CreateDate, LastUpdateDate, LocationKey, IsEmpty, IsAbandoned, IsDryRun, IsBobtail, 
				IsDocumentVerified, IsRateVerified, DocumentVerifiedDate, RateVerifiedDate, DocumentVerifiedUserKey, 
				RateVerifiedUserKey, DelConfirmationNo, isStreetTurn, StreetTurnSetUser, StreetTurnSetDate 
			FROM ROUTES_DELETED WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail_Deleted WHERE OrderKey = @OrderKey)
			SET IDENTITY_INSERT routes OFF

			INSERT INTO  OrderHeaderComments (OrderKey,CommentKey)
			SELECT OrderKey,CommentKey FROM OrderHeaderComments_Deleted  WHERE OrderKey = @OrderKey

			INSERT INTO OrderheaderDocuments (DocumentKey, OrderKey)
			SELECT DocumentKey, OrderKey FROM OrderheaderDocuments_Deleted  WHERE OrderKey = @OrderKey

			INSERT INTO OrderDetailComments (OrderDetailKey, CommentKey)
			SELECT C.OrderDetailKey, C.CommentKey FROM   OrderDetailComments_Deleted C
			INNER JOIN OrderDetail_Deleted D ON D.OrderDetailKey = C.OrderDetailKey
			WHERE ORDERKEY = @OrderKey

			INSERT INTO  OrderDetailDocuments(OrderDetailKey, DocumentKey)
			SELECT C.OrderDetailKey, C.DocumentKey FROM OrderDetailDocuments_Deleted C
			INNER JOIN OrderDetail_Deleted D ON D.OrderDetailKey = C.OrderDetailKey
			WHERE ORDERKEY = @OrderKey
			
			DELETE FROM Order_Delete 
			WHERE  OrderKey =  @OrderKey 

			DELETE FROM OrderDetailComments_Deleted
			WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail_Deleted WHERE OrderKey = @OrderKey)

			DELETE FROM OrderDetailDocuments_Deleted
			WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail_Deleted WHERE OrderKey = @OrderKey)
			
			DELETE FROM ROUTES_DELETED   WHERE 
			OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail_Deleted WHERE OrderKey = @OrderKey)

			DELETE FROM OrderHeaderComments_Deleted
			WHERE OrderKey = @OrderKey

			DELETE FROM OrderheaderDocuments_Deleted
			WHERE OrderKey = @OrderKey						

			DELETE FROM OrderDetail_Deleted
			WHERE OrderKey = @OrderKey

			DELETE FROM OrderHeader_Deleted
			WHERE OrderKey = @OrderKey
			
			COMMIT TRANSACTION
			Print 'Committed'
			SET @Output = 1

		END TRY
		BEGIN CATCH
			 SELECT   
				ERROR_NUMBER() AS ErrorNumber  
				,ERROR_SEVERITY() AS ErrorSeverity  
				,ERROR_STATE() AS ErrorState  
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_LINE() AS ErrorLine  
				,ERROR_MESSAGE() AS ErrorMessage;  
			ROLLBACK TRANSACTION
			Print 'Rolled Back'
			SET IDENTITY_INSERT OrderHeader OFF
			SET IDENTITY_INSERT OrderDetail OFF
			SET IDENTITY_INSERT routes OFF
			SET @Output = 0
		END CATCH
	END
	ELSE
		BEGIN
			SET @Output = 0
		END
END
