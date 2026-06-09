CREATE PROCEDURE [dbo].[Get_InvoiceOrderKey]
/*
InvoiceDL
*/
@InvoiceKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT OrderKey 
	FROM dbo.OrderInvoices 
	WHERE invoicekey = @InvoiceKey
END
