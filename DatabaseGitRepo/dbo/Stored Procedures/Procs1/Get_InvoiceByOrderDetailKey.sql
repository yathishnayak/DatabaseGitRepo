CREATE PROCEDURE [dbo].[Get_InvoiceByOrderDetailKey]
/*
dbo.fn_getinvoicebyorderdetailkey
*/
@OrderDetailKey  INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT
		inv.InvoiceNo ,
		inv.CustKey ,
		inv.BilltoaddrKey ,
		--inv.BilltoCopyAddrKey ,
		inv.InvoiceAmount ,
		inv.DueDate ,
		inv.InvoiceDate,
		inv.InvoiceType
	FROM dbo.InvoiceHeader inv 
		JOIN dbo.OrderInvoices tmsinv ON inv.InvoiceKey = tmsinv.InvoiceKey AND tmsinv.OrderKey = @OrderDetailKey;
END
