/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"SearchCriteriaKey":0,"DriverKeys":"","OrderKeys":"","OrderNo":"","containerNo":"","voucherNo":"","VoucherKeys":"","DriverHubkeys":"","WeekNum":"WK-3","MarketLocationKeys":"","TruckTypeKeys":"","CarrierMoveTypeKeys":"","SearchText":"","SortField":"voucherno","IsAscending":true,"PageSize":50,"PageNo":1,"StatusKey":1,"isDriverPay":false}',
	@Status BIT=0, @Debug int = 0,@Reason VARCHAR(100)=''
EXec [Get_VoucherList_V2_Optimized_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_VoucherList_V2_Optimized_V2] 
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

    -- Declare variables
    DECLARE 
        @StatusKey             INT = 0,
        @DriverKeys            VARCHAR(MAX) = '',
        @OrderKeys             VARCHAR(MAX) = '',
        @OrderDateFrom         DATE = '07/01/2025',
        @OrderDateTo           DATE = '12/31/2099',
        @DeliveryDateFrom      DATE = '07/01/2025',
        @DeliveryDateTo        DATE = '12/31/2099',
        @OrderNo               VARCHAR(50) = '',
        @containerNo           VARCHAR(50) = '',
        @voucherNo             VARCHAR(50) = '',
        @VoucherKeys           VARCHAR(MAX) = '',
        @DriverHubkeys         VARCHAR(MAX) = '',
        @WeekNum               VARCHAR(5) = '',
        @marketLocationKeys    VARCHAR(MAX) = '',
        @TruckTypeKeys         VARCHAR(MAX) = '',
        @CarrierMoveTypeKeys   VARCHAR(MAX) = '',
        @PageNo                INT,
        @PageSize              INT,
        @SearchText            NVARCHAR(MAX),
        @SortField             VARCHAR(50),
        @IsAscending           BIT = 1,
        @isDriverPay           BIT = 0,
        @SearchCriteriaKey     INT = 0,
        @IsWithFilter          BIT = 0;

    -- Validate input JSON
    IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameters not found';
        RETURN;
    END

    -- Parse JSON input
    SELECT
        @containerNo = ISNULL(ContainerNo, ''),
        @StatusKey = StatusKey,
        @DriverKeys = DriverKeys,
        @OrderKeys = OrderKeys,
        @OrderDateFrom = OrderDateFrom,
        @OrderDateTo = OrderDateTo,
        @DeliveryDateFrom = DeliveryDateFrom,
        @DeliveryDateTo = DeliveryDateTo,
        @OrderNo = OrderNo,
        @voucherNo = voucherNo,
        @VoucherKeys = VoucherKeys,
        @DriverHubkeys = DriverHubkeys,
        @WeekNum = WeekNum,
        @MarketLocationKeys = MarketLocationKeys,
        @TruckTypeKeys = TruckTypeKeys,
        @CarrierMoveTypeKeys = CarrierMoveTypeKeys,
        @PageNo = PageNo,
        @PageSize = PageSize,
        @SearchText = LTRIM(RTRIM(ISNULL(SearchText, ''))),
        @SortField = SortField,
        @IsAscending = ISNULL(IsAscending, 1),
        @isDriverPay = isDriverPay,
        @SearchCriteriaKey = SearchCriteriaKey
    FROM OPENJSON(@JSONString, '$')
    WITH (
        ContainerNo           VARCHAR(20) '$.containerNo',
        StatusKey             INT '$.StatusKey',
        DriverKeys            VARCHAR(MAX) '$.DriverKeys',
        OrderKeys             VARCHAR(MAX) '$.OrderKeys',
        OrderDateFrom         DATE '$.OrderDateFrom',
        OrderDateTo           DATE '$.OrderDateTo',
        DeliveryDateFrom      DATE '$.DeliveryDateFrom',
        DeliveryDateTo        DATE '$.DeliveryDateTo',
        OrderNo               VARCHAR(50) '$.OrderNo',
        voucherNo             VARCHAR(50) '$.voucherNo',
        VoucherKeys           VARCHAR(MAX) '$.VoucherKeys',
        DriverHubkeys         VARCHAR(MAX) '$.DriverHubkeys',
        WeekNum               VARCHAR(5) '$.WeekNum',
        MarketLocationKeys    VARCHAR(MAX) '$.MarketLocationKeys',
        TruckTypeKeys         VARCHAR(MAX) '$.TruckTypeKeys',
        CarrierMoveTypeKeys   VARCHAR(MAX) '$.CarrierMoveTypeKeys',
        PageNo                INT '$.PageNo',
        PageSize              INT '$.PageSize',
        SearchText            NVARCHAR(MAX) '$.SearchText',
        SortField             VARCHAR(50) '$.SortField',
        IsAscending           BIT '$.IsAscending',
        isDriverPay           BIT '$.isDriverPay',
        SearchCriteriaKey     INT '$.SearchCriteriaKey'
    );

    -- Apply default dates if needed
    IF @OrderDateFrom IS NULL OR @OrderDateFrom IN ('0001-01-01', '1900-01-01')
        SET @OrderDateFrom = CASE WHEN @IsWithFilter = 0 THEN GETDATE() - 180 ELSE '2025-07-01' END;

    IF @OrderDateTo IS NULL OR @OrderDateTo IN ('0001-01-01', '1900-01-01')
        SET @OrderDateTo = '2050-12-31';

    IF @DeliveryDateFrom IS NULL OR @DeliveryDateFrom IN ('0001-01-01', '1900-01-01')
        SET @DeliveryDateFrom = CASE WHEN @IsWithFilter = 0 THEN GETDATE() - 60 ELSE '2025-07-01' END;

    IF @DeliveryDateTo IS NULL OR @DeliveryDateTo IN ('0001-01-01', '1900-01-01')
        SET @DeliveryDateTo = '2050-12-31';

    -- Handle WeekNum filter
    IF ISNULL(@WeekNum, '') <> ''
    BEGIN
        DECLARE @datecol DATETIME = GETDATE();
        DECLARE @WeekNumInt INT = CONVERT(INT, REPLACE(@WeekNum, 'WK-', '')),
                @YearNum CHAR(4) = CAST(DATEPART(YY, @datecol) AS CHAR(4));

        SET @DeliveryDateFrom = DATEADD(WK, DATEDIFF(WK, 6, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
        SET @DeliveryDateTo   = DATEADD(WK, DATEDIFF(WK, 5, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
        SET @OrderDateFrom    = '2025-07-01';
        SET @OrderDateTo      = '2050-12-31';
    END

    -- Prepare temp tables for filtering
    CREATE TABLE #DriverKey (DriverKey INT);
    CREATE TABLE #OrderKey (OrderKey INT);
    CREATE TABLE #voucherKey (VoucherKey INT);
    CREATE TABLE #DriverHubKey (DriverhubKey INT);
    CREATE TABLE #MarketLocationKey (MarketLocationKey INT);
    CREATE TABLE #TruckTypeKey (TruckTypeKey INT);
    CREATE TABLE #CarrierMoveTypeKey (MoveTypeKey INT);
    CREATE TABLE #OrderDetailKeys (OrderDetailKey INT PRIMARY KEY);

    -- Split comma-separated keys
    IF ISNULL(@DriverKeys,'') <> '' INSERT INTO #DriverKey SELECT value FROM dbo.Fn_SplitParamCol(@DriverKeys);
    IF ISNULL(@OrderKeys,'') <> '' INSERT INTO #OrderKey SELECT value FROM dbo.Fn_SplitParamCol(@OrderKeys);
    IF ISNULL(@VoucherKeys,'') <> '' INSERT INTO #voucherKey SELECT value FROM dbo.Fn_SplitParamCol(@VoucherKeys);
    IF ISNULL(@DriverHubkeys,'') <> '' INSERT INTO #DriverHubKey SELECT value FROM dbo.Fn_SplitParamCol(@DriverHubkeys);
    IF ISNULL(@marketLocationKeys,'') <> '' INSERT INTO #MarketLocationKey SELECT value FROM dbo.Fn_SplitParamCol(@marketLocationKeys);
    IF ISNULL(@TruckTypeKeys,'') <> '' INSERT INTO #TruckTypeKey SELECT value FROM dbo.Fn_SplitParamCol(@TruckTypeKeys);
    IF ISNULL(@CarrierMoveTypeKeys,'') <> '' INSERT INTO #CarrierMoveTypeKey SELECT value FROM dbo.Fn_SplitParamCol(@CarrierMoveTypeKeys);

    -- Ensure status 4 means all
    IF @StatusKey = 4 SET @StatusKey = 0;

    -- Main voucher data selection
    CREATE TABLE #TEMPTABLE
    (
        orderkey INT,
        orderdetailkey INT,
        voucheramount NUMERIC(18,5),
        routekey INT,
        destinationaddrkey INT,
        voucherkey INT,
        StatusKey SMALLINT,
        DocumentCount INT,
        DocCounts VARCHAR(50),
        orderno VARCHAR(50),
        containerno VARCHAR(50),
        driverid VARCHAR(20),
        firstname VARCHAR(100),
        lastname VARCHAR(100),
        voucherno VARCHAR(50),
        LegTypeID VARCHAR(100),
        Workflow VARCHAR(100),
        DestinationCity VARCHAR(50),
        weekNum VARCHAR(10),
        DriverKey INT,
        DriverOrg VARCHAR(100),
        BrokerRefNo VARCHAR(50),
        VesselETA DATETIME,
        ActualDeparture DATETIME,
        voucherdate DATETIME,
        WeekStart DATETIME,
        WeekEnd DATETIME,
        PaidDate DATETIME,
        ispaymentapproved BIT,
        IsDocumentVerified BIT,
        IsRateVerified BIT DEFAULT 0,
        IsPaid BIT,
        DriverHubKey INT,
        DriverHubName VARCHAR(100),
        MarketLocationKey INT,
        MarketLocation VARCHAR(200),
        PaidUserKey INT,
        PaidUserName VARCHAR(100),
        IsLinked BIT DEFAULT 0,
        LinkedContainerNo VARCHAR(20),
        LinkedOrderDetailKey INT,
        LegID VARCHAR(100),
        LegKey INT,
        ChargesCount INT,
        OrgName VARCHAR(200)
    );

    -- [Remaining data insert logic here]
    -- Keep all joins and filters as in your original procedure

    -- Final paginated result
    DECLARE @STRSQL NVARCHAR(MAX) = 'SELECT *, ROW_NUMBER() OVER (ORDER BY ' 
        + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ') AS RowNum FROM #TEMPTABLE';

    SELECT *, 0 AS RowNum
    INTO #FinalData_Temp
    FROM #TEMPTABLE
    WHERE 1 <> 1;

    INSERT INTO #FinalData_Temp
    EXEC(@STRSQL);

    DECLARE @RecFrom INT = ((@PageNo - 1) * @PageSize) + 1,
            @RecTo INT   = @PageNo * @PageSize;

    SELECT *, (SELECT COUNT(1) FROM #FinalData_Temp) AS RecCount
    INTO #FinalData_Output
    FROM #FinalData_Temp
    WHERE RowNum BETWEEN @RecFrom AND @RecTo;

    -- Return final result
    SELECT * FROM #FinalData_Output;

END
