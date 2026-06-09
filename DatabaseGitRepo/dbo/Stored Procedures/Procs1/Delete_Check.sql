----select * from Cheque_Header(nolock) where ChequeRef='4940'
--select * from Cheque_Detail(nolock) where ChequeKey=173--have to delete this
----select * from Cheque_Detail(nolock) where ChequeKey=778
--select * from InvoicePayment(nolock) where ChequeKey=173
--select * from InvoicePayment(nolock) where ChequeKey=778

Create Proc Delete_Check
(
 @CheckKey as int
)
AS
BEGIN
	Delete from InvoicePayment where ChequeKey=@CheckKey
	Delete from Cheque_Detail where ChequeKey=@CheckKey  
	Delete from Cheque_Header where ChequeKey=@CheckKey

END

