

CREATE PROCEDURE [dbo].[Update_InvoiceDate]
(
@InvoiceKey		INT,
@InvoiceDate	DateTime,
@UserKey		INT,
@OutPut			BIT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	declare @PrevInvoicedate datetime;

	select @PrevInvoicedate = InvoiceDate from InvoiceHeader where InvoiceKey = @InvoiceKey

	UPDATE dbo.InvoiceHeader
	SET 		
		InvoiceDate		= @InvoiceDate,
		UpdateUserKey	= @UserKey,
		UpdateDate	= GETDATE()
	WHERE InvoiceKey = @InvoiceKey;

	Update A set DueDate =  DATEADD (d, C.Days,  A.InvoiceDate ) 
	from InvoiceHeader A
	inner join  Customer  B on (A.CustKey = B.CustKey)
	inner join  PaymentTerms C on (B.PaymentTermsKey = C.PaymentTermsKey)
	WHERE A.InvoiceKey = @InvoiceKey;

	insert into Invoice_Log (InvoiceKey, LogDate, LogText, ActionUserKey)
	select					 @InvoiceKey, GETDATE(), 'Invoice Date changed from ' + convert(varchar,@PrevInvoicedate,101) 
			+ ' to ' + convert(varchar,@InvoiceDate,101) , @UserKey
	SET @OutPut=1;
END
