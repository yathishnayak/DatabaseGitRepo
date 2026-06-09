CREATE Procedure [dbo].[Get_InvoicePayment] -- Get_InvoicePayment 'M', 3
(
	@InvoiceType	char(1) = 'I',
	@InvoiceKey		INT = 0
)
As
select IP.PaymentKey,IP.InvoiceKey, IP.PaymentDate, IP.PaidAmount,IP.UserKey, IP.PaymentType, IP.PaymentReference, IP.Note, U.UserName , 
IP.CreatedDate, IP.InvoiceType
from InvoicePayment IP WITH (NOLOCK)
Left Join InvoiceHeader IH  WITH (NOLOCK) on IP.InvoiceKey=IH.InvoiceKey and IP.InvoiceType =  @InvoiceType 
Left Join PrepayInvoiceHeader PH  WITH (NOLOCK) on IP.InvoiceKey = PH.PPInvoiceKey and IP.InvoiceType =  @InvoiceType 
Left join ManualInvoiceHeader MH  WITH (NOLOCK) on IP.InvoiceKey = MH.MInvoiceKey and IP.InvoiceType =  @InvoiceType 
Left Join [User] U on IP.UserKey = U.UserKey
where IP.InvoiceKey= @InvoiceKey and ( IH.InvoiceKey is not null OR PH.PPInvoiceKey is not null OR MH.MInvoiceKey is not null)
