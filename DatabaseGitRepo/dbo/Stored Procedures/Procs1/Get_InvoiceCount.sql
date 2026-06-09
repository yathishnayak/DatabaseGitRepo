CREATE PROCEDURE [dbo].[Get_InvoiceCount]
/*
InvoiceDL
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT COUNT(1) AS cnt FROM dbo.InvoiceHeader
END
