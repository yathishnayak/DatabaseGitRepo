/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"TerminationDateFrom":null, "TerminationDateTo":null, "StatusKey":1, "CustKey":3241, "CsrKey":0}'
	EXEC [Get_TerminationReport_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE proc [dbo].[Get_TerminationReport_V2] 
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF


	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

Declare 
	@TerminationDateFrom	dateTime,
	@TerminationDateTo		dateTime,
	@StatusKey				int = NULL,
	@CustKey				int = NULL,
	@CSRKey					int = 0

	SELECT
	@TerminationDateFrom	=	TerminationDateFrom,
	@TerminationDateTo		=   TerminationDateTo,
	@StatusKey				=	Statuskey,
	@CustKey				=	CustKey,
	@CSRKey					=	CSRKey
	FROM OPENJSON (@JSONString, '$')
	WITH(
		TerminationDateFrom		DATETIME	'$.TerminationDateFrom',
		TerminationDateTo		DATETIME	'$.TerminationDateTo',
		StatusKey				INT			'$.StatusKey',
		CustKey					INT			'$.CustKey',
		CSRKey					INT			'$.CsrKey'
	)

	SET @TerminationDateFrom = ISNULL(@TerminationDateFrom,getdate() - 30)
	SET @TerminationDateTo = DATEADD(D,1, ISNULL(@TerminationDateTo, getdate() + 1))
	SET @StatusKey = ISNULL(@StatusKey,0)
	SET @CustKey = ISNULL(@CustKey,0)

	select  distinct
			OD.ContainerNo,
			S.CsrName,
			C.CustID,
			C.CustName,
			OH.OrderNo,
			DA.City AS DestinationCity,
			SA.City AS SourceCity,
			OH.BrokerRefNo,
			OD.CompleteDate,
			IH.InvoiceNo, 
			IH.InvoiceDate,
			IM.ContInvAmt AS ContainerInvoiceAmt,
			isnull(ISS.Description, 'Pending') AS InvoiceStatus
		 
	From orderDetail OD WITH (NOLOCK)
	INNER JOIN OrderHeader OH  WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
	INNER JOIN CUSTOMER C  WITH (NOLOCK) ON OH.CustKey = C.CustKey
	INNER JOIN OrderDetailStatus ODS  WITH (NOLOCK) ON OD.Status = ODS.Status
	LEFT JOIN ADDRESS DA  WITH (NOLOCK) ON OH.DestinationAddrKey = DA.AddrKey
	LEFT JOIN ADDRESS SA  WITH (NOLOCK) ON OH.DestinationAddrKey = SA.AddrKey
	LEFT JOIN CSR S  WITH (NOLOCK) ON OH.CsrKey = S.CsrKey
	left JOIN Invoicedetail  ID WITH (NOLOCK) ON OD.OrderDetailKey = ID.OrderDetailKey
	LEFT JOIN InvoiceHeader IH  WITH (NOLOCK) ON ID.InvoiceKey = IH.InvoiceKey
	left join InvoiceStatus ISS  WITH (NOLOCK) ON IH.StatusKey = ISS.StatusKey
	LEFT JOIN (
		SELECT OrderDetailKey, InvoiceKey, SUM(ExtAmt) AS ContInvAmt
		FROM INVOICEDETAIL ID  WITH (NOLOCK)
		group by OrderDetailKey, InvoiceKey
	) IM  on id.OrderDetailKey = IM.OrderDetailKey AND ID.InvoiceKey = IM.InvoiceKey
	WHERE
		(OD.CompleteDate IS NOT NULL AND OD.CompleteDate BETWEEN @TerminationDateFrom AND @TerminationDateTo) AND
		--(isnull(@StatusKey,0) = 0 OR IH.StatusKey = @StatusKey) AND 
		(
    ISNULL(@StatusKey,0) = 0
    OR (@StatusKey = 1 AND IH.StatusKey IS NULL)
    OR IH.StatusKey = @StatusKey
) AND 
		(isnull(@CustKey,0) = 0 OR OH.CustKey = @CustKey) AND
		(ISNULL(@CSRKey,0)= 0 OR OH.CsrKey = @CSRKey)

		order by OD.ContainerNo, C.CustName
		FOR JSON PATH;

		SET @Status = 1
		SET @Reason = 'Success'
END