
CREATE View [dbo].[vInvoiceBalance]
as
select IH.InvoiceKey,IH.InvoiceAmount, PaymentReceived, IH.InvoiceAmount - isnull(PaymentReceived,0) as NetDue
from InvoiceHeader IH WITH (NOLOCK) 
Left join (select invoicekey,sum(PaidAmount) as PaymentReceived 
	from InvoicePayment  WITH (NOLOCK) 
	group by InvoiceKey) IP on IH.InvoiceKey = IP.InvoiceKey
