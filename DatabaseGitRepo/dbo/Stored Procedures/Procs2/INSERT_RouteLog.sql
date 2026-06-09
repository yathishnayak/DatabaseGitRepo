

CREATE PROCEDURE [dbo].[INSERT_RouteLog]
AS
BEGIN	
	DECLARE @User		VARCHAR(50)
	SET @User=( SELECT SYSTEM_USER )	
--***************Insert Only******************			
			INSERT INTO [dbo].[Routes_Log]
				(
					[RouteKey],[OrderDetailKey],[OrderKey],[LegKey],[LegNo],[SourceAddrKey],[PickupDateFrom],[PickupDateTo]
				,[CutOffDate],[DeliveryDateFrom],[DeliveryDateTo],[AppointmentNo],[ConfirmationNo],[LastFreeDay],[SwitchTo],[PortWaitingTimeFrom]
				,[PortWaitingTimeTo],[CustomerWaitingTimeFrom],[CustomerWaitingTimeTo],[ChassisNo],[ChassisType]
				,[TruckNo],[FromLocation],[ToLocation],[DestinationAddrKey],[EstimatedDistanceInMiles],[EstimatedTravelTime]
				,[Status],[DriverKey],[ScheduledPickupDate],[ScheduledArrival],[ScheduledDeparture],[ActualDeparture]
				,[ActualArrival],[OdometerAtSource],[OdometerAtDestination],[DriverCommentKey],[SchedulerCommentKey]
				,[ChassisKey],[CompanyKey],[CreateUserKey],[UpdateUserKey],[CreateDate],[LastUpdateDate],ActionDate
				,[ActionType],[ActionUser]
				)
			SELECT  	
					 [RouteKey],[OrderDetailKey],[OrderKey],[LegKey],[LegNo],[SourceAddrKey],[PickupDateFrom],[PickupDateTo]
					,[CutOffDate],[DeliveryDateFrom],[DeliveryDateTo],[AppointmentNo],[ConfirmationNo],[LastFreeDay],[SwitchTo],[PortWaitingTimeFrom]
					,[PortWaitingTimeTo],[CustomerWaitingTimeFrom],[CustomerWaitingTimeTo],[ChassisNo],[ChassisType]
					,[TruckNo],[FromLocation],[ToLocation],[DestinationAddrKey],[EstimatedDistanceInMiles],[EstimatedTravelTime]
					,[Status],[DriverKey],[ScheduledPickupDate],[ScheduledArrival],[ScheduledDeparture],[ActualDeparture]
					,[ActualArrival],[OdometerAtSource],[OdometerAtDestination],[DriverCommentKey],[SchedulerCommentKey]
					,[ChassisKey],[CompanyKey],[CreateUserKey],[UpdateUserKey],[CreateDate],[LastUpdateDate],GETDATE()
					,'INSERT',isnull(CreateUserKey,UpdateUserKey)
			FROM #inserted 

			

			INSERT INTO [dbo].[Routes_Log]
				(
					[RouteKey],[OrderDetailKey],[OrderKey],[LegKey],[LegNo],[SourceAddrKey],[PickupDateFrom],[PickupDateTo]
				,[CutOffDate],[DeliveryDateFrom],[DeliveryDateTo],[AppointmentNo],[ConfirmationNo],[LastFreeDay],[SwitchTo],[PortWaitingTimeFrom]
				,[PortWaitingTimeTo],[CustomerWaitingTimeFrom],[CustomerWaitingTimeTo],[ChassisNo],[ChassisType]
				,[TruckNo],[FromLocation],[ToLocation],[DestinationAddrKey],[EstimatedDistanceInMiles],[EstimatedTravelTime]
				,[Status],[DriverKey],[ScheduledPickupDate],[ScheduledArrival],[ScheduledDeparture],[ActualDeparture]
				,[ActualArrival],[OdometerAtSource],[OdometerAtDestination],[DriverCommentKey],[SchedulerCommentKey]
				,[ChassisKey],[CompanyKey],[CreateUserKey],[UpdateUserKey],[CreateDate],[LastUpdateDate],ActionDate
				,[ActionType],[ActionUser]
				)
			SELECT  	
					 [RouteKey],[OrderDetailKey],[OrderKey],[LegKey],[LegNo],[SourceAddrKey],[PickupDateFrom],[PickupDateTo]
					,[CutOffDate],[DeliveryDateFrom],[DeliveryDateTo],[AppointmentNo],[ConfirmationNo],[LastFreeDay],[SwitchTo],[PortWaitingTimeFrom]
					,[PortWaitingTimeTo],[CustomerWaitingTimeFrom],[CustomerWaitingTimeTo],[ChassisNo],[ChassisType]
					,[TruckNo],[FromLocation],[ToLocation],[DestinationAddrKey],[EstimatedDistanceInMiles],[EstimatedTravelTime]
					,[Status],[DriverKey],[ScheduledPickupDate],[ScheduledArrival],[ScheduledDeparture],[ActualDeparture]
					,[ActualArrival],[OdometerAtSource],[OdometerAtDestination],[DriverCommentKey],[SchedulerCommentKey]
					,[ChassisKey],[CompanyKey],[CreateUserKey],[UpdateUserKey],[CreateDate],[LastUpdateDate],GETDATE()
					,'DELETE',isnull(CreateUserKey,UpdateUserKey)
			FROM #deleted 
	--END
END

