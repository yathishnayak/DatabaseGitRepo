CREATE proc [dbo].[Get_InvoiceReport] -- Get_InvoiceReport @STATUSKEY = 2, @DATEFROM = '2021-01-01', @CUSTKEY = 0, @DateTo='2022-09-16' ,@CustomerType=2
(
	@DateFrom	dateTime = '2020-01-01',
	@DateTo		dateTime = '2050-12-31',
	@StatusKey	int = NULL,
	@CustKey	int = NULL,
	@City		varchar(100)='',

	@CSRKey		int = 0,
	@CreateUserKey int = 0,
	@CustomerType	int = 0 , -- IsFactored= 0, Non-Factored = 1, all=2
	@BillingCompanykey int = 0,
	@MarketLocationKey int = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SET @DateFrom = ISNULL(@DateFrom,GETDATE()-7)
	SET @DateTo = DATEADD(D,1, ISNULL(@DateTo, GETDATE()) )
	SET @StatusKey = ISNULL(@StatusKey,2)
	SET @CustKey = ISNULL(@CustKey,0)
	Set @CSRKey = 0
	
	DECLARE @IsFactored BIT
	IF @CustomerType=0
	BEGIN
		SET @IsFactored=0
	END
	IF @CustomerType=1
	BEGIN
		SET @IsFactored=1
	END
	
	
	select  DI.InvoiceKey,
			DI.InvoiceNo,
			DI.InvoiceDate,
			DI.STATUS,
			DI.StatusKey,
			DI.CustKey,
			DI.CustID,
			DI.CustName,
			DI.OrderNo,
			DI.ContainerCount,
			DI.DestinationCity,
			DI.BrokerRefNo,
			DI.InvoiceAmount,
			OverDueDays,
			DI.Balance as NetDue,
			DI.Payments, 
			Credit, 
			DI.Balance,
			DI.InvoiceType, 
			DI.Containers,
			0 as CsrKey, 
			'' as CsrName, 
		   InvoicerName,
			convert(date,'01-01-1970') as CompleteDate, -- ISNULL(CompleteDate,'01-01-1970') AS CompleteDate
			CONVERT(BIT,ISNULL(A.IsApproved,0)) AS IsApproved, A.ApprovedDate,
			ISNULL(U.UserName,'') AS UserName, S.StatusCodeName,IRC.ReasonCode,ICARC.ApprovedReasonCode
--	From vAllInvoiceStatement VIS WITH (NOLOCK)
--		inner join [User] U with(nolock) on u.UserKey = VIS.CreateUserKey

	From Data_InvoiceReport DI
	LEFT JOIN customer C WITH (NOLOCK) ON C.CustKey=DI.CustKey
	LEFT JOIN InvoiceHeader H WITH(NOLOCK) ON H.InvoiceKey = DI.InvoiceKey
	LEFT JOIN InvoiceApproval A WITH (NOLOCK) ON DI.InvoiceType = A.InvoiceType AND DI.InvoiceKey = A.InvoiceKey
	LEFT JOIN [User] U WITH (NOLOCK) ON A.ApprovedUserKey = U.UserKey
	LEFT JOIN CollectionQueue Q WITH(NOLOCK) ON Q.InvoiceKey = DI.InvoiceKey
	LEFT JOIN CollectionStatuCode S WITH(NOLOCK) ON S.StatusCodeKey = Q.StatusCodeKey
	LEFT JOIN InvoiceReasonCode IRC WITH (NOLOCK) ON IRC.ReasoncodeKey=H.ReasoncodeKey
	LEFT JOIN InvoiceCustApprovedReasonCode ICARC WITH (NOLOCK) ON ICARC.AprovedReasonCodeKey=H.AprovedReasonCodeKey
	LEFT JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey = H.OrderKey
	WHERE
		(DI.InvoiceDate BETWEEN @DateFrom AND @DateTo) AND
		(ISNULL(@StatusKey,0) = 0 OR DI.StatusKey = @StatusKey) AND 
		(DI.CustKey = @CustKey OR @CustKey = 0) AND
		(ISNULL(@city,'')= '' OR DI.DestinationCity like '%' + @City + '%') AND
		(ISNULL(@CSRKey,0)= 0 OR DI.CsrKey = @CSRKey) AND
		(iSNULL(@CreateUserKey,0)= 0 OR DI.CreateUserKey = @CreateUserKey)AND
		(ISNULL(@CustomerType,2)=2 OR ISNULL(C.IsFactored,0)=@IsFactored) AND
		(ISNULL(@BillingCompanykey,0) = 0 OR ISNULL(H.InvoiceCompanyKey,0) = @BillingCompanykey) AND
		((ISNULL(@MarketLocationKey,0) = 0) OR (OH.MarketLocationKey = @MarketLocationKey))
		ORDER BY DI.CustName,DI.InvoiceDate
END
