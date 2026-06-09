
CREATE PROCEDURE [dbo].[Get_InvoiceByInvoiceKey]
/*
dbo.fn_getinvoicebyinvoicekey
*/
@InvoiceKey  INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	SELECT  
		ih.InvoiceKey,
		ih.InvoiceNo,
		ih.CustKey,
		ih.BilltoaddrKey,
		ih.InvoiceAmount,
		ih.DueDate,
		ih.InvoiceDate,
		ih.InvoiceType
	FROM dbo.InvoiceHeader ih WITH (NOLOCK)
	WHERE ih.InvoiceKey = @InvoiceKey;
END
