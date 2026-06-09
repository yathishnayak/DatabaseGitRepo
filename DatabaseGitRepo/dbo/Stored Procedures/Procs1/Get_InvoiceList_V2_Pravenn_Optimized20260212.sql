-- Created by GitHub Copilot in SSMS - review carefully before executing
CREATE PROCEDURE [dbo].[Get_InvoiceList_V2_Pravenn_Optimized20260212]
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
    SET ARITHABORT ON;
    SET CONCAT_NULL_YIELDS_NULL ON;

    IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameters not found';
        RETURN;
    END

    IF @IsDebug = 1
    BEGIN
        SET @Status = 0;
        SET @Reason = 'In Debug Mode';
    END

    DECLARE 
        @IsFactored         BIT,
        @IsCustApproved     BIT,
        @IsSearchActive     BIT = 0,
        @StatusKey          INT = 0,
        @CustomerKey        VARCHAR(MAX),
        @OrderKey           INT = 0,
        @OrderDateFrom      DATE = '2020-01-01',
        @OrderDateTO        DATE = '2099-12-31',
        @DeliveryDateFrom   DATE = '2020-01-01',
        @DeliveryDateTo     DATE = '2099-12-31',
        @OrderNo            VARCHAR(50) = '',
        @containerNo        VARCHAR(50) = '',
        @InvoiceNo          VARCHAR(50) = '',
        @InvoiceKey         INT = 0,
        @BOL                VARCHAR(30) = '',
        @PageNo             INT = 1,
        @PageSize           INT = 10,
        @SortField          VARCHAR(50) = 'ORDERNO',
        @IsAscending        BIT = 1,
        @SearchText         NVARCHAR(MAX) = '',
        @marketLocationKey  VARCHAR(MAX),
        @Factored           INT,
        @CustApproved       INT,
        @InvoicerKey        VARCHAR(MAX),
        @CustCompanyKey     VARCHAR(MAX),
        @outputType         VARCHAR(20),
        @WarehouseStatusKeys VARCHAR(MAX),
        @ChargeConfirmed    INT = 2,
        @InvoiceDateFrom    DATE,
        @InvoiceDateTo      DATE,
        @ReasonCode         INT,
        @DoorToDoor         INT,
        @IsDoorToDoor       BIT,
        @PaymentStatus      INT,
        @SearchCriteriaKey  INT,
        @cnt                INT,
        @HasComma           BIT,
        @HasCustomerFilter  BIT = 0,
        @HasMarketLocFilter BIT = 0,
        @HasInvoicerFilter  BIT = 0,
        @HasCustCompanyFilter BIT = 0,
        @HasWarehouseFilter BIT = 0,
        @HasInvoiceDateFilter BIT = 0;

    -- Parse JSON
    SELECT  @StatusKey = StatusKey,
            @CustomerKey = CustomerKey,
            @OrderKey = OrderKey,
            @OrderDateFrom = ISNULL(OrderDateFrom, '2020-01-01'),
            @OrderDateTO = ISNULL(OrderDateTO, '2099-12-31'),
            @DeliveryDateFrom = ISNULL(DeliveryDateFrom, '2020-01-01'),
            @DeliveryDateTo = ISNULL(DeliveryDateTo, '2099-12-31'),
            @OrderNo = OrderNo,
            @containerNo = containerNo,
            @InvoiceNo = InvoiceNo,
            @InvoiceKey = InvoiceKey,
            @BOL = BOL,
            @PageNo = ISNULL(PageNo, 1),
            @PageSize = ISNULL(PageSize, 10),
            @SortField = ISNULL(SorField, 'TerminationDate'),
            @IsAscending = IsAscending,
            @SearchText = SearchText,
            @marketLocationKey = MarketLocationKey,
            @Factored = Factored,
            @CustApproved = CustApproved,
            @InvoicerKey = InvoicerKey,
            @CustCompanyKey = CustCompanyKey,
            @outputType = outputType,
            @ChargeConfirmed = ChargeConfirmed,
            @WarehouseStatusKeys = WarehouseStatusKey,
            @InvoiceDateFrom = InvoiceDateFrom,
            @InvoiceDateTo = InvoiceDateTo,
            @ReasonCode = ReasonCode,
            @DoorToDoor = DoorToDoor,
            @PaymentStatus = PaymentStatus,
            @SearchCriteriaKey = SearchCriteriaKey
    FROM OPENJSON(@JsonString, '$')
    WITH (
        StatusKey           INT             '$.StatusKey',
        CustomerKey         VARCHAR(MAX)    '$.CustomerKey',
        OrderKey            INT             '$.OrderKey',
        OrderDateFrom       DATE            '$.OrderDateFrom',
        OrderDateTO         DATE            '$.OrderDateTO',
        DeliveryDateFrom    DATE            '$.DeliVeryDateFrom',
        DeliveryDateTo      DATE            '$.DeliveryDateTo',
        OrderNo             VARCHAR(50)     '$.OrderNo',
        containerNo         VARCHAR(50)     '$.containerNo',
        InvoiceNo           VARCHAR(50)     '$.InvoiceNo',
        InvoiceKey          INT             '$.InvoiceKey',
        BOL                 VARCHAR(30)     '$.BOL',
        PageNo              INT             '$.PageNo',
        PageSize            INT             '$.PageSize',
        SorField            VARCHAR(50)     '$.SortField',
        IsAscending         BIT             '$.IsAscending',
        SearchText          NVARCHAR(MAX)   '$.SearchText',
        MarketLocationKey   VARCHAR(MAX)    '$.MarketLocationKey',
        Factored            INT             '$.Factored',
        CustApproved        INT             '$.CustApproved',
        InvoicerKey         VARCHAR(MAX)    '$.InvoicerKey',
        CustCompanyKey      VARCHAR(MAX)    '$.CustCompanyKey',
        outputType          VARCHAR(20)     '$.outputType',
        ChargeConfirmed     INT             '$.ChargeConfirmed',
        WarehouseStatusKey  VARCHAR(MAX)    '$.WarehouseStatusKeys',
        InvoiceDateFrom     DATE            '$.InvoiceDateFrom',
        InvoiceDateTo       DATE            '$.InvoiceDateTo',
        ReasonCode          INT             '$.ReasonCodeKey',
        DoorToDoor          INT             '$.DoorToDoor',
        PaymentStatus       INT             '$.PaymentStatus',
        SearchCriteriaKey   INT             '$.SearchCriteriaKey'
    );

    -- Set computed values
    SET @CustCompanyKey = ISNULL(@CustCompanyKey, '');
    SET @WarehouseStatusKeys = ISNULL(@WarehouseStatusKeys, '');
    SET @CustomerKey = ISNULL(@CustomerKey, '');
    SET @marketLocationKey = ISNULL(@marketLocationKey, '');
    SET @InvoicerKey = ISNULL(@InvoicerKey, '');
    SET @IsDoorToDoor = CASE WHEN @DoorToDoor = 1 THEN 1 WHEN @DoorToDoor = 0 THEN 0 END;
    SET @IsFactored = CASE WHEN @Factored IN (0, 1) THEN @Factored END;
    SET @IsCustApproved = CASE WHEN @CustApproved IN (0, 1) THEN @CustApproved END;

    -- Pre-compute filter flags
    SET @HasCustomerFilter = CASE WHEN @CustomerKey <> '' THEN 1 ELSE 0 END;
    SET @HasMarketLocFilter = CASE WHEN @marketLocationKey <> '' THEN 1 ELSE 0 END;
    SET @HasInvoicerFilter = CASE WHEN @InvoicerKey <> '' THEN 1 ELSE 0 END;
    SET @HasCustCompanyFilter = CASE WHEN @CustCompanyKey <> '' THEN 1 ELSE 0 END;
    SET @HasWarehouseFilter = CASE WHEN @WarehouseStatusKeys <> '' THEN 1 ELSE 0 END;
    SET @HasInvoiceDateFilter = CASE WHEN @InvoiceDateFrom IS NOT NULL AND @InvoiceDateTo IS NOT NULL THEN 1 ELSE 0 END;

    IF LEFT(@InvoiceNo, 1) = '0'
        SET @InvoiceNo = RIGHT(@InvoiceNo, LEN(@InvoiceNo) - 1);

    IF @StatusKey = 16
        SET @StatusKey = 0;

    -- Create filter tables
    CREATE TABLE #CustomerKeys (CustomerKey INT PRIMARY KEY);
    CREATE TABLE #CustCompanyKeys (CustCompanyKey INT PRIMARY KEY);
    CREATE TABLE #MarketLocationKeys (MarketLocationKey INT PRIMARY KEY);
    CREATE TABLE #InvoicerKeys (InvoicerKey INT PRIMARY KEY);
    CREATE TABLE #WarehouseStatusKeys (StatusKey INT PRIMARY KEY);
    CREATE TABLE #OrderDetailKeys (OrderDetailKey INT PRIMARY KEY);
    CREATE TABLE #InvoiceKeys (InvoiceKey INT PRIMARY KEY);

    IF @HasWarehouseFilter = 1
        INSERT INTO #WarehouseStatusKeys (StatusKey)
        SELECT DISTINCT CAST(value AS INT) FROM dbo.Fn_SplitParamCol(@WarehouseStatusKeys);

    IF @HasCustomerFilter = 1
        INSERT INTO #CustomerKeys (CustomerKey)
        SELECT DISTINCT CAST(VALUE AS INT) FROM dbo.Fn_SplitParamCol(@CustomerKey);

    IF @HasCustCompanyFilter = 1
        INSERT INTO #CustCompanyKeys (CustCompanyKey)
        SELECT DISTINCT CAST(VALUE AS INT) FROM dbo.Fn_SplitParamCol(@CustCompanyKey);

    IF @HasMarketLocFilter = 1
        INSERT INTO #MarketLocationKeys (MarketLocationKey)
        SELECT DISTINCT CAST(VALUE AS INT) FROM dbo.Fn_SplitParamCol(@MarketLocationKey);

    IF @HasInvoicerFilter = 1
        INSERT INTO #InvoicerKeys (InvoicerKey)
        SELECT DISTINCT CAST(VALUE AS INT) FROM dbo.Fn_SplitParamCol(@InvoicerKey);

    IF @IsDebug = 1
    BEGIN
        SELECT @StatusKey AS StatusKey, @CustomerKey AS CustomerKey, @OrderKey AS OrderKey,
               @OrderDateFrom AS OrderDateFrom, @OrderDateTO AS OrderDateTO,
               @DeliveryDateFrom AS DeliVeryDateFrom, @DeliveryDateTo AS DeliveryDateTo,
               @OrderNo AS OrderNo, @containerNo AS containerNo, @InvoiceNo AS InvoiceNo,
               @InvoiceKey AS InvoiceKey, @BOL AS BOL, @PageNo AS PageNo, @PageSize AS PageSize,
               @SortField AS SorField, @IsAscending AS IsAscending, @SearchText AS SearchText,
               @marketLocationKey AS marketLocationKey, @Factored AS Factored,
               @CustApproved AS CustApproved, @InvoicerKey AS InvoicerKey,
               @CustCompanyKey AS CustCompanyKey, @ChargeConfirmed AS ChargeConfirmed,
               @WarehouseStatusKeys AS WarehouseStatusKeys, @InvoiceDateFrom AS InvoiceDateFrom,
               @InvoiceDateTo AS InvoiceDateTo, @ReasonCode AS ReasonCode,
               @SearchCriteriaKey AS SearchCriteriaKey,
               @HasMarketLocFilter AS HasMarketLocFilter,
               @HasInvoiceDateFilter AS HasInvoiceDateFilter;

        SELECT '#CustCompanyKeys', CustCompanyKey FROM #CustCompanyKeys;
        SELECT '#CustomerKeys', CustomerKey FROM #CustomerKeys;
        SELECT '#MarketLocationKeys', MarketLocationKey FROM #MarketLocationKeys;
        SELECT '#WarehouseStatusKeys', StatusKey FROM #WarehouseStatusKeys;
    END

    -- Search functionality
    IF ISNULL(@SearchText, '') <> ''
    BEGIN
        SET @IsSearchActive = 1;
        SET @HasComma = CASE WHEN CHARINDEX(',', @SearchText) > 0 THEN 1 ELSE 0 END;

        IF @HasComma = 0
        BEGIN
            INSERT INTO #OrderDetailKeys (OrderDetailKey)
            SELECT DISTINCT OD.OrderDetailKey
            FROM dbo.OrderDetail OD WITH (NOLOCK)
            WHERE LTRIM(RTRIM(OD.ContainerNo)) = @SearchText;

            INSERT INTO #OrderDetailKeys (OrderDetailKey)
            SELECT DISTINCT OD.OrderDetailKey
            FROM dbo.OrderDetail OD WITH (NOLOCK)
            INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
            WHERE OH.OrderNo = @SearchText
              AND NOT EXISTS (SELECT 1 FROM #OrderDetailKeys OK WHERE OK.OrderDetailKey = OD.OrderDetailKey);

            INSERT INTO #InvoiceKeys (InvoiceKey)
            SELECT DISTINCT IH.InvoiceKey
            FROM dbo.InvoiceHeader IH WITH (NOLOCK)
            WHERE IH.InvoiceNo = @SearchText;

            INSERT INTO #InvoiceKeys (InvoiceKey)
            SELECT DISTINCT IC.InvoiceKey
            FROM dbo.InvoiceContainers IC WITH (NOLOCK)
            WHERE LTRIM(RTRIM(IC.ContainerNo)) = @SearchText
              AND NOT EXISTS (SELECT 1 FROM #InvoiceKeys IK WHERE IK.InvoiceKey = IC.InvoiceKey);

            INSERT INTO #InvoiceKeys (InvoiceKey)
            SELECT DISTINCT IH.InvoiceKey
            FROM dbo.InvoiceHeader IH WITH (NOLOCK)
            INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON IH.OrderKey = OH.OrderKey
            WHERE OH.OrderNo = @SearchText
              AND NOT EXISTS (SELECT 1 FROM #InvoiceKeys IK WHERE IK.InvoiceKey = IH.InvoiceKey);
        END
        ELSE
        BEGIN
            IF @SearchCriteriaKey = 1
            BEGIN
                INSERT INTO #OrderDetailKeys (OrderDetailKey)
                SELECT DISTINCT OD.OrderDetailKey
                FROM dbo.OrderDetail OD WITH (NOLOCK)
                WHERE OD.ContainerNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText));

                INSERT INTO #InvoiceKeys (InvoiceKey)
                SELECT DISTINCT IC.InvoiceKey
                FROM dbo.InvoiceContainers IC WITH (NOLOCK)
                WHERE IC.ContainerNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText))
                  AND NOT EXISTS (SELECT 1 FROM #InvoiceKeys IK WHERE IK.InvoiceKey = IC.InvoiceKey);
            END

            IF @SearchCriteriaKey = 2
            BEGIN
                INSERT INTO #OrderDetailKeys (OrderDetailKey)
                SELECT DISTINCT OD.OrderDetailKey
                FROM dbo.OrderDetail OD WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
                WHERE OH.OrderNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText));

                INSERT INTO #InvoiceKeys (InvoiceKey)
                SELECT DISTINCT IH.InvoiceKey
                FROM dbo.InvoiceHeader IH WITH (NOLOCK)
                INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON IH.OrderKey = OH.OrderKey
                WHERE OH.OrderNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText))
                  AND NOT EXISTS (SELECT 1 FROM #InvoiceKeys IK WHERE IK.InvoiceKey = IH.InvoiceKey);
            END

            IF @SearchCriteriaKey = 4
            BEGIN
                INSERT INTO #InvoiceKeys (InvoiceKey)
                SELECT DISTINCT IH.InvoiceKey
                FROM dbo.InvoiceHeader IH WITH (NOLOCK)
                WHERE IH.InvoiceNo IN (SELECT LTRIM(RTRIM(value)) FROM dbo.fn_splitparam(@SearchText));
            END
        END
    END

    IF @IsDebug = 1
    BEGIN
        SELECT '#OrderDetailKeys', OrderDetailKey FROM #OrderDetailKeys;
        SELECT '#InvoiceKeys', InvoiceKey FROM #InvoiceKeys;
    END

    -- Invoice status reference
    SELECT StatusKey, [Description] AS StatusName
    INTO #InvStatus
    FROM dbo.InvoiceStatus WITH (NOLOCK)
    UNION ALL
    SELECT 9, 'Pending to Invoice';

    -- Main result table
    CREATE TABLE #ToInvoice (
        RowId               INT IDENTITY(1,1) PRIMARY KEY,
        OrderKey            INT,
        OrderNo             VARCHAR(50),
        ContainerNo         VARCHAR(500),
        ActualArrival       DATETIME,
        CustId              VARCHAR(100),
        CustName            VARCHAR(200),
        IsInvoiceApproved   BIT,
        StatusKey           SMALLINT,
        InvoiceAmount       NUMERIC(18,2),
        City                VARCHAR(50),
        [Status]            VARCHAR(50),
        DestinationAddrKey  INT,
        InvoiceKey          INT,
        InvoiceNo           VARCHAR(50),
        InvoiceDate         DATETIME,
        DocumentCount       INT DEFAULT 0,
        IsPrinted           BIT,
        PrintedUserKey      INT,
        PaymentRecdUserKey  INT,
        PaymentRecdDate     DATETIME,
        PrintedDate         DATETIME,
        IsRevised           BIT,
        RevisionDate        DATETIME,
        BrokerRefNo         VARCHAR(50),
        IsFactored          BIT,
        VesselETA           VARCHAR(50),
        BalanceAmount       NUMERIC(18,2),
        CustKey             INT,
        OrderDate           DATETIME,
        BillOfLading        VARCHAR(50),
        OrderTypeKey        INT,
        OrderType           VARCHAR(50),
        BookingNo           VARCHAR(50),
        TerminationDate     DATETIME,
        ContainerList       VARCHAR(MAX),
        AddrName            VARCHAR(100),
        MarketLocationKey   INT,
        MarketLocation      VARCHAR(100),
        OrderDetailKey      INT,
        IsPaymentReceived   BIT,
        RevisionUserKey     INT,
        InvoiceApprovedUserKey INT,
        CustomerNote        VARCHAR(MAX),
        InternalNote        VARCHAR(MAX),
        CustApproved        BIT,
        InvoicerKey         INT,
        ReasonCodeKey       INT,
        ReasonCodeName      VARCHAR(100),
        CustCompanyKey      INT,
        AgingDays           INT,
        AprovedReasonCodeKey INT,
        ApprovedReasonCode  VARCHAR(100),
        CustCompanyName     VARCHAR(500),
        RouteKey            INT,
        LegID               VARCHAR(100) DEFAULT '',
        CSR                 VARCHAR(100),
        WarehouseStatus     VARCHAR(100),
        WarehouseStatusKey  INT,
        AllowInvoicing      BIT,
        IsCSChargesApproved BIT,
        CSChargesApproveDate DATETIME,
        ExpCount            INT DEFAULT 0,
        DoorToDoor          BIT,
        InvoicePaymentStatus INT,
        IsDataSelected      BIT DEFAULT 1,
        IsSelectedStatusKey BIT DEFAULT 0,
        INDEX IX_ToInvoice_InvoiceKey (InvoiceKey),
        INDEX IX_ToInvoice_StatusKey (StatusKey),
        INDEX IX_ToInvoice_OrderKey (OrderKey)
    );

    -- Insert pending to invoice records (StatusKey = 9) with filters applied
    INSERT INTO #ToInvoice (
        OrderKey, OrderNo, ContainerNo, CustId, CustName, OrderDetailKey,
        IsInvoiceApproved, StatusKey, InvoiceAmount, City, [Status], DestinationAddrKey,
        InvoiceKey, InvoiceNo, InvoiceDate, IsPrinted, PrintedUserKey,
        PaymentRecdUserKey, PaymentRecdDate, PrintedDate, IsRevised, RevisionDate,
        BrokerRefNo, IsFactored, VesselETA, BalanceAmount, CustKey, OrderDate,
        BillOfLading, OrderTypeKey, OrderType, BookingNo, TerminationDate, AddrName,
        MarketLocationKey, MarketLocation, CustApproved, ReasonCodeKey, ReasonCodeName,
        CustCompanyKey, AgingDays, InvoicerKey, AprovedReasonCodeKey, ApprovedReasonCode,
        CustCompanyName, RouteKey, CSR, WarehouseStatus, WarehouseStatusKey, 
        AllowInvoicing, IsCSChargesApproved, CSChargesApproveDate, ExpCount, DoorToDoor
    )
    SELECT 
        OH.OrderKey, OH.OrderNo, OD.ContainerNo, CU.CustId, CU.CustName, OD.OrderDetailKey,
        0, 9, 0, AD.City, 'Pending to Invoice', OH.DestinationAddrKey,
        0, '', '1900-01-01', 0, 0, 0, '1900-01-01', '1900-01-01', 0, '1900-01-01',
        OH.BrokerRefNo, CU.IsFactored, '', 0, OH.CustKey, OH.OrderDate,
        OH.BillOfLading, OT.OrderTypeKey, OT.OrderType,
        ISNULL(OD.BookingNo, OH.BookingNo),
        OD.CompleteDate, AD.AddrName, ML.MarketLocationKey, ML.MarketLocation,
        0, 0, '', CU.CustomerCompanyKey,
        DATEDIFF(DAY, ISNULL(OD.CompleteDate, GETDATE()), GETDATE()),
        0, 0, '', CC.CompanyName, OD.CurrentRouteKey, CSR.CsrName,
        CASE WHEN CT.OrderDetailKey IS NULL THEN 'N/A' ELSE ISNULL(WS.[Description], 'Open') END,
        CASE WHEN CT.OrderDetailKey IS NULL THEN -1 ELSE ISNULL(WS.StatusKey, 1) END,
        CASE WHEN OD.CompleteDate < DATEADD(DAY, -1, GETDATE()) THEN 1 ELSE 0 END,
        OD.isChargesSharedWithCust, OD.ChargeSharedWithCustDate,
        ISNULL(OE.ExpCount, 0),
        CASE WHEN ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) = 3 THEN 1 ELSE 0 END
    FROM dbo.OrderDetail OD WITH (NOLOCK)
    INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
    INNER JOIN dbo.Customer CU WITH (NOLOCK) ON OH.CustKey = CU.CustKey
    LEFT JOIN dbo.[Address] AD WITH (NOLOCK) ON AD.AddrKey = OH.DestinationAddrKey
    LEFT JOIN dbo.OrderType OT WITH (NOLOCK) ON ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) = OT.OrderTypeKey
    LEFT JOIN dbo.MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey = ML.MarketLocationKey
    LEFT JOIN dbo.CustomerCompany CC WITH (NOLOCK) ON CU.CustomerCompanyKey = CC.CustomerCompanyKey
    LEFT JOIN dbo.CSR CSR WITH (NOLOCK) ON CSR.CsrKey = OH.CsrKey
    LEFT JOIN dbo.vContainerType CT WITH (NOLOCK) ON CT.OrderDetailKey = OD.OrderDetailKey AND CT.TypeID = 'Transload'
    LEFT JOIN dbo.Warehouse_ContainerDetails WCD WITH (NOLOCK) ON OD.OrderDetailKey = WCD.OrderDetailKey
    LEFT JOIN dbo.WarehouseStatus WS WITH (NOLOCK) ON WCD.StatusKey = WS.StatusKey
    LEFT JOIN dbo.vorderExpencesCount OE WITH (NOLOCK) ON OE.OrderDetailKey = OD.OrderDetailKey
    WHERE OD.Status IN (6, 10, 12, 13, 14)
      AND NOT EXISTS (SELECT 1 FROM dbo.RouteInvoice RI WITH (NOLOCK) WHERE RI.OrderDetailKey = OD.OrderDetailKey AND RI.InvoiceKey IS NOT NULL)
      AND NOT EXISTS (SELECT 1 FROM dbo.InvoiceContainers IC WITH (NOLOCK) WHERE IC.OrderDetailsKey = OD.OrderDetailKey)
      AND (@IsSearchActive = 0 OR OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys))
      -- Apply filters during INSERT for pending records
      AND (ISNULL(@OrderKey, 0) = 0 OR OH.OrderKey = @OrderKey)
      AND (@HasCustomerFilter = 0 OR OH.CustKey IN (SELECT CustomerKey FROM #CustomerKeys))
      AND (@HasMarketLocFilter = 0 OR OH.MarketLocationKey IN (SELECT MarketLocationKey FROM #MarketLocationKeys))
      AND (@HasCustCompanyFilter = 0 OR CU.CustomerCompanyKey IN (SELECT CustCompanyKey FROM #CustCompanyKeys))
      AND (ISNULL(@Factored, 2) = 2 OR ISNULL(CU.IsFactored, 0) = @IsFactored)
      AND (ISNULL(@DoorToDoor, 2) = 2 
     OR (@DoorToDoor = 1 AND ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) = 3) 
     OR (@DoorToDoor = 0 AND ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) <> 3))
      AND (@HasWarehouseFilter = 0 
           OR (CT.OrderDetailKey IS NULL AND -1 IN (SELECT StatusKey FROM #WarehouseStatusKeys))
           OR (CT.OrderDetailKey IS NOT NULL AND ISNULL(WS.StatusKey, 1) IN (SELECT StatusKey FROM #WarehouseStatusKeys)));

    IF @IsDebug = 1
    BEGIN
        SELECT '#ToInvoice 1 (Pending)', COUNT(1) FROM #ToInvoice;
    END

    -- Insert already invoiced records with filters applied
    INSERT INTO #ToInvoice (
        OrderKey, OrderNo, ContainerNo, CustId, CustName, OrderDetailKey,
        IsInvoiceApproved, StatusKey, InvoiceAmount, City, [Status], DestinationAddrKey,
        InvoiceKey, InvoiceNo, InvoiceDate, IsPrinted, PrintedUserKey,
        PaymentRecdUserKey, PaymentRecdDate, PrintedDate, IsRevised, RevisionDate,
        BrokerRefNo, IsFactored, VesselETA, BalanceAmount, CustKey, OrderDate,
        BillOfLading, OrderTypeKey, OrderType, BookingNo, TerminationDate, AddrName,
        MarketLocationKey, MarketLocation, IsPaymentReceived, RevisionUserKey,
        InvoiceApprovedUserKey, CustomerNote, InternalNote, CustApproved, ReasonCodeKey,
        ReasonCodeName, CustCompanyKey, AgingDays, InvoicerKey, AprovedReasonCodeKey,
        ApprovedReasonCode, CustCompanyName, RouteKey, CSR, WarehouseStatus, 
        WarehouseStatusKey, AllowInvoicing, DoorToDoor, InvoicePaymentStatus
    )
    SELECT 
        OH.OrderKey, OH.OrderNo, '', CU.CustId, CU.CustName, 0,
        ISNULL(IH.IsInvoiceApproved, 0), ISNULL(IH.StatusKey, 9), IH.InvoiceAmount,
        AD.City, INS.[Description], OH.DestinationAddrKey,
        IH.InvoiceKey, IH.InvoiceNo, IH.InvoiceDate, IH.IsPrinted, IH.PrintedUserKey,
        IH.PaymentRecdUserKey, IH.PaymentRecdDate, IH.PrintedDate, IH.IsRevised, IH.RevisionDate,
        ISNULL(IH.BrokerRefNo, OH.BrokerRefNo), CU.IsFactored, '',
        ISNULL(VIB.BalanceAmount, IH.InvoiceAmount), OH.CustKey, OH.OrderDate,
        OH.BillOfLading, OT.OrderTypeKey, OT.OrderType, OH.BookingNo,
        IC.TerminationDate, AD.AddrName, ML.MarketLocationKey, ML.MarketLocation,
        IH.IsPaymentReceived, IH.RevisionUserKey, IH.InvoiceApprovedUserKey,
        IH.CustomerNote, IH.InternalNote, ISNULL(IH.CustApproved, 0),
        ISNULL(IH.ReasonCodeKey, 0), IR.ReasonCode, CU.CustomerCompanyKey,
        DATEDIFF(DAY, IH.InvoiceDate, GETDATE()), IH.CreateUserKey,
        IH.AprovedReasonCodeKey, IARC.ApprovedReasonCode, CC.CompanyName,
        0, CSR.CsrName, '', 0, 0,
        CASE WHEN OH.OrderTypeKey = 3 THEN 1 ELSE 0 END,
        IP.StatusKey
    FROM dbo.InvoiceHeader IH WITH (NOLOCK)
    INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON IH.OrderKey = OH.OrderKey
    INNER JOIN dbo.Customer CU WITH (NOLOCK) ON IH.CustKey = CU.CustKey
    LEFT JOIN (SELECT InvoiceKey, MAX(TerminationDate) AS TerminationDate FROM dbo.InvoiceContainers WITH (NOLOCK) GROUP BY InvoiceKey) IC ON IH.InvoiceKey = IC.InvoiceKey
    LEFT JOIN dbo.[Address] AD WITH (NOLOCK) ON AD.AddrKey = OH.DestinationAddrKey
    LEFT JOIN dbo.InvoiceStatus INS WITH (NOLOCK) ON INS.StatusKey = IH.StatusKey
    LEFT JOIN dbo.vInvoiceBalanceAmount VIB WITH (NOLOCK) ON IH.InvoiceKey = VIB.InvoiceKey
    LEFT JOIN dbo.OrderType OT WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
    LEFT JOIN dbo.MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey = ML.MarketLocationKey
    LEFT JOIN dbo.InvoiceReasonCode IR WITH (NOLOCK) ON IR.ReasonCodeKey = IH.ReasonCodeKey
    LEFT JOIN dbo.InvoiceCustApprovedReasonCode IARC WITH (NOLOCK) ON IARC.AprovedReasonCodeKey = IH.AprovedReasonCodeKey
    LEFT JOIN dbo.CustomerCompany CC WITH (NOLOCK) ON CU.CustomerCompanyKey = CC.CustomerCompanyKey
    LEFT JOIN dbo.CSR CSR WITH (NOLOCK) ON CSR.CsrKey = OH.CsrKey
    OUTER APPLY (SELECT TOP 1 StatusKey FROM dbo.InvoicePayment WITH (NOLOCK) WHERE InvoiceKey = IH.InvoiceKey ORDER BY PaymentKey DESC) IP
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ArchivedInvoiceHistory AIH WITH (NOLOCK) WHERE AIH.InvoiceKey = IH.InvoiceKey)
      AND NOT (IH.StatusKey = 3 AND IH.CreateDate <= DATEADD(DAY, -60, GETDATE()) AND ISNULL(@InvoiceNo, '') = '' AND ISNULL(@SearchText, '') = '')
      AND (@IsSearchActive = 0 OR IH.InvoiceKey IN (SELECT InvoiceKey FROM #InvoiceKeys))
      -- Apply filters during INSERT for invoiced records
      AND (ISNULL(@OrderKey, 0) = 0 OR OH.OrderKey = @OrderKey)
      AND (@HasCustomerFilter = 0 OR OH.CustKey IN (SELECT CustomerKey FROM #CustomerKeys))
      AND (@HasMarketLocFilter = 0 OR OH.MarketLocationKey IN (SELECT MarketLocationKey FROM #MarketLocationKeys))
      AND (@HasInvoicerFilter = 0 OR IH.CreateUserKey IN (SELECT InvoicerKey FROM #InvoicerKeys))
      AND (@HasCustCompanyFilter = 0 OR CU.CustomerCompanyKey IN (SELECT CustCompanyKey FROM #CustCompanyKeys))
      AND (ISNULL(@CustApproved, 2) = 2 OR ISNULL(IH.CustApproved, 0) = @IsCustApproved)
      AND (ISNULL(@Factored, 2) = 2 OR ISNULL(CU.IsFactored, 0) = @IsFactored)
      AND (ISNULL(@InvoiceNo, '') = '' OR IH.InvoiceNo LIKE @InvoiceNo + '%')
      AND (ISNULL(@InvoiceKey, 0) = 0 OR IH.InvoiceKey = @InvoiceKey)
      AND (@HasInvoiceDateFilter = 0 OR CAST(IH.InvoiceDate AS DATE) BETWEEN @InvoiceDateFrom AND @InvoiceDateTo)
      AND (ISNULL(@ReasonCode, 0) = 0 OR IH.ReasonCodeKey = @ReasonCode)
      AND (ISNULL(@DoorToDoor, 2) = 2 
      OR (@DoorToDoor = 1 AND OH.OrderTypeKey = 3) 
      OR (@DoorToDoor = 0 AND OH.OrderTypeKey <> 3))
      AND (ISNULL(@PaymentStatus, 0) = 0 OR IP.StatusKey = @PaymentStatus);

    IF @IsDebug = 1
    BEGIN
        SELECT '#ToInvoice 2 (Total)', COUNT(1) FROM #ToInvoice;
        SELECT '#ToInvoice by StatusKey', StatusKey, COUNT(1) AS Cnt FROM #ToInvoice GROUP BY StatusKey;
    END

    -- Update ContainerList for invoiced records
    ;WITH InvoiceCounts AS (
        SELECT InvoiceKey, COUNT(1) AS ContCount, STRING_AGG(ContainerNo, ',') AS ContainerList
        FROM dbo.InvoiceContainers WITH (NOLOCK)
        WHERE InvoiceKey IN (SELECT InvoiceKey FROM #ToInvoice WHERE InvoiceKey > 0)
        GROUP BY InvoiceKey
    )
    UPDATE T
    SET ContainerList = IC.ContainerList,
        ContainerNo = CASE WHEN IC.ContCount = 1 THEN IC.ContainerList 
                           ELSE 'Multiple Containers (' + CAST(IC.ContCount AS VARCHAR(10)) + ')' END
    FROM #ToInvoice T
    INNER JOIN InvoiceCounts IC ON T.InvoiceKey = IC.InvoiceKey;

    -- Mark selected status records
    UPDATE #ToInvoice
    SET IsSelectedStatusKey = 1
    WHERE (ISNULL(@SearchText, '') <> '' AND StatusKey = @StatusKey)
       OR (StatusKey IN (1, 2, 3, 9) AND (ISNULL(@StatusKey, 0) = 0 OR StatusKey = @StatusKey));

    SELECT @cnt = COUNT(1) FROM #ToInvoice WHERE IsSelectedStatusKey = 1;

    IF @IsDebug = 1
    BEGIN
        SELECT '#ToInvoice Selected Count', @cnt AS SelectedCount;
        SELECT TOP 10 '#ToInvoice Selected Sample', * FROM #ToInvoice WHERE IsSelectedStatusKey = 1;
    END

    -- Build dashboard counts
    SELECT S.StatusKey, S.StatusName AS [Description], ISNULL(A.cnt, 0) AS InvoiceCount
    INTO #Temp
    FROM #InvStatus S
    LEFT JOIN (SELECT StatusKey, COUNT(1) AS cnt FROM #ToInvoice GROUP BY StatusKey) A ON S.StatusKey = A.StatusKey;

    IF @IsDebug = 1
        SELECT '#Temp', StatusKey, [Description], InvoiceCount FROM #Temp;

    UPDATE A SET LastCount = B.InvoiceCount
    FROM dbo.InvoiceCounts A
    INNER JOIN #Temp B ON A.StatusKey = B.StatusKey;

    SELECT A.StatusKey, B.[Description],
           CASE WHEN ISNULL(B.InvoiceCount, 0) > 0 THEN B.InvoiceCount ELSE A.LastCount END AS InvoiceCount,
           'I' AS [Level]
    INTO #Dashboard
    FROM dbo.InvoiceCounts A WITH (NOLOCK)
    LEFT JOIN #Temp B ON A.StatusKey = B.StatusKey;

    INSERT INTO #Dashboard (StatusKey, [Description], InvoiceCount, [Level])
    SELECT 0, 'All', SUM(InvoiceCount), 'S' FROM #Dashboard;

    IF @IsDebug = 1
        SELECT '#Dashboard', StatusKey, [Description], InvoiceCount, [Level] FROM #Dashboard;

    IF ISNULL(@outputType, '') IN ('Excel', 'PDF')
    BEGIN
        SET @PageNo = 1;
        SET @PageSize = @cnt;
    END

    IF @IsDebug = 1
        SELECT 'Pagination', @PageNo AS PageNo, @PageSize AS PageSize, @cnt AS TotalCount;

    -- Whitelist valid sort fields
    SET @SortField = CASE @SortField
        WHEN 'OrderNo' THEN 'OrderNo'
        WHEN 'ContainerNo' THEN 'ContainerNo'
        WHEN 'InvoiceNo' THEN 'InvoiceNo'
        WHEN 'InvoiceDate' THEN 'InvoiceDate'
        WHEN 'TerminationDate' THEN 'TerminationDate'
        WHEN 'CustName' THEN 'CustName'
        WHEN 'InvoiceAmount' THEN 'InvoiceAmount'
        WHEN 'OrderDate' THEN 'OrderDate'
        ELSE 'TerminationDate'
    END;

    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @SortOrder NVARCHAR(4) = CASE @IsAscending WHEN 0 THEN N'DESC' ELSE N'ASC' END;
    DECLARE @OffsetRows INT = (@PageNo - 1) * @PageSize;

    -- Ensure PageSize is at least 1
    IF @PageSize < 1 SET @PageSize = 50;

    CREATE TABLE #FinalData_Temp (
        OrderKey INT, OrderDetailKey INT, OrderNo VARCHAR(50), ContainerNo VARCHAR(500),
        ActualArrival DATETIME, CustID VARCHAR(100), CustName VARCHAR(200),
        DestinationCity VARCHAR(50), IsInvoiceApproved BIT, StatusKey SMALLINT,
        [Status] VARCHAR(50), InvoiceAmount NUMERIC(18,2), DestinationAddrKey INT,
        InvoiceKey INT, InvoiceNo VARCHAR(50), InvoiceDate DATETIME, DocumentCount INT,
        CustomerNote VARCHAR(MAX), InternalNote VARCHAR(MAX), IsRateVerified BIT,
        ContCount INT, IsPrinted BIT, PrintedUserKey INT, PaymentRecdUserKey INT,
        PaymentRecdDate DATETIME, PrintedDate DATETIME, IsRevised BIT,
        RevisionDate DATETIME, RevisionUserKey INT, ApprovedUserName VARCHAR(100),
        PrintedUserName VARCHAR(100), PaymentRecdUserName VARCHAR(100),
        RevisedUserName VARCHAR(100), IsPaymentReceived BIT, BrokerRefNo VARCHAR(50),
        IsFactored BIT, VesselETA VARCHAR(50), BalanceAmount NUMERIC(18,2),
        CustKey INT, OrderDate DATETIME, BillOfLading VARCHAR(50), BookingNo VARCHAR(50),
        TerminationDate DATETIME, ContainerList VARCHAR(MAX), AddrName VARCHAR(100),
        MarketLocationKey INT, MarketLocation VARCHAR(100), CustApproved BIT,
        ReasonCodeKey INT, ReasonCodeName VARCHAR(100), CustCompanyKey INT, AgingDays INT,
        InvoicerKey INT, AprovedReasonCodeKey INT, OrderTypeKey INT,
        OrderType VARCHAR(50), ApprovedReasonCode VARCHAR(100), CustCompanyName VARCHAR(500),
        InvoicerName VARCHAR(100), RouteKey INT, LegID VARCHAR(100), IsDataSelected BIT,
        IsSelectedStatusKey BIT, CSR VARCHAR(100), WarehouseStatus VARCHAR(100),
        AllowInvoicing BIT, IsCSChargesApproved BIT, CSChargesApproveDate DATETIME,
        ExpCount INT, DoorToDoor BIT, ContainerCount INT, RecCount INT
    );

    SET @SQL = N'
    INSERT INTO #FinalData_Temp (
        OrderKey, OrderDetailKey, OrderNo, ContainerNo, ActualArrival,
        CustID, CustName, DestinationCity, IsInvoiceApproved,
        StatusKey, [Status], InvoiceAmount, DestinationAddrKey,
        InvoiceKey, InvoiceNo, InvoiceDate, DocumentCount,
        CustomerNote, InternalNote, IsRateVerified,
        ContCount, IsPrinted, PrintedUserKey, PaymentRecdUserKey,
        PaymentRecdDate, PrintedDate, IsRevised, RevisionDate, RevisionUserKey,
        ApprovedUserName, PrintedUserName, PaymentRecdUserName, RevisedUserName,
        IsPaymentReceived, BrokerRefNo, IsFactored, VesselETA, BalanceAmount,
        CustKey, OrderDate, BillOfLading, BookingNo, TerminationDate,
        ContainerList, AddrName, MarketLocationKey, MarketLocation, CustApproved,
        ReasonCodeKey, ReasonCodeName, CustCompanyKey, AgingDays, InvoicerKey,
        AprovedReasonCodeKey, OrderTypeKey, OrderType, ApprovedReasonCode,
        CustCompanyName, InvoicerName, RouteKey, LegID, IsDataSelected,
        IsSelectedStatusKey, CSR, WarehouseStatus, AllowInvoicing,
        IsCSChargesApproved, CSChargesApproveDate, ExpCount, DoorToDoor, ContainerCount, RecCount
    )
    SELECT 
        T.OrderKey, T.OrderDetailKey, T.OrderNo, T.ContainerNo, T.ActualArrival,
        T.CustID, T.CustName, T.City, T.IsInvoiceApproved,
        T.StatusKey, T.[Status], T.InvoiceAmount, T.DestinationAddrKey,
        T.InvoiceKey, T.InvoiceNo, T.InvoiceDate, T.DocumentCount,
        T.CustomerNote, T.InternalNote,
        CAST(CASE WHEN T.ExpCount > 0 THEN 1 ELSE 0 END AS BIT),
        NULL, T.IsPrinted, T.PrintedUserKey, T.PaymentRecdUserKey,
        T.PaymentRecdDate, T.PrintedDate, T.IsRevised, T.RevisionDate, T.RevisionUserKey,
        U1.UserName, U2.UserName, U3.UserName, U4.UserName,
        T.IsPaymentReceived, T.BrokerRefNo, T.IsFactored,
        ISNULL(T.VesselETA, ''1900-01-01''), T.BalanceAmount,
        T.CustKey, T.OrderDate, T.BillOfLading, T.BookingNo, T.TerminationDate,
        ISNULL(T.ContainerList, T.ContainerNo), T.AddrName,
        T.MarketLocationKey, T.MarketLocation, T.CustApproved, T.ReasonCodeKey,
        T.ReasonCodeName, T.CustCompanyKey, T.AgingDays, T.InvoicerKey,
        T.AprovedReasonCodeKey, T.OrderTypeKey, T.OrderType, T.ApprovedReasonCode,
        T.CustCompanyName, U5.UserName, T.RouteKey, T.LegID,
        CAST(1 AS BIT), CAST(1 AS BIT),
        T.CSR, T.WarehouseStatus, T.AllowInvoicing,
        CAST(1 AS BIT), T.CSChargesApproveDate,
        T.ExpCount, T.DoorToDoor, NULL, @cnt
    FROM #ToInvoice T
    LEFT JOIN dbo.[User] U1 WITH (NOLOCK) ON T.InvoiceApprovedUserKey = U1.UserKey
    LEFT JOIN dbo.[User] U2 WITH (NOLOCK) ON T.PrintedUserKey = U2.UserKey
    LEFT JOIN dbo.[User] U3 WITH (NOLOCK) ON T.PaymentRecdUserKey = U3.UserKey
    LEFT JOIN dbo.[User] U4 WITH (NOLOCK) ON T.RevisionUserKey = U4.UserKey
    LEFT JOIN dbo.[User] U5 WITH (NOLOCK) ON T.InvoicerKey = U5.UserKey
    WHERE T.IsSelectedStatusKey = 1
    ORDER BY ' + QUOTENAME(@SortField) + ' ' + @SortOrder + ', T.ContainerNo
    OFFSET @OffsetRows ROWS FETCH NEXT @PageSize ROWS ONLY;';

    EXEC sp_executesql @SQL, N'@cnt INT, @OffsetRows INT, @PageSize INT', @cnt, @OffsetRows, @PageSize;

    -- Update OrderDetailKey for invoiced records
    UPDATE A SET OrderDetailKey = IC.OrderDetailsKey
    FROM #FinalData_Temp A
    INNER JOIN dbo.InvoiceContainers IC WITH (NOLOCK) ON A.InvoiceKey = IC.InvoiceKey
    WHERE A.StatusKey IN (1, 2, 3);

    -- Update ExpCount for invoiced records
    UPDATE A SET ExpCount = ISNULL(OE.ExpCount, 0)
    FROM #FinalData_Temp A
    LEFT JOIN dbo.vorderExpencesCount OE WITH (NOLOCK) ON OE.OrderDetailKey = A.OrderDetailKey
    WHERE A.StatusKey IN (1, 2, 3);

    IF @IsDebug = 1
        SELECT '#FinalData_Temp Count', COUNT(1) FROM #FinalData_Temp;

    -- Return final JSON result
    SELECT 
        InvoiceList = (SELECT * FROM #FinalData_Temp FOR JSON PATH),
        DropDowns = (
            SELECT
                CustomerList = (SELECT DISTINCT CustKey, CustName FROM #ToInvoice WHERE IsSelectedStatusKey = 1 AND ISNULL(CustName, '') <> '' ORDER BY CustName FOR JSON PATH),
                CustCompanyList = (SELECT DISTINCT CustCompanyKey, CustCompanyName FROM #ToInvoice WHERE IsSelectedStatusKey = 1 AND ISNULL(CustCompanyName, '') <> '' ORDER BY CustCompanyName FOR JSON PATH),
                MarketLocList = (SELECT DISTINCT MarketLocationKey, MarketLocation FROM #ToInvoice WHERE IsSelectedStatusKey = 1 AND ISNULL(MarketLocation, '') <> '' ORDER BY MarketLocation FOR JSON PATH),
                InvoicerList = (SELECT DISTINCT T.InvoicerKey, U.UserName AS InvoicerName FROM #ToInvoice T LEFT JOIN dbo.[User] U WITH (NOLOCK) ON T.InvoicerKey = U.UserKey WHERE T.IsSelectedStatusKey = 1 AND T.InvoicerKey > 0 ORDER BY U.UserName FOR JSON PATH),
                WarehouseStatus = (SELECT DISTINCT StatusKey, [Description] FROM dbo.WarehouseStatus WITH (NOLOCK) ORDER BY StatusKey FOR JSON PATH),
                ReasonCodeList = (SELECT DISTINCT ReasonCodeKey, ReasonCodeName FROM #ToInvoice WHERE IsSelectedStatusKey = 1 AND ISNULL(ReasonCodeName, '') <> '' ORDER BY ReasonCodeName FOR JSON PATH)
            FOR JSON PATH
        ),
        Dashboard = (SELECT StatusKey, [Description], InvoiceCount, [Level] FROM #Dashboard FOR JSON PATH)
    FOR JSON PATH;

    DROP TABLE IF EXISTS #FinalData_Temp;

    SET @Status = 1;
    SET @Reason = 'Success';
    SET ARITHABORT OFF;
END