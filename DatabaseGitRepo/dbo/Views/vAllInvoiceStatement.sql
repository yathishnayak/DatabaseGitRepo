CREATE view [dbo].[vAllInvoiceStatement]
as
	select CustID, CustName, OrderNo, ContainerCount, DestinationCity, BrokerRefNo, InvoiceNo, InvoiceDate, 
			InvoiceKey, CustKey, DueDate, StatusKey, Description, OverDueDays, InvoiceAmount, Payments, 
			Credit, Balance, InvoiceType , Containers, CsrKey, CsrName, CompleteDate,CreateUserKey, BookingNo,
			InvoiceCompanyKey
	From vInvoiceStatement With (NoLock)

	union all

	select CustID, CustName, OrderNo, ContainerCount, DestinationCity, BrokerRefNo, PPInvoiceNo, PPInvoiceDate, 
			PPInvoiceKey, CustomerKey, DueDate, StatusKey, Description, OverDueDays, PPInvoiceAmount, Payments, 
			Credit, Balance, InvoiceType  , Containers, CsrKey, CsrName, CompleteDate,CreatedUserKey, BookingNo,
			InvoiceCompanyKey
	From vPrepayInvoiceStatement With (NoLock)

	union all

	select CustID, CustName, OrderNo, ContainerCount, DestinationCity, BrokerRefNo, MInvoiceNo, MInvoiceDate, 
			MInvoiceKey, CustomerKey, DueDate, StatusKey, Description, OverDueDays, MInvoiceAmount, Payments, 
			Credit, Balance, InvoiceType  , Containers, CsrKey, CsrName, CompleteDate,CreatedUserKey, BookingNo,
			InvoiceCompanyKey
	From vManualInvoiceStatement With (NoLock)

