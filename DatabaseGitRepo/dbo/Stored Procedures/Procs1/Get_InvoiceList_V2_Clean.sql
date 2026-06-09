

CREATE PROCEDURE [dbo].[Get_InvoiceList_V2_Clean]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX),
    @Status         BIT OUTPUT,
    @Reason         VARCHAR(1000) OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameters not found';
        RETURN;
    END;

    /* -----------------------------
       1. Variables
    ------------------------------*/
    DECLARE
        @StatusKey INT,
        @CustomerKey VARCHAR(MAX),
        @OrderKey INT,
        @OrderNo VARCHAR(50),
        @ContainerNo VARCHAR(50),
        @InvoiceNo VARCHAR(50),
        @BOL VARCHAR(30),
        @PageNo INT = 1,
        @PageSize INT = 10,
        @SortField VARCHAR(50) = 'TerminationDate',
        @IsAscending BIT = 1,
        @SearchText VARCHAR(50),
        @MarketLocationKey VARCHAR(MAX),
        @Factored INT,
        @CustApproved INT,
        @InvoicerKey VARCHAR(MAX),
        @CustCompanyKey VARCHAR(MAX),
        @WarehouseStatusKeys VARCHAR(MAX),
        @ReasonCode INT,
        @DoorToDoor INT,
        @PaymentStatus INT,
        @OrderDateFrom DATE = '2020-01-01',
        @OrderDateTo   DATE = '2099-12-31',
        @InvoiceDateFrom DATE = '2020-01-01',
        @InvoiceDateTo   DATE = '2099-12-31';

    /* -----------------------------
       2. Read JSON
    ------------------------------*/
    SELECT
        @StatusKey = StatusKey,
        @CustomerKey = CustomerKey,
        @OrderKey = OrderKey,
        @OrderNo = OrderNo,
        @ContainerNo = ContainerNo,
        @InvoiceNo = InvoiceNo,
        @BOL = BOL,
        @PageNo = ISNULL(PageNo,1),
        @PageSize = ISNULL(PageSize,10),
        @SortField = ISNULL(SortField,'TerminationDate'),
        @IsAscending = ISNULL(IsAscending,1),
        @SearchText = SearchText,
        @MarketLocationKey = MarketLocationKey,
        @Factored = Factored,
        @CustApproved = CustApproved,
        @InvoicerKey = InvoicerKey,
        @CustCompanyKey = CustCompanyKey,
        @WarehouseStatusKeys = WarehouseStatusKeys,
        @ReasonCode = ReasonCode,
        @DoorToDoor = DoorToDoor,
        @PaymentStatus = PaymentStatus
    FROM OPENJSON(@JSONString)
    WITH (
        StatusKey INT,
        CustomerKey VARCHAR(MAX),
        OrderKey INT,
        OrderNo VARCHAR(50),
        ContainerNo VARCHAR(50),
        InvoiceNo VARCHAR(50),
        BOL VARCHAR(30),
        PageNo INT,
        PageSize INT,
        SortField VARCHAR(50),
        IsAscending BIT,
        SearchText VARCHAR(50),
        MarketLocationKey VARCHAR(MAX),
        Factored INT,
        CustApproved INT,
        InvoicerKey VARCHAR(MAX),
        CustCompanyKey VARCHAR(MAX),
        WarehouseStatusKeys VARCHAR(MAX),
        ReasonCode INT,
        DoorToDoor INT,
        PaymentStatus INT
    );

    /* -----------------------------
       3. Split multi-value params
    ------------------------------*/
    SELECT value INTO #CustomerKeys FROM dbo.Fn_SplitParamCol(@CustomerKey);
    SELECT value INTO #CustCompanyKeys FROM dbo.Fn_SplitParamCol(@CustCompanyKey);
    SELECT value INTO #MarketLocationKeys FROM dbo.Fn_SplitParamCol(@MarketLocationKey);
    SELECT value INTO #InvoicerKeys FROM dbo.Fn_SplitParamCol(@InvoicerKey);
    SELECT value INTO #WarehouseStatus FROM dbo.Fn_SplitParamCol(@WarehouseStatusKeys);

    /* -----------------------------
       4. Main Query (STATIC SQL)
    ------------------------------*/
    ;WITH InvoiceCTE AS
    (
        SELECT
            IH.InvoiceKey,
            IH.InvoiceNo,
            IH.InvoiceDate,
            IH.InvoiceAmount,
            IH.StatusKey,
            OH.OrderKey,
            OH.OrderNo,
            CU.CustName,
            ML.MarketLocation,
            ROW_NUMBER() OVER
            (
                ORDER BY
                  CASE WHEN @SortField='TerminationDate' AND @IsAscending=1 THEN IH.InvoiceDate END ASC,
                  CASE WHEN @SortField='TerminationDate' AND @IsAscending=0 THEN IH.InvoiceDate END DESC,
                  CASE WHEN @SortField='OrderNo' AND @IsAscending=1 THEN OH.OrderNo END ASC,
                  CASE WHEN @SortField='OrderNo' AND @IsAscending=0 THEN OH.OrderNo END DESC,
                  CASE WHEN @SortField='InvoiceNo' AND @IsAscending=1 THEN IH.InvoiceNo END ASC,
                  CASE WHEN @SortField='InvoiceNo' AND @IsAscending=0 THEN IH.InvoiceNo END DESC,
                  CASE WHEN @SortField='CustName' AND @IsAscending=1 THEN CU.CustName END ASC,
                  CASE WHEN @SortField='CustName' AND @IsAscending=0 THEN CU.CustName END DESC
            ) AS RowNum
        FROM InvoiceHeader IH
        JOIN OrderHeader OH ON IH.OrderKey = OH.OrderKey
        JOIN Customer CU ON IH.CustKey = CU.CustKey
        LEFT JOIN MarketLocation ML ON OH.MarketLocationKey = ML.MarketLocationKey
        WHERE
            (@OrderKey = 0 OR IH.OrderKey = @OrderKey)
            AND (@CustomerKey = '' OR CU.CustKey IN (SELECT value FROM #CustomerKeys))
            AND (@CustCompanyKey = '' OR CU.CustomerCompanyKey IN (SELECT value FROM #CustCompanyKeys))
            AND (@MarketLocationKey = '' OR ML.MarketLocationKey IN (SELECT value FROM #MarketLocationKeys))
            AND (@InvoicerKey = '' OR IH.CreateUserKey IN (SELECT value FROM #InvoicerKeys))
            AND (@WarehouseStatusKeys = '' OR IH.StatusKey IN (SELECT value FROM #WarehouseStatus))
            AND (IH.InvoiceDate BETWEEN @InvoiceDateFrom AND @InvoiceDateTo)
            AND (ISNULL(@SearchText,'')='' OR
                 OH.OrderNo LIKE '%' + @SearchText + '%' OR
                 IH.InvoiceNo LIKE '%' + @SearchText + '%' OR
                 CU.CustName LIKE '%' + @SearchText + '%')
    )
    SELECT *
    FROM InvoiceCTE
    WHERE RowNum BETWEEN ((@PageNo-1)*@PageSize+1) AND (@PageNo*@PageSize)
    ORDER BY RowNum;

    SET @Status = 1;
    SET @Reason = 'Success';
END;
