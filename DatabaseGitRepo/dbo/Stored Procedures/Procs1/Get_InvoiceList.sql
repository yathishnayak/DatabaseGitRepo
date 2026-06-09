

CREATE PROCEDURE [dbo].[Get_InvoiceList]
/*
fn_getinvoicelist
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT A.OrderKey,O.OrderNo,O.OrderDate,A.InvoiceKey,B.InvoiceNo,B.InvoiceDate,B.CustKey
	,B.BilltoAddrKey,B.InvoiceAmount,B.DueDate,F.CustName, B.CustomerNote, B.InternalNote, F.IsFactored
	FROM OrderInvoices A 
		INNER JOIN InvoiceHeader B ON A.InvoiceKey=B.InvoiceKey
		INNER JOIN Customer F ON F.CustKey=B.CustKey	
		INNER JOIN OrderHeader O ON O.OrderKey=A.OrderKey
END
