CREATE Proc [dbo].[Get_InvoicePaymentByCustKey]  -- Get_InvoicePaymentByCustKey 28
(
	@CustomerKey	int = 0
)
as
select IH.InvoiceKey, InvoiceNo, InvoiceDate, InvoiceAmount, 
	isnull(B.PaymentReceived,0) as PaidAmount, 
	InvoiceAmount - isnull(PaymentReceived,0) as BalanceAmount
from InvoiceHeader IH
left join (select invoicekey,sum(PaidAmount) as PaymentReceived 
	from InvoicePayment group by InvoiceKey) B on IH.InvoiceKey = B.InvoiceKey
where IH.CustKey = @CustomerKey and StatusKey = 2
