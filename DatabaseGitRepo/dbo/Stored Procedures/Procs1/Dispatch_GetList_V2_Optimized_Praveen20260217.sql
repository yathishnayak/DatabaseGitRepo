-- Created by GitHub Copilot in SSMS - review carefully before executing
CREATE PROCEDURE [dbo].[Dispatch_GetList_V2_Optimized_Praveen20260217]
(    
    @UserKey        INT,
    @JSONString     NVARCHAR(MAX),
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
) 
AS    
BEGIN     
    SET NOCOUNT ON;    
    SET FMTONLY OFF;    
    SET ARITHABORT ON;    

    DECLARE
        @Weekday               CHAR(3) = '',    
        @ContainerType         VARCHAR(100) = '',   
        @PickUpDateFrom        DATE = '2020-01-01',    
        @PickUpDateTo          DATE = '2099-12-31',    
        @PickupTypeKey         SMALLINT = 0,    
        @DriverKey             INT = 0,    
        @marketLocationKey     INT = 0,    
        @searchText            NVARCHAR(MAX) = '',    
        @LegID                 VARCHAR(100) = '',    
        @CarrierStatus         INT = 0,    
        @Dispatcher            INT = 0,    
        @IsDriverApp           INT = 0,
        @SearchCriteriaKey     INT = 0,
        @StatusKey             NVARCHAR(20) = '0';

    SELECT 
        @Weekday = WeekDay, 
        @ContainerType = ContainerType,
        @PickUpDateFrom = PickupDateFrom, 
        @PickUpDateTo = PickupDateTo, 
        @PickupTypeKey = PickupTypeKey,
        @DriverKey = DriverKey, 
        @marketLocationKey = MarketLocationKey,
        @searchText = LTRIM(RTRIM(ISNULL(searchText, ''))), 
        @LegID = LegID, 
        @CarrierStatus = CarrierStatus,
        @Dispatcher = Dispatcher, 
        @IsDriverApp = IsDriverApp, 
        @SearchCriteriaKey = SearchCriteriaKey, 
        @StatusKey = StatusKey
    FROM OPENJSON(@JSONString, '$')
    WITH (
        [Weekday]           CHAR(3)         '$.Weekday',    
        ContainerType       VARCHAR(100)    '$.ContainerType',
        PickUpDateFrom      DATE            '$.PickUpDateFrom',
        PickUpDateTo        DATE            '$.PickUpDateTo',
        PickupTypeKey       SMALLINT        '$.PickupTypeKey',    
        DriverKey           INT             '$.DriverKey',
        marketLocationKey   INT             '$.MarketLocationKey',    
        searchText          NVARCHAR(MAX)   '$.SearchText',    
        LegID               VARCHAR(100)    '$.LegID',    
        CarrierStatus       INT             '$.CarrierStatus',    
        Dispatcher          INT             '$.Dispatcher',    
        IsDriverApp         INT             '$.IsDriverApp',
        SearchCriteriaKey   INT             '$.SearchCriteriaKey',
        StatusKey           NVARCHAR(20)    '$.Status'
    );
    
    -- Handle default dates
    IF @PickUpDateFrom = '0001-01-01' SET @PickUpDateFrom = '2020-01-01';
    IF @PickUpDateTo = '0001-01-02' SET @PickUpDateTo = '2050-12-31';
    
    SET @StatusKey = REPLACE(ISNULL(@StatusKey, ''), ':', '');
    IF ISNULL(@StatusKey, '') = '' SET @StatusKey = '0';

    IF @IsDebug = 1 SELECT '@searchText', @searchText;
    
    DECLARE 
        @StartDate         DATETIME = CAST(GETDATE() AS DATE),
        @EndDate           DATETIME = DATEADD(DAY, 7, CAST(GETDATE() AS DATE)),
        @PickUpFrom        VARCHAR(50),
        @HazardTypeKey     SMALLINT,
        @CompleteStatusKey INT,
        @MoveTypesString   NVARCHAR(MAX);
    
    SET @PickUpFrom = (SELECT PickUpType FROM dbo.PickUpType WITH (NOLOCK) WHERE PickupTypeKey = @PickupTypeKey);
    SELECT @HazardTypeKey = ContainerTypeKey FROM dbo.ContainerTypes WITH (NOLOCK) WHERE TypeID = 'Hazard';
    SELECT @CompleteStatusKey = [Status] FROM dbo.RouteStatus WITH (NOLOCK) WHERE Description = 'Leg Completed';

    -- Pre-compute MoveTypes string once (not per-row)
    SELECT @MoveTypesString = STUFF((
        SELECT DISTINCT ', ' + CMT.MoveTypeName
        FROM dbo.CarrierMoveType CMT WITH (NOLOCK)
        INNER JOIN dbo.Driver_MoveType DM WITH (NOLOCK) ON DM.MoveTypeKey = CMT.MoveTypeKey AND DM.IsSelected = 1
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

    IF @IsDebug = 1
    BEGIN
        SELECT '@StartDate', @StartDate, '@EndDate', @EndDate;
        SELECT '@PickUpFrom', @PickUpFrom, '@HazardTypeKey', @HazardTypeKey;
        SELECT '@MoveTypesString', @MoveTypesString;
    END    

    -- Split parameters using STRING_SPLIT (SQL 2017+) instead of custom functions
    SELECT TRIM(value) AS ContainerType INTO #ContainerType FROM STRING_SPLIT(@ContainerType, ',') WHERE TRIM(value) <> '';
    SELECT TRIM(value) AS LegKey INTO #LegKeys FROM STRING_SPLIT(@LegID, ',') WHERE TRIM(value) <> '';

    -- Container search temp table
    SELECT OrderDetailKey INTO #OrderDetailkey_Temp 
    FROM dbo.OrderDetail WITH (NOLOCK) 
    WHERE ContainerNo = ISNULL(@searchText, '-') AND ISNULL(ContainerNo, '') <> '';

    DECLARE @HasTempKeys BIT = CASE WHEN EXISTS(SELECT 1 FROM #OrderDetailkey_Temp) THEN 1 ELSE 0 END;

    IF @IsDebug = 1 SELECT '#OrderDetailkey_Temp', * FROM #OrderDetailkey_Temp;

    -- Determine valid statuses
    CREATE TABLE #OrderDetailStatus (StatusKey INT PRIMARY KEY);
    
    IF @HasTempKeys = 1
        INSERT INTO #OrderDetailStatus SELECT [Status] FROM dbo.OrderDetailStatus WITH (NOLOCK);
    ELSE
        INSERT INTO #OrderDetailStatus 
        SELECT [Status] FROM dbo.OrderDetailStatus WITH (NOLOCK)    
        WHERE Description IN ('Schedule Confirmed', 'Dispatch InProgress', 'Dispatch OnHold');

    -- Search-based order detail keys
    DECLARE @IsSearchActive BIT = CASE WHEN ISNULL(@SearchText, '') <> '' THEN 1 ELSE 0 END;
    
    CREATE TABLE #OrderDetailKeys (OrderDetailKey INT PRIMARY KEY);

    IF @IsSearchActive = 1
    BEGIN
        IF CHARINDEX(',', @SearchText) = 0
        BEGIN
            INSERT INTO #OrderDetailKeys
            SELECT DISTINCT OD.OrderDetailKey
            FROM dbo.OrderDetail OD WITH (NOLOCK)
            INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
            WHERE OH.OrderNo = @SearchText 
               OR ISNULL(OD.BookingNo, OH.BookingNo) = @SearchText
               OR OD.ContainerNo = @SearchText
               OR ISNULL(OD.BillOfLadding, OH.BillOfLading) = @SearchText
               OR ISNULL(OD.CustRefNo, OH.BrokerRefNo) = @SearchText;
        END
        ELSE
        BEGIN
            IF @SearchCriteriaKey = 1
                INSERT INTO #OrderDetailKeys
                SELECT OrderDetailKey FROM dbo.OrderDetail WITH (NOLOCK)
                WHERE ContainerNo IN (SELECT TRIM(value) FROM STRING_SPLIT(@searchText, ','));
            ELSE IF @SearchCriteriaKey = 2
                INSERT INTO #OrderDetailKeys
                SELECT DISTINCT OD.OrderDetailKey
                FROM dbo.OrderDetail OD WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.orderKey = OH.orderKey
                WHERE OH.OrderNo IN (SELECT TRIM(value) FROM STRING_SPLIT(@searchText, ','));
            ELSE IF @SearchCriteriaKey = 3
                INSERT INTO #OrderDetailKeys
                SELECT DISTINCT OD.OrderDetailKey
                FROM dbo.OrderDetail OD WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
                WHERE ISNULL(OD.BillOfLadding, OH.BillOfLading) IN (SELECT TRIM(value) FROM STRING_SPLIT(@SearchText, ','));
            ELSE IF @SearchCriteriaKey = 5
                INSERT INTO #OrderDetailKeys
                SELECT OD.OrderDetailKey
                FROM dbo.OrderDetail OD WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
                WHERE ISNULL(OD.CustRefNo, OH.BrokerRefNo) IN (SELECT TRIM(value) FROM STRING_SPLIT(@searchText, ','));
        END
    END

    IF @IsDebug = 1 SELECT '#OrderDetailKeys', * FROM #OrderDetailKeys;

    /*=====================================================================
      STAGE 1: Build filtered OrderDetail set with ALL early filters
    =====================================================================*/
    CREATE TABLE #FilteredOrderDetails (
        OrderDetailKey INT PRIMARY KEY,
        OrderKey INT,
        OrderTypeKey SMALLINT,
        ContainerNo VARCHAR(20),
        SourceAddrKey INT,
        DestinationAddrKey INT,
        ContainerSizeKey SMALLINT,
        CurrentLegNo INT,
        TotalLegs INT,
        DropOffDate DATETIME,
        IsEmpty BIT,
        VesselETA DATETIME,
        isStreetTurn BIT,
        StreetTurnSetUser INT,
        StreetTurnSetDate DATETIME,
        IsLinked BIT,
        LinkedContainerNo VARCHAR(20),
        LinkedOrderDetailKey INT,
        TMFCheckOff BIT,
        CTFCheckOff BIT,
        IsTMFJCTPaid BIT,
        IsTMFCustomerPaid BIT,
        IsCTFJCTPaid BIT,
        IsCTFCustomerPaid BIT,
        MarkedNoEmptyAvailable BIT,
        CurrentRouteKey INT,
        [Status] INT
    );

    INSERT INTO #FilteredOrderDetails
    SELECT 
        OD.OrderDetailKey, OD.OrderKey, OD.OrderTypeKey, OD.ContainerNo,
        OD.SourceAddrKey, OD.DestinationAddrKey, OD.ContainerSizeKey,
        OD.CurrentLegNo, OD.TotalLegs, OD.DropOffDate, OD.IsEmpty,
        OD.VesselETA, OD.isStreetTurn, OD.StreetTurnSetUser, OD.StreetTurnSetDate,
        OD.IsLinked, OD.LinkedContainerNo, OD.LinkedOrderDetailKey,
        OD.TMFCheckOff, OD.CTFCheckOff, OD.IsTMFJCTPaid, OD.IsTMFCustomerPaid,
        OD.IsCTFJCTPaid, OD.IsCTFCustomerPaid, OD.MarkedNoEmptyAvailable,
        OD.CurrentRouteKey, OD.[Status]
    FROM dbo.OrderDetail OD WITH (NOLOCK)
    WHERE OD.[Status] NOT IN (1, 11)
        AND OD.[Status] IN (SELECT StatusKey FROM #OrderDetailStatus)
        AND (@HasTempKeys = 0 OR OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailkey_Temp))
        AND (@IsSearchActive = 0 OR OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys))
    OPTION (RECOMPILE);  -- Selective RECOMPILE for parameter sniffing

    -- Add indexes for join performance
    CREATE NONCLUSTERED INDEX IX_FOD_OrderKey ON #FilteredOrderDetails(OrderKey);
    CREATE NONCLUSTERED INDEX IX_FOD_CurrentRouteKey ON #FilteredOrderDetails(CurrentRouteKey);

    IF @IsDebug = 1 SELECT '#FilteredOrderDetails Count', COUNT(1) FROM #FilteredOrderDetails;

    /*=====================================================================
      STAGE 2: Build filtered Routes with date range and last route
    =====================================================================*/
    CREATE TABLE #FilteredRoutes (
        OrderDetailKey INT,
        RouteKey INT,
        LAST_ROUTEKEY INT,
        LegKey INT,
        DriverKey INT,
        ChassisKey INT,
        SourceAddrkey INT,
        DestinationAddrkey INT,
        PickupDateFrom DATETIME,
        PickupDateTo DATETIME,
        DeliveryDateFrom DATETIME,
        DeliveryDateTo DATETIME,
        ScheduledPickupDate DATETIME,
        ScheduledArrival DATETIME,
        [Status] INT,
        CarrierAssignedBy INT,
        ActualDepartureUpdateMethod VARCHAR(50),
        ActualArrivalUpdateMethod VARCHAR(50),
        ChassisSource VARCHAR(50),
        DryRunSource VARCHAR(50),
        EmptySource VARCHAR(50),
        BobtailSource VARCHAR(50),
        StreetTurnSource VARCHAR(50),
        PRIMARY KEY (OrderDetailKey, RouteKey)
    );

    INSERT INTO #FilteredRoutes
    SELECT 
        RT.OrderDetailKey, RT.RouteKey, RTM.LAST_ROUTEKEY,
        RT.LegKey, RT.DriverKey, RT.ChassisKey,
        RT.SourceAddrkey, RT.DestinationAddrkey,
        RT.PickupDateFrom, RT.PickupDateTo, RT.DeliveryDateFrom, RT.DeliveryDateTo,
        RT.ScheduledPickupDate, RT.ScheduledArrival, RT.[Status], RT.CarrierAssignedBy,
        RT.ActualDepartureUpdateMethod, RT.ActualArrivalUpdateMethod,
        RT.ChassisSource, RT.DryRunSource, RT.EmptySource, RT.BobtailSource, RT.StreetTurnSource
    FROM dbo.Routes RT WITH (NOLOCK)
    INNER JOIN #FilteredOrderDetails FOD ON FOD.OrderDetailKey = RT.OrderDetailKey
    INNER JOIN (
        SELECT R2.OrderDetailKey, MAX(R2.RouteKey) AS LAST_ROUTEKEY 
        FROM dbo.Routes R2 WITH (NOLOCK)
        INNER JOIN #FilteredOrderDetails FOD2 ON FOD2.OrderDetailKey = R2.OrderDetailKey
        GROUP BY R2.OrderDetailKey
    ) RTM ON RTM.OrderDetailKey = RT.OrderDetailKey AND RT.RouteKey = RTM.LAST_ROUTEKEY
    WHERE (@PickUpDateFrom IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom >= @PickUpDateFrom)
        AND (@PickUpDateTo IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom <= @PickUpDateTo)
        AND (ISNULL(@DriverKey, 0) = 0 OR RT.DriverKey = @DriverKey)
        AND (ISNULL(@Dispatcher, 0) = 0 OR RT.CarrierAssignedBy = @Dispatcher);

    CREATE NONCLUSTERED INDEX IX_FR_LegKey ON #FilteredRoutes(LegKey);

    IF @IsDebug = 1 SELECT '#FilteredRoutes Count', COUNT(1) FROM #FilteredRoutes;

    /*=====================================================================
      STAGE 3: Pre-compute PortDropLegCount (eliminates correlated subquery)
    =====================================================================*/
    SELECT 
        FOD.OrderDetailKey,
        COUNT(RT.LegKey) AS PortDropLegCount
    INTO #PortDropCounts
    FROM #FilteredOrderDetails FOD
    LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey = FOD.OrderDetailKey
        AND RT.LegKey IN (35, 37, 39, 52, 54, 56)
    GROUP BY FOD.OrderDetailKey;

    CREATE NONCLUSTERED INDEX IX_PDC ON #PortDropCounts(OrderDetailKey);

    /*=====================================================================
      STAGE 4: Pre-compute Carrier Status (eliminates inline subquery)
    =====================================================================*/
    SELECT 
        ODI.OrderDetailKey,
        CASE 
            WHEN DRA.Description = 'Reject' AND ISNULL(RTI.DriverKey, 0) = 0 THEN 1
            WHEN RTI.[Status] IN (2, 3) THEN 2
            WHEN RTI.[Status] = 4 THEN 3
            WHEN RTI.[Status] = 1 THEN 4
            WHEN DRA.Description = 'Accept' THEN 5
            ELSE 0
        END AS RouteStatus
    INTO #CarrierStatus
    FROM #FilteredOrderDetails ODI
    LEFT JOIN dbo.Routes RTI WITH (NOLOCK) ON RTI.RouteKey = ODI.CurrentRouteKey
    LEFT JOIN dbo.DriverRouteAcceptance DRA WITH (NOLOCK) ON DRA.RouteKey = RTI.RouteKey;

    CREATE NONCLUSTERED INDEX IX_CS ON #CarrierStatus(OrderDetailKey);

    /*=====================================================================
      STAGE 5: Pre-compute Container_GnosisData (eliminates OUTER APPLY)
    =====================================================================*/
    SELECT 
        CGD.OrderDetailKey,
        CGD.ETA_ATAChangedByUser,
        CGD.ContainerStatusChangedByUser,
        CGD.MBLChangedByUser,
        CGD.LFDChangedByUser,
        CGD.SSLChangedByUser,
        CGD.Size_TypeChangedByUser,
        CGD.HoldChangedByUser,
        CGD.VesselChangedByUser,
        CGD.AvailableChangedByUser,
        CGD.HoldTypeChangedByUser,
        CGD.AvailableDateChangedByUser
    INTO #GnosisData
    FROM (
        SELECT 
            CGDI.OrderDetailKey,
            CGDI.ETA_ATAChangedByUser,
            CGDI.ContainerStatusChangedByUser,
            CGDI.MBLChangedByUser,
            CGDI.LFDChangedByUser,
            CGDI.SSLChangedByUser,
            CGDI.Size_TypeChangedByUser,
            CGDI.HoldChangedByUser,
            CGDI.VesselChangedByUser,
            CGDI.AvailableChangedByUser,
            CGDI.HoldTypeChangedByUser,
            CGDI.AvailableDateChangedByUser,
            ROW_NUMBER() OVER (PARTITION BY CGDI.OrderDetailKey ORDER BY (SELECT NULL)) AS rn
        FROM dbo.Container_GnosisData CGDI WITH (NOLOCK)
        INNER JOIN #FilteredOrderDetails FOD ON CGDI.OrderDetailKey = FOD.OrderDetailKey
    ) CGD
    WHERE CGD.rn = 1;

    CREATE NONCLUSTERED INDEX IX_GD ON #GnosisData(OrderDetailKey);

    /*=====================================================================
      STAGE 6: Pre-compute ReadyToRelease and ReadyToMoveComplete
               (replaces scalar UDFs with set-based logic)
    =====================================================================*/
    -- Step 6a: Route status counts per OrderDetail
    SELECT 
        FOD.OrderDetailKey,
        SUM(CASE WHEN RT.[Status] <> 5 THEN 1 ELSE 0 END) AS NonStatus5Count,
        SUM(CASE WHEN RT.[Status] <> @CompleteStatusKey THEN 1 ELSE 0 END) AS NotCompleteCount,
        SUM(CASE WHEN L.ToLocation = 'PORT' THEN 1 ELSE 0 END) AS PortLegCount,
        COUNT(RT.RouteKey) AS TotalRouteCount
    INTO #RouteCounts
    FROM #FilteredOrderDetails FOD
    LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey = FOD.OrderDetailKey
    LEFT JOIN dbo.Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
    GROUP BY FOD.OrderDetailKey;

    CREATE NONCLUSTERED INDEX IX_RC ON #RouteCounts(OrderDetailKey);

    -- Step 6b: Street turn route counts
    SELECT 
        FOD.OrderDetailKey,
        COUNT(R.RouteKey) AS StreetTurnRouteCount
    INTO #StreetTurnCounts
    FROM #FilteredOrderDetails FOD
    INNER JOIN dbo.Routes R WITH (NOLOCK) ON R.OrderDetailKey = FOD.OrderDetailKey
    WHERE FOD.isStreetTurn = 1
    GROUP BY FOD.OrderDetailKey;

    CREATE NONCLUSTERED INDEX IX_STC ON #StreetTurnCounts(OrderDetailKey);

    -- Step 6c: Compute ReadyToRelease logic (inlined from FN_IsOrderDetailComplete)
    SELECT 
        FOD.OrderDetailKey,
        CAST(
            CASE 
                WHEN RC.NonStatus5Count > 0 THEN 0
                WHEN FOD.isStreetTurn = 1 AND ISNULL(STC.StreetTurnRouteCount, 0) > 0 
                     AND RC.NotCompleteCount = 0 THEN 1
                WHEN RC.PortLegCount > 0 AND RC.NotCompleteCount = 0 THEN 1
                WHEN RC.NonStatus5Count = 0 AND RC.TotalRouteCount > 0 AND RC.NotCompleteCount = 0 THEN 1
                ELSE 0
            END AS BIT) AS ReadyToRelease,
        CAST(
            CASE 
                WHEN RC.NonStatus5Count > 0 THEN 0
                WHEN FOD.isStreetTurn = 1 AND ISNULL(STC.StreetTurnRouteCount, 0) > 0 
                     AND RC.NotCompleteCount = 0 THEN 1
                WHEN RC.TotalRouteCount > 0 AND RC.NotCompleteCount = 0 THEN 1
                ELSE 0
            END AS BIT) AS ReadyToMoveComplete
    INTO #ReadyStatus
    FROM #FilteredOrderDetails FOD
    LEFT JOIN #RouteCounts RC ON RC.OrderDetailKey = FOD.OrderDetailKey
    LEFT JOIN #StreetTurnCounts STC ON STC.OrderDetailKey = FOD.OrderDetailKey;

    CREATE NONCLUSTERED INDEX IX_RS ON #ReadyStatus(OrderDetailKey);

    /*=====================================================================
      STAGE 7: Main query using pre-computed tables
    =====================================================================*/
    SELECT 
        WeekNum = CASE 
            WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN DATEPART(WEEKDAY, RT.PickupDateFrom)
            WHEN RT.PickupDateFrom < CONVERT(DATE, @StartDate) THEN -9 
            ELSE 9 
        END,
        [WeekDay] = CASE 
            WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN LEFT(DATENAME(DW, RT.PickupDateFrom), 3)
            WHEN RT.PickupDateFrom < CONVERT(DATE, @StartDate) THEN 'PAS' 
            ELSE 'FUT' 
        END,
        CONVERT(VARCHAR(10), CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, RT.PickupDateFrom), 0) AS TIME), 0) AS ContainerPickUpTime,
        OD.ContainerNo, OT.OrderType, OD.DropOffDate,
        ISNULL(SR.AddrName, '') AS Origin,
        ISNULL(DT.AddrName, '') AS FinalDestination,
        OD.OrderDetailKey, OD.OrderKey, OH.OrderNo, CUS.CustName, RTS.Description AS StatusName,
        ISNULL(RS.ReadyToRelease, 0) AS ReadytoRelease,
        ISNULL(RS.ReadyToMoveComplete, 0) AS ReadytoMoveComplete,
        ISNULL(OH.BookingNo, '') AS BookingNo,
        ISNULL(CAdr.Address1, '') + ', ' + ISNULL(CAdr.City, '') + ', ' + 
            ISNULL(CAdr.State, '') + ', ' + ISNULL(CAdr.ZipCode, '') + ', ' + ISNULL(CAdr.Country, '') AS CustAddress,
        ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) AS OrderTypeKey,
        CONVERT(BIGINT, ISNULL(OD.CurrentLegNo, 0)) AS LegNo,
        CAST(ISNULL(OD.CurrentLegNo, 0) AS VARCHAR(50)) + ' of ' + CAST(OD.TotalLegs AS VARCHAR(50)) AS CurLeg,
        ISNULL(SRR.AddrName, '') AS FromLocation,
        ISNULL(DTR.AddrName, '') AS ToLocation,
        ISNULL(DR.DriverID + ' : ' + DR.FirstName + ' ' + ISNULL(DR.LastName, ''), '') AS DriverName,
        DR.DriverKey,
        ISNULL(RT.ScheduledPickupDate, '01-01-1900') AS ScheduledPickupDate,
        ISNULL(RT.ScheduledArrival, '01-01-1900') AS ScheduledArrival,
        RT.RouteKey,
        ISNULL(SRR.AddrName, '') AS S_AddrName, ISNULL(SRR.Address1, '') AS S_Address1,
        ISNULL(SRR.City, '') AS S_City, ISNULL(SRR.State, '') AS S_State,
        ISNULL(SRR.ZipCode, '') AS S_ZipCode, ISNULL(SRR.Country, '') AS S_Country,
        ISNULL(DTR.AddrName, '') AS D_AddrName, ISNULL(DTR.Address1, '') AS D_Address1,
        ISNULL(DTR.City, '') AS D_City, ISNULL(DTR.State, '') AS D_State,
        ISNULL(DTR.ZipCode, '') AS D_ZipCode, ISNULL(DTR.Country, '') AS D_Country,
        ISNULL(RT.PickupDateFrom, '01-01-1900') AS PickupDateFrom,
        ISNULL(RT.PickupDateTo, '01-01-1900') AS PickupDateTo,
        ISNULL(RT.DeliveryDateFrom, '01-01-1900') AS DeliveryDateFrom,
        ISNULL(RT.DeliveryDateTo, '01-01-1900') AS DeliveryDateTo,
        CASE WHEN ISNULL(HZ.TypeID, '') = '' THEN 0 ELSE 1 END AS IsHazmat,
        ISNULL(CDC.DocumentCount, 0) AS DocumentCount,
        ISNULL(OD.IsEmpty, 0) AS IsEmpty,
        ISNULL(PT.PickUpType, '') AS PickUpType,
        ISNULL(S.Description, '') AS ContainerSize,
        ISNULL(S.ContainerSizeKey, 0) AS ContainerSizeKey,
        ISNULL(OD.VesselETA, '01-01-1900') AS VesselETA,
        ISNULL(OH.BillOfLading, '') AS BillOfLading,
        '' AS ContainerType,
        OD.isStreetTurn,
        ISNULL(U2.UserName, '') AS StreetTurnSetUser,
        OD.StreetTurnSetDate, OD.IsLinked, OD.LinkedContainerNo, OD.LinkedOrderDetailKey,
        CAST(ISNULL(OD.TMFCheckOff, 0) AS BIT) AS TMFCheckOff,
        CAST(ISNULL(OD.CTFCheckOff, 0) AS BIT) AS CTFCheckOff,
        CAST(ISNULL(OD.IsTMFJCTPaid, 0) AS BIT) AS IsTMFJCTPaid,
        CAST(ISNULL(OD.IsTMFCustomerPaid, 0) AS BIT) AS IsTMFCustomerPaid,
        CAST(ISNULL(OD.IsCTFJCTPaid, 0) AS BIT) AS IsCTFJCTPaid,
        CAST(ISNULL(OD.IsCTFCustomerPaid, 0) AS BIT) AS IsCTFCustomerPaid,
        RT.[Status],
        L.LegID,
        ISNULL(RT.ScheduledPickupDate, '01-01-1900') AS ContainerTime,
        CASE 
            WHEN RT.[Status] = 2 THEN 0
            WHEN RT.ScheduledPickupDate IS NULL THEN 0
            ELSE DATEDIFF(HOUR, RT.ScheduledPickupDate, GETDATE()) 
        END AS DelayHours,
        CASE 
            WHEN RT.ScheduledPickupDate IS NULL THEN 'NA'
            WHEN DATEPART(HOUR, RT.ScheduledPickupDate) >= 18 THEN 'Night'
            WHEN DATEPART(HOUR, RT.ScheduledPickupDate) <= 2 THEN 'Night'
            ELSE 'Day' 
        END AS DayNightIndicator,
        @MoveTypesString AS MoveTypes,  -- Pre-computed once
        CASE 
            WHEN RT.ActualDepartureUpdateMethod = 'DriverApp' OR RT.ActualArrivalUpdateMethod = 'DriverApp' OR
                RT.ChassisSource = 'DriverApp' OR RT.DryRunSource = 'DriverApp' OR
                RT.EmptySource = 'DriverApp' OR RT.BobtailSource = 'DriverApp' OR
                RT.StreetTurnSource = 'DriverApp' THEN 1
            ELSE 2 
        END AS IsDriverApp,
        ML.MarketLocationKey, ML.MarketLocation, TT.TruckType, DR.TruckTypeKey,
        SL.LineName AS SteamShipLine, CH.chassisNo AS ChassisNo,
        CUS.CustID, OH.CustKey,
        CAST(ISNULL(OD.MarkedNoEmptyAvailable, 0) AS BIT) AS MarkedNoEmptyAvailable,
        ISNULL(PDC.PortDropLegCount, 0) AS PortDropLegCount,  -- From pre-computed temp table
        RT.LAST_ROUTEKEY,
        GD.ETA_ATAChangedByUser, GD.ContainerStatusChangedByUser, 
        ISNULL(GD.MBLChangedByUser, 0) AS MBLChangedByUser,
        GD.LFDChangedByUser, GD.SSLChangedByUser, GD.Size_TypeChangedByUser, 
        GD.HoldChangedByUser, GD.VesselChangedByUser,
        GD.AvailableChangedByUser, GD.HoldTypeChangedByUser, GD.AvailableDateChangedByUser
    INTO #Data
    FROM #FilteredOrderDetails OD
    INNER JOIN #FilteredRoutes RT ON RT.OrderDetailKey = OD.OrderDetailKey
    INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
    INNER JOIN dbo.Customer CUS WITH (NOLOCK) ON CUS.CustKey = OH.CustKey
    INNER JOIN dbo.OrderType OT WITH (NOLOCK) ON OT.OrderTypeKey = ISNULL(OD.OrderTypeKey, OH.OrderTypeKey)
    INNER JOIN dbo.Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
    INNER JOIN dbo.LegType LT WITH (NOLOCK) ON LT.LegtypeKey = L.LegTypeKey
    INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status] = ISNULL(RT.[Status], 1)
    LEFT JOIN dbo.[Address] CAdr WITH (NOLOCK) ON CAdr.Addrkey = OH.BillToAddrKey
    LEFT JOIN dbo.[Address] SRR WITH (NOLOCK) ON SRR.Addrkey = RT.SourceAddrkey
    LEFT JOIN dbo.[Address] DTR WITH (NOLOCK) ON DTR.Addrkey = RT.DestinationAddrkey
    LEFT JOIN dbo.[Address] SR WITH (NOLOCK) ON SR.Addrkey = OD.SourceAddrKey
    LEFT JOIN dbo.[Address] DT WITH (NOLOCK) ON DT.Addrkey = OD.DestinationAddrKey
    LEFT JOIN dbo.Driver DR WITH (NOLOCK) ON DR.DriverKey = RT.DriverKey
    LEFT JOIN dbo.Chassis CH WITH (NOLOCK) ON CH.chassisKey = RT.ChassisKey
    LEFT JOIN dbo.ContainerSize S WITH (NOLOCK) ON S.ContainerSizeKey = OD.ContainerSizeKey
    LEFT JOIN dbo.PickUpType PT WITH (NOLOCK) ON L.PickupTypeKey = PT.PickupTypeKey
    LEFT JOIN dbo.ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
    LEFT JOIN dbo.[User] U2 WITH (NOLOCK) ON OD.StreetTurnSetUser = U2.UserKey
    LEFT JOIN dbo.vContainerType HZ WITH (NOLOCK) ON HZ.OrderDetailKey = OD.OrderDetailKey 
        AND HZ.ContainerTypeKey = @HazardTypeKey
    LEFT JOIN dbo.ContainerTypesLink CTL WITH (NOLOCK) ON CTL.OrderDetailKey = OD.OrderDetailKey 
        AND CTL.IsSelected = 1
    LEFT JOIN dbo.MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey = ML.MarketLocationKey
    LEFT JOIN dbo.TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey = DR.TruckTypeKey
    LEFT JOIN dbo.SteamShipLine SL WITH (NOLOCK) ON SL.LineKey = OH.SteamShipLinekey
    LEFT JOIN #CarrierStatus CS ON CS.OrderDetailKey = OD.OrderDetailKey
    LEFT JOIN #GnosisData GD ON GD.OrderDetailKey = OD.OrderDetailKey
    LEFT JOIN #PortDropCounts PDC ON PDC.OrderDetailKey = OD.OrderDetailKey
    LEFT JOIN #ReadyStatus RS ON RS.OrderDetailKey = OD.OrderDetailKey
    WHERE (@Weekday IS NULL OR @Weekday = '' OR 
            LEFT(CASE 
                WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN UPPER(DATENAME(DW, RT.PickupDateFrom))
                WHEN RT.PickupDateFrom < @StartDate THEN 'PAS' 
                ELSE 'FUT' 
            END, 3) = @Weekday)
        AND (ISNULL(@PickupTypeKey, 0) = 0 OR L.PickupTypeKey = @PickupTypeKey)
        AND (ISNULL(@ContainerType, '') = '' OR CTL.ContainerTypeKey IN (SELECT ContainerType FROM #ContainerType))
        AND (ISNULL(@LegID, '') = '' OR RT.LegKey IN (SELECT LegKey FROM #LegKeys))
        AND (ISNULL(@marketLocationKey, 0) = 0 OR OH.MarketLocationKey = @marketLocationKey)
        AND (ISNULL(@CarrierStatus, '') = '' OR CS.RouteStatus = @CarrierStatus)
    ORDER BY ContainerTime, ScheduledPickupDate, ContainerNo;

    IF @IsDebug = 1
    BEGIN
        SELECT '#Data', COUNT(1) FROM #Data;
        SELECT * FROM #OrderDetailStatus;
    END

    -- Dashboard data using CTE
    ;WITH DashBoardCTE AS (
        SELECT A.[Description] AS StatusName, A.[Status], COUNT(F.ContainerNo) AS ContainerCount, 'I' AS [Level]
        FROM dbo.RouteStatus A WITH (NOLOCK)
        LEFT JOIN #Data F ON F.StatusName = A.Description
        GROUP BY A.[Description], A.[Status]
        UNION ALL
        SELECT 'Total Containers', 0, COUNT(ContainerNo), 'S'
        FROM #Data
    )
    SELECT D.StatusName, D.[Status], D.ContainerCount, D.[Level], ISNULL(B.OrderBy, 50) AS OrderBy
    INTO #DashBoarData
    FROM DashBoardCTE D
    LEFT JOIN dbo.RouteStatus B ON B.[Description] = D.StatusName;

    IF @IsDebug = 1
    BEGIN
        SELECT * FROM #Data
        WHERE (ISNULL(@StatusKey, 0) = 0 OR @StatusKey = [Status])
            AND (ISNULL(@IsDriverApp, 0) = 0 OR IsDriverApp = @IsDriverApp)
        ORDER BY ContainerTime, ScheduledPickupDate, ContainerNo;
    END
    ELSE
    BEGIN
        SELECT
            DispatchListResult = (
                SELECT * FROM #Data
                WHERE (ISNULL(@StatusKey, 0) = 0 OR @StatusKey = [Status])
                    AND (ISNULL(@IsDriverApp, 0) = 0 OR IsDriverApp = @IsDriverApp)
                ORDER BY ContainerTime, ScheduledPickupDate, ContainerNo
                FOR JSON AUTO
            ),
            DashBoardData = (
                SELECT A.[Status] AS StatusKey, A.StatusName AS Description,
                    A.[Level], A.OrderBy, A.ContainerCount AS DispatchCount
                FROM #DashBoarData A 
                FOR JSON AUTO
            )
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END

    -- Cleanup all temp tables
    DROP TABLE #Data;
    DROP TABLE #DashBoarData;
    DROP TABLE #OrderDetailStatus;
    DROP TABLE #OrderDetailkey_Temp;
    DROP TABLE #LegKeys;
    DROP TABLE #ContainerType;
    DROP TABLE #OrderDetailKeys;
    DROP TABLE #FilteredOrderDetails;
    DROP TABLE #FilteredRoutes;
    DROP TABLE #PortDropCounts;
    DROP TABLE #CarrierStatus;
    DROP TABLE #GnosisData;
    DROP TABLE #RouteCounts;
    DROP TABLE #StreetTurnCounts;
    DROP TABLE #ReadyStatus;

    SET @Status = 1;
    SET @Reason = 'Success';
END