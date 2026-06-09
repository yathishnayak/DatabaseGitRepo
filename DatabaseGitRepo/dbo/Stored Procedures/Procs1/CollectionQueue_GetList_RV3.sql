-- [CollectionQueue_GetList_RV3]  @StatusCodeKey=0 , @DATEFROM = '2022-01-01', @CustomerKey = 0, @DateTo='2023-09-16' ,@CustomerType=2
CREATE PROCEDURE [dbo].[CollectionQueue_GetList_RV3]
(
	@StatusCodeKey INT = 0,
	@CustomerKey INT = 0,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@DestinationCity VARCHAR(100) = '',
	@InvoicerKey INT = 0,
	@CustomerType INT = 0,
	@BillingCompanyKey INT = 0,
	@OrderNo VARCHAR(100) = '',
	@OrderDateFrom DATETIME = '2020-01-01',
	@OrderDateTo DATETIME = '2020-01-01',
	@DeliveryDateFrom DATETIME = '2020-01-01',
	@DeliveryDateTo DATETIME = '2020-01-01',
	@ContainerNo VARCHAR(100) = '',
	@InvoiceNo VARCHAR(100) = '',
	@BOL VARCHAR(100) = '',
	@MarketLocationKey INT = 0,
	@SearchText VARCHAR(100) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @DateFrom = ISNULL(@DateFrom, '2023-12-01');
	SET @DateTo = DATEADD(DAY, 1, ISNULL(@DateTo, GETDATE()));

	DECLARE @IsFactored BIT,
			@OpenCount INT = 0, 
			@ReviewCount INT = 0, 
			@PendingCount INT = 0, 
			@DeniedCount INT = 0, 
			@ApprovedCount INT = 0,
			@RevisedCount INT = 0;

	SET @IsFactored = CASE WHEN @CustomerType = 1 THEN 1 ELSE 0 END;

	IF (@StatusCodeKey = 0)
	BEGIN
		SELECT  
			CAST(0 AS INT) AS CollectionRecordKey,
			H.InvoiceKey,
			H.InvoiceNo,
			H.InvoiceDate,
			C.CustID,
			C.CustName,
			C.IsFactored AS CustomerType,
			ContainerCount,
			DestinationCity,
			H.BrokerRefNo,
			H.InvoiceAmount,
			Payments,
			Balance,
			Containers,
			U.UserName AS InvoicerName,
			H.CreateUserKey,
			CAST(0 AS INT) AS StatusCodeKey,
			H.CreateUserKey AS InvoicerKey,
			C.CustKey AS CustomerKey,
			OH.BookingNo,
			@OpenCount AS OpenCount,
			@ReviewCount AS ReviewCount,
			@PendingCount AS PendingCount,
			@DeniedCount AS DeniedCount,
			@ApprovedCount AS ApprovedCount,
			@RevisedCount AS RevisedCount,
			IRC.ReasonCode
		FROM Data_InvoiceReport H WITH(NOLOCK)
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = H.CustKey
		INNER JOIN [User] U ON U.UserKey = H.CreateUserKey	
		INNER JOIN InvoiceHeader IH WITH(NOLOCK) ON IH.InvoiceKey = H.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = IH.OrderKey
		LEFT JOIN InvoiceReasonCode IRC WITH(NOLOCK) ON IRC.ReasoncodeKey = IH.ReasoncodeKey
		WHERE 	
			(@CustomerKey = 0 OR H.CustKey = @CustomerKey)
			AND H.InvoiceDate BETWEEN @DateFrom AND @DateTo
			AND (@DestinationCity = '' OR H.DestinationCity = @DestinationCity)
			AND (@InvoiceNo = '' OR H.InvoiceNo = @InvoiceNo)
			AND (@BillingCompanyKey = 0 OR IH.InvoiceCompanyKey = @BillingCompanyKey)
			AND NOT EXISTS (
				SELECT 1 
				FROM CollectionQueue CQ WITH(NOLOCK) 
				WHERE CQ.InvoiceKey = H.InvoiceKey 
				AND CQ.StatusCodeKey <> 1
			)
			AND (@ContainerNo = '' OR H.Containers LIKE '%' + @ContainerNo + '%')
			AND (@OrderNo = '' OR H.OrderNo = @OrderNo)
			AND (@BOL = '' OR OH.BillOfLading = @BOL)
			AND (@MarketLocationKey = 0 OR OH.MarketLocationKey = @MarketLocationKey)
		FOR JSON PATH
	END
	ELSE 
	BEGIN
		SELECT 
			CollectionRecordKey,
			Q.InvoiceKey,
			Q.InvoiceNo,
			Q.InvoiceDate,
			C.CustID,
			C.CustName,
			C.IsFactored AS CustomerType,
			ContainerCount,
			DestinationCity,
			Q.BrokerRefNo,
			Q.InvoiceAmount,
			Payments,
			Balance,
			Containers,
			U.UserName AS InvoicerName,
			Q.StatusCodeKey,
			Q.OrderDetailKey,
			InvoicerKey,
			C.CustKey AS CustomerKey,
			@OpenCount AS OpenCount,
			@ReviewCount AS ReviewCount,
			@PendingCount AS PendingCount,
			OH.BookingNo,
			@DeniedCount AS DeniedCount,
			@ApprovedCount AS ApprovedCount,
			@RevisedCount AS RevisedCount,
			IRC.ReasonCode
		FROM CollectionQueue Q WITH(NOLOCK)
		INNER JOIN CollectionStatuCode S WITH(NOLOCK) ON S.StatusCodeKey = Q.StatusCodeKey
		INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = Q.CustomerKey
		INNER JOIN InvoiceHeader H WITH(NOLOCK) ON H.InvoiceKey = Q.InvoiceKey
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = H.OrderKey
		LEFT JOIN [User] U WITH(NOLOCK) ON U.UserKey = Q.InvoicerKey
		LEFT JOIN InvoiceReasonCode IRC WITH(NOLOCK) ON IRC.ReasoncodeKey = H.ReasoncodeKey
		WHERE 
			(@StatusCodeKey = 0 OR S.StatusCodeKey = @StatusCodeKey)
			AND (@CustomerKey = 0 OR Q.CustomerKey = @CustomerKey)
			AND Q.InvoiceDate BETWEEN @DateFrom AND @DateTo
			AND (@DestinationCity = '' OR Q.DestinationCity = @DestinationCity)
			AND (@InvoicerKey = 0 OR Q.InvoicerKey = @InvoicerKey)
			AND (@InvoiceNo = '' OR Q.InvoiceNo = @InvoiceNo)
			AND (@BillingCompanyKey = 0 OR H.InvoiceCompanyKey = @BillingCompanyKey)
			AND (@ContainerNo = '' OR Q.Containers LIKE '%' + @ContainerNo + '%')
			AND (@OrderNo = '' OR OH.OrderNo = @OrderNo)
			AND (@BOL = '' OR OH.BillOfLading = @BOL)
			AND (@MarketLocationKey = 0 OR OH.MarketLocationKey = @MarketLocationKey)
		FOR JSON PATH
	END
END
