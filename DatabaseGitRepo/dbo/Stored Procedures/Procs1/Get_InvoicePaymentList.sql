CREATE Procedure [dbo].[Get_InvoicePaymentList]-- Get_InvoicePaymentList @ChequeNo='',0,
(
	@ChequeNo		VARCHAR(50) = '',
	@DateFrom		DATETIME = '2000-01-01',
	@DateTo			DATETIME = '2050-12-31',
	@CustKey		INT = 0,
	@InvoiceNo		VARCHAR(50) = '',
	@PageNo			INT = 1,
	@PageSize		INT	= 10
)
as
BEGIN
	SELECT			IP.InvoiceKey, IP.InvoiceType, IP.PaymentKey, Ip.PaidAmount, Ip.PaymentReference, IP.PaymentDate, ISNULL(Ip.Note,'') Note, 
					I.InvoiceAmount, I.InvoiceNo, I.InvoiceDate, IPS.Description as PaymentStatus,
					C.CustID, C.CustName, A.AddrName, A.City, A.ZipCode, A.State, A.Country,
					ROW_NUMBER() over (Order by IP.InvoiceKey, IP.PaymentKey ) as RowNum
	INTO			#TMP
	FROM			InvoicePayment IP WITH (NOLOCK)
	LEFT JOIN		(SELECT			InvoiceKey, InvoiceNo, InvoiceDate, InvoiceAmount, CustKey, StatusKey, 'I' AS InvoiceType
					FROM			InvoiceHeader IH WITH (NOLOCK)
					--WHERE StatusKey > 1
					union all
					SELECT			PPInvoiceKey, PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount, CustomerKey, StatusKey, 'P' AS InvoiceType
					FROM			PrepayInvoiceHeader IH WITH (NOLOCK)
					--WHERE StatusKey > 1
					union all 
					SELECT			MInvoiceKey, MInvoiceNo, MInvoiceDate, MInvoiceAmount, CustomerKey, StatusKey, 'M' AS InvoiceType
					FROM			ManualInvoiceHeader IH WITH (NOLOCK)
					--WHERE StatusKey > 1
					) I on IP.InvoiceKey = I.InvoiceKey and IP.InvoiceType = I.InvoiceType
	LEFT JOIN		Customer C WITH (NOLOCK) ON i.CustKey = c.CustKey
	LEFT JOIN		Address a WITH (NOLOCK) ON C.AddrKey = A.AddrKey
	LEFT JOIN       InvoicePaymentStatus IPS WITH (NOLOCK) ON IPS.StatusKey = IP.StatusKey
	WHERE			( isnull(@ChequeNo,'') = '' OR LTRIM(RTRIM(IP.PaymentReference)) = LTRIM(RTRIM(@ChequeNo)) ) AND
					( isnull(@DateFrom, '2000-01-01') = '2000-01-01' OR ip.PaymentDate >= @DateFrom) AND
					( isnull(@DateTo, '2050-12-31') = '2050-12-31' OR ip.PaymentDate <= @DateTo) AND
					( isnull(@CustKey,0) = 0 OR i.CustKey = @CustKey ) AND
					( isnull(@InvoiceNo,'') = '' OR I.InvoiceNo = @InvoiceNo)


	DECLARE			@RecCount INT = 0, @PaidAmtTotal DECIMAL(18,2)

	SET				@RecCount = (SELECT COUNT(*) FROM #TMP )
	SET				@PaidAmtTotal = (SELECT SUM(PaidAmount) FROM #TMP )

	DECLARE			@RecFrom int, @RecTo  int
	SELECT			@RecFrom = ((@PageNo - 1) * @PageSize) + 1
	SELECT			@RecTo = (@RecFrom +  @PageSize)-1


	SELECT			*, @RecCount RecCount , @PaidAmtTotal AS PaidAmtTotal
	FROM			#TMP
	WHERE			RowNum between @RecFrom and @RecTo
	ORDER BY		RowNum 

	DROP TABLE		#TMP
END