
CREATE view  [dbo].[vInvoiceBalanceAmount]
As
select IP.InvoiceKey, IH.InvoiceAmount, isnull(sum(IP.PaidAmount),0) AS TotalPartialPaymentReceived, isnull((IH.InvoiceAmount-sum(IP.PaidAmount)),0) as BalanceAmount
from InvoicePayment IP  WITH (NOLOCK)
Inner Join InvoiceHeader IH  WITH (NOLOCK) on IP.InvoiceKey = IH.InvoiceKey
--where IP.InvoiceKey = 28
group by IP.InvoiceKey, IH.InvoiceAmount

