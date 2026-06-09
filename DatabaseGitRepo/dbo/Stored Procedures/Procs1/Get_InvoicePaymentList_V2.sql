/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"DateFrom":"2025-08-18T00:00:00.000Z","DateTo":"2025-08-21T00:00:00.000Z","CustKey":0,"InvoiceNo":"","ChequeNo":"","PageNo":1,"PageSize":10,"PaymentStatusKey":null}',
	@Status BIT=0,@IsDebug		BIT = 1,
	@Reason VARCHAR(100)=''
EXec Get_InvoicePaymentList_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT,@IsDebug
Select @Status, @Reason
**/
CREATE Procedure [dbo].[Get_InvoicePaymentList_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;
	SET Concat_null_Yields_null ON;

	DECLARE @ChequeNo		VARCHAR(50) = '',
	@DateFrom		DATETIME = '2000-01-01',
	@DateTo			DATETIME = '2050-12-31',
	@CustKey		INT = 0,
	@InvoiceNo		VARCHAR(50) = '',
	@PaymentStatusKey  INT,
	@PageNo			INT = 1,
	@PageSize		INT	= 10

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END

	SELECT			@ChequeNo			= ChequeNo,			@DateFrom		= DateFrom,		@DateTo			= DateTo,			
					@CustKey		= CustKey	,		@InvoiceNo		= InvoiceNo,		@PaymentStatusKey	= PaymentStatusKey,	
					@PageNo		= PageNo,		@PageSize			= PageSize
	FROM	OPENJSON(@JsonString, '$')
			WITH (
					ChequeNo			NVARCHAR(100)	'$.ChequeNo',
					DateFrom			DATE			'$.DateFrom',
					DateTo				DATE			'$.DateTo',
					CustKey				INT				'$.CustKey',
					InvoiceNo			NVARCHAR(100)	'$.InvoiceNo',
					PaymentStatusKey	INT				'$.PaymentStatusKey',
					PageNo				INT				'$.PageNo',
					PageSize			INT				'$.PageSize'
				)

	IF  @DateFrom IS NULL OR @DateFrom = '1900-01-01'
    SET @DateFrom = DATEADD(DAY, -280, GETDATE()) ;

	IF  @DateTo IS NULL OR @DateTo = '1900-01-01'
    SET @DateTo =  '2050-12-31';

	SELECT		 top 100	IP.InvoiceKey, IP.InvoiceType, IP.PaymentKey, Ip.PaidAmount, Ip.PaymentReference, IP.PaymentDate, ISNULL(Ip.Note,'') Note, 
					I.InvoiceAmount, I.InvoiceNo, I.InvoiceDate, IPS.StatusKey AS PaymentStatusKey ,IPS.Description as PaymentStatus,
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
					( isnull(@DateFrom, '2000-01-01') = '2000-01-01' OR IP.PaymentDate >= @DateFrom) AND
					( isnull(@DateTo, '2050-12-31') = '2050-12-31' OR IP.PaymentDate <= @DateTo) AND
					( isnull(@CustKey,0) = 0 OR i.CustKey = @CustKey ) AND
					( isnull(@InvoiceNo,'') = '' OR I.InvoiceNo = @InvoiceNo) AND
					( isnull(@PaymentStatusKey,0) = 0 OR IPS.StatusKey = @PaymentStatusKey) 


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
	FOR JSON PATH

	SET		@Status = 1
	SET		@Reason = 'SUCCESS'

	DROP TABLE		#TMP
END