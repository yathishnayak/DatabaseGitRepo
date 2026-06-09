



CREATE proc [dbo].[Process_InvoiceReport] 
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	declare 
		@DateFrom	dateTime = '2020-01-01',
		@DateTo		dateTime = '2050-12-31',
		@StatusKey	int = NULL,
		@CustKey	int = NULL,
		@City		varchar(100)='',
		@CSRKey		int = 0,
		@CreateUserKey int = 0

	SET @DateFrom = ISNULL(@DateFrom,GETDATE()-7)
	SET @DateTo = DATEADD(D,1, ISNULL(@DateTo, GETDATE()) )
	SET @StatusKey = 0
	SET @CustKey = ISNULL(@CustKey,0)
	Set @CSRKey = 0

	begin transaction
	begin try
		TRUNCATE TABLE Data_InvoiceReport
	insert into Data_InvoiceReport(
		InvoiceKey, 
		InvoiceNo, 
		InvoiceDate, 
		STATUS, 
		StatusKey, 
		CustKey, 
		CustID, 
		CustName, 
		OrderNo, 
		ContainerCount, 
		DestinationCity, 
		BrokerRefNo, 
		InvoiceAmount, 
		OverDueDays, 
		NetDue, 
		Payments, 
		Credit, 
		Balance, 
		InvoiceType, 
		Containers, 
		CsrKey, 
		CsrName, 
		InvoicerName, 
		CompleteDate,
		CreateUserKey,
		bookingNo
	)
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
			Balance,
			InvoiceType, 
			Replace(Containers,',',', ') as Containers,
			0 as CsrKey, 
			'' as CsrName, 
		   u.UserName as InvoicerName,
			convert(date,'01-01-1970') as CompleteDate ,
			CreateUserKey,
			BookingNo
	From vAllInvoiceStatement VIS WITH (NOLOCK)
		inner join [User] U with(nolock) on u.UserKey = VIS.CreateUserKey

		commit transaction
	end try
	begin catch
	
		PRint ERROR_MESSAGE()
	end catch

	select * from Data_InvoiceReport
END
