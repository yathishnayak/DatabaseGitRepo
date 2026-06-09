
CREATE PROC [dbo].[Delete_InvoiceFull]
(
	@InvoiceKey		INT,
	@DeleteUserKey	INT,
	@OUTPUT			BIT = 0 OUTPUT
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE @TRAN VARCHAR(50) = 'INVOICE_TRAN'
	BEGIN TRANSACTION @TRAN;
	BEGIN TRY 
		DECLARE @CNT INT = 0

		SET @OUTPUT = 0
		
		SELECT @CNT = COUNT(1) FROM InvoiceHeader WHERE InvoiceKey = @InvoiceKey AND StatusKey = 1

		IF(@CNT > 0)
		BEGIN
			PRINT '1'
			INSERT INTO InvoiceHeader_Deleted (InvoiceKey, InvoiceNo, InvoiceDate, CustKey, BillToAddrKey, InvoiceAmount, 
				DueDate, InvoiceType, CompanyKey, StatusKey, CreateUserKey, IsInvoiceApproved, IsPaymentReceived, CreateDate,
				UpdateUserKey, UpdateDate, InvoiceApprovedUserKey, InvoiceApprovedDate, OrderKey, CustomerNote, InternalNote, 
				IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, IsRevised, RevisionDate, PrintedDate, 
				RevisionUserKey, BrokerRefNo, DeleteUserKey, DeletedDate)
			select InvoiceKey, InvoiceNo, InvoiceDate, CustKey, BillToAddrKey, InvoiceAmount, 
				DueDate, InvoiceType, CompanyKey, StatusKey, CreateUserKey, IsInvoiceApproved, IsPaymentReceived, CreateDate,
				UpdateUserKey, UpdateDate, InvoiceApprovedUserKey, InvoiceApprovedDate, OrderKey, CustomerNote, InternalNote, 
				IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, IsRevised, RevisionDate, PrintedDate, 
				RevisionUserKey, BrokerRefNo, @DeleteUserKey, GETDATE()
			from InvoiceHeader
			where InvoiceKey = @InvoiceKey

			PRINT '2'
			INSERT INTO Invoicedetail_Deleted (InvoicelineKey, InvoiceKey, ItemKey, Description, UnitPrice, Qty, ExtAmt, Container, 
				OrderDetailKey, CreateUserKey, CreateDate, UpdateUserKey, UpdateDate, DeleteUserKey, DeletedDate)
			SELECT InvoicelineKey, InvoiceKey, ItemKey, Description, UnitPrice, Qty, ExtAmt, Container, 
				OrderDetailKey, CreateUserKey, CreateDate, UpdateUserKey, UpdateDate, @DeleteUserKey, GETDATE()
			FROM Invoicedetail 
			WHERE InvoiceKey = @InvoiceKey

			PRINT '3'
			insert into InvoiceContainers_Deleted (InvoiceKey, OrderDetailsKey, ContainerNo, TerminationDate,DeleteUserKey, DeletedDate )
			select InvoiceKey, OrderDetailsKey, ContainerNo, TerminationDate, @DeleteUserKey, Getdate() 
			from InvoiceContainers WHERE InvoiceKey = @InvoiceKey 

			PRINT '4'
			DELETE FROM Invoicedetail WHERE InvoiceKey = @InvoiceKey

			PRINT '5'
			DELETE FROM InvoiceContainers WHERE InvoiceKey = @InvoiceKey

			PRINT '6'
			DELETE FROM RouteInvoice WHERE InvoiceKey = @InvoiceKey

			PRINT '7'
			DELETE FROM InvoiceHeader WHERE InvoiceKey = @InvoiceKey

			SET @OUTPUT = 1
			COMMIT TRANSACTION @TRAN;
		END
		RETURN
	 END TRY
	 BEGIN CATCH
		PRINT 'ERROR'
		ROLLBACK TRANSACTION @TRAN
	 END CATCH
END
