

CREATE PROCEDURE [dbo].[Get_InvoiceTotal]
/*
fn_autopullinvoicetotals
*/
@OrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT Container,I.ItemID,F.UnitPrice,I.ItemKey
	FROM OrderInvoices A 
		INNER JOIN InvoiceHeader B ON A.InvoiceKey=B.InvoiceKey
		INNER JOIN InvoiceDetail F ON F.InvoiceKey=B.InvoiceKey
		INNER JOIN Item I ON I.ItemKey=F.Itemkey
	WHERE A.OrderKey= @OrderKey
	--SELECT Container,C.ItemID,B.UnitPrice,B.Qty, C.ItemKey
	--FROM InvoiceHeader A
	--	INNER JOIN InvoiceDetail B ON A.InvoiceKey=B.InvoiceKey
	--	INNER JOIN Item C ON B.ItemKey=C.Itemkey
	--	WHERE A.OrderKey= @OrderKey

END
