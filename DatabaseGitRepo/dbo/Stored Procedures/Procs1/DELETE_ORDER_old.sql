

/*
declare @output bit = 0
EXEC Delete_Order 145, 1, @output OUTPUT
select @output 

select * from Order_Delete
select * from OrderHeader_Deleted
select * from OrderDetail_Deleted
*/


CREATE PROC [dbo].[DELETE_ORDER_old] -- EXEC Delete_Order 169407, 512
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
		return;
	end

	IF(@CNT > 0 AND @RouteCnt = 0)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
			SET IDENTITY_INSERT OrderHeader_Deleted ON
			INSERT INTO OrderHeader_Deleted (OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, SourceAddrKey,
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
				ETADate, BaseRateAmount FROM OrderHeader where OrderKey = @OrderKey
			SET IDENTITY_INSERT OrderHeader_Deleted OFF

			SET IDENTITY_INSERT OrderDetail_Deleted ON
			INSERT INTO OrderDetail_Deleted (OrderDetailKey, OrderKey, ContainerNo, ConfirmationNo, ContainerSizeKey, Chassis, 
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
			FROM OrderDetail WHERE OrderKey = @OrderKey
			SET IDENTITY_INSERT OrderDetail_Deleted OFF

			SET IDENTITY_INSERT ROUTES_DELETED ON
			INSERT INTO ROUTES_DELETED (RouteKey, OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, 
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
			FROM routes WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM OrderDetail WHERE OrderKey = @OrderKey)
			SET IDENTITY_INSERT ROUTES_DELETED OFF

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

			DELETE FROM OrderHeaderComments
			WHERE OrderKey = @OrderKey

			DELETE FROM OrderheaderDocuments
			WHERE OrderKey = @OrderKey
						

			DELETE FROM OrderDetail
			WHERE OrderKey = @OrderKey
			--Changes done
			DELETE FROM OrderStops
			WHERE OrderKey = @OrderKey

			DELETE FROM OrderHeader
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
			SET IDENTITY_INSERT OrderHeader_Deleted OFF
			SET IDENTITY_INSERT OrderDetail_Deleted OFF
			SET IDENTITY_INSERT routes_deleted OFF
		END CATCH
	END
END

