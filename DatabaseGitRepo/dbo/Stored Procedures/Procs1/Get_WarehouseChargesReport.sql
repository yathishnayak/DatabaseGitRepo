
CREATE Proc Get_WarehouseChargesReport
(
	@CustomerKey	int = 0,
	@InvoiceNo		int = 0,
	@InvFromDate	datetime = '2022-01-01',
	@InvToDate		datetime	= '2022-12-31',
	@OrderNo		varchar(50) = '',
	@ContainerNo	varchar(50) = ''
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	select CustomerID, CustomerName, InvoiceNo, InvoiceDate, OrderNumber, 
			Container, city, BrokerRefNo, InvoiceAmount, Status, 
			ItemID, UnitPrice, NoOfDays, ExtAmt, CustKey
	from [vInvoiceReportByWarehouseCharges] A
	where
		(@CustomerKey = 0 OR A.CustKey = @CustomerKey) AND
		(@InvoiceNo = 0 OR A.InvoiceNo = @InvoiceNo) AND
		(@InvFromDate =  '2022-01-01' OR A.[InvoiceDate] >= @InvFromDate) AND
		(@InvToDate = '2022-12-31' OR A.[InvoiceDate] <= @InvToDate) AND
		(@ContainerNo = '' OR A.Container = @ContainerNo) AND
		(@OrderNo = '' OR A.OrderNumber = @OrderNo)
END
