CREATE PROCEDURE [dbo].[Update_PmtRecievedInvoice]
/*
Invoice Screen
*/
@InvoiceKey INT,
@Output BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @Output=0;

	UPDATE dbo.InvoiceHeader
	SET IsPaymentReceived=1
	WHERE InvoiceKey= @InvoiceKey;

	SET @Output=1;
END
