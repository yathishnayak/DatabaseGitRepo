
/*
Declare @PendingAmount decimal(18,5) = 0
exec Get_CustomerTotals 411, @PendingAmount output
select @PendingAmount
*/
CREATE Proc Get_CustomerTotals -- Get_CustomerTotals 411
(
	@CustKey	int,
	@PendingAmount	decimal(18,5) OUTPUT
)
as
Begin
	set nocount on
	set fmtonly off

	select @PendingAmount = isnull(C.CreditLimit,0.00) - sum(IH.Balance) 
	from vInvoiceStatement IH
	inner join Customer C on IH.CustKey = C.CustKey
	where IH.CustKey = @CustKey and
	IH.StatusKey in (select StatusKey from InvoiceStatus where Description <> 'Payment Received')
	group by C.CreditLimit
End
