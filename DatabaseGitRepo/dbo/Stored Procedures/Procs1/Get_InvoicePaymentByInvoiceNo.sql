
CREATE Proc [dbo].[Get_InvoicePaymentByInvoiceNo]  -- [Get_InvoicePaymentByInvoiceNo] '9997'
(
	@InvoiceNo		Varchar(50)
)
as
select IH.InvoiceKey, InvoiceNo, InvoiceDate, InvoiceAmount, 
	IH.CustKey, C.CustID, C.CustName,
	isnull(B.PaymentReceived,0) as PaidAmount, 
	InvoiceAmount - isnull(PaymentReceived,0) as BalanceAmount
from InvoiceHeader IH
Left join Customer C on IH.CustKey = C.CustKey
left join (select invoicekey,sum(PaidAmount) as PaymentReceived 
	from InvoicePayment group by InvoiceKey) B on IH.InvoiceKey = B.InvoiceKey
where IH.InvoiceNo = @InvoiceNo and IH.StatusKey in (2,3)
