/*
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"SearchCriteriaKey":0,"DriverKeys":"","OrderKeys":"","OrderNo":"","containerNo":"","voucherNo":"","VoucherKeys":"","DriverHubkeys":"","WeekNum":"WK-3","MarketLocationKeys":"","TruckTypeKeys":"","CarrierMoveTypeKeys":"","SearchText":"","SortField":"voucherno","IsAscending":true,"PageSize":50,"PageNo":1,"StatusKey":1,"isDriverPay":false}',
	@Status BIT=0, @Debug int = 0,@Reason VARCHAR(100)=''
EXec Get_VoucherList_V2_Optimized @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
Select @Status, @Reason
*/

-- Created by GitHub Copilot in SSMS - review carefully before executing
CREATE PROCEDURE [dbo].[Get_VoucherList_V2_Optimized]
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
    SET FMTONLY OFF;
    SET ARITHABORT ON;

    DECLARE 
        @StatusKey INT = 0, @DriverKeys VARCHAR(MAX) = '', @OrderKeys VARCHAR(MAX) = '',
        @OrderDateFrom DATE = '2025-07-01', @OrderDateTo DATE = '2099-12-31',
        @DeliveryDateFrom DATE = '2025-07-01', @DeliveryDateTo DATE = '2099-12-31',
        @OrderNo VARCHAR(50) = '', @containerNo VARCHAR(50) = '', @voucherNo VARCHAR(50) = '',
        @VoucherKeys VARCHAR(MAX) = '', @DriverHubkeys VARCHAR(MAX) = '', @WeekNum VARCHAR(5) = '',
        @marketLocationKeys VARCHAR(MAX) = '', @TruckTypeKeys VARCHAR(MAX) = '',
        @CarrierMoveTypeKeys VARCHAR(MAX) = '', @PageNo INT, @PageSize INT,
        @SearchText NVARCHAR(MAX), @SortField VARCHAR(50), @IsAscending BIT = 1,
        @isDriverPay BIT = 0, @SearchCriteriaKey INT = 0;

    IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
    BEGIN
        SET @Status = 0; SET @Reason = 'Parameters not found'; RETURN;
    END

    SELECT @containerNo = ISNULL(ContainerNo, ''), @StatusKey = StatusKey, @DriverKeys = DriverKeys,
        @OrderKeys = OrderKeys, @OrderDateFrom = OrderDateFrom, @OrderDateTo = OrderDateTo,
        @DeliveryDateFrom = DeliveryDateFrom, @DeliveryDateTo = DeliveryDateTo, @OrderNo = OrderNo,
        @voucherNo = voucherNo, @VoucherKeys = VoucherKeys, @DriverHubkeys = DriverHubkeys,
        @WeekNum = WeekNum, @MarketLocationKeys = MarketLocationKeys, @TruckTypeKeys = TruckTypeKeys,
        @CarrierMoveTypeKeys = CarrierMoveTypeKeys, @PageNo = PageNo, @PageSize = PageSize,
        @SearchText = LTRIM(RTRIM(ISNULL(SearchText, ''))), @SortField = SortField,
        @IsAscending = ISNULL(IsAscending, 1), @isDriverPay = isDriverPay, @SearchCriteriaKey = SearchCriteriaKey
    FROM OPENJSON(@JSONString, '$') WITH (
        ContainerNo VARCHAR(20) '$.containerNo', StatusKey INT '$.StatusKey',
        DriverKeys VARCHAR(MAX) '$.DriverKeys', OrderKeys VARCHAR(MAX) '$.OrderKeys',
        OrderDateFrom DATE '$.OrderDateFrom', OrderDateTo DATE '$.OrderDateTo',
        DeliveryDateFrom DATE '$.DeliveryDateFrom', DeliveryDateTo DATE '$.DeliveryDateTo',
        OrderNo VARCHAR(50) '$.OrderNo', voucherNo VARCHAR(50) '$.voucherNo',
        VoucherKeys VARCHAR(MAX) '$.VoucherKeys', DriverHubkeys VARCHAR(MAX) '$.DriverHubkeys',
        WeekNum VARCHAR(5) '$.WeekNum', MarketLocationKeys VARCHAR(MAX) '$.MarketLocationKeys',
        TruckTypeKeys VARCHAR(MAX) '$.TruckTypeKeys', CarrierMoveTypeKeys VARCHAR(MAX) '$.CarrierMoveTypeKeys',
        PageNo INT '$.PageNo', PageSize INT '$.PageSize', SearchText NVARCHAR(MAX) '$.SearchText',
        SortField VARCHAR(50) '$.SortField', IsAscending BIT '$.IsAscending',
        isDriverPay BIT '$.isDriverPay', SearchCriteriaKey INT '$.SearchCriteriaKey'
    );

    DECLARE @IsWithFilter BIT = 0;
    IF ISNULL(@voucherNo, '') <> '' OR ISNULL(@containerNo, '') <> '' OR ISNULL(@OrderNo, '') <> ''
        SET @IsWithFilter = 1;

    IF @OrderDateFrom IS NULL OR @OrderDateFrom IN ('0001-01-01', '1900-01-01')
        SET @OrderDateFrom = CASE WHEN @IsWithFilter = 0 THEN DATEADD(DAY, -180, GETDATE()) ELSE '2025-07-01' END;
    IF @OrderDateTo IS NULL OR @OrderDateTo IN ('0001-01-01', '1900-01-01') SET @OrderDateTo = '2050-12-31';
    IF @DeliveryDateFrom IS NULL OR @DeliveryDateFrom IN ('0001-01-01', '1900-01-01')
        SET @DeliveryDateFrom = CASE WHEN @IsWithFilter = 0 THEN DATEADD(DAY, -60, GETDATE()) ELSE '2025-07-01' END;
    IF @DeliveryDateTo IS NULL OR @DeliveryDateTo IN ('0001-01-01', '1900-01-01') SET @DeliveryDateTo = '2050-12-31';

    CREATE TABLE #DriverKey (DriverKey INT PRIMARY KEY);
    CREATE TABLE #OrderKey (OrderKey INT PRIMARY KEY);
    CREATE TABLE #VoucherKey (VoucherKey INT PRIMARY KEY);
    CREATE TABLE #DriverHubKey (DriverhubKey INT PRIMARY KEY);
    CREATE TABLE #MarketLocationKey (MarketLocationKey INT PRIMARY KEY);
    CREATE TABLE #TruckTypeKey (TruckTypeKey INT PRIMARY KEY);
    CREATE TABLE #CarrierMoveTypeKey (MoveTypeKey INT PRIMARY KEY);
    CREATE TABLE #OrderDetailKeys (OrderDetailKey INT PRIMARY KEY);

    IF ISNULL(@DriverKeys, '') <> '' INSERT INTO #DriverKey SELECT value FROM dbo.Fn_SplitParamCol(@DriverKeys);
    IF ISNULL(@OrderKeys, '') <> '' INSERT INTO #OrderKey SELECT value FROM dbo.Fn_SplitParamCol(@OrderKeys);
    IF ISNULL(@VoucherKeys, '') <> '' INSERT INTO #VoucherKey SELECT value FROM dbo.Fn_SplitParamCol(@VoucherKeys);
    IF ISNULL(@DriverHubkeys, '') <> '' INSERT INTO #DriverHubKey SELECT value FROM dbo.Fn_SplitParamCol(@DriverHubkeys);
    IF ISNULL(@marketLocationKeys, '') <> '' INSERT INTO #MarketLocationKey SELECT value FROM dbo.Fn_SplitParamCol(@marketLocationKeys);
    IF ISNULL(@TruckTypeKeys, '') <> '' INSERT INTO #TruckTypeKey SELECT value FROM dbo.Fn_SplitParamCol(@TruckTypeKeys);
    IF ISNULL(@CarrierMoveTypeKeys, '') <> '' INSERT INTO #CarrierMoveTypeKey SELECT value FROM dbo.Fn_SplitParamCol(@CarrierMoveTypeKeys);

    IF @StatusKey = 4 SET @StatusKey = 0;

    DECLARE @IsSearchActive BIT = 0;
    IF ISNULL(@SearchText, '') <> ''
    BEGIN
        SET @IsSearchActive = 1;
        DECLARE @HasComma BIT = CASE WHEN CHARINDEX(',', @SearchText) > 0 THEN 1 ELSE 0 END;
        IF @HasComma = 0
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.VoucherHeader WITH (NOLOCK) WHERE VoucherNo = @SearchText)
                INSERT INTO #VoucherKey SELECT DISTINCT VoucherKey FROM dbo.VoucherHeader WITH (NOLOCK) 
                WHERE VoucherNo = @SearchText AND NOT EXISTS (SELECT 1 FROM #VoucherKey VK WHERE VK.VoucherKey = VoucherHeader.VoucherKey);
            ELSE
            BEGIN
                INSERT INTO #OrderDetailKeys SELECT DISTINCT OrderDetailKey FROM dbo.OrderDetail WITH (NOLOCK) WHERE ContainerNo = @SearchText;
                INSERT INTO #OrderDetailKeys SELECT DISTINCT OD.OrderDetailKey FROM dbo.OrderDetail OD WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
                WHERE OH.OrderNo = @SearchText AND NOT EXISTS (SELECT 1 FROM #OrderDetailKeys OK WHERE OK.OrderDetailKey = OD.OrderDetailKey);
            END
        END
        ELSE
        BEGIN
            IF @SearchCriteriaKey = 1 INSERT INTO #OrderDetailKeys SELECT DISTINCT OrderDetailKey FROM dbo.OrderDetail WITH (NOLOCK) WHERE ContainerNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.fn_splitparam(@SearchText));
            ELSE IF @SearchCriteriaKey = 2 INSERT INTO #OrderDetailKeys SELECT DISTINCT OD.OrderDetailKey FROM dbo.OrderDetail OD WITH (NOLOCK) INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey WHERE OH.OrderNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.fn_splitparam(@SearchText));
            ELSE IF @SearchCriteriaKey = 6 INSERT INTO #VoucherKey SELECT DISTINCT VoucherKey FROM dbo.VoucherHeader WITH (NOLOCK) WHERE VoucherNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM dbo.fn_splitparam(@SearchText)) AND NOT EXISTS (SELECT 1 FROM #VoucherKey VK WHERE VK.VoucherKey = VoucherHeader.VoucherKey);
        END
    END

    IF ISNULL(@WeekNum, '') <> ''
    BEGIN
        DECLARE @datecol DATETIME = GETDATE(), @WeekNumInt INT = CONVERT(INT, REPLACE(@WeekNum, 'WK-', '')), @YearNum CHAR(4) = CAST(DATEPART(YY, GETDATE()) AS CHAR(4));
        SET @DeliveryDateFrom = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
        SET @DeliveryDateTo = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
        SET @OrderDateFrom = '2025-07-01'; SET @OrderDateTo = '2050-12-31';
    END

    DECLARE @OpenStatusKey SMALLINT = 0;
    SELECT @OpenStatusKey = Status FROM dbo.RouteStatus WITH (NOLOCK) WHERE Description = 'Leg Completed';

    CREATE TABLE #VoucherData (VoucherKey INT PRIMARY KEY, VoucherAmt NUMERIC(18,5), MinArrival DATETIME, Week_Start_Date DATETIME, Week_End_Date DATETIME, ContCount INT, ContNo VARCHAR(50), OrdCount INT, MultiOrderNo VARCHAR(50));
    --INSERT INTO #VoucherData SELECT VH.VoucherKey, VMT.VoucherAmt, A.MinArrival, A.Week_Start_Date, A.Week_End_Date, ISNULL(DF.ContCount, 1), ISNULL(VF.ContNo, ''), ISNULL(DK.OrdCount, 1), ISNULL(VD.OrderNo, '')
    --FROM dbo.VoucherHeader VH WITH (NOLOCK) LEFT JOIN dbo.vVoucherAmt VMT ON VH.VoucherKey = VMT.VoucherKey LEFT JOIN dbo.vVoucherWeekNums A ON A.VoucherKey = VH.VoucherKey LEFT JOIN dbo.vVoucherContainerCount DF ON DF.VoucherKey = VH.VoucherKey LEFT JOIN dbo.vVoucherContainers VF ON VF.VoucherKey = VH.VoucherKey LEFT JOIN dbo.vVoucherOrderCount DK ON DK.VoucherKey = VH.VoucherKey LEFT JOIN dbo.vVoucherMultiOrders VD ON VD.VoucherKey = VH.VoucherKey WHERE VH.VoucherDate > DATEADD(DAY, -90, GETDATE());

    INSERT INTO #VoucherData 
    SELECT VH.VoucherKey, VMT.VoucherAmt, A.MinArrival, A.Week_Start_Date, A.Week_End_Date, 
           ISNULL(DF.ContCount, 1), ISNULL(VF.ContNo, ''), ISNULL(DK.OrdCount, 1), 
           ISNULL(VD.OrdNo, '')  -- Fixed: was 'ordno'
    FROM dbo.VoucherHeader VH WITH (NOLOCK) 
    LEFT JOIN dbo.vVoucherAmt VMT ON VH.VoucherKey = VMT.VoucherKey 
    LEFT JOIN dbo.vVoucherWeekNums A ON A.VoucherKey = VH.VoucherKey 
    LEFT JOIN dbo.vVoucherContainerCount DF ON DF.VoucherKey = VH.VoucherKey 
    LEFT JOIN dbo.vVoucherContainers VF ON VF.VoucherKey = VH.VoucherKey 
    LEFT JOIN dbo.vVoucherOrderCount DK ON DK.VoucherKey = VH.VoucherKey 
    LEFT JOIN dbo.vVoucherMultiOrders VD ON VD.VoucherKey = VH.VoucherKey 
    WHERE VH.VoucherDate > DATEADD(DAY, -90, GETDATE());

    CREATE TABLE #TEMPTABLE (orderkey INT, orderdetailkey INT, voucheramount NUMERIC(18,5), routekey INT, destinationaddrkey INT, voucherkey INT, StatusKey SMALLINT, DocumentCount INT, DocCounts VARCHAR(50), orderno VARCHAR(50), containerno VARCHAR(50), driverid VARCHAR(20), firstname VARCHAR(100), lastname VARCHAR(100), voucherno VARCHAR(50), LegTypeID VARCHAR(100), Workflow VARCHAR(100), DestinationCity VARCHAR(50), weekNum VARCHAR(10), DriverKey INT, DriverOrg VARCHAR(100), BrokerRefNo VARCHAR(50), VesselETA DATETIME, ActualDeparture DATETIME, voucherdate DATETIME, WeekStart DATETIME, WeekEnd DATETIME, PaidDate DATETIME, CompleteDate DATETIME, ispaymentapproved BIT, IsDocumentVerified BIT, IsRateVerified BIT DEFAULT 0, IsPaid BIT, DriverHubKey INT, DriverHubName VARCHAR(100), MarketLocationKey INT, MarketLocation VARCHAR(200), PaidUserKey INT, PaidUserName VARCHAR(100), IsLinked BIT DEFAULT 0, LinkedContainerNo VARCHAR(20), LinkedOrderDetailKey INT, LegID VARCHAR(100), LegKey INT, ChargesCount INT, OrgName VARCHAR(200), INDEX IX_Status NONCLUSTERED (StatusKey), INDEX IX_VoucherKey NONCLUSTERED (voucherkey));

    -- First query: Existing vouchers
    INSERT INTO #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname, ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate, Workflow, LegTypeID, DestinationCity, DocumentCount, weekNum, DriverKey, DriverHubName, IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts, WeekStart, WeekEnd, IsPaid, PaidDate, BrokerRefNo, VesselETA, DriverOrg, DriverHubKey, MarketLocationKey, MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, LegID, Legkey, OrgName)
    SELECT DISTINCT CASE WHEN VD.OrdCount = 1 THEN OH.OrderKey ELSE 0 END, CASE WHEN VD.ContCount = 1 THEN OD.OrderDetailKey ELSE 0 END, CASE WHEN VD.OrdCount = 1 THEN OH.OrderNo ELSE 'Multiple Orders (' + CAST(VD.OrdCount AS VARCHAR(50)) + ')' END, CASE WHEN VD.ContCount = 1 THEN OD.ContainerNo ELSE 'Multiple Containers (' + CAST(VD.ContCount AS VARCHAR(50)) + ')' END, ISNULL(VD.MinArrival, '2022-01-01'), D.DriverID, D.FirstName, D.LastName, ISNULL(VH.IsPaymentApproved, 0), ISNULL(VH.Statuskey, 9), VD.VoucherAmt, 0, NULL, VH.VoucherKey, VH.VoucherNo, VH.VoucherDate, '', '', '', ISNULL(CDC.DocumentCount, 0), 'WK-' + CONVERT(VARCHAR, DATEPART(iso_week, VD.MinArrival)), RT.DriverKey, DH.DriverHubName, RT.IsDocumentVerified, RT.IsRateVerified, NULL, '', VD.Week_Start_Date, VD.Week_End_Date, VH.IsPaid, VH.PaidDate, OH.BrokerRefNo, OD.VesselETA, CASE WHEN ISNULL(D.OrgName, '') = '' THEN '' ELSE ISNULL(D.OrgName, '') + ' ' + ISNULL(D.OrgCity, '') + ' ' + ISNULL(D.OrgZipCode, '') + ' ' + ISNULL(D.OrgState, '') + ' ' + ISNULL(D.OrgCountry, '') END, D.DriverHubKey, ML.MarketLocationKey, ML.MarketLocation, VH.PaidUserKey, UI.UserID, OD.IsLinked, UPPER(OD.LinkedContainerNo), OD.LinkedOrderDetailKey, '', 0, D.OrgName
    FROM dbo.[routes] RT WITH (NOLOCK) INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailkey INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey INNER JOIN dbo.Driver D WITH (NOLOCK) ON D.DriverKey = RT.DriverKey INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.Status = RT.Status LEFT JOIN dbo.RouteVouchers RV WITH (NOLOCK) ON RV.RouteKey = RT.RouteKey LEFT JOIN dbo.VoucherHeader VH WITH (NOLOCK) ON VH.VoucherKey = RV.VoucherKey LEFT JOIN #VoucherData VD ON VD.VoucherKey = VH.VoucherKey LEFT JOIN dbo.UserInfo UI WITH (NOLOCK) ON VH.PaidUserKey = UI.UserKey LEFT JOIN dbo.ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey LEFT JOIN dbo.MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey = ML.MarketLocationKey LEFT JOIN dbo.DriverHUB DH WITH (NOLOCK) ON D.DriverHubKey = DH.DriverHubKey LEFT JOIN #OrderDetailKeys ODK ON ODK.OrderDetailKey = OD.OrderDetailKey LEFT JOIN #VoucherKey VK ON VK.VoucherKey = VH.VoucherKey
    WHERE RTS.Status = @OpenStatusKey AND VH.VoucherKey IS NOT NULL AND VH.VoucherDate > DATEADD(DAY, -90, GETDATE()) AND (ISNULL(@DriverKeys, '') = '' OR EXISTS (SELECT 1 FROM #DriverKey DK WHERE DK.DriverKey = RT.DriverKey)) AND (ISNULL(@OrderKeys, '') = '' OR EXISTS (SELECT 1 FROM #OrderKey OK WHERE OK.OrderKey = OH.OrderKey)) AND (ISNULL(@OrderDateFrom, '') = '' OR OH.OrderDate IS NULL OR OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo) AND (ISNULL(@containerNo, '') = '' OR OD.ContainerNo IS NULL OR OD.ContainerNo LIKE '%' + @containerNo + '%') AND (ISNULL(@DriverHubkeys, '') = '' OR EXISTS (SELECT 1 FROM #DriverHubKey DHK WHERE DHK.DriverhubKey = D.DriverHubKey)) AND (ISNULL(@marketLocationKeys, '') = '' OR EXISTS (SELECT 1 FROM #MarketLocationKey MLK WHERE MLK.MarketLocationKey = OH.MarketLocationKey)) AND (ISNULL(@TruckTypeKeys, '') = '' OR EXISTS (SELECT 1 FROM #TruckTypeKey TTK WHERE TTK.TruckTypeKey = D.TruckTypeKey)) AND (@IsSearchActive = 0 OR ODK.OrderDetailKey IS NOT NULL OR VK.VoucherKey IS NOT NULL);

    -- Second query: Pending vouchers
    IF ISNULL(@voucherNo, '') = ''
    BEGIN
        INSERT INTO #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname, ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate, Workflow, LegTypeID, DestinationCity, DocumentCount, weekNum, DriverKey, DriverHubName, IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts, WeekStart, WeekEnd, IsPaid, PaidDate, BrokerRefNo, VesselETA, DriverOrg, DriverHubKey, MarketLocationKey, MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, LegID, Legkey, OrgName)
        SELECT OH.OrderKey, OD.OrderDetailKey, OH.OrderNo, OD.ContainerNo, RT.ActualArrival, D.DriverID, D.FirstName, D.LastName, 0, 9, 0, RT.RouteKey, RT.DestinationAddrKey, NULL, '', NULL, L.Instruction, LG.LegID, DST.City, ISNULL(CDC.DocumentCount, 0), 'WK-' + CONVERT(VARCHAR, DATEPART(iso_week, RT.ActualArrival)), RT.DriverKey, DH.DriverHubName, RT.IsDocumentVerified, 0, OD.CompleteDate, '', A.Week_Start_Date, A.Week_End_Date, 0, NULL, OH.BrokerRefNo, OD.VesselETA, CASE WHEN ISNULL(D.OrgName, '') = '' THEN '' ELSE ISNULL(D.OrgName, '') + ' ' + ISNULL(D.OrgCity, '') + ' ' + ISNULL(D.OrgZipCode, '') + ' ' + ISNULL(D.OrgState, '') + ' ' + ISNULL(D.OrgCountry, '') END, D.DriverHubKey, ML.MarketLocationKey, ML.MarketLocation, NULL, NULL, OD.IsLinked, UPPER(OD.LinkedContainerNo), OD.LinkedOrderDetailKey, LG.LegID, RT.LegKey, D.OrgName
        FROM dbo.vPendingRoutesToVoucher PV WITH (NOLOCK) INNER JOIN dbo.[routes] RT WITH (NOLOCK) ON PV.routeKey = RT.RouteKey INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailkey INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey INNER JOIN dbo.Leg LG WITH (NOLOCK) ON LG.LegKey = RT.LegKey INNER JOIN dbo.LegType L WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey INNER JOIN dbo.Driver D WITH (NOLOCK) ON D.DriverKey = RT.DriverKey INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.Status = RT.Status AND RTS.Status = @OpenStatusKey LEFT JOIN dbo.[Address] DST WITH (NOLOCK) ON DST.AddrKey = RT.DestinationAddrKey LEFT JOIN dbo.ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey CROSS APPLY dbo.fn_getIsoWeekStartEndDates(RT.ActualArrival) A LEFT JOIN dbo.MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey = ML.MarketLocationKey LEFT JOIN dbo.DriverHUB DH WITH (NOLOCK) ON D.DriverHubKey = DH.DriverHubKey
        WHERE RT.ActualArrival IS NOT NULL AND (ISNULL(@DriverKeys, '') = '' OR EXISTS (SELECT 1 FROM #DriverKey DK WHERE DK.DriverKey = RT.DriverKey)) AND (ISNULL(@OrderKeys, '') = '' OR EXISTS (SELECT 1 FROM #OrderKey OK WHERE OK.OrderKey = OH.OrderKey)) AND (@OrderDateFrom IS NULL OR OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo) AND (@containerNo = '' OR OD.ContainerNo LIKE '%' + @containerNo + '%') AND (ISNULL(@marketLocationKeys, '') = '' OR EXISTS (SELECT 1 FROM #MarketLocationKey MLK WHERE MLK.MarketLocationKey = OH.MarketLocationKey)) AND (ISNULL(@TruckTypeKeys, '') = '' OR EXISTS (SELECT 1 FROM #TruckTypeKey TTK WHERE TTK.TruckTypeKey = D.TruckTypeKey)) AND (@IsSearchActive = 0 OR EXISTS (SELECT 1 FROM #OrderDetailKeys ODK WHERE ODK.OrderDetailKey = OD.OrderDetailKey));
    END

    UPDATE #TEMPTABLE SET IsRateVerified = 0 WHERE StatusKey = 9;

    IF @isDriverPay = 1 DELETE FROM #TEMPTABLE WHERE TRY_CAST(LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1) AS INT) NOT BETWEEN 700 AND 948;
    ELSE IF @isDriverPay = 0 DELETE FROM #TEMPTABLE WHERE TRY_CAST(LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1) AS INT) BETWEEN 700 AND 948;

    UPDATE A SET ChargesCount = ISNULL(B.ChargeCount, 0), IsRateVerified = CASE WHEN A.StatusKey = 9 THEN CASE WHEN ISNULL(B.ChargeCount, 0) > 0 THEN 1 ELSE 0 END ELSE A.IsRateVerified END
    FROM #TEMPTABLE A INNER JOIN (SELECT T.Routekey, COUNT(1) AS ChargeCount FROM #TEMPTABLE T INNER JOIN dbo.OrderExpense OE WITH (NOLOCK) ON T.Routekey = OE.Routekey INNER JOIN dbo.Item I WITH (NOLOCK) ON OE.itemkey = I.ItemKey WHERE I.ItemTypeKey IN (4, 5) GROUP BY T.Routekey) B ON A.Routekey = B.Routekey;

    -- FIX: Insert driver voucher data BEFORE pagination
    IF @isDriverPay = 1
    BEGIN
        INSERT INTO #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname, ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate, Workflow, LegTypeID, DestinationCity, DocumentCount, weekNum, DriverKey, DriverHubName, IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts, WeekStart, WeekEnd, IsPaid, PaidDate, BrokerRefNo, VesselETA, DriverOrg, DriverHubKey, MarketLocationKey, MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, LegID, Legkey, OrgName)
        SELECT 0, 0, '', DV.ContainerNo, '1900-01-01', D.DriverID, D.FirstName, D.LastName, 0, @StatusKey, ISNULL(DriverVoucherAmount, 0), 0, @StatusKey, DV.DriverVoucherKey, DriverVoucherNumber, DV.DriverVoucherdate, '', '', '', 0, 'WK-' + CONVERT(VARCHAR, DATEPART(iso_week, DV.DriverVoucherdate)), DV.DriverKey, DH.DriverHubName, 0, 0, NULL, '', '1900-01-01', '1900-01-01', 0, DV.DriverVoucherdate, '', NULL, '', D.DriverHubKey, ISNULL(D.MarketLocationKey, 0), '', DV.CreateUser, '', 0, '', 0, '', 0, D.OrgName
        FROM dbo.DriverVoucher DV WITH (NOLOCK) INNER JOIN dbo.Driver D WITH (NOLOCK) ON D.DriverKey = DV.DriverKey LEFT JOIN dbo.DriverHUB DH WITH (NOLOCK) ON DH.DriverHubKey = D.DriverHubKey
        WHERE DV.DriverVoucherdate > DATEADD(DAY, -60, GETDATE()) AND (ISNULL(@DriverKeys, '') = '' OR DV.DriverKey IN (SELECT DriverKey FROM #DriverKey)) AND (ISNULL(@WeekNum, '') = '' OR 'WK-' + CONVERT(VARCHAR, DATEPART(iso_week, DV.DriverVoucherdate)) = @WeekNum) AND (@IsSearchActive = 0 OR DV.ContainerNo IN (SELECT OD.ContainerNo FROM #OrderDetailKeys ODK INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON ODK.OrderDetailKey = OD.OrderDetailKey)) AND (@containerNo = '' OR DV.ContainerNo LIKE '%' + @containerNo + '%');
    END

    CREATE TABLE #Dashboard (StatusKey INT, StatusName VARCHAR(50), StatusCount INT);
    INSERT INTO #Dashboard SELECT VS.StatusKey, VS.Description, ISNULL(T.cnt, 0) FROM dbo.VoucherStatus VS WITH (NOLOCK) LEFT JOIN (SELECT StatusKey, COUNT(1) AS cnt FROM #TEMPTABLE GROUP BY StatusKey) T ON VS.StatusKey = T.StatusKey;
    INSERT INTO #Dashboard VALUES (9, 'Open', (SELECT COUNT(1) FROM #TEMPTABLE WHERE StatusKey = 9));
    INSERT INTO #Dashboard VALUES (0, 'All', (SELECT SUM(StatusCount) FROM #Dashboard));

    SELECT ISNULL(orderkey, 0) AS orderkey, ISNULL(orderdetailkey, 0) AS orderdetailkey, ISNULL(voucheramount, 0) AS voucheramount, ISNULL(routekey, 0) AS routekey, ISNULL(destinationaddrkey, 0) AS destinationaddrkey, ISNULL(voucherkey, 0) AS voucherkey, ISNULL(StatusKey, 0) AS StatusKey, ISNULL(DocumentCount, 0) AS DocumentCount, ISNULL(DocCounts, '0') AS DocCounts, ISNULL(orderno, '') AS orderno, ISNULL(containerno, '') AS containerno, ISNULL(driverid, '') AS driverid, ISNULL(firstname, '') AS firstname, ISNULL(lastname, '') AS lastname, ISNULL(firstname, '') + ' ' + ISNULL(lastname, '') AS DriverName, DriverKey, ISNULL(voucherno, '') AS voucherno, ISNULL(LegTypeID, '') AS LegTypeID, ISNULL(Workflow, '') AS Workflow, ISNULL(DestinationCity, '') AS DestinationCity, ISNULL(weekNum, '') AS weekNum, ISNULL(DriverOrg, '') AS DriverOrg, ISNULL(BrokerRefNo, '') AS BrokerRefNo, ISNULL(VesselETA, '') AS VesselETA, CONVERT(DATETIME, ISNULL(ActualDeparture, '1900-01-01')) AS ActualDeparture, CONVERT(DATETIME, ISNULL(voucherdate, '1900-01-01')) AS voucherdate, CONVERT(DATETIME, ISNULL(WeekStart, '1900-01-01')) AS WeekStart, CONVERT(DATETIME, ISNULL(WeekEnd, '1900-01-01')) AS WeekEnd, CONVERT(DATETIME, ISNULL(PaidDate, '1900-01-01')) AS PaidDate, ISNULL(ispaymentapproved, CONVERT(BIT, 0)) AS ispaymentapproved, ISNULL(IsDocumentVerified, CONVERT(BIT, 0)) AS IsDocumentVerified, ISNULL(IsRateVerified, CONVERT(BIT, 0)) AS IsRateVerified, ISNULL(IsPaid, CONVERT(BIT, 0)) AS IsPaid, ISNULL(DriverHubKey, 0) AS DriverHubKey, DriverHubName, ISNULL(MarketLocationKey, 0) AS MarketLocationKey, MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, ISNULL(LegID, '') AS LegID, LegKey, ISNULL(ChargesCount, 0) AS ChargesCount, OrgName
    INTO #TempPrev FROM #TEMPTABLE WHERE (ISNULL(@WeekNum, '') = '' OR weekNum = @WeekNum) AND (@StatusKey = 0 OR ISNULL(Statuskey, 9) = @StatusKey);

    DECLARE @RecCount INT = (SELECT COUNT(1) FROM #TempPrev), @RecFrom INT = ((@PageNo - 1) * @PageSize) + 1, @RecTo INT = @PageNo * @PageSize;

    SELECT *, @RecCount AS RecCount INTO #FinalData_Output FROM (
        SELECT *, ROW_NUMBER() OVER (ORDER BY 
            CASE WHEN @SortField = 'voucherno' AND @IsAscending = 1 THEN voucherno END ASC, CASE WHEN @SortField = 'voucherno' AND @IsAscending = 0 THEN voucherno END DESC,
            CASE WHEN @SortField = 'orderno' AND @IsAscending = 1 THEN orderno END ASC, CASE WHEN @SortField = 'orderno' AND @IsAscending = 0 THEN orderno END DESC,
            CASE WHEN @SortField = 'containerno' AND @IsAscending = 1 THEN containerno END ASC, CASE WHEN @SortField = 'containerno' AND @IsAscending = 0 THEN containerno END DESC,
            CASE WHEN @SortField = 'driverid' AND @IsAscending = 1 THEN driverid END ASC, CASE WHEN @SortField = 'driverid' AND @IsAscending = 0 THEN driverid END DESC,
            CASE WHEN @SortField = 'voucherdate' AND @IsAscending = 1 THEN voucherdate END ASC, CASE WHEN @SortField = 'voucherdate' AND @IsAscending = 0 THEN voucherdate END DESC,
            CASE WHEN @SortField = 'weeknum' AND @IsAscending = 1 THEN weekNum END ASC, CASE WHEN @SortField = 'weeknum' AND @IsAscending = 0 THEN weekNum END DESC, voucherno ASC
        ) AS RowNum FROM #TempPrev
    ) AS Sorted WHERE RowNum BETWEEN @RecFrom AND @RecTo;

    SELECT VoucherList = (SELECT * FROM #FinalData_Output FOR JSON PATH),
    DropDowns = (SELECT CarrierList = (SELECT DISTINCT DriverKey, driverid AS DriverName FROM #TempPrev WHERE ISNULL(driverid, '') <> '' ORDER BY driverid FOR JSON PATH), DriverHubList = (SELECT DISTINCT DriverHubKey, DriverHubName FROM #TempPrev WHERE ISNULL(DriverHubName, '') <> '' ORDER BY DriverHubName FOR JSON PATH), MarketLocList = (SELECT DISTINCT MarketLocation, MarketLocationKey FROM #TempPrev WHERE ISNULL(MarketLocation, '') <> '' ORDER BY MarketLocation FOR JSON PATH), TruckTypeList = (SELECT DISTINCT TruckTypeKey, TruckType FROM dbo.TruckType WITH (NOLOCK) WHERE ISNULL(TruckType, '') <> '' ORDER BY TruckType FOR JSON PATH), MoveTypeList = (SELECT DISTINCT MoveTypeKey, MoveTypeName FROM dbo.CarrierMoveType WITH (NOLOCK) WHERE ISNULL(MoveTypeName, '') <> '' ORDER BY MoveTypeName FOR JSON PATH) FOR JSON PATH),
    Dashboard = (SELECT * FROM #Dashboard FOR JSON PATH) FOR JSON PATH;

    SET @Status = 1; SET @Reason = 'Success';
END
