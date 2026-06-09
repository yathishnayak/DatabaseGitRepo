

CREATE Proc Delete_CheckDetail
(
	@CheckDetailKey	int,
	@InvoiceKey		int,
	@DeleteUserKey	int,
	@Output			Bit = 0 output
)
as
BEGIN
	IF(@CheckDetailKey > 0 and @DeleteUserKey > 0)
	BEGIN
		declare @CheckKey int = 0,
				@InvAdjAmount	decimal(18,4)

		select @CheckKey = ChequeKey
		from Cheque_Detail D
		where D.ChequeDetailKey = @CheckDetailKey

		
		insert INTO Cheque_Detail_DELETED 
		(
			ChequeDetailKey, ChequeKey, InvoiceKey, InvAdjAmount, InvAdjDate, CreateDate,
			UpdateDate, CreateUser, UpdateUser, DeleteUserKey, DeleteDate
		)
		SELECT ChequeDetailKey, ChequeKey, InvoiceKey, InvAdjAmount, InvAdjDate, CreateDate,
			UpdateDate, CreateUser, UpdateUser, @DeleteUserKey, GETDATE()
		FROM Cheque_Detail
		WHERE ChequeDetailKey = @CheckDetailKey

		DELETE FROM Cheque_Detail
		WHERE ChequeDetailKey = @CheckDetailKey

		delete from InvoicePayment
		where PaymentType = 'Check' and ChequeKey = @CheckKey 
			and InvoiceKey = @InvoiceKey and PaidAmount = @InvAdjAmount
		set @Output = 1
	END
END
