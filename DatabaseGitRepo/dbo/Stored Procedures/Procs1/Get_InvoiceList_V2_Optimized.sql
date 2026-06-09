/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"Factored":2,"CustApproved":2,"PageNo":1,"PageSize":50,"Ascending":true,"IsAscending":true,"CustomerKey":"","InvoiceNo":"","MarketLocationKey":"3:","InvoicerKey":"","CustCompanyKey":"","ChargeConfirmed":2,"SortField":"TerminationDate","StatusKey":9,"WarehouseStatusKeys":""}',
	@Status BIT=0,@IsDebug		BIT = 1,
	@Reason VARCHAR(100)=''
EXec Get_InvoiceList_V2_Optimized @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE dbo.Get_InvoiceList_V2_Optimized
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
    SET ARITHABORT ON;

    DECLARE 
        @StatusKey INT = 0, @CustomerKey VARCHAR(MAX), @OrderKey INT = 0,
        @OrderDateFrom DATE = '2020-01-01', @OrderDateTo DATE = '2099-12-31',
        @OrderNo VARCHAR(50) = '', @containerNo VARCHAR(50) = '', @InvoiceNo VARCHAR(50) = '',
        @InvoiceKey INT = 0, @BOL VARCHAR(30) = '', @PageNo INT = 1, @PageSize INT = 10,
        @SortField VARCHAR(50) = 'TerminationDate', @IsAscending BIT = 1,
        @SearchText NVARCHAR(MAX) = '', @marketLocationKey VARCHAR(MAX),
        @Factored INT, @CustApproved INT, @InvoicerKey VARCHAR(MAX), @CustCompanyKey VARCHAR(MAX),
        @outputType VARCHAR(20), @WarehouseStatusKeys VARCHAR(MAX), @ChargeConfirmed INT = 2,
        @InvoiceDateFrom DATE, @InvoiceDateTo DATE, @ReasonCode INT, @DoorToDoor INT,
        @IsDoorToDoor BIT, @PaymentStatus INT, @SearchCriteriaKey INT,
        @IsFactored BIT, @IsCustApproved BIT, @IsSearchActive BIT = 0;

    IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameters not found';
        RETURN;
    END

    SELECT 
        @StatusKey = StatusKey, @CustomerKey = CustomerKey, @OrderKey = OrderKey,
        @OrderDateFrom = OrderDateFrom, @OrderDateTo = OrderDateTo,
        @OrderNo = OrderNo, @containerNo = containerNo, @InvoiceNo = InvoiceNo,
        @InvoiceKey = InvoiceKey, @BOL = BOL, @PageNo = PageNo, @PageSize = PageSize,
        @SortField = SortField, @IsAscending = IsAscending, @SearchText = SearchText,
        @marketLocationKey = MarketLocationKey, @Factored = Factored, @CustApproved = CustApproved,
        @InvoicerKey = InvoicerKey, @CustCompanyKey = CustCompanyKey, @outputType = outputType,
        @ChargeConfirmed = ChargeConfirmed, @WarehouseStatusKeys = WarehouseStatusKey,
        @InvoiceDateFrom = InvoiceDateFrom, @InvoiceDateTo = InvoiceDateTo,
        @ReasonCode = ReasonCode, @DoorToDoor = DoorToDoor, @PaymentStatus = PaymentStatus,
        @SearchCriteriaKey = SearchCriteriaKey
    FROM OPENJSON(@JSONString, '$') WITH (
        StatusKey INT '$.StatusKey', CustomerKey VARCHAR(MAX) '$.CustomerKey',
        OrderKey INT '$.OrderKey', OrderDateFrom DATE '$.OrderDateFrom',
        OrderDateTo DATE '$.OrderDateTO', OrderNo VARCHAR(50) '$.OrderNo',
        containerNo VARCHAR(50) '$.containerNo', InvoiceNo VARCHAR(50) '$.InvoiceNo',
        InvoiceKey INT '$.InvoiceKey', BOL VARCHAR(30) '$.BOL', PageNo INT '$.PageNo',
        PageSize INT '$.PageSize', SortField VARCHAR(50) '$.SortField',
        IsAscending BIT '$.IsAscending', SearchText NVARCHAR(MAX) '$.SearchText',
        MarketLocationKey VARCHAR(MAX) '$.MarketLocationKey', Factored INT '$.Factored',
        CustApproved INT '$.CustApproved', InvoicerKey VARCHAR(MAX) '$.InvoicerKey',
        CustCompanyKey VARCHAR(MAX) '$.CustCompanyKey', outputType VARCHAR(20) '$.outputType',
        ChargeConfirmed INT '$.ChargeConfirmed', WarehouseStatusKey VARCHAR(MAX) '$.WarehouseStatusKeys',
        InvoiceDateFrom DATE '$.InvoiceDateFrom', InvoiceDateTo DATE '$.InvoiceDateTo',
        ReasonCode INT '$.ReasonCodeKey', DoorToDoor INT '$.DoorToDoor',
        PaymentStatus INT '$.PaymentStatus', SearchCriteriaKey INT '$.SearchCriteriaKey'
    );

    -- Set defaults
    SET @OrderDateFrom = ISNULL(@OrderDateFrom, '2020-01-01');
    SET @OrderDateTo = ISNULL(@OrderDateTo, DATEADD(DAY, 30, GETDATE()));
    SET @InvoiceDateFrom = ISNULL(@InvoiceDateFrom, '2020-01-01');
    SET @InvoiceDateTo = ISNULL(@InvoiceDateTo, DATEADD(DAY, 30, GETDATE()));
    SET @CustCompanyKey = ISNULL(@CustCompanyKey, '');
    SET @WarehouseStatusKeys = ISNULL(@WarehouseStatusKeys, '');
    SET @CustomerKey = ISNULL(@CustomerKey, '');
    SET @SortField = ISNULL(@SortField, 'TerminationDate');
    SET @IsDoorToDoor = CASE WHEN @DoorToDoor = 1 THEN 1 WHEN @DoorToDoor = 0 THEN 0 ELSE NULL END;
    SET @IsFactored = CASE WHEN @Factored = 1 THEN 1 WHEN @Factored = 0 THEN 0 ELSE NULL END;
    SET @IsCustApproved = CASE WHEN @CustApproved = 1 THEN 1 WHEN @CustApproved = 0 THEN 0 ELSE NULL END;
    IF LEFT(@InvoiceNo, 1) = '0' SET @InvoiceNo = RIGHT(@InvoiceNo, LEN(@InvoiceNo) - 1);
    IF @StatusKey = 16 SET @StatusKey = 0;

    -- Temp tables with PRIMARY KEY for better join performance
    CREATE TABLE #WarehouseStatusKeys (StatusKey INT PRIMARY KEY);
    CREATE TABLE #CustomerKeys (CustomerKey INT PRIMARY KEY);
    CREATE TABLE #CustCompanyKeys (CustCompanyKey INT PRIMARY KEY);
    CREATE TABLE #MarketLocationKeys (MarketLocationKey INT PRIMARY KEY);
    CREATE TABLE #InvoicerKeys (InvoicerKey INT PRIMARY KEY);
    CREATE TABLE #OrderDetailKeys (OrderDetailKey INT PRIMARY KEY);
    CREATE TABLE #InvoiceKeys (InvoiceKey INT PRIMARY KEY);

    IF LEN(@WarehouseStatusKeys) > 0 INSERT INTO #WarehouseStatusKeys SELECT value FROM dbo.Fn_SplitParamCol(@WarehouseStatusKeys);
    IF LEN(@CustomerKey) > 0 INSERT INTO #CustomerKeys SELECT value FROM dbo.Fn_SplitParamCol(@CustomerKey);
    IF LEN(@CustCompanyKey) > 0 INSERT INTO #CustCompanyKeys SELECT value FROM dbo.Fn_SplitParamCol(@CustCompanyKey);
    IF LEN(@MarketLocationKey) > 0 INSERT INTO #MarketLocationKeys SELECT value FROM dbo.Fn_SplitParamCol(@MarketLocationKey);
    IF LEN(@InvoicerKey) > 0 INSERT INTO #InvoicerKeys SELECT value FROM dbo.Fn_SplitParamCol(@InvoicerKey);

    -- Search handling
    IF ISNULL(@SearchText, '') <> ''
    BEGIN
        SET @IsSearchActive = 1;
        DECLARE @HasComma BIT = CASE WHEN CHARINDEX(',', @SearchText) > 0 THEN 1 ELSE 0 END;
        IF @HasComma = 0
        BEGIN
            INSERT INTO #OrderDetailKeys SELECT DISTINCT OrderDetailKey FROM dbo.OrderDetail WITH (NOLOCK) WHERE ContainerNo = @SearchText;
            INSERT INTO #OrderDetailKeys SELECT DISTINCT OD.OrderDetailKey FROM dbo.OrderDetail OD WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
                WHERE OH.OrderNo = @SearchText AND NOT EXISTS (SELECT 1 FROM #OrderDetailKeys OK WHERE OK.OrderDetailKey = OD.OrderDetailKey);
            INSERT INTO #InvoiceKeys SELECT DISTINCT InvoiceKey FROM dbo.InvoiceHeader WITH (NOLOCK) WHERE InvoiceNo = @SearchText;
            INSERT INTO #InvoiceKeys SELECT DISTINCT IC.InvoiceKey FROM dbo.InvoiceContainers IC WITH (NOLOCK)
                WHERE IC.ContainerNo = @SearchText AND NOT EXISTS (SELECT 1 FROM #InvoiceKeys IK WHERE IK.InvoiceKey = IC.InvoiceKey);
            INSERT INTO #InvoiceKeys SELECT DISTINCT IH.InvoiceKey FROM dbo.InvoiceHeader IH WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON IH.OrderKey = OH.OrderKey
                WHERE OH.OrderNo = @SearchText AND NOT EXISTS (SELECT 1 FROM #InvoiceKeys IK WHERE IK.InvoiceKey = IH.InvoiceKey);
        END
        ELSE
        BEGIN
            IF @SearchCriteriaKey = 1
            BEGIN
                INSERT INTO #OrderDetailKeys SELECT DISTINCT OrderDetailKey FROM dbo.OrderDetail WITH (NOLOCK) WHERE ContainerNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText));
                INSERT INTO #InvoiceKeys SELECT DISTINCT InvoiceKey FROM dbo.InvoiceContainers WITH (NOLOCK) WHERE ContainerNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText));
            END
            IF @SearchCriteriaKey = 2
            BEGIN
                INSERT INTO #OrderDetailKeys SELECT DISTINCT OD.OrderDetailKey FROM dbo.OrderDetail OD WITH (NOLOCK)
                    INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey WHERE OH.OrderNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText));
                INSERT INTO #InvoiceKeys SELECT DISTINCT IH.InvoiceKey FROM dbo.InvoiceHeader IH WITH (NOLOCK)
                    INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON IH.OrderKey = OH.OrderKey WHERE OH.OrderNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText));
            END
            IF @SearchCriteriaKey = 4 INSERT INTO #InvoiceKeys SELECT DISTINCT InvoiceKey FROM dbo.InvoiceHeader WITH (NOLOCK) WHERE InvoiceNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText));
        END
    END

    -- Container counts with STRING_AGG (SQL 2017+)
    SELECT OrderKey, COUNT(1) AS ContainerCount, STRING_AGG(ContainerNo, ',') AS ContainerNos INTO #ContainerCount
    FROM dbo.OrderDetail WITH (NOLOCK) WHERE Status <> 15 GROUP BY OrderKey;
    CREATE INDEX IX_CC ON #ContainerCount(OrderKey);

    -- Main results table with indexes
    CREATE TABLE #ToInvoice (
        OrderKey INT, OrderNo VARCHAR(50), ContainerNo VARCHAR(500), CustId VARCHAR(100), CustName VARCHAR(200),
        IsInvoiceApproved BIT, StatusKey SMALLINT, InvoiceAmount NUMERIC(18,2), City VARCHAR(50), Status VARCHAR(50),
        DestinationAddrKey INT, InvoiceKey INT, InvoiceNo VARCHAR(50), InvoiceDate DATETIME, IsPrinted BIT,
        PrintedUserKey INT, PaymentRecdUserKey INT, PaymentRecdDate DATETIME, PrintedDate DATETIME, IsRevised BIT,
        RevisionDate DATETIME, BrokerRefNo VARCHAR(50), IsFactored BIT, BalanceAmount NUMERIC(18,2), CustKey INT,
        OrderDate DATETIME, BillOfLading VARCHAR(50), OrderTypeKey INT, OrderType VARCHAR(50), BookingNo VARCHAR(50),
        TerminationDate DATETIME, ContainerList VARCHAR(MAX), AddrName VARCHAR(100), MarketLocationKey INT,
        MarketLocation VARCHAR(100), OrderDetailKey INT, IsPaymentReceived BIT, RevisionUserKey INT,
        InvoiceApprovedUserKey INT, CustomerNote VARCHAR(MAX), InternalNote VARCHAR(MAX), CustApproved BIT,
        InvoicerKey INT, ReasonCodeKey INT, ReasonCodeName VARCHAR(100), CustCompanyKey INT, AgingDays INT,
        AprovedReasonCodeKey INT, ApprovedReasonCode VARCHAR(100), CustCompanyName VARCHAR(500), RouteKey INT,
        CSR VARCHAR(100), WarehouseStatus VARCHAR(100), WarehouseStatusKey INT, AllowInvoicing BIT,
        IsCSChargesApproved BIT, CSChargesApproveDate DATETIME, ExpCount INT DEFAULT 0, DoorToDoor BIT,
        ContainerCount INT, InvoicePaymentStatus INT, IsDataSelected BIT DEFAULT 0, IsSelectedStatusKey BIT DEFAULT 0,
        INDEX IX_S NONCLUSTERED (StatusKey), INDEX IX_I NONCLUSTERED (InvoiceKey)
    );

    -- Query 1: Pending to Invoice (StatusKey = 9) - Merged #ContainersNotInvoiced logic
    INSERT INTO #ToInvoice (OrderKey, OrderNo, ContainerNo, CustId, CustName, OrderDetailKey, IsInvoiceApproved,
        StatusKey, InvoiceAmount, City, Status, DestinationAddrKey, InvoiceKey, InvoiceNo, InvoiceDate, IsPrinted,
        PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate, IsRevised, RevisionDate, BrokerRefNo,
        IsFactored, BalanceAmount, CustKey, OrderDate, BillOfLading, OrderTypeKey, OrderType, BookingNo,
        TerminationDate, AddrName, MarketLocationKey, MarketLocation, CustApproved, ReasonCodeKey, ReasonCodeName,
        CustCompanyKey, AgingDays, InvoicerKey, AprovedReasonCodeKey, ApprovedReasonCode, CustCompanyName, RouteKey,
        CSR, WarehouseStatus, WarehouseStatusKey, AllowInvoicing, IsCSChargesApproved, CSChargesApproveDate,
        ExpCount, DoorToDoor, ContainerCount)
    SELECT OH.OrderKey, OH.OrderNo, OD.ContainerNo, CU.CustId, CU.CustName, OD.OrderDetailKey, 0, 9, 0, AD.City,
        'Pending to Invoice', OH.DestinationAddrKey, 0, '', '1900-01-01', 0, 0, 0, '1900-01-01', '1900-01-01', 0,
        '1900-01-01', OH.BrokerRefNo, CU.IsFactored, 0, OH.CustKey, OH.OrderDate, OH.BillOfLading,
        ISNULL(OD.OrderTypeKey, OH.OrderTypeKey), OT.OrderType, ISNULL(OD.BookingNo, OH.BookingNo), OD.CompleteDate,
        AD.AddrName, ML.MarketLocationKey, ML.MarketLocation, 0, 0, '', CU.CustomerCompanyKey,
        DATEDIFF(DAY, ISNULL(OD.CompleteDate, GETDATE()), GETDATE()), 0, 0, '', CC.CompanyName, OD.CurrentRouteKey,
        CSR.CsrName, CASE WHEN CT.OrderDetailKey IS NULL THEN 'N/A' ELSE ISNULL(WS.Description, 'Open') END,
        CASE WHEN CT.OrderDetailKey IS NULL THEN -1 ELSE ISNULL(WS.StatusKey, 1) END,
        CASE WHEN OD.CompleteDate < DATEADD(DAY, -1, GETDATE()) THEN 1 ELSE 0 END, OD.isChargesSharedWithCust,
        OD.ChargeSharedWithCustDate, ISNULL(OE.ExpCount, 0),
        CASE WHEN ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) = 3 THEN 1 ELSE 0 END, CCT.ContainerCount
    FROM dbo.OrderDetail OD WITH (NOLOCK)
    INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
    INNER JOIN dbo.Customer CU WITH (NOLOCK) ON OH.CustKey = CU.CustKey
    LEFT JOIN dbo.RouteInvoice RI WITH (NOLOCK) ON OD.OrderDetailKey = RI.OrderDetailKey
    LEFT JOIN dbo.Address AD WITH (NOLOCK) ON AD.AddrKey = OH.DestinationAddrKey
    LEFT JOIN dbo.OrderType OT WITH (NOLOCK) ON ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) = OT.OrderTypeKey
    LEFT JOIN dbo.MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey = ML.MarketLocationKey
    LEFT JOIN dbo.CustomerCompany CC WITH (NOLOCK) ON CU.CustomerCompanyKey = CC.CustomerCompanyKey
    LEFT JOIN dbo.CSR CSR WITH (NOLOCK) ON CSR.CsrKey = OH.CsrKey
    LEFT JOIN dbo.vContainerType CT WITH (NOLOCK) ON CT.OrderDetailKey = OD.OrderDetailKey AND CT.TypeID = 'Transload'
    LEFT JOIN dbo.Warehouse_ContainerDetails WCD WITH (NOLOCK) ON OD.OrderDetailKey = WCD.OrderDetailKey
    LEFT JOIN dbo.WarehouseStatus WS WITH (NOLOCK) ON WCD.StatusKey = WS.StatusKey
    LEFT JOIN dbo.vorderExpencesCount OE WITH (NOLOCK) ON OE.OrderDetailKey = OD.OrderDetailKey
    LEFT JOIN #ContainerCount CCT ON CCT.OrderKey = OH.OrderKey
    LEFT JOIN #OrderDetailKeys ODK ON ODK.OrderDetailKey = OD.OrderDetailKey
    WHERE OD.Status IN (6, 10, 12, 13, 14) AND RI.InvoiceKey IS NULL
      AND NOT EXISTS (SELECT 1 FROM dbo.InvoiceContainers IC WITH (NOLOCK) WHERE IC.OrderDetailsKey = OD.OrderDetailKey)
      AND (@IsSearchActive = 0 OR ODK.OrderDetailKey IS NOT NULL);

    -- Query 2: Existing Invoices (StatusKey 1, 2, 3)
    INSERT INTO #ToInvoice (OrderKey, OrderNo, ContainerNo, CustId, CustName, OrderDetailKey, IsInvoiceApproved,
        StatusKey, InvoiceAmount, City, Status, DestinationAddrKey, InvoiceKey, InvoiceNo, InvoiceDate, IsPrinted,
        PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate, IsRevised, RevisionDate, BrokerRefNo,
        IsFactored, BalanceAmount, CustKey, OrderDate, BillOfLading, OrderTypeKey, OrderType, BookingNo,
        TerminationDate, AddrName, MarketLocationKey, MarketLocation, IsPaymentReceived, RevisionUserKey,
        InvoiceApprovedUserKey, CustomerNote, InternalNote, CustApproved, ReasonCodeKey, ReasonCodeName,
        CustCompanyKey, AgingDays, InvoicerKey, AprovedReasonCodeKey, ApprovedReasonCode, CustCompanyName, CSR,
        ExpCount, DoorToDoor, ContainerCount, InvoicePaymentStatus)
    SELECT OH.OrderKey, OH.OrderNo, '', CU.CustId, CU.CustName, 0, ISNULL(IH.IsInvoiceApproved, 0),
        ISNULL(IH.StatusKey, 9), IH.InvoiceAmount, AD.City, INS.Description, OH.DestinationAddrKey, IH.InvoiceKey,
        IH.InvoiceNo, IH.InvoiceDate, IH.IsPrinted, IH.PrintedUserKey, IH.PaymentRecdUserKey, IH.PaymentRecdDate,
        IH.PrintedDate, IH.IsRevised, IH.RevisionDate, ISNULL(IH.BrokerRefNo, OH.BrokerRefNo), CU.IsFactored,
        ISNULL(VIB.BalanceAmount, IH.InvoiceAmount), OH.CustKey, OH.OrderDate, OH.BillOfLading, OH.OrderTypeKey,
        OT.OrderType, OH.BookingNo, IC.TerminationDate, AD.AddrName, ML.MarketLocationKey, ML.MarketLocation,
        IH.IsPaymentReceived, IH.RevisionUserKey, IH.InvoiceApprovedUserKey, IH.CustomerNote, IH.InternalNote,
        ISNULL(IH.CustApproved, 0), ISNULL(IH.ReasoncodeKey, 0), IR.ReasonCode, CU.CustomerCompanyKey,
        DATEDIFF(DAY, IH.InvoiceDate, GETDATE()), IH.CreateUserKey, IH.AprovedReasonCodeKey, IARC.ApprovedReasonCode,
        CC.CompanyName, CSR.CsrName, 0, CASE WHEN OH.OrderTypeKey = 3 THEN 1 ELSE 0 END, CCT.ContainerCount, IP.StatusKey
    FROM dbo.InvoiceHeader IH WITH (NOLOCK)
    INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON IH.OrderKey = OH.OrderKey
    INNER JOIN dbo.Customer CU WITH (NOLOCK) ON IH.CustKey = CU.CustKey
    LEFT JOIN (SELECT DISTINCT InvoiceKey, TerminationDate FROM dbo.InvoiceContainers WITH (NOLOCK)) IC ON IH.InvoiceKey = IC.InvoiceKey
    LEFT JOIN dbo.Address AD WITH (NOLOCK) ON AD.AddrKey = OH.DestinationAddrKey
    LEFT JOIN dbo.InvoiceStatus INS WITH (NOLOCK) ON INS.StatusKey = IH.StatusKey
    LEFT JOIN dbo.vInvoiceBalanceAmount VIB WITH (NOLOCK) ON IH.InvoiceKey = VIB.InvoiceKey
    LEFT JOIN dbo.OrderType OT WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
    LEFT JOIN dbo.MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey = ML.MarketLocationKey
    LEFT JOIN dbo.InvoiceReasonCode IR WITH (NOLOCK) ON IR.ReasoncodeKey = IH.ReasoncodeKey
    LEFT JOIN dbo.InvoiceCustApprovedReasonCode IARC WITH (NOLOCK) ON IARC.AprovedReasonCodeKey = IH.AprovedReasonCodeKey
    LEFT JOIN dbo.CustomerCompany CC WITH (NOLOCK) ON CU.CustomerCompanyKey = CC.CustomerCompanyKey
    LEFT JOIN dbo.CSR CSR WITH (NOLOCK) ON CSR.CsrKey = OH.CsrKey
    LEFT JOIN #ContainerCount CCT ON CCT.OrderKey = OH.OrderKey
    LEFT JOIN #InvoiceKeys IK ON IK.InvoiceKey = IH.InvoiceKey
    OUTER APPLY (SELECT TOP 1 StatusKey FROM dbo.InvoicePayment WHERE InvoiceKey = IH.InvoiceKey ORDER BY PaymentKey DESC) IP
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ArchivedInvoiceHistory AIH WITH (NOLOCK) WHERE AIH.InvoiceKey = IH.InvoiceKey)
      AND NOT (IH.StatusKey = 3 AND IH.CreateDate <= DATEADD(DAY, -60, GETDATE()) AND ISNULL(@InvoiceNo, '') = '' AND ISNULL(@SearchText, '') = '')
      AND (@IsSearchActive = 0 OR IK.InvoiceKey IS NOT NULL);

    -- Update ContainerList using STRING_AGG
    UPDATE A SET ContainerList = IC.ContainerList FROM #ToInvoice A
    INNER JOIN (SELECT InvoiceKey, STRING_AGG(ContainerNo, ',') AS ContainerList FROM dbo.InvoiceContainers WITH (NOLOCK) GROUP BY InvoiceKey) IC ON A.InvoiceKey = IC.InvoiceKey;

    -- Apply filters using EXISTS instead of IN
    UPDATE #ToInvoice SET IsDataSelected = 1
    WHERE (ISNULL(@OrderKey, 0) = 0 OR OrderKey = @OrderKey)
      AND (ISNULL(@CustomerKey, '') = '' OR EXISTS (SELECT 1 FROM #CustomerKeys CK WHERE CK.CustomerKey = CustKey))
      AND (ISNULL(@MarketLocationKey, '') = '' OR EXISTS (SELECT 1 FROM #MarketLocationKeys MLK WHERE MLK.MarketLocationKey = #ToInvoice.MarketLocationKey))
      AND (ISNULL(@InvoicerKey, '') = '' OR EXISTS (SELECT 1 FROM #InvoicerKeys IK WHERE IK.InvoicerKey = #ToInvoice.InvoicerKey))
      AND (@IsCustApproved IS NULL OR CustApproved = @IsCustApproved)
      AND (@IsFactored IS NULL OR IsFactored = @IsFactored)
      AND (ISNULL(@CustCompanyKey, '') = '' OR EXISTS (SELECT 1 FROM #CustCompanyKeys CCK WHERE CCK.CustCompanyKey = #ToInvoice.CustCompanyKey))
      AND OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo
      AND (ISNULL(@InvoiceNo, '') = '' OR InvoiceNo LIKE @InvoiceNo + '%')
      AND (ISNULL(@InvoiceKey, 0) = 0 OR #ToInvoice.InvoiceKey = @InvoiceKey)
      AND (ISNULL(@WarehouseStatusKeys, '') = '' OR EXISTS (SELECT 1 FROM #WarehouseStatusKeys WSK WHERE WSK.StatusKey = WarehouseStatusKey))
      AND (@InvoiceDateFrom IS NULL AND @InvoiceDateTo IS NULL 
           OR CAST(InvoiceDate AS DATE) BETWEEN COALESCE(@InvoiceDateFrom, '1900-01-01') AND COALESCE(@InvoiceDateTo, '2099-12-31'))
      AND (ISNULL(@ReasonCode, 0) = 0 OR ReasonCodeKey = @ReasonCode)
      AND (@IsDoorToDoor IS NULL OR DoorToDoor = @IsDoorToDoor);

    UPDATE #ToInvoice SET IsSelectedStatusKey = 1 WHERE IsDataSelected = 1
      AND ((ISNULL(@SearchText, '') <> '' AND StatusKey = @StatusKey) OR (StatusKey IN (1, 2, 3, 9) AND (ISNULL(@StatusKey, 0) = 0 OR StatusKey = @StatusKey)));

    -- Build final result with CTE instead of separate temp table
    ;WITH MultContainer AS (SELECT InvoiceKey, COUNT(1) AS ContCount FROM dbo.InvoiceContainers WITH (NOLOCK) GROUP BY InvoiceKey)
    SELECT T.OrderKey, T.OrderDetailKey, T.OrderNo,
        CASE WHEN ISNULL(M.ContCount, 1) = 1 THEN ISNULL(T.ContainerList, T.ContainerNo) ELSE 'Multiple Containers (' + CAST(M.ContCount AS VARCHAR(50)) + ')' END AS ContainerNo,
        T.CustId, T.CustName, T.City AS DestinationCity, T.IsInvoiceApproved, T.StatusKey, T.Status, T.InvoiceAmount,
        T.DestinationAddrKey, T.InvoiceKey, T.InvoiceNo, T.InvoiceDate, T.CustomerNote, T.InternalNote,
        CASE WHEN ISNULL(T.ExpCount, 0) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsRateVerified, M.ContCount,
        T.IsPrinted, T.PrintedUserKey, T.PaymentRecdUserKey, T.PaymentRecdDate, T.PrintedDate, T.IsRevised,
        T.RevisionDate, T.RevisionUserKey, U1.UserName AS ApprovedUserName, U2.UserName AS PrintedUserName,
        U3.UserName AS PaymentRecdUserName, U4.UserName AS RevisedUserName, T.IsPaymentReceived, T.BrokerRefNo,
        T.IsFactored, T.BalanceAmount, T.CustKey, T.OrderDate, T.BillOfLading, T.BookingNo, T.TerminationDate,
        ISNULL(T.ContainerList, T.ContainerNo) AS ContainerList, T.AddrName, T.MarketLocationKey, T.MarketLocation,
        T.CustApproved, T.ReasonCodeKey, T.ReasonCodeName, T.CustCompanyKey, T.AgingDays, T.InvoicerKey,
        T.AprovedReasonCodeKey, T.OrderTypeKey, T.OrderType, T.ApprovedReasonCode, T.CustCompanyName,
        U5.UserName AS InvoicerName, T.RouteKey, T.IsDataSelected, T.IsSelectedStatusKey, T.CSR, T.WarehouseStatus,
        T.AllowInvoicing, 1 AS IsCSChargesApproved, T.CSChargesApproveDate, ISNULL(T.ExpCount, 0) AS ExpCount, T.DoorToDoor, T.ContainerCount
    INTO #InvoiceListData FROM #ToInvoice T
    LEFT JOIN MultContainer M ON M.InvoiceKey = T.InvoiceKey
    LEFT JOIN dbo.[User] U1 WITH (NOLOCK) ON T.InvoiceApprovedUserKey = U1.UserKey
    LEFT JOIN dbo.[User] U2 WITH (NOLOCK) ON T.PrintedUserKey = U2.UserKey
    LEFT JOIN dbo.[User] U3 WITH (NOLOCK) ON T.PaymentRecdUserKey = U3.UserKey
    LEFT JOIN dbo.[User] U4 WITH (NOLOCK) ON T.RevisionUserKey = U4.UserKey
    LEFT JOIN dbo.[User] U5 WITH (NOLOCK) ON T.InvoicerKey = U5.UserKey
    WHERE T.IsDataSelected = 1 AND (@IsDoorToDoor IS NULL OR T.DoorToDoor = @IsDoorToDoor)
      AND (ISNULL(@PaymentStatus, 0) = 0 OR T.InvoicePaymentStatus = @PaymentStatus);

    -- Dashboard
    SELECT IC.StatusKey, INS.Description AS StatusName, ISNULL(IC.LastCount, 0) AS InvoiceCount INTO #Dashboard
    FROM dbo.InvoiceCounts IC WITH (NOLOCK) LEFT JOIN dbo.InvoiceStatus INS WITH (NOLOCK) ON IC.StatusKey = INS.StatusKey;
    INSERT INTO #Dashboard VALUES (0, 'All', (SELECT COUNT(1) FROM #InvoiceListData WHERE IsSelectedStatusKey = 1));

    -- Pagination using inline ORDER BY instead of dynamic SQL
    DECLARE @cnt INT = (SELECT COUNT(1) FROM #InvoiceListData WHERE IsSelectedStatusKey = 1);
    IF ISNULL(@outputType, '') IN ('Excel', 'PDF') BEGIN SET @PageNo = 1; SET @PageSize = @cnt; END
    DECLARE @RecFrom INT = ((@PageNo - 1) * @PageSize) + 1, @RecTo INT = @PageNo * @PageSize;

    SELECT ILD.*, @cnt AS RecCount INTO #FinalData FROM (
        SELECT *, ROW_NUMBER() OVER (ORDER BY
            CASE WHEN @SortField = 'TerminationDate' AND @IsAscending = 1 THEN TerminationDate END ASC,
            CASE WHEN @SortField = 'TerminationDate' AND @IsAscending = 0 THEN TerminationDate END DESC,
            CASE WHEN @SortField = 'InvoiceNo' AND @IsAscending = 1 THEN InvoiceNo END ASC,
            CASE WHEN @SortField = 'InvoiceNo' AND @IsAscending = 0 THEN InvoiceNo END DESC,
            CASE WHEN @SortField = 'OrderNo' AND @IsAscending = 1 THEN OrderNo END ASC,
            CASE WHEN @SortField = 'OrderNo' AND @IsAscending = 0 THEN OrderNo END DESC,
            CASE WHEN @SortField = 'InvoiceDate' AND @IsAscending = 1 THEN InvoiceDate END ASC,
            CASE WHEN @SortField = 'InvoiceDate' AND @IsAscending = 0 THEN InvoiceDate END DESC,
            CASE WHEN @SortField = 'CustName' AND @IsAscending = 1 THEN CustName END ASC,
            CASE WHEN @SortField = 'CustName' AND @IsAscending = 0 THEN CustName END DESC, ContainerNo ASC
        ) AS RowNum FROM #InvoiceListData WHERE IsSelectedStatusKey = 1
    ) ILD WHERE RowNum BETWEEN @RecFrom AND @RecTo;

    UPDATE F SET OrderDetailKey = IC.OrderDetailsKey FROM #FinalData F
    INNER JOIN dbo.InvoiceContainers IC WITH (NOLOCK) ON F.InvoiceKey = IC.InvoiceKey WHERE F.StatusKey IN (1, 2, 3);

    UPDATE F SET ExpCount = ISNULL(OE.ExpCount, 0) FROM #FinalData F
    LEFT JOIN dbo.vorderExpencesCount OE WITH (NOLOCK) ON OE.OrderDetailKey = F.OrderDetailKey WHERE F.StatusKey IN (1, 2, 3);

    -- JSON output
    SELECT InvoiceList = (SELECT * FROM #FinalData FOR JSON PATH),
        DropDowns = (SELECT
            CustomerList = (SELECT DISTINCT CustKey, CustName FROM #InvoiceListData WHERE IsSelectedStatusKey = 1 AND CustName <> '' ORDER BY CustName FOR JSON PATH),
            CustCompanyList = (SELECT DISTINCT CustCompanyKey, CustCompanyName FROM #InvoiceListData WHERE IsSelectedStatusKey = 1 AND ISNULL(CustCompanyName, '') <> '' ORDER BY CustCompanyName FOR JSON PATH),
            MarketLocList = (SELECT DISTINCT MarketLocationKey, MarketLocation FROM #InvoiceListData WHERE IsSelectedStatusKey = 1 AND ISNULL(MarketLocation, '') <> '' ORDER BY MarketLocation FOR JSON PATH),
            InvoicerList = (SELECT DISTINCT InvoicerKey, InvoicerName FROM #InvoiceListData WHERE IsSelectedStatusKey = 1 AND ISNULL(InvoicerName, '') <> '' ORDER BY InvoicerName FOR JSON PATH),
            WarehouseStatus = (SELECT DISTINCT StatusKey, Description FROM dbo.WarehouseStatus ORDER BY StatusKey FOR JSON PATH),
            ReasonCodeList = (SELECT DISTINCT ReasonCodeKey, ReasonCodeName FROM #InvoiceListData WHERE IsSelectedStatusKey = 1 AND ISNULL(ReasonCodeName, '') <> '' ORDER BY ReasonCodeName FOR JSON PATH)
        FOR JSON PATH), Dashboard = (SELECT * FROM #Dashboard FOR JSON PATH) FOR JSON PATH;

    SET @Status = 1; SET @Reason = 'Success';
END
