

CREATE proc [dbo].[Get_InvoiceExportData] -- Get_InvoiceExportData @STATUSKEY = 2, @DATEFROM = '2021-01-01', @CUSTKEY = 0, @DateTo='2022-03-16'
(
	@DateFrom	dateTime = NULL,
	@DateTo		dateTime = NULL,
	@StatusKey	int = NULL,
	@CustKey	int = NULL,
	@City		varchar(100)
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SET @DateFrom = ISNULL(@DateFrom,GETDATE()-7)
	SET @DateTo = DATEADD(D,1, ISNULL(@DateTo, GETDATE()) )
	SET @StatusKey = ISNULL(@StatusKey,2)
	SET @CustKey = ISNULL(@CustKey,0)

	select  InvoiceKey,
			InvoiceNo,
			InvoiceDate,
			Description AS STATUS,
			StatusKey,
			CustKey,
			VIS.CustID,
			VIS.CustName,
			VIS.OrderNo,
			ContainerCount,
			VIS.DestinationCity,
			VIS.BrokerRefNo,
			VIS.InvoiceAmount,
			VIS.OverDueDays,
			VIS.Balance as NetDue,
			Payments, 
			Credit, 
			Balance
	From vInvoiceStatement VIS
	WHERE
		(InvoiceDate BETWEEN @DateFrom AND @DateTo) AND
		(isnull(@StatusKey,0) = 0 OR StatusKey = @StatusKey) AND 
		(CustKey = @CustKey or @CustKey = 0) AND
		(isnull(@city,'')= '' OR VIS.DestinationCity like '%' + @City + '%')
END
