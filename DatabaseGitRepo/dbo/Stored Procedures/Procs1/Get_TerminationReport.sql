

CREATE proc [dbo].[Get_TerminationReport] -- Get_TerminationReport @STATUSKEY = 0, @TerminationDateFrom = '2021-01-01', @CUSTKEY = 0, @TerminationDateTo='2022-09-16'
(
	@TerminationDateFrom	dateTime = '2020-01-01',
	@TerminationDateTo		dateTime = '2050-12-31',
	@StatusKey				int = NULL,
	@CustKey				int = NULL,
	@CSRKey		int = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

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
		(isnull(@StatusKey,0) = 0 OR IH.StatusKey = @StatusKey) AND 
		(isnull(@CustKey,0) = 0 OR OH.CustKey = @CustKey) AND
		(ISNULL(@CSRKey,0)= 0 OR OH.CsrKey = @CSRKey)

		order by OD.ContainerNo, C.CustName
END
