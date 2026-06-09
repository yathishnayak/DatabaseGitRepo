/*

DECLARE @UserKey INT, @Status INT, @Reason NVARCHAR(500), @IsDebug     BIT;

EXEC dbo.Get_DriverManifestList_V3
    @JSONString     = '{"VoucherKey": 299399}',
    @Status         = @Status OUTPUT,
    @Reason         = @Reason OUTPUT,
    @IsDebug        =  0;

SELECT @Status AS Status, @Reason AS Reason;

*/
CREATE PROCEDURE [dbo].[Get_DriverManifestList_V3]
    @UserKey     INT = 0,
    @JSONString  NVARCHAR(MAX) = '',
    @Status      BIT = 0 OUTPUT,
    @Reason      VARCHAR(1000) = '' OUTPUT,
    @IsDebug     BIT = 0
AS
BEGIN
    /*
    NOTE: STATUS KEY 0 = ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3 = Paid, 9 = PENDING TO CREATE VOUCHER
    */
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Initialize outputs
    SET @Status = 0;
    SET @Reason = '';

    BEGIN TRY
        -- Validate JSON input
        IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
        BEGIN
            SET @Reason = 'Parameters not found';
            RETURN;
        END

        IF ISJSON(@JSONString) = 0
        BEGIN
            SET @Reason = 'Invalid JSON format';
            RETURN;
        END

        -- Declare filter variables
        DECLARE @StatusKey           INT = 0,
                @DriverKeys          VARCHAR(MAX) = '',
                @OrderKeys           VARCHAR(MAX) = '',
                @OrderDateFrom       DATE = '2020-01-01',
                @OrderDateTo         DATE = '2099-12-31',
                @DeliveryDateFrom    DATE = '2020-01-01',
                @DeliveryDateTo      DATE = '2099-12-31',
                @OrderNo             VARCHAR(50) = '',
                @ContainerNo         VARCHAR(50) = '',
                @VoucherNo           VARCHAR(50) = '',
                @VoucherKeys         VARCHAR(MAX) = '',
                @DriverHubKeys       VARCHAR(MAX) = '',
                @MarketLocationKeys  VARCHAR(MAX) = '',
                @WeekNum             VARCHAR(10) = '',
                @TruckTypeKeys       VARCHAR(MAX) = '',
                @CarrierMoveTypeKeys VARCHAR(MAX) = '',
                @IsDriverPay         BIT = 0,
                @SearchText          VARCHAR(50) = '';

        -- Parse JSON parameters
        SELECT 
            @ContainerNo         = ISNULL(ContainerNo, ''),
            @StatusKey           = ISNULL(StatusKey, 0),
            @DriverKeys          = ISNULL(DriverKeys, ''),
            @OrderKeys           = ISNULL(OrderKeys, ''),
            @OrderDateFrom       = ISNULL(OrderDateFrom, '2020-01-01'),
            @OrderDateTo         = ISNULL(OrderDateTo, '2099-12-31'),
            @DeliveryDateFrom    = ISNULL(DeliveryDateFrom, '2020-01-01'),
            @DeliveryDateTo      = ISNULL(DeliveryDateTo, '2099-12-31'),
            @OrderNo             = ISNULL(OrderNo, ''),
            @VoucherNo           = ISNULL(VoucherNo, ''),
            @VoucherKeys         = ISNULL(VoucherKeys, ''),
            @DriverHubKeys       = ISNULL(DriverHubKeys, ''),
            @WeekNum             = ISNULL(WeekNum, ''),
            @MarketLocationKeys  = ISNULL(MarketLocationKeys, ''),
            @TruckTypeKeys       = ISNULL(TruckTypeKeys, ''),
            @CarrierMoveTypeKeys = ISNULL(CarrierMoveTypeKeys, ''),
            @IsDriverPay         = ISNULL(IsDriverPay, 0),
            @SearchText          = LTRIM(RTRIM(ISNULL(SearchText, '')))
        FROM OPENJSON(@JSONString, '$')
        WITH (
            ContainerNo          VARCHAR(20)  '$.ContainerNo',
            StatusKey            INT          '$.StatusKey',
            DriverKeys           VARCHAR(MAX) '$.DriverKeys',
            OrderKeys            VARCHAR(MAX) '$.OrderKeys',
            OrderDateFrom        DATE         '$.OrderDateFrom',
            OrderDateTo          DATE         '$.OrderDateTo',
            DeliveryDateFrom     DATE         '$.DeliveryDateFrom',
            DeliveryDateTo       DATE         '$.DeliveryDateTo',
            OrderNo              VARCHAR(50)  '$.OrderNo',
            VoucherNo            VARCHAR(50)  '$.VoucherNo',
            VoucherKeys          VARCHAR(MAX) '$.VoucherKeys',
            DriverHubKeys        VARCHAR(MAX) '$.DriverHubkeys',
            WeekNum              VARCHAR(10)  '$.WeekNum',
            MarketLocationKeys   VARCHAR(MAX) '$.MarketLocationKeys',
            TruckTypeKeys        VARCHAR(MAX) '$.TruckTypeKeys',
            CarrierMoveTypeKeys  VARCHAR(MAX) '$.CarrierMoveTypeKeys',
            IsDriverPay          BIT          '$.IsDriverPay',
            SearchText           VARCHAR(50)  '$.SearchText'
        );

        -- Create temp tables for filter keys
        CREATE TABLE #DriverKey (DriverKey INT PRIMARY KEY);
        CREATE TABLE #OrderKey (OrderKey INT PRIMARY KEY);
        CREATE TABLE #VoucherKey (VoucherKey INT PRIMARY KEY);
        CREATE TABLE #DriverHubKey (DriverHubKey INT PRIMARY KEY);
        CREATE TABLE #MarketLocationKey (MarketLocationKey INT PRIMARY KEY);
        CREATE TABLE #TruckTypeKey (TruckTypeKey INT PRIMARY KEY);
        CREATE TABLE #CarrierMoveTypeKey (MoveTypeKey INT PRIMARY KEY);
        CREATE TABLE #IsDriverPayDriverKeys (DriverKey INT PRIMARY KEY);

        -- Populate driver pay filter
        IF @IsDriverPay = 1
            INSERT INTO #IsDriverPayDriverKeys (DriverKey)
            SELECT DriverKey 
            FROM dbo.Driver 
            WHERE TRY_CAST(LEFT(DriverID, PATINDEX('%[^0-9]%', DriverID + 'A') - 1) AS INT) BETWEEN 700 AND 948;
        ELSE
            INSERT INTO #IsDriverPayDriverKeys (DriverKey)
            SELECT DriverKey 
            FROM dbo.Driver 
            WHERE TRY_CAST(LEFT(DriverID, PATINDEX('%[^0-9]%', DriverID + 'A') - 1) AS INT) NOT BETWEEN 700 AND 948;

        -- Populate filter tables
        IF ISNULL(@DriverKeys, '') <> ''
            INSERT INTO #DriverKey (DriverKey)
            SELECT DISTINCT CAST(value AS INT) FROM dbo.Fn_SplitParamCol(@DriverKeys);

        IF ISNULL(@OrderKeys, '') <> ''
            INSERT INTO #OrderKey (OrderKey)
            SELECT DISTINCT CAST(value AS INT) FROM dbo.Fn_SplitParamCol(@OrderKeys);

        IF ISNULL(@VoucherKeys, '') <> ''
            INSERT INTO #VoucherKey (VoucherKey)
            SELECT DISTINCT CAST(value AS INT) FROM dbo.Fn_SplitParamCol(@VoucherKeys);

        IF ISNULL(@DriverHubKeys, '') <> ''
            INSERT INTO #DriverHubKey (DriverHubKey)
            SELECT DISTINCT CAST(value AS INT) FROM dbo.Fn_SplitParamCol(@DriverHubKeys);

        IF ISNULL(@MarketLocationKeys, '') <> ''
            INSERT INTO #MarketLocationKey (MarketLocationKey)
            SELECT DISTINCT CAST(value AS INT) FROM dbo.Fn_SplitParamCol(@MarketLocationKeys);

        IF ISNULL(@TruckTypeKeys, '') <> ''
            INSERT INTO #TruckTypeKey (TruckTypeKey)
            SELECT DISTINCT CAST(value AS INT) FROM dbo.Fn_SplitParamCol(@TruckTypeKeys);

        IF ISNULL(@CarrierMoveTypeKeys, '') <> ''
            INSERT INTO #CarrierMoveTypeKey (MoveTypeKey)
            SELECT DISTINCT CAST(value AS INT) FROM dbo.Fn_SplitParamCol(@CarrierMoveTypeKeys);

        -- Handle StatusKey = 4 as ALL
        IF @StatusKey = 4
            SET @StatusKey = 0;

        -- Calculate week date range if WeekNum provided
        IF ISNULL(@WeekNum, '') <> ''
        BEGIN
            DECLARE @WeekNumInt INT = TRY_CAST(REPLACE(@WeekNum, 'WK-', '') AS INT),
                    @YearNum    CHAR(4) = CAST(YEAR(GETDATE()) AS CHAR(4));

            SET @DeliveryDateFrom = DATEADD(WEEK, DATEDIFF(WEEK, 6, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
            SET @DeliveryDateTo = DATEADD(WEEK, DATEDIFF(WEEK, 5, '1/1/' + @YearNum) + (@WeekNumInt - 1), 6);
            SET @OrderDateFrom = '2020-01-01';
            SET @OrderDateTo = '2050-12-31';
        END

        -- Main manifest query
        SELECT 
            D.DriverID,
            D.FirstName AS DriverFirstName,
            D.LastName AS DriverLastName,
            VH.VoucherNo,
            VH.VoucherDate,
            SR.City AS FromLocation,
            DT.City AS ToLocation,
            OD.ContainerNo,
            I.ItemID,
            VD.ExtCost,
            VD.Qty,
            VD.UnitCost,
            ISNULL(VH.IsPaymentApproved, 0) AS IsPaymentApproved,
            ISNULL(VH.StatusKey, 9) AS StatusKey,
            VH.VoucherAmount,
            CASE WHEN ISNULL(IC.InvoiceKey, 0) = 0 THEN 0 ELSE 1 END AS IsInvoiced,
            ISNULL(IH.InvoiceNo, 'NA') AS InvoiceNo,
            IH.InvoiceDate,
            VS.Description,
            IH.InvoiceKey,
            VD.Voucherkey AS VoucherKey,
            LG.LegID,
            D.DriverKey,
            D.DrivingLicenseNo,
            D.DrivingLicenseExpiryDate,
            RT.ActualArrival,
            'WK-' + ISNULL(CAST(DATEPART(ISO_WEEK, RT.ActualArrival) AS VARCHAR), '') AS WeekNum,
            CAST(0 AS DECIMAL) AS ApDeductions,
            OD.OrderDetailKey,
            CASE 
                WHEN ISNULL(d.OrgName, '') = '' THEN ''
                ELSE CONCAT(ISNULL(d.OrgName, ''), ' ', ISNULL(d.OrgCity, ''), ' ', 
                           ISNULL(d.OrgZipCode, ''), ' ', ISNULL(d.OrgState, ''), ' ', ISNULL(d.OrgCountry, ''))
            END AS DriverOrg,
            A.Week_Start_Date AS WeekStartDate,
            A.Week_End_Date AS WeekEndDate,
            d.DriverHubKey,
            DH.DriverHubName,
            VD.DriverPay
        INTO #tmpManifest
        FROM dbo.VoucherHeader VH
        INNER JOIN dbo.VoucherDetail VD WITH (NOLOCK) ON VH.Voucherkey = VD.Voucherkey
        INNER JOIN dbo.VoucherStatus VS  WITH (NOLOCK) ON VS.StatusKey = VH.StatusKey
        INNER JOIN dbo.Routes RT WITH (NOLOCK) ON VD.RouteKey = RT.RouteKey
        INNER JOIN #IsDriverPayDriverKeys TD WITH (NOLOCK) ON TD.DriverKey = RT.DriverKey
        INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
        INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
        INNER JOIN dbo.Leg LG WITH (NOLOCK) ON LG.LegKey = RT.LegKey
        INNER JOIN dbo.Driver D WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
        INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.Status = RT.Status
        LEFT JOIN dbo.RouteVouchers RV WITH (NOLOCK) ON RV.RouteKey = RT.RouteKey AND RV.VoucherKey = VH.VoucherKey
        LEFT JOIN dbo.[Address] SR WITH (NOLOCK) ON SR.AddrKey = RT.SourceAddrKey
        LEFT JOIN dbo.[Address] DT WITH (NOLOCK) ON DT.AddrKey = RT.DestinationAddrKey
        LEFT JOIN dbo.Item I WITH (NOLOCK) ON I.ItemKey = VD.ItemKey
        LEFT JOIN dbo.InvoiceContainers IC WITH (NOLOCK) ON IC.OrderDetailsKey = OD.OrderDetailKey
        LEFT JOIN dbo.InvoiceHeader IH WITH (NOLOCK) ON IC.InvoiceKey = IH.InvoiceKey
        LEFT JOIN dbo.DriverHub DH WITH (NOLOCK) ON d.DriverHubKey = DH.DriverHubKey
        CROSS APPLY dbo.fn_getIsoWeekStartEndDates(RT.ActualArrival) A
        WHERE (@StatusKey = 0 OR ISNULL(VH.StatusKey, 9) = @StatusKey)
          AND (ISNULL(@DriverKeys, '') = '' OR RT.DriverKey IN (SELECT DriverKey FROM #DriverKey))
          AND (ISNULL(@OrderKeys, '') = '' OR OH.OrderKey IN (SELECT OrderKey FROM #OrderKey))
          AND (ISNULL(@OrderDateFrom, '') = '' OR OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
          AND (ISNULL(@DeliveryDateFrom, '') = '' OR RT.DeliveryDateFrom BETWEEN @DeliveryDateFrom AND @DeliveryDateTo)
          AND (ISNULL(@OrderNo, '') = '' OR OH.OrderNo LIKE '%' + @OrderNo + '%')
          AND (ISNULL(@ContainerNo, '') = '' OR OD.ContainerNo LIKE '%' + @ContainerNo + '%')
          AND (ISNULL(@VoucherNo, '') = '' OR ISNULL(VH.VoucherNo, 'NA') LIKE '%' + @VoucherNo + '%')
          AND (ISNULL(@SearchText, '') = '' OR 
               OH.OrderNo LIKE '%' + @SearchText + '%' OR 
               OD.ContainerNo LIKE '%' + @SearchText + '%' OR 
               ISNULL(VH.VoucherNo, 'NA') LIKE '%' + @SearchText + '%')
          AND (ISNULL(@VoucherKeys, '') = '' OR VH.VoucherKey IN (SELECT VoucherKey FROM #VoucherKey))
          AND (ISNULL(@DriverHubKeys, '') = '' OR d.DriverHubKey IN (SELECT DriverHubKey FROM #DriverHubKey))
          AND (ISNULL(@MarketLocationKeys, '') = '' OR OH.MarketLocationKey IN (SELECT MarketLocationKey FROM #MarketLocationKey))
          AND (ISNULL(@TruckTypeKeys, '') = '' OR d.TruckTypeKey IN (SELECT TruckTypeKey FROM #TruckTypeKey));

        -- Build final result with deductions
        ;WITH FinalData AS (
            SELECT 
                DriverID, DriverFirstName, DriverLastName, VoucherNo, VoucherDate,
                FromLocation, ToLocation, ContainerNo, ItemID, ExtCost, Qty, UnitCost,
                IsPaymentApproved, StatusKey, VoucherAmount, IsInvoiced, InvoiceNo, InvoiceDate,
                Description, InvoiceKey, Voucherkey AS VoucherKey, LegID, DriverKey, DrivingLicenseNo,
                DrivingLicenseExpiryDate, ActualArrival, WeekNum, ApDeductions, OrderDetailKey,
                DriverOrg, WeekStartDate, WeekEndDate, DriverHubKey, DriverHubName, DriverPay,
                9999 AS DriverID1
            FROM #tmpManifest
            
            UNION ALL
            
            SELECT DISTINCT
                M.DriverID, M.DriverFirstName, M.DriverLastName,
                DVH.DriverVoucherNumber AS VoucherNo, DVH.DriverVoucherDate AS VoucherDate,
                '' AS FromLocation, '' AS ToLocation, ISNULL(DVD.Remarks, '') AS ContainerNo,
                I.ItemID, DVD.ExtCost, DVD.Qty, DVD.UnitCost,
                M.IsPaymentApproved, M.StatusKey, DVH.DriverVoucherAmount AS VoucherAmount,
                0 AS IsInvoiced, '' AS InvoiceNo, GETDATE() AS InvoiceDate,
                DVD.Description, 0 AS InvoiceKey, '' AS VoucherKey, '' AS LegID,
                DVH.DriverKey, M.DrivingLicenseNo, M.DrivingLicenseExpiryDate,
                GETDATE() AS ActualArrival,
                'WK-' + CAST(DVH.WeekNumber AS VARCHAR) AS WeekNum,
                DVD.ExtCost AS ApDeductions, 9999 AS OrderDetailKey,
                M.DriverOrg, M.WeekStartDate, M.WeekEndDate,
                M.DriverHubKey, M.DriverHubName, '' AS DriverPay,
                9999 AS DriverID1
            FROM dbo.DriverVoucherDeduction DVH
            INNER JOIN dbo.DriverVoucherDeductionDetail DVD WITH (NOLOCK) ON DVH.DriverVoucherKey = DVD.DriverVoucherKey
            INNER JOIN dbo.Item I WITH (NOLOCK) ON DVD.ItemKey = I.ItemKey
            INNER JOIN dbo.Item MI WITH (NOLOCK) ON I.MasterItemKey = MI.ItemKey
            INNER JOIN #tmpManifest M ON 'WK-' + ISNULL(CAST(DATEPART(ISO_WEEK, DVH.DriverVoucherDate) AS VARCHAR), '') = M.WeekNum
                AND YEAR(DVH.DriverVoucherDate) = YEAR(M.VoucherDate)
                AND M.DriverKey = DVH.DriverKey
        )
        SELECT 
            DriverID, DriverFirstName, DriverLastName, VoucherNo, VoucherDate,
            FromLocation, ToLocation, ContainerNo, ItemID, ExtCost, Qty, UnitCost,
            IsPaymentApproved, StatusKey, VoucherAmount, IsInvoiced, InvoiceNo, InvoiceDate,
            Description, InvoiceKey, Voucherkey AS VoucherKey,
            CASE WHEN CHARINDEX('(', LegID) = 0 THEN LegID ELSE LEFT(LegID, CHARINDEX('(', LegID) - 1) END AS LegID,
            DriverKey, DrivingLicenseNo, DrivingLicenseExpiryDate, ActualArrival, WeekNum,
            ApDeductions, OrderDetailKey, DriverOrg, WeekStartDate, WeekEndDate,
            DriverHubKey, DriverHubName, DriverPay, DriverID1,
            CAST(0 AS INT) AS RouteKey,
            @UserKey AS UserKey,
            CAST(0 AS INT) AS VendKey
        FROM FinalData
        ORDER BY 
            CAST(SUBSTRING(WeekNum, 4, LEN(WeekNum)) AS INT),
            DriverID1,
            DriverID,
            ActualArrival,
            OrderDetailKey,
            ContainerNo,
            LegID,
            ItemID
        FOR JSON PATH;

        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();
    END CATCH
END;