/*
    DECLARE 
        @UserKey        INT,
        @JSONString     NVARCHAR(MAX)='{"DriverKeys":"","OrderKeys":"","OrderNo":"","ContainerNo":"","VoucherNo":"","VoucherKeys":"","DriverHubKeys":"","WeekNum":"","MarketLocationKeys":"","TruckTypeKeys":"","CarrierMoveTypeKeys":"","SearchText":"","SortField":"ActualDeparture","IsAscending":true,"PageSize":50,"PageNo":1,"StatusKey":9,"SearchCriteriaKey":0,"IsDriverPay":false,"DeliveryDateFrom":"2026-01-31T18:30:00.000Z","DeliveryDateTo":"2026-02-27T18:30:00.000Z"}',
        @Status         BIT = 0 ,
        @Reason         VARCHAR(1000) = '',
        @IsDebug        BIT = 1

    EXEC Get_VoucherList_V3 @UserKey,@JSONString,@Status output,@Reason output,@IsDebug
    SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_VoucherList_V3]
(
    @UserKey        INT,
    @JSONString     NVARCHAR(MAX),
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
WITH RECOMPILE
AS
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT ON;

    IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameters not found';
        RETURN;
    END

    DECLARE 
        @StatusKey INT = 0, 
        @DriverKeys VARCHAR(MAX) = '', 
        @OrderKeys VARCHAR(MAX) = '',
        @OrderDateFrom DATE = '2025-07-01', 
        @OrderDateTo DATE = '2099-12-31',
        @DeliveryDateFrom DATE = '2025-07-01', 
        @DeliveryDateTo DATE = '2099-12-31',
        @OrderNo VARCHAR(50) = '',
        @containerNo VARCHAR(50) = '', 
        @voucherNo VARCHAR(50) = '',
        @VoucherKeys VARCHAR(MAX) = '', 
        @DriverHubkeys VARCHAR(MAX) = '', 
        @WeekNum VARCHAR(5) = '',
        @marketLocationKeys VARCHAR(MAX) = '', 
        @TruckTypeKeys VARCHAR(MAX) = '',
        @CarrierMoveTypeKeys VARCHAR(MAX) = '', 
        @PageNo INT, @PageSize INT,
        @SearchText NVARCHAR(MAX), 
        @SortField VARCHAR(50), 
        @IsAscending BIT = 1,
        @isDriverPay BIT = 0, 
        @SearchCriteriaKey INT = 0, 
        @IsWithFilter BIT = 0,
        @IsSearchActive BIT = 0, 
        @OpenStatusKey SMALLINT = 0;

    SELECT  
        @containerNo        = ISNULL(ContainerNo, ''), 
        @StatusKey          = StatusKey,
        @DriverKeys         = DriverKeys, 
        @OrderKeys          = OrderKeys,
        @OrderDateFrom      = OrderDateFrom, 
        @OrderDateTo        = OrderDateTo,
        @DeliveryDateFrom   = DeliveryDateFrom, 
        @DeliveryDateTo     = DeliveryDateTo,
        @OrderNo            = OrderNo, 
        @voucherNo          = voucherNo, 
        @VoucherKeys        = VoucherKeys,
        @DriverHubkeys      = DriverHubkeys, 
        @WeekNum            = WeekNum,
        @MarketLocationKeys = MarketLocationKeys, 
        @TruckTypeKeys      = TruckTypeKeys,
        @CarrierMoveTypeKeys= CarrierMoveTypeKeys, 
        @PageNo             = PageNo, 
        @PageSize           = PageSize,
        @SearchText         = LTRIM(RTRIM(ISNULL(SearchText, ''))), 
        @SortField          = SortField,
        @IsAscending        = ISNULL(IsAscending, 1), 
        @isDriverPay        = isDriverPay,
        @SearchCriteriaKey  = SearchCriteriaKey
    FROM OPENJSON(@JsonString, '$')
    WITH (
        ContainerNo         VARCHAR(20)     '$.ContainerNo', 
        StatusKey           INT             '$.StatusKey',
        DriverKeys          VARCHAR(MAX)    '$.DriverKeys', 
        OrderKeys           VARCHAR(MAX)    '$.OrderKeys',
        OrderDateFrom       DATE            '$.OrderDateFrom', 
        OrderDateTo         DATE            '$.OrderDateTo',
        DeliveryDateFrom    DATE            '$.DeliveryDateFrom', 
        DeliveryDateTo      DATE            '$.DeliveryDateTo',
        OrderNo             VARCHAR(50)     '$.OrderNo', 
        voucherNo           VARCHAR(50)     '$.VoucherNo',
        VoucherKeys         VARCHAR(MAX)    '$.VoucherKeys', 
        DriverHubkeys       VARCHAR(MAX)    '$.DriverHubKeys',
        WeekNum             VARCHAR(5)      '$.WeekNum', 
        MarketLocationKeys  VARCHAR(MAX)    '$.MarketLocationKeys',
        TruckTypeKeys       VARCHAR(MAX)    '$.TruckTypeKeys', 
        CarrierMoveTypeKeys VARCHAR(MAX)    '$.CarrierMoveTypeKeys',
        PageNo              INT             '$.PageNo', 
        PageSize            INT             '$.PageSize', 
        SearchText          NVARCHAR(MAX)   '$.SearchText',
        SortField           VARCHAR(50)     '$.SortField', 
        IsAscending         BIT             '$.IsAscending',
        isDriverPay         BIT             '$.IsDriverPay', 
        SearchCriteriaKey   INT             '$.SearchCriteriaKey'
    );

    IF ISNULL(@voucherNo, '') <> '' OR ISNULL(@containerNo, '') <> '' 
       OR ISNULL(@OrderNo, '') <> '' OR ISNULL(@SearchText, '') <> ''
        SET @IsWithFilter = 1;

    IF @OrderDateFrom = '' OR @OrderDateFrom IS NULL OR @OrderDateFrom IN ('0001-01-01', '1900-01-01')
        SET @OrderDateFrom = CASE WHEN @IsWithFilter = 0 THEN DATEADD(DAY, -180, GETDATE()) ELSE DATEADD(DAY, -280, GETDATE()) END;
    IF @OrderDateTo = '' OR @OrderDateTo IS NULL OR @OrderDateTo IN ('0001-01-01', '1900-01-01')
        SET @OrderDateTo = '2050-12-31';
    IF @DeliveryDateFrom = '' OR @DeliveryDateFrom IS NULL OR @DeliveryDateFrom IN ('0001-01-01', '1900-01-01')
        SET @DeliveryDateFrom = CASE WHEN @IsWithFilter = 0 THEN DATEADD(DAY, -180, GETDATE()) ELSE DATEADD(DAY, -280, GETDATE()) END;
    IF @DeliveryDateTo = '' OR @DeliveryDateTo IS NULL OR @DeliveryDateTo IN ('0001-01-01', '1900-01-01')
        SET @DeliveryDateTo = '2050-12-31';

    IF(@IsDebug = 1)
    BEGIN
        SELECT
            @StatusKey           AS '@StatusKey',
            @DriverKeys          AS '@DriverKeys',
            @OrderKeys           AS '@OrderKeys',
            @OrderDateFrom       AS '@OrderDateFrom',
            @OrderDateTo         AS '@OrderDateTo',
            @DeliveryDateFrom    AS '@DeliveryDateFrom',
            @DeliveryDateTo      AS '@DeliveryDateTo',
            @OrderNo             AS '@OrderNo',
            @containerNo         AS '@containerNo',
            @voucherNo           AS '@voucherNo',
            @VoucherKeys         AS '@VoucherKeys',
            @DriverHubkeys       AS '@DriverHubkeys',
            @WeekNum             AS '@WeekNum',
            @marketLocationKeys  AS '@marketLocationKeys',
            @TruckTypeKeys       AS '@TruckTypeKeys',
            @CarrierMoveTypeKeys AS '@CarrierMoveTypeKeys',
            @PageNo              AS '@PageNo',
            @PageSize            AS '@PageSize',
            @SearchText          AS '@SearchText',
            @SortField           AS '@SortField',
            @IsAscending         AS '@IsAscending',
            @isDriverPay         AS '@isDriverPay',
            @SearchCriteriaKey   AS '@SearchCriteriaKey',
            @IsWithFilter        AS '@IsWithFilter',
            @IsSearchActive      AS '@IsSearchActive',
            @OpenStatusKey       AS '@OpenStatusKey'
    END

    IF @StatusKey = 4 SET @StatusKey = 0;

    SELECT @OpenStatusKey = Status 
    FROM dbo.RouteStatus WITH (NOLOCK) 
    WHERE Description = 'Leg Completed';

    DECLARE @VoucherDateThreshold DATE = DATEADD(DAY, -180, GETDATE());

    -- ====================================================================
    -- FILTER TEMP TABLES
    -- ====================================================================
    CREATE TABLE #DriverKey         (DriverKey INT PRIMARY KEY);
    CREATE TABLE #OrderKey          (OrderKey INT PRIMARY KEY);
    CREATE TABLE #voucherKey        (VoucherKey INT PRIMARY KEY);
    CREATE TABLE #DriverHubKey      (DriverhubKey INT PRIMARY KEY);
    CREATE TABLE #MarketLocationKey (MarketLocationKey INT PRIMARY KEY);
    CREATE TABLE #TruckTypeKey      (TruckTypeKey INT PRIMARY KEY);
    CREATE TABLE #OrderDetailKeys   (OrderDetailKey INT PRIMARY KEY);

    -- ====================================================================
    -- 1. PRE-FILTER DRIVER TABLE
    -- ====================================================================
    CREATE TABLE #FilteredDrivers (
        DriverKey   INT PRIMARY KEY,
        DriverID    VARCHAR(20),
        FirstName   VARCHAR(100),
        LastName    VARCHAR(100),
        DriverHubKey INT,
        TruckTypeKey INT,
        OrgName     VARCHAR(100),
        OrgCity     VARCHAR(50),
        OrgZipCode  VARCHAR(20),
        OrgState    VARCHAR(50),
        OrgCountry  VARCHAR(50),
        INDEX IX_FD_DriverHubKey (DriverHubKey),
        INDEX IX_FD_TruckTypeKey (TruckTypeKey)
    );

    IF @IsDriverPay = 1
        INSERT INTO #FilteredDrivers
        SELECT DriverKey, DriverID, FirstName, LastName, DriverHubKey, TruckTypeKey,
               OrgName, OrgCity, OrgZipCode, OrgState, OrgCountry
        FROM dbo.Driver WITH (NOLOCK) 
        WHERE TRY_CAST(LEFT(DriverID, PATINDEX('%[^0-9]%', DriverID + 'A') - 1) AS INT) BETWEEN 700 AND 948;
    ELSE
        INSERT INTO #FilteredDrivers
        SELECT DriverKey, DriverID, FirstName, LastName, DriverHubKey, TruckTypeKey,
               OrgName, OrgCity, OrgZipCode, OrgState, OrgCountry
        FROM dbo.Driver WITH (NOLOCK) 
        WHERE TRY_CAST(LEFT(DriverID, PATINDEX('%[^0-9]%', DriverID + 'A') - 1) AS INT) NOT BETWEEN 700 AND 948;

    -- Populate filter temp tables
    IF ISNULL(@DriverKeys, '') <> ''
        INSERT INTO #DriverKey SELECT value FROM dbo.Fn_SplitParamCol(@DriverKeys);
    IF ISNULL(@OrderKeys, '') <> ''
        INSERT INTO #OrderKey SELECT value FROM dbo.Fn_SplitParamCol(@OrderKeys);
    IF ISNULL(@VoucherKeys, '') <> ''
        INSERT INTO #voucherKey SELECT value FROM dbo.Fn_SplitParamCol(@VoucherKeys);
    IF ISNULL(@DriverHubkeys, '') <> ''
        INSERT INTO #DriverHubKey SELECT value FROM dbo.Fn_SplitParamCol(@DriverHubkeys);
    IF ISNULL(@marketLocationKeys, '') <> ''
        INSERT INTO #MarketLocationKey SELECT value FROM dbo.Fn_SplitParamCol(@marketLocationKeys);
    IF ISNULL(@TruckTypeKeys, '') <> ''
        INSERT INTO #TruckTypeKey SELECT value FROM dbo.Fn_SplitParamCol(@TruckTypeKeys);

    --  CONDITION ADDED ON 22-05-2026 PER TICKET #4882
    IF (ISNULL(@DriverKeys, '') <> '' OR ISNULL(@OrderKeys, '') <> '' OR ISNULL(@VoucherKeys, '') <> '' 
        OR  ISNULL(@DriverHubkeys, '') <> '' OR ISNULL(@marketLocationKeys, '') <> '' OR ISNULL(@TruckTypeKeys, '') <> '' OR ISNULL(@WeekNum, '') <> '')
        SET @OrderDateFrom =  DATEADD(DAY, -365, GETDATE()) ;
    -- END OF CONDITION ADDED ON 22-05-2026 PER TICKET #4882

    -- Handle search text
    IF ISNULL(@SearchText, '') <> ''
    BEGIN
        SET @IsSearchActive = 1;
        DECLARE @HasComma BIT = CASE WHEN CHARINDEX(',', @SearchText) > 0 THEN 1 ELSE 0 END;

        IF @HasComma = 0
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.VoucherHeader WITH (NOLOCK) WHERE VoucherNo = @SearchText)
                INSERT INTO #VoucherKey 
                SELECT VoucherKey FROM dbo.VoucherHeader WITH (NOLOCK) WHERE VoucherNo = @SearchText;
            ELSE
            BEGIN
                INSERT INTO #OrderDetailKeys 
                SELECT OrderDetailKey FROM dbo.OrderDetail WITH (NOLOCK) WHERE ContainerNo = @SearchText;

                INSERT INTO #OrderDetailKeys 
                SELECT OD.OrderDetailKey FROM dbo.OrderDetail OD WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
                WHERE OH.OrderNo = @SearchText
                  AND NOT EXISTS (SELECT 1 FROM #OrderDetailKeys OK WHERE OK.OrderDetailKey = OD.OrderDetailKey);
            END
        END
        ELSE
        BEGIN
            IF @SearchCriteriaKey = 1
                INSERT INTO #OrderDetailKeys 
                SELECT DISTINCT OrderDetailKey FROM dbo.OrderDetail WITH (NOLOCK)
                WHERE ContainerNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.fn_splitparam(@SearchText));
            ELSE IF @SearchCriteriaKey = 2
                INSERT INTO #OrderDetailKeys 
                SELECT DISTINCT OD.OrderDetailKey FROM dbo.OrderDetail OD WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.orderKey = OH.orderKey
                WHERE OrderNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.fn_splitparam(@SearchText));
            ELSE IF @SearchCriteriaKey = 6
                INSERT INTO #voucherKey 
                SELECT DISTINCT VoucherKey FROM dbo.VoucherHeader WITH (NOLOCK)
                WHERE VoucherNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.fn_splitparam(@SearchText));
        END
    END

    IF(@IsDebug = 1)
    BEGIN
        SELECT '#OrderDetailKeys', * FROM #OrderDetailKeys;
        SELECT '#OrderKey', * FROM #OrderKey;
    END

    IF ISNULL(@WeekNum, '') <> ''
    BEGIN
        DECLARE @WeekNumInt INT  = CAST(REPLACE(@weekNum, 'WK-', '') AS INT);
        DECLARE @YearNum CHAR(4) = CAST(DATEPART(YEAR, GETDATE()) AS CHAR(4));
        SET @DeliveryDateFrom = DATEADD(WEEK, DATEDIFF(WEEK, 6, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
        SET @DeliveryDateTo   = DATEADD(WEEK, DATEDIFF(WEEK, 5, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
        SET @OrderDateFrom    = '2025-07-01';
        SET @OrderDateTo      = '2050-12-31';
    END
    ELSE IF @StatusKey = 9
    BEGIN
        SET @DeliveryDateFrom = DATEADD(DAY, -180, GETDATE());
        SET @DeliveryDateTo   = DATEADD(DAY, 5, GETDATE());
    END

    -- ====================================================================
    -- 2. PRE-FILTER ORDERHEADER TABLE
    -- ====================================================================
    CREATE TABLE #FilteredOrderHeaders (
        OrderKey         INT PRIMARY KEY,
        OrderNo          VARCHAR(50),
        OrderDate        DATE,
        BrokerRefNo      VARCHAR(50),
        MarketLocationKey INT,
        INDEX IX_FOH_MarketLocationKey (MarketLocationKey)
    );

    PRINT '@OrderKeys';         PRINT @OrderKeys;
    PRINT '@marketLocationKeys'; PRINT @marketLocationKeys;
    PRINT '@OrderDateFrom';     PRINT @OrderDateFrom;
    PRINT '@OrderDateTo';       PRINT @OrderDateTo;
    PRINT '@DeliveryDateFrom';  PRINT @DeliveryDateFrom;
    PRINT '@DeliveryDateTo';    PRINT @DeliveryDateTo;

    INSERT INTO #FilteredOrderHeaders
    SELECT OH.OrderKey, OH.OrderNo, OH.OrderDate, OH.BrokerRefNo, OH.MarketLocationKey
    FROM dbo.OrderHeader OH WITH (NOLOCK)
    WHERE (OH.OrderDate IS NULL OR OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
      AND (@OrderKeys = '' OR OH.OrderKey IN (SELECT OrderKey FROM #OrderKey))
      AND (@marketLocationKeys = '' OR OH.MarketLocationKey IN (SELECT MarketLocationKey FROM #MarketLocationKey));

    -- ====================================================================
    -- 3. PRE-FILTER ORDERDETAIL TABLE
    -- ====================================================================
    CREATE TABLE #FilteredOrderDetails (
        OrderDetailKey      INT PRIMARY KEY,
        OrderKey            INT,
        ContainerNo         VARCHAR(50),
        VesselETA           DATETIME,
        CompleteDate        DATETIME,
        IsLinked            BIT,
        LinkedContainerNo   VARCHAR(20),
        LinkedOrderDetailKey INT,
        INDEX IX_FOD_OrderKey (OrderKey)
    );

    INSERT INTO #FilteredOrderDetails
    SELECT OD.OrderDetailKey, OD.OrderKey, OD.ContainerNo, OD.VesselETA, OD.CompleteDate,
           OD.IsLinked, OD.LinkedContainerNo, OD.LinkedOrderDetailKey
    FROM dbo.OrderDetail OD WITH (NOLOCK)
    INNER JOIN #FilteredOrderHeaders FOH ON FOH.OrderKey = OD.OrderKey
    WHERE (@containerNo = '' OR OD.ContainerNo LIKE '%' + @containerNo + '%')
      AND (@IsSearchActive = 0 
           OR OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys) 
           OR EXISTS (SELECT 1 FROM #VoucherKey))
      AND OD.Status != 15;

    -- ====================================================================
    -- 4. PRE-FILTER ROUTES TABLE
    -- ====================================================================
    CREATE TABLE #FilteredRoutes (
        RouteKey           INT PRIMARY KEY,
        DriverKey          INT,
        OrderDetailKey     INT,
        LegKey             INT,
        DestinationAddrKey INT,
        ActualArrival      DATETIME,
        DeliveryDateFrom   DATETIME,
        IsDocumentVerified BIT,
        IsRateVerified     BIT,
        INDEX IX_FR_DriverKey (DriverKey),
        INDEX IX_FR_OrderDetailKey (OrderDetailKey)
    );

    INSERT INTO #FilteredRoutes
    SELECT RT.RouteKey, RT.DriverKey, RT.OrderDetailKey, RT.LegKey, RT.DestinationAddrKey,
           RT.ActualArrival, RT.DeliveryDateFrom, RT.IsDocumentVerified, RT.IsRateVerified
    FROM dbo.[Routes] RT WITH (NOLOCK)
    INNER JOIN #FilteredDrivers FD  ON FD.DriverKey = RT.DriverKey
    INNER JOIN #FilteredOrderDetails FOD ON FOD.OrderDetailKey = RT.OrderDetailKey
    WHERE RT.Status = @OpenStatusKey
      AND (@DriverKeys    = '' OR RT.DriverKey IN (SELECT DriverKey FROM #DriverKey))
      AND (@DriverHubkeys = '' OR FD.DriverHubKey IN (SELECT DriverhubKey FROM #DriverHubKey))
      AND (@TruckTypeKeys = '' OR FD.TruckTypeKey IN (SELECT TruckTypeKey FROM #TruckTypeKey));

    -- ====================================================================
    -- 5. PRE-FILTER VOUCHERHEADER TABLE
    -- ====================================================================
    CREATE TABLE #FilteredVouchers (
        VoucherKey        INT PRIMARY KEY,
        VoucherNo         VARCHAR(50),
        VoucherDate       DATETIME,
        IsPaymentApproved BIT,
        StatusKey         SMALLINT,
        IsPaid            BIT,
        PaidDate          DATETIME,
        PaidUserKey       INT
    );

    INSERT INTO #FilteredVouchers
    SELECT VH.VoucherKey, VH.VoucherNo, VH.VoucherDate, VH.IsPaymentApproved, 
           VH.StatusKey, VH.IsPaid, VH.PaidDate, VH.PaidUserKey
    FROM dbo.VoucherHeader VH WITH (NOLOCK)
    WHERE (@IsWithFilter = 1 OR VH.VoucherDate > @VoucherDateThreshold)
      AND (@IsSearchActive = 0 
           OR VH.VoucherKey IN (SELECT VoucherKey FROM #VoucherKey) 
           OR EXISTS (SELECT 1 FROM #OrderDetailKeys));

    -- ====================================================================
    -- 6. PRE-FILTER ROUTEVOUCHERS TABLE
    -- ====================================================================
    CREATE TABLE #FilteredRouteVouchers (
        RouteKey   INT,
        VoucherKey INT,
        PRIMARY KEY (RouteKey, VoucherKey),
        INDEX IX_FRV_VoucherKey (VoucherKey)
    );

    INSERT INTO #FilteredRouteVouchers
    SELECT RV.RouteKey, RV.VoucherKey
    FROM dbo.RouteVouchers RV WITH (NOLOCK)
    INNER JOIN #FilteredRoutes FR   ON FR.RouteKey = RV.RouteKey
    INNER JOIN #FilteredVouchers FV ON FV.VoucherKey = RV.VoucherKey;

    -- ====================================================================
    -- 7. PRE-AGGREGATE VOUCHER VIEW DATA
    -- ====================================================================
    CREATE TABLE #VoucherAggregates (
        VoucherKey      INT PRIMARY KEY,
        VoucherAmt      NUMERIC(18,5),
        MinArrival      DATETIME,
        Week_Start_Date DATETIME,
        Week_End_Date   DATETIME,
        ContCount       INT,
        ContNo          VARCHAR(1000),
        OrdCount        INT
    );

    INSERT INTO #VoucherAggregates
    SELECT FV.VoucherKey, VMT.VoucherAmt, A.MinArrival, A.Week_Start_Date, A.Week_End_Date,
           DF.ContCount, VF.ContNo, DK.OrdCount
    FROM #FilteredVouchers FV
    LEFT JOIN dbo.vVoucherAmt           VMT ON FV.VoucherKey = VMT.VoucherKey
    LEFT JOIN dbo.vVoucherWeekNums      A   ON A.VoucherKey  = FV.VoucherKey
    LEFT JOIN dbo.vVoucherContainerCount DF ON DF.VoucherKey = FV.VoucherKey
    LEFT JOIN dbo.vVoucherContainers    VF  ON VF.VoucherKey = FV.VoucherKey
    LEFT JOIN dbo.vVoucherOrderCount    DK  ON DK.VoucherKey = FV.VoucherKey;

    -- ====================================================================
    -- 8. PRE-COMPUTE WEEK DATES
    -- ====================================================================
    CREATE TABLE #WeekDates (
        ActualArrival   DATE PRIMARY KEY,
        Week_Start_Date DATETIME,
        Week_End_Date   DATETIME
    );

    INSERT INTO #WeekDates
    SELECT DISTINCT 
        CAST(FR.ActualArrival AS DATE),
        DATEADD(DAY, 1 - DATEPART(WEEKDAY, FR.ActualArrival), CAST(FR.ActualArrival AS DATE)),
        DATEADD(DAY, 7 - DATEPART(WEEKDAY, FR.ActualArrival), CAST(FR.ActualArrival AS DATE))
    FROM #FilteredRoutes FR
    WHERE FR.ActualArrival IS NOT NULL;

    -- ====================================================================
    -- MAIN RESULTS TABLE
    -- ====================================================================
    CREATE TABLE #TEMPTABLE (
        OrderKey             INT,
        OrderDetailKey       INT,
        VoucherAmount        NUMERIC(18,5),
        RouteKey             INT,
        DestinationAddrKey   INT,
        VoucherKey           INT,
        StatusKey            SMALLINT,
        DocumentCount        INT,
        DocCounts            VARCHAR(50),
        OrderNo              VARCHAR(50),
        ContainerNo          VARCHAR(50),
        DriverId             VARCHAR(20),
        FirstName            VARCHAR(100),
        LastName             VARCHAR(100),
        VoucherNo            VARCHAR(50),
        LegTypeId            VARCHAR(100),
        Workflow             VARCHAR(100),
        DestinationCity      VARCHAR(50),
        WeekNum              VARCHAR(10),
        DriverKey            INT,
        DriverOrg            VARCHAR(100),
        BrokerRefNo          VARCHAR(50),
        VesselEta            DATETIME,
        ActualDeparture      DATETIME,
        VoucherDate          DATETIME,
        WeekStart            DATETIME,
        WeekEnd              DATETIME,
        PaidDate             DATETIME,
        CompleteDate         DATETIME,
        IsPaymentApproved    BIT,
        IsDocumentVerified   BIT,
        IsRateVerified       BIT DEFAULT 0,
        IsPaid               BIT,
        DriverHubKey         INT,
        DriverHubName        VARCHAR(100),
        MarketLocationKey    INT,
        MarketLocation       VARCHAR(200),
        PaidUserKey          INT,
        PaidUserName         VARCHAR(100),
        IsLinked             BIT DEFAULT 0,
        LinkedContainerNo    VARCHAR(20),
        LinkedOrderDetailKey INT,
        LegId                VARCHAR(100),
        LegKey               INT,
        ChargesCount         INT,
        OrgName              VARCHAR(200),
        INDEX IX_TT_VoucherKey NONCLUSTERED (VoucherKey),
        INDEX IX_TT_RouteKey   NONCLUSTERED (RouteKey)
    );

    IF(@IsDebug = 1)
    BEGIN
        SELECT '#OrderKey',              * FROM #OrderKey;
        SELECT '#MarketLocationKey',     * FROM #MarketLocationKey;
        SELECT '#FilteredDrivers',       * FROM #FilteredDrivers;
        SELECT '#FilteredOrderHeaders',  * FROM #FilteredOrderHeaders WHERE orderkey = 220608;
        SELECT '#FilteredOrderDetails',  * FROM #FilteredOrderDetails;
        SELECT '#FilteredRoutes',        * FROM #FilteredRoutes;
        SELECT '#FilteredRouteVouchers', * FROM #FilteredRouteVouchers;
        SELECT '#FilteredVouchers',      * FROM #FilteredVouchers;
        SELECT '#VoucherAggregates',     * FROM #VoucherAggregates;
        SELECT '#WeekDates',             * FROM #WeekDates;
    END

    -- ====================================================================
    -- MAIN QUERY
    -- ====================================================================
    ;WITH VoucherData AS (
        SELECT 
            CASE WHEN VA.OrdCount = 1 THEN FOH.OrderKey ELSE 0 END AS OrderKey,
            CASE WHEN VA.ContCount = 1 THEN FOD.OrderDetailKey ELSE 0 END AS OrderDetailKey,
            CASE WHEN VA.OrdCount = 1 THEN FOH.OrderNo 
                 ELSE 'Multiple Orders (' + CAST(VA.OrdCount AS VARCHAR(50)) + ')' END AS OrderNo,
            CASE WHEN VA.ContCount = 1 THEN VA.ContNo 
                 ELSE 'Multiple Containers (' + CAST(VA.ContCount AS VARCHAR(50)) + ')' END AS ContainerNo,
            ISNULL(VA.MinArrival, '2022-01-01') AS ActualDeparture,
            FD.DriverID AS DriverId,
            FD.FirstName,
            FD.LastName,
            ISNULL(FV.IsPaymentApproved, 0) AS IsPaymentApproved,
            ISNULL(FV.StatusKey, 9) AS StatusKey,
            VA.VoucherAmt AS VoucherAmount,
            0 AS RouteKey,
            NULL AS DestinationAddrKey, 
            FV.VoucherKey,
            CASE WHEN @isDriverPay = 1 
                 THEN ISNULL(DV.DriverVoucherNumber, FV.VoucherNo) 
                 ELSE FV.VoucherNo END AS VoucherNo,
            FV.VoucherDate,
            '' AS Workflow,
            '' AS LegTypeId,
            '' AS DestinationCity,
            ISNULL(CDC.DocumentCount, 0) AS DocumentCount,
            'WK-' + ISNULL(CAST(DVD.WeekNumber AS VARCHAR), CONVERT(VARCHAR, DATEPART(ISO_WEEK, VA.MinArrival))) AS WeekNum,
            FR.DriverKey,
            DH.DriverHubName,
            FR.IsDocumentVerified,
            FR.IsRateVerified,
            NULL AS CompleteDate,
            '' AS DocCounts,
            VA.Week_Start_Date AS WeekStart,
            VA.Week_End_Date   AS WeekEnd,
            FV.IsPaid,
            FV.PaidDate,
            FOH.BrokerRefNo,
            FOD.VesselETA AS VesselEta,
            CASE WHEN ISNULL(FD.OrgName, '') = '' THEN '' 
                 ELSE CONCAT(FD.OrgName, ' ', FD.OrgCity, ' ', FD.OrgZipCode, ' ', FD.OrgState, ' ', FD.OrgCountry) 
            END AS DriverOrg,
            FD.DriverHubKey,
            ML.MarketLocationKey,
            ML.MarketLocation,
            FV.PaidUserKey,
            UI.UserID AS PaidUserName, 
            FOD.IsLinked,
            UPPER(FOD.LinkedContainerNo) AS LinkedContainerNo, 
            FOD.LinkedOrderDetailKey,
            '' AS LegId,
            0 AS LegKey,
            NULL AS ChargesCount,
            FD.OrgName,
            ROW_NUMBER() OVER (PARTITION BY FV.VoucherKey ORDER BY FR.RouteKey) AS rn
        FROM #FilteredRoutes FR
        INNER JOIN #FilteredRouteVouchers FRV ON FRV.RouteKey   = FR.RouteKey
        INNER JOIN #FilteredVouchers FV       ON FV.VoucherKey  = FRV.VoucherKey
        INNER JOIN #VoucherAggregates VA       ON VA.VoucherKey  = FV.VoucherKey
        INNER JOIN #FilteredOrderDetails FOD   ON FR.OrderDetailKey = FOD.OrderDetailKey
        INNER JOIN #FilteredOrderHeaders FOH   ON FOH.OrderKey   = FOD.OrderKey
        INNER JOIN #FilteredDrivers FD         ON FD.DriverKey   = FR.DriverKey
        LEFT JOIN dbo.DriverVoucher DV   WITH (NOLOCK) ON @isDriverPay = 1 AND DV.LinkedVoucherKey = FV.VoucherKey
        LEFT JOIN dbo.UserInfo UI        WITH (NOLOCK) ON FV.PaidUserKey = UI.UserKey
        LEFT JOIN dbo.ContainerDocumentCount CDC WITH (NOLOCK) ON FOD.OrderDetailKey = CDC.OrderDetailKey
        LEFT JOIN dbo.MarketLocation ML  WITH (NOLOCK) ON FOH.MarketLocationKey = ML.MarketLocationKey
        LEFT JOIN dbo.DriverHUB DH       WITH (NOLOCK) ON FD.DriverHubKey = DH.DriverHubKey
        LEFT JOIN dbo.DriverVoucher DVD  WITH (NOLOCK) ON DVD.LinkedVoucherKey = FV.VoucherKey
    )
    INSERT INTO #TEMPTABLE (
        OrderKey, OrderDetailKey, OrderNo, ContainerNo, ActualDeparture,
        DriverId, FirstName, LastName, IsPaymentApproved, StatusKey,
        VoucherAmount, RouteKey, DestinationAddrKey, VoucherKey, VoucherNo,
        VoucherDate, Workflow, LegTypeId, DestinationCity, DocumentCount,
        WeekNum, DriverKey, DriverHubName, IsDocumentVerified, IsRateVerified,
        CompleteDate, DocCounts, WeekStart, WeekEnd, IsPaid, PaidDate,
        BrokerRefNo, VesselEta, DriverOrg, DriverHubKey, MarketLocationKey,
        MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo,
        LinkedOrderDetailKey, LegId, LegKey, ChargesCount, OrgName
    )
    SELECT 
        OrderKey, OrderDetailKey, OrderNo, ContainerNo, ActualDeparture,
        DriverId, FirstName, LastName, IsPaymentApproved, StatusKey,
        VoucherAmount, RouteKey, DestinationAddrKey, VoucherKey, VoucherNo,
        VoucherDate, Workflow, LegTypeId, DestinationCity, DocumentCount,
        WeekNum, DriverKey, DriverHubName, IsDocumentVerified, IsRateVerified,
        CompleteDate, DocCounts, WeekStart, WeekEnd, IsPaid, PaidDate,
        BrokerRefNo, VesselEta, DriverOrg, DriverHubKey, MarketLocationKey,
        MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo,
        LinkedOrderDetailKey, LegId, LegKey, ChargesCount, OrgName
    FROM VoucherData 
    WHERE rn = 1;

    -- ====================================================================
    -- PENDING VOUCHERS QUERY
    -- ====================================================================
    IF @voucherNo = ''
    BEGIN
        INSERT INTO #TEMPTABLE (
            OrderKey, OrderDetailKey, OrderNo, ContainerNo, ActualDeparture,
            DriverId, FirstName, LastName, IsPaymentApproved, StatusKey,
            VoucherAmount, RouteKey, DestinationAddrKey, VoucherKey, VoucherNo,
            VoucherDate, Workflow, LegTypeId, DestinationCity, DocumentCount,
            WeekNum, DriverKey, DriverHubName, IsDocumentVerified, IsRateVerified,
            CompleteDate, DocCounts, WeekStart, WeekEnd, IsPaid, PaidDate,
            BrokerRefNo, VesselEta, DriverOrg, DriverHubKey, MarketLocationKey,
            MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo,
            LinkedOrderDetailKey, LegId, LegKey, ChargesCount, OrgName
        )
        SELECT 
            FOH.OrderKey, FOD.OrderDetailKey, FOH.OrderNo, FOD.ContainerNo,
            FR.ActualArrival AS ActualDeparture,
            FD.DriverID AS DriverId, FD.FirstName, FD.LastName,
            0 AS IsPaymentApproved, 9 AS StatusKey,
            0 AS VoucherAmount, FR.RouteKey, FR.DestinationAddrKey,
            NULL AS VoucherKey, '' AS VoucherNo, NULL AS VoucherDate,
            L.Instruction AS Workflow, LG.LegID AS LegTypeId, DST.City AS DestinationCity, 
            ISNULL(CDC.DocumentCount, 0) AS DocumentCount,
            'WK-' + CONVERT(VARCHAR, DATEPART(ISO_WEEK, FR.ActualArrival)) AS WeekNum,
            FR.DriverKey, DH.DriverHubName,
            FR.IsDocumentVerified, 0 AS IsRateVerified, 
            FOD.CompleteDate, '' AS DocCounts,
            WD.Week_Start_Date AS WeekStart, WD.Week_End_Date AS WeekEnd, 
            0 AS IsPaid, NULL AS PaidDate,
            FOH.BrokerRefNo, FOD.VesselETA AS VesselEta,
            CASE WHEN ISNULL(FD.OrgName, '') = '' THEN '' 
                 ELSE CONCAT(FD.OrgName, ' ', FD.OrgCity, ' ', FD.OrgZipCode, ' ', FD.OrgState, ' ', FD.OrgCountry) 
            END AS DriverOrg,
            FD.DriverHubKey, ML.MarketLocationKey, ML.MarketLocation, 
            NULL AS PaidUserKey, NULL AS PaidUserName,
            FOD.IsLinked, UPPER(FOD.LinkedContainerNo) AS LinkedContainerNo, 
            FOD.LinkedOrderDetailKey, LG.LegID AS LegId, FR.LegKey,
            NULL AS ChargesCount, FD.OrgName
        FROM dbo.vPendingRoutesToVoucher PV WITH (NOLOCK)
        INNER JOIN #FilteredRoutes FR         ON PV.RouteKey = FR.RouteKey
        INNER JOIN #FilteredOrderDetails FOD  ON FR.OrderDetailKey = FOD.OrderDetailKey
        INNER JOIN #FilteredOrderHeaders FOH  ON FOH.OrderKey = FOD.OrderKey
        INNER JOIN dbo.Leg LG          WITH (NOLOCK) ON LG.LegKey = FR.LegKey
        INNER JOIN dbo.LegType L       WITH (NOLOCK) ON L.LegTypeKey = LG.LegTypeKey
        INNER JOIN #FilteredDrivers FD        ON FD.DriverKey = FR.DriverKey
        LEFT JOIN dbo.[Address] DST    WITH (NOLOCK) ON DST.AddrKey = FR.DestinationAddrKey
        LEFT JOIN dbo.ContainerDocumentCount CDC WITH (NOLOCK) ON FOD.OrderDetailKey = CDC.OrderDetailKey
        LEFT JOIN #WeekDates WD                ON WD.ActualArrival = CAST(FR.ActualArrival AS DATE)
        LEFT JOIN dbo.MarketLocation ML WITH (NOLOCK) ON FOH.MarketLocationKey = ML.MarketLocationKey
        LEFT JOIN dbo.DriverHUB DH     WITH (NOLOCK) ON FD.DriverHubKey = DH.DriverHubKey
        WHERE FR.ActualArrival IS NOT NULL
          AND (-- FR.DeliveryDateFrom IS NULL 
               -- OR FR.DeliveryDateFrom = '1900-01-01' OR
                FR.DeliveryDateFrom BETWEEN @DeliveryDateFrom AND @DeliveryDateTo)
          AND (
                @IsSearchActive = 0
                OR FOD.OrderDetailKey IN (
                    SELECT OrderDetailKey
                    FROM #OrderDetailKeys
                )
                OR EXISTS (
                    SELECT 1
                    FROM #VoucherKey VK
                    INNER JOIN dbo.RouteVouchers RV
                        ON RV.VoucherKey = VK.VoucherKey
                    WHERE RV.RouteKey = FR.RouteKey
                )
              );
    END

    -- Update charges
    UPDATE T SET 
        ChargesCount   = ISNULL(B.ChargeCount, 0),
        IsRateVerified = CASE WHEN T.StatusKey = 9 AND ISNULL(B.ChargeCount, 0) > 0 
                              THEN 1 ELSE T.IsRateVerified END
    FROM #TEMPTABLE T
    INNER JOIN (
        SELECT T2.RouteKey, COUNT(1) AS ChargeCount
        FROM #TEMPTABLE T2
        INNER JOIN dbo.OrderExpense OE WITH (NOLOCK) ON T2.RouteKey = OE.RouteKey
        INNER JOIN dbo.Item I          WITH (NOLOCK) ON OE.ItemKey  = I.ItemKey
        WHERE I.ItemTypeKey IN (4, 5) AND T2.RouteKey > 0
        GROUP BY T2.RouteKey
    ) B ON T.RouteKey = B.RouteKey;

    UPDATE #TEMPTABLE SET IsRateVerified = 0 
    WHERE StatusKey = 9 AND ChargesCount IS NULL;

    -- ====================================================================
    -- DASHBOARD  
    -- ====================================================================
    CREATE TABLE #Dashboard (StatusKey INT, StatusName VARCHAR(50), StatusCount INT);

    INSERT INTO #Dashboard 
    SELECT VS.StatusKey, VS.Description, 0 
    FROM dbo.VoucherStatus VS WITH (NOLOCK)
    UNION ALL 
    SELECT 9, 'Open', 0;

   
    UPDATE D SET StatusCount = ISNULL(T.cnt, 0) 
    FROM #Dashboard D
    LEFT JOIN (
        SELECT ISNULL(StatusKey, 9) AS StatusKey, COUNT(1) AS cnt 
        FROM #TEMPTABLE
        WHERE (@WeekNum = '' OR WeekNum = @WeekNum)
          AND (@OrderNo = '' OR OrderNo = @OrderNo)
        GROUP BY ISNULL(StatusKey, 9)
    ) T ON D.StatusKey = T.StatusKey;

    INSERT INTO #Dashboard 
    SELECT 0, 'All', ISNULL(SUM(StatusCount), 0) FROM #Dashboard;

    -- ====================================================================
    -- FINAL 
    -- ====================================================================
    SELECT 
        ISNULL(OrderKey, 0)                                     AS OrderKey, 
        ISNULL(OrderDetailKey, 0)                               AS OrderDetailKey,
        ISNULL(VoucherAmount, 0)                                AS VoucherAmount, 
        ISNULL(RouteKey, 0)                                     AS RouteKey,
        ISNULL(DestinationAddrKey, 0)                           AS DestinationAddrKey, 
        ISNULL(VoucherKey, 0)                                   AS VoucherKey,
        ISNULL(StatusKey, 0)                                    AS StatusKey, 
        ISNULL(DocumentCount, 0)                                AS DocumentCount,
        ISNULL(DocCounts, '0')                                  AS DocCounts, 
        ISNULL(OrderNo, '')                                     AS OrderNo,
        ISNULL(ContainerNo, '')                                 AS ContainerNo, 
        ISNULL(DriverId, '')                                    AS DriverID,
        ISNULL(FirstName, '')                                   AS FirstName, 
        ISNULL(LastName, '')                                    AS LastName,
        ISNULL(FirstName, '') + ' ' + ISNULL(LastName, '')      AS DriverName, 
        DriverKey,
        ISNULL(VoucherNo, '')                                   AS VoucherNo, 
        ISNULL(LegTypeId, '')                                   AS LegTypeId,
        ISNULL(Workflow, '')                                     AS Workflow, 
        ISNULL(DestinationCity, '')                             AS DestinationCity,
        ISNULL(WeekNum, '')                                     AS WeekNum, 
        ISNULL(DriverOrg, '')                                   AS DriverOrgName,
        ISNULL(BrokerRefNo, '')                                 AS BrokerRefNo, 
        ISNULL(VesselEta, '')                                   AS VesselEta,
        CONVERT(DATETIME, ISNULL(ActualDeparture, '1900-01-01')) AS ActualDeparture,
        CONVERT(DATETIME, ISNULL(VoucherDate,     '1900-01-01')) AS VoucherDate,
        CONVERT(DATETIME, ISNULL(WeekStart,       '1900-01-01')) AS WeekStart,
        CONVERT(DATETIME, ISNULL(WeekEnd,         '1900-01-01')) AS WeekEnd,
        CONVERT(DATETIME, ISNULL(PaidDate,        '1900-01-01')) AS PaidDate,
        ISNULL(IsPaymentApproved,  CONVERT(BIT, 0))             AS IsPaymentApproved,
        ISNULL(IsDocumentVerified, CONVERT(BIT, 0))             AS IsDocumentVerified,
        ISNULL(IsRateVerified,     CONVERT(BIT, 0))             AS IsRateVerified,
        ISNULL(IsPaid,             CONVERT(BIT, 0))             AS IsPaid, 
        ISNULL(DriverHubKey, 0)                                 AS DriverHubKey,
        DriverHubName, 
        ISNULL(MarketLocationKey, 0)                            AS MarketLocationKey, 
        MarketLocation,
        PaidUserKey, 
        PaidUserName, 
        IsLinked, 
        LinkedContainerNo, 
        LinkedOrderDetailKey,
        ISNULL(LegId, '')                                       AS LegId, 
        LegKey, 
        ISNULL(ChargesCount, 0)                                 AS ChargesCount, 
        OrgName
    INTO #TempPrev
    FROM #TEMPTABLE
    WHERE (@WeekNum  = '' OR WeekNum  = @WeekNum)
      AND (@StatusKey = 0 OR ISNULL(StatusKey, 9) = @StatusKey)  
      AND (@OrderNo = '' OR OrderNo = @OrderNo)

    -- ====================================================================
    -- DROPDOWN LISTS  
    -- ====================================================================
    CREATE TABLE #CarrierList (DriverKey INT, DriverName VARCHAR(20));

    IF @isDriverPay = 1
        INSERT INTO #CarrierList
        SELECT DISTINCT D.DriverKey, D.DriverID
        FROM dbo.Driver D WITH (NOLOCK)
        INNER JOIN #TempPrev TP ON TP.DriverKey = D.DriverKey
        WHERE D.DriverID <> ''
          AND TRY_CAST(LEFT(D.DriverID, PATINDEX('%[^0-9]%', D.DriverID + 'A') - 1) AS INT) BETWEEN 700 AND 948;
    ELSE
        INSERT INTO #CarrierList
        SELECT DISTINCT D.DriverKey, D.DriverID
        FROM dbo.Driver D WITH (NOLOCK)
        INNER JOIN #TempPrev TP ON TP.DriverKey = D.DriverKey
        WHERE D.DriverID <> ''
          AND TRY_CAST(LEFT(D.DriverID, PATINDEX('%[^0-9]%', D.DriverID + 'A') - 1) AS INT) NOT BETWEEN 700 AND 948;

    CREATE TABLE #DriverHubList (DriverHubKey INT, DriverHubName VARCHAR(100));

    INSERT INTO #DriverHubList
    SELECT DISTINCT DH.DriverHubKey, DH.DriverHubName
    FROM dbo.DriverHUB DH WITH (NOLOCK)
    INNER JOIN dbo.Driver D WITH (NOLOCK) ON D.DriverHubKey = DH.DriverHubKey
    WHERE DH.DriverHubName IS NOT NULL
      AND D.DriverKey IN (
          SELECT DISTINCT DriverKey 
          FROM #TempPrev 
          WHERE DriverKey IS NOT NULL AND DriverKey > 0
      );

    IF NOT EXISTS (SELECT 1 FROM #DriverHubList)
    BEGIN
        INSERT INTO #DriverHubList
        SELECT DISTINCT DriverHubKey, DriverHubName
        FROM dbo.DriverHUB WITH (NOLOCK)
        WHERE DriverHubName IS NOT NULL;
    END

    CREATE TABLE #MarketLocList (MarketLocation VARCHAR(200), MarketLocationKey INT);

    INSERT INTO #MarketLocList
    SELECT DISTINCT ML.MarketLocation, ML.MarketLocationKey
    FROM dbo.MarketLocation ML WITH (NOLOCK)
    INNER JOIN #TempPrev TP ON TP.MarketLocationKey = ML.MarketLocationKey
    WHERE ML.MarketLocation IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM #MarketLocList)
    BEGIN
        INSERT INTO #MarketLocList
        SELECT DISTINCT MarketLocation, MarketLocationKey
        FROM dbo.MarketLocation WITH (NOLOCK)
        WHERE MarketLocation IS NOT NULL;
    END

    IF(@IsDebug = 1)
    BEGIN
        SELECT DISTINCT TP.DriverKey, D.DriverID, D.DriverHubKey, DH.DriverHubName
        FROM #TempPrev TP
        INNER JOIN dbo.Driver D   WITH (NOLOCK) ON D.DriverKey   = TP.DriverKey
        LEFT JOIN  dbo.DriverHUB DH WITH (NOLOCK) ON DH.DriverHubKey = D.DriverHubKey
        ORDER BY D.DriverID;

        SELECT '#DriverHubList (full master)', * FROM dbo.DriverHUB WITH (NOLOCK);
        SELECT '#CarrierList',    * FROM #CarrierList;
        SELECT '#DriverHubList',  * FROM #DriverHubList;
        SELECT '#MarketLocList',  * FROM #MarketLocList;
    END

    -- ====================================================================
    -- SORT FIELD VALIDATION
    -- ====================================================================
    IF @SortField NOT IN (
        'OrderKey', 'OrderDetailKey', 'VoucherAmount', 'RouteKey', 'VoucherKey', 
        'StatusKey', 'OrderNo', 'ContainerNo', 'DriverId', 'FirstName', 'LastName', 
        'DriverName', 'VoucherNo', 'LegTypeId', 'WeekNum', 'ActualDeparture', 
        'VoucherDate', 'WeekStart', 'WeekEnd', 'PaidDate', 'DriverHubName', 'MarketLocation')
        SET @SortField = 'VoucherNo';

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @SortDirection NVARCHAR(4) = CASE WHEN @IsAscending = 0 THEN 'DESC' ELSE 'ASC' END;

    -- ====================================================================
    -- DYNAMIC SQL - Pagination + JSON output
    -- ====================================================================
    SET @SQL = N'
    DECLARE @RecCount INT = (SELECT COUNT(1) FROM #TempPrev);
    DECLARE @RecFrom  INT = ((@PageNo - 1) * @PageSize) + 1;
    DECLARE @RecTo    INT = @PageNo * @PageSize;

    ;WITH FinalData AS (
        SELECT 
            OrderKey, OrderDetailKey, VoucherAmount, RouteKey, DestinationAddrKey,
            VoucherKey, StatusKey, DocumentCount, DocCounts, OrderNo, ContainerNo,
            DriverID, FirstName, LastName, DriverName, DriverKey, VoucherNo,
            LegTypeId, Workflow, DestinationCity, WeekNum, DriverOrgName,
            BrokerRefNo, VesselEta, ActualDeparture, VoucherDate, WeekStart, WeekEnd,
            PaidDate, IsPaymentApproved, IsDocumentVerified, IsRateVerified, IsPaid,
            DriverHubKey, DriverHubName, MarketLocationKey, MarketLocation,
            PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey,
            LegId, LegKey, ChargesCount, OrgName,
            ROW_NUMBER() OVER (ORDER BY ' + QUOTENAME(@SortField) + N' ' + @SortDirection + N') AS RowNum 
        FROM #TempPrev
    )
    SELECT 
        VoucherList = (
            SELECT 
                OrderKey, OrderDetailKey, VoucherAmount, RouteKey, DestinationAddrKey,
                VoucherKey, StatusKey, DocumentCount, DocCounts, OrderNo, ContainerNo,
                DriverID, FirstName, LastName, DriverName, DriverKey, VoucherNo,
                LegTypeId, Workflow, DestinationCity, WeekNum, DriverOrgName,
                BrokerRefNo, VesselEta, ActualDeparture, VoucherDate, WeekStart, WeekEnd,
                PaidDate, IsPaymentApproved, IsDocumentVerified, IsRateVerified, IsPaid,
                DriverHubKey, DriverHubName, MarketLocationKey, MarketLocation,
                PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey,
                LegId, LegKey, ChargesCount, OrgName,
                RowNum,
                @RecCount AS RecCount 
            FROM FinalData 
            WHERE RowNum BETWEEN @RecFrom AND @RecTo 
            FOR JSON PATH
        ),
        DropDowns = (
            SELECT
                CarrierList = (
                    SELECT DriverKey, DriverName 
                    FROM #CarrierList 
                    ORDER BY DriverName 
                    FOR JSON PATH
                ),
                DriverHubList = (
                    SELECT DriverHubKey, DriverHubName 
                    FROM #DriverHubList 
                    ORDER BY DriverHubName 
                    FOR JSON PATH
                ),
                MarketLocList = (
                    SELECT MarketLocation, MarketLocationKey 
                    FROM #MarketLocList 
                    ORDER BY MarketLocation 
                    FOR JSON PATH
                ),
                TruckTypeList = (
                    SELECT DISTINCT TruckTypeKey, TruckType 
                    FROM dbo.TruckType WITH (NOLOCK) 
                    WHERE TruckType IS NOT NULL 
                    ORDER BY TruckType 
                    FOR JSON PATH
                ),
                MoveTypeList = (
                    SELECT DISTINCT MoveTypeKey, MoveTypeName 
                    FROM dbo.CarrierMoveType WITH (NOLOCK) 
                    WHERE MoveTypeName IS NOT NULL 
                    ORDER BY MoveTypeName 
                    FOR JSON PATH
                )
            FOR JSON PATH
        ),
        Dashboard = (
            SELECT StatusKey, StatusName, StatusCount 
            FROM #Dashboard 
            FOR JSON PATH
        )
    FOR JSON PATH;';

    EXEC sp_executesql @SQL, 
         N'@PageNo INT, @PageSize INT', 
         @PageNo  = @PageNo, 
         @PageSize = @PageSize;

    SET @Status = 1;
    SET @Reason = 'Success';
END