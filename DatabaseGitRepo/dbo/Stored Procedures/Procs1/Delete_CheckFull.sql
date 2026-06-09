

CREATE Proc [dbo].[Delete_CheckFull]
(
	@CheckKey	int,
	@DeleteUserKey	int,
	@Output			Bit = 0 output
)
as
BEGIN
	IF(@CheckKey > 0 and @DeleteUserKey > 0)
	BEGIN
		declare @cnt int = 0;
		select @cnt = count(1) from Cheque_Header H where H.ChequeKey = @CheckKey
		if(@cnt = 0)
		Begin
			set @Output = 0
			return;
		End

		insert into Cheque_Header_Deleted (ChequeKey, CustKey, ChequeRef, ChequeDate, ChequeAmount, Balance,
				CreateUser, UpdateUser, UpdateDate, CreateDate, DeletedUserKey, DeletedDate)
		select ChequeKey, CustKey, ChequeRef, ChequeDate, ChequeAmount, Balance, 
				CreateUser, UpdateUser, UpdateDate, CreateDate, @DeleteUserKey, GETDATE()
		from Cheque_Header 
		where ChequeKey = @CheckKey
		
		insert INTO Cheque_Detail_DELETED 
		(
			ChequeDetailKey, ChequeKey, InvoiceKey, InvAdjAmount, InvAdjDate, CreateDate,
			UpdateDate, CreateUser, UpdateUser, DeleteUserKey, DeleteDate
		)
		SELECT ChequeDetailKey, ChequeKey, InvoiceKey, InvAdjAmount, InvAdjDate, CreateDate,
			UpdateDate, CreateUser, UpdateUser, @DeleteUserKey, GETDATE()
		FROM Cheque_Detail
		WHERE ChequeKey = @CheckKey

		DELETE FROM Cheque_Detail
		WHERE ChequeKey = @CheckKey

		delete from InvoicePayment
		where PaymentType = 'Check' and ChequeKey = @CheckKey 
		
		delete from Cheque_Header
		where ChequeKey = @CheckKey

		set @Output = 1
	END
END
