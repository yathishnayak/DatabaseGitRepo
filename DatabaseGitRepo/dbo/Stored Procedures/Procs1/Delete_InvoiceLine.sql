
CREATE PROCEDURE [dbo].[Delete_InvoiceLine]
@Invoicelinekey	INT,
@Invoicekey		INT,
@OutPut			BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	declare @InvoiceTotal decimal(18,5) = 0, @NewInvoiceAmount decimal(18,5) = 0, @IsPayReceived bit = 0
	select @InvoiceTotal = InvoiceAmount, @IsPayReceived = IsPaymentReceived from InvoiceHeader where InvoiceKey = @Invoicekey

	DELETE 
	FROM dbo.Invoicedetail
	WHERE Invoicelinekey = @Invoicelinekey and Invoicekey =@Invoicekey;  
	SELECT @NewInvoiceAmount = SUM(ExtAmt) FROM dbo.Invoicedetail WHERE InvoiceKey=@Invoicekey

	UPDATE dbo.InvoiceHeader
	SET InvoiceAmount= @NewInvoiceAmount,
		IsPaymentReceived = case when @InvoiceTotal = @NewInvoiceAmount then @IsPayReceived else 0 end,
		StatusKey = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then 2 else StatusKey end,
		PaymentRecdDate = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then null else PaymentRecdDate end,
		PaymentRecdUserKey = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then null else PaymentRecdUserKey end
	WHERE InvoiceKey=@Invoicekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @OutPut=1
	END	;

END
