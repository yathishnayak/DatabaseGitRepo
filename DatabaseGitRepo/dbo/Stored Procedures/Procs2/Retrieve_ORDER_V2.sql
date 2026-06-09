/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"OrderKey": 195351}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Retrieve_ORDER_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROC [dbo].[Retrieve_ORDER_V2]
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

    SET @Status = 0;
    SET @Reason = 'Fail';

    DECLARE @OrderKey INT = 0;
    
    -- Parse JSON input
    SELECT @OrderKey = ISNULL(OrderKey, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        OrderKey INT '$.OrderKey'
    );

    IF (@OrderKey = 0)
    BEGIN
        SET @Reason = 'Invalid OrderKey';
        RETURN;
    END

    DECLARE @CNT INT = 0, @RouteCnt INT = 0;
    
    SELECT @CNT = COUNT(1) 
    FROM dbo.OrderHeader_Deleted H WITH (NOLOCK)
    INNER JOIN dbo.OrderDetail_Deleted D WITH (NOLOCK) ON H.OrderKey = D.OrderKey
    WHERE H.OrderKey = @OrderKey AND H.Status IN (1, 12);

    SELECT @RouteCnt = COUNT(1) 
    FROM dbo.OrderHeader_Deleted H WITH (NOLOCK)
    INNER JOIN dbo.OrderDetail_Deleted D WITH (NOLOCK) ON H.OrderKey = D.OrderKey
    INNER JOIN dbo.Routes_Deleted RT WITH (NOLOCK) ON D.OrderDetailKey = RT.OrderDetailKey
    WHERE H.OrderKey = @OrderKey AND RT.Status <> 1;

    IF (@IsDebug = 1)
    BEGIN
        PRINT 'CNT: ' + CAST(@CNT AS VARCHAR(10));
        PRINT 'RouteCnt: ' + CAST(@RouteCnt AS VARCHAR(10));
    END

    -- Stop if routes are in progress
    IF (@RouteCnt > 0)
    BEGIN
        SELECT   
            0 AS ErrorNumber,
            500 AS ErrorSeverity,
            '' AS ErrorState,
            '' AS ErrorProcedure,
            '' AS ErrorLine,
            'Orders with Leg actions in Progress/Completed cannot be retrieved' AS ErrorMessage;
        
        SET @Status = 0;
        SET @Reason = 'Routes in progress';
        RETURN;
    END

    IF (@CNT = 0)
    BEGIN
        SET @Reason = 'No deleted order found';
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- OrderHeader - Fixed with all columns
        SET IDENTITY_INSERT dbo.OrderHeader ON;
        
        INSERT INTO dbo.OrderHeader (
            OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, 
            SourceAddrKey, DestinationAddrKey, ReturnAddrKey, SourceKey, OrderTypeKey, 
            Status, StatusDate, HoldReasonKey, HoldDate, BrokerKey, BrokerRefNo, 
            PortoForiginKey, CarrierKey, VesselName, BillOfLading, BookingNo, IsHazardous, 
            IsOverWeight, IsTriaxle, NeedsTobeScaled, PriorityKey, CreateDate, Ach_Enabled, 
            Ach_Amount, CreateUserKey, LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, 
            ConsigneeAddrKey, CompanyKey, CsrKey, CommentKey, ETADate, BaseRateAmount,
            SalesPersonKey, ReleaseNo, IntegrationWONo, CSRManagerKey, OrderSource,
            MarketLocationKey, Consignee, SteamShipLinekey, SenderInfo, DropLive
        )
        SELECT 
            OrderKey, OrderNo, OrderDate, CustKey, BillToAddrKey, BillToCopyAddrKey, 
            SourceAddrKey, DestinationAddrKey, ReturnAddrKey, SourceKey, OrderTypeKey, 
            Status, StatusDate, HoldReasonKey, HoldDate, BrokerKey, BrokerRefNo, 
            PortoForiginKey, CarrierKey, VesselName, BillOfLading, BookingNo, IsHazardous, 
            IsOverWeight, IsTriaxle, NeedsTobeScaled, PriorityKey, CreateDate, Ach_Enabled, 
            Ach_Amount, CreateUserKey, LastUpdateDate, LastUpdateUserKey, PortofDestinationKey, 
            ConsigneeAddrKey, CompanyKey, CsrKey, CommentKey, ETADate, BaseRateAmount,
            SalesPersonKey, ReleaseNo, IntegrationWONo, CSRManagerKey, OrderSource,
            MarketLocationKey, Consignee, SteamShipLinekey, SenderInfo, DropLive
        FROM dbo.OrderHeader_Deleted WITH (NOLOCK) 
        WHERE OrderKey = @OrderKey;
        
        SET IDENTITY_INSERT dbo.OrderHeader OFF;

        -- OrderDetail - Fixed with all columns
        SET IDENTITY_INSERT dbo.OrderDetail ON;
        
        INSERT INTO dbo.OrderDetail (
            OrderDetailKey, OrderKey, ContainerNo, ConfirmationNo, ContainerSizeKey, 
            Chassis, SealNo, Weight, ApptDateFrom, ApptDateTo, Status, StatusDate, 
            HoldReasonKey, LastFreeDay, HoldDate, ReturnDate, ReturnTime, PickupTime, 
            DropOffTime, PickupDate, DropOffDate, CutOffDate, RouteKey, ActualPickupTime, 
            ActualDropOffTime, ActualPickupDate, ActualDropOffDate, ContainerID, IsHazardus, 
            IsOverWeight, IsTriaxle, NeedtobeScaled, CommentKey, CreateUserKey, UpdateUserKey, 
            SourceAddrKey, DestinationAddrKey, CreateDate, LastUpdateDate, LegTypeKey, 
            WeightUnit, IsEmpty, DriverNotes, SchedulerNotes, IsTMF, CompleteDate, VesselETA
        )
        SELECT 
            OrderDetailKey, OrderKey, ContainerNo, ConfirmationNo, ContainerSizeKey, 
            Chassis, SealNo, Weight, ApptDateFrom, ApptDateTo, Status, StatusDate, 
            HoldReasonKey, LastFreeDay, HoldDate, ReturnDate, ReturnTime, PickupTime, 
            DropOffTime, PickupDate, DropOffDate, CutOffDate, RouteKey, ActualPickupTime, 
            ActualDropOffTime, ActualPickupDate, ActualDropOffDate, ContainerID, IsHazardus, 
            IsOverWeight, IsTriaxle, NeedtobeScaled, CommentKey, CreateUserKey, UpdateUserKey, 
            SourceAddrKey, DestinationAddrKey, CreateDate, LastUpdateDate, LegTypeKey, 
            WeightUnit, IsEmpty, DriverNotes, SchedulerNotes, IsTMF, CompleteDate, VesselETA
        FROM dbo.OrderDetail_Deleted WITH (NOLOCK) 
        WHERE OrderKey = @OrderKey;
        
        SET IDENTITY_INSERT dbo.OrderDetail OFF;

        -- Routes - Fixed with matching columns only
        SET IDENTITY_INSERT dbo.Routes ON;
        
        INSERT INTO dbo.Routes (
            RouteKey, OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, 
            PickupDateFrom, PickupDateTo, CutOffDate, DeliveryDateFrom, DeliveryDateTo, 
            AppointmentNo, ConfirmationNo, LastFreeDay, SwitchTo, PortWaitingTimeFrom, 
            PortWaitingTimeTo, CustomerWaitingTimeFrom, CustomerWaitingTimeTo, ChassisNo, 
            ChassisType, TruckNo, FromLocation, ToLocation, DestinationAddrKey, 
            EstimatedDistanceInMiles, EstimatedTravelTime, Status, DriverKey, 
            ScheduledPickupDate, ScheduledArrival, ScheduledDeparture, ActualDeparture, 
            ActualArrival, OdometerAtSource, OdometerAtDestination, DriverCommentKey, 
            SchedulerCommentKey, ChassisKey, CompanyKey, CreateUserKey, UpdateUserKey, 
            CreateDate, LastUpdateDate, LocationKey, IsEmpty, IsAbandoned, IsDryRun, 
            IsBobtail, IsDocumentVerified, IsRateVerified, DocumentVerifiedDate, 
            RateVerifiedDate, DocumentVerifiedUserKey, RateVerifiedUserKey, DelConfirmationNo, 
            isStreetTurn, StreetTurnSetUser, StreetTurnSetDate,
            IsChargesApproved, ChargesApprovedDate, ChargesApprovedBy, DryRunType,
            YardCheckIn, YardCheckOut, ChassisCategoryKey, ActualDepartureUpdateMethod,
            ActualArrivalUpdateMethod, CarrierRate, StreeTurnPrevStatusKey
        )
        SELECT 
            RouteKey, OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, 
            PickupDateFrom, PickupDateTo, CutOffDate, DeliveryDateFrom, DeliveryDateTo, 
            AppointmentNo, ConfirmationNo, LastFreeDay, SwitchTo, PortWaitingTimeFrom, 
            PortWaitingTimeTo, CustomerWaitingTimeFrom, CustomerWaitingTimeTo, ChassisNo, 
            ChassisType, TruckNo, FromLocation, ToLocation, DestinationAddrKey, 
            EstimatedDistanceInMiles, EstimatedTravelTime, Status, DriverKey, 
            ScheduledPickupDate, ScheduledArrival, ScheduledDeparture, ActualDeparture, 
            ActualArrival, OdometerAtSource, OdometerAtDestination, DriverCommentKey, 
            SchedulerCommentKey, ChassisKey, CompanyKey, CreateUserKey, UpdateUserKey, 
            CreateDate, LastUpdateDate, LocationKey, IsEmpty, IsAbandoned, IsDryRun, 
            IsBobtail, IsDocumentVerified, IsRateVerified, DocumentVerifiedDate, 
            RateVerifiedDate, DocumentVerifiedUserKey, RateVerifiedUserKey, DelConfirmationNo, 
            isStreetTurn, StreetTurnSetUser, StreetTurnSetDate,
            IsChargesApproved, ChargesApprovedDate, ChargesApprovedBy, DryRunType,
            YardCheckIn, YardCheckOut, ChassisCategoryKey, ActualDepartureUpdateMethod,
            ActualArrivalUpdateMethod, CarrierRate, StreeTurnPrevStatusKey
        FROM dbo.Routes_Deleted WITH (NOLOCK) 
        WHERE OrderDetailKey IN (
            SELECT OrderDetailKey FROM dbo.OrderDetail_Deleted WHERE OrderKey = @OrderKey
        );
        
        SET IDENTITY_INSERT dbo.Routes OFF;

        -- Comments and Documents
        INSERT INTO dbo.OrderHeaderComments (OrderKey, CommentKey)
        SELECT OrderKey, CommentKey 
        FROM dbo.OrderHeaderComments_Deleted WITH (NOLOCK) 
        WHERE OrderKey = @OrderKey;

        INSERT INTO dbo.OrderheaderDocuments (DocumentKey, OrderKey)
        SELECT DocumentKey, OrderKey 
        FROM dbo.OrderheaderDocuments_Deleted WITH (NOLOCK) 
        WHERE OrderKey = @OrderKey;

        INSERT INTO dbo.OrderDetailComments (OrderDetailKey, CommentKey)
        SELECT C.OrderDetailKey, C.CommentKey 
        FROM dbo.OrderDetailComments_Deleted C WITH (NOLOCK)
        INNER JOIN dbo.OrderDetail_Deleted D WITH (NOLOCK) ON D.OrderDetailKey = C.OrderDetailKey
        WHERE D.OrderKey = @OrderKey;

        INSERT INTO dbo.OrderDetailDocuments (OrderDetailKey, DocumentKey)
        SELECT C.OrderDetailKey, C.DocumentKey 
        FROM dbo.OrderDetailDocuments_Deleted C WITH (NOLOCK)
        INNER JOIN dbo.OrderDetail_Deleted D WITH (NOLOCK) ON D.OrderDetailKey = C.OrderDetailKey
        WHERE D.OrderKey = @OrderKey;
        
        -- Delete from _Deleted tables in correct order
        DELETE FROM dbo.Order_Delete WHERE OrderKey = @OrderKey;
        
        DELETE FROM dbo.OrderDetailComments_Deleted
        WHERE OrderDetailKey IN (
            SELECT OrderDetailKey FROM dbo.OrderDetail_Deleted WHERE OrderKey = @OrderKey
        );

        DELETE FROM dbo.OrderDetailDocuments_Deleted
        WHERE OrderDetailKey IN (
            SELECT OrderDetailKey FROM dbo.OrderDetail_Deleted WHERE OrderKey = @OrderKey
        );
        
        DELETE FROM dbo.Routes_Deleted 
        WHERE OrderDetailKey IN (
            SELECT OrderDetailKey FROM dbo.OrderDetail_Deleted WHERE OrderKey = @OrderKey
        );

        DELETE FROM dbo.OrderHeaderComments_Deleted WHERE OrderKey = @OrderKey;
        DELETE FROM dbo.OrderheaderDocuments_Deleted WHERE OrderKey = @OrderKey;
        DELETE FROM dbo.OrderDetail_Deleted WHERE OrderKey = @OrderKey;
        DELETE FROM dbo.OrderHeader_Deleted WHERE OrderKey = @OrderKey;
        
        COMMIT TRANSACTION;
        
        SET @Status = 1;
        SET @Reason = 'Order retrieved successfully';

        IF (@IsDebug = 1)
            PRINT 'Transaction committed successfully';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Safely turn off IDENTITY_INSERT
        BEGIN TRY SET IDENTITY_INSERT dbo.OrderHeader OFF; END TRY BEGIN CATCH END CATCH;
        BEGIN TRY SET IDENTITY_INSERT dbo.OrderDetail OFF; END TRY BEGIN CATCH END CATCH;
        BEGIN TRY SET IDENTITY_INSERT dbo.Routes OFF; END TRY BEGIN CATCH END CATCH;
        
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();

        --SELECT   
        --    ERROR_NUMBER() AS ErrorNumber,
        --    ERROR_SEVERITY() AS ErrorSeverity,
        --    ERROR_STATE() AS ErrorState,
        --    ERROR_PROCEDURE() AS ErrorProcedure,
        --    ERROR_LINE() AS ErrorLine,
        --    ERROR_MESSAGE() AS ErrorMessage;

        IF (@IsDebug = 1)
            PRINT 'Transaction rolled back due to error';
    END CATCH
END;