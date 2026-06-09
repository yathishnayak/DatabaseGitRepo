
CREATE Procedure [dbo].[InsertUpdate_ChequeDetail]
(
	@ChequeKey			int,
	@ChequeDetailKey	int,
	@InvoiceKey			Int,
	@InvAdjAmount		decimal(18,4),
	@InvAdjDate			datetime,
	@CreateUser			Varchar(50),
	@ChequeNo			varchar(50),
	@OutPut				BIT=0 OUTPUT  -- @Result 1 - sucess, 0 - failure
)
as
BEGIN
  SET NOCOUNT ON;
  SET FMTONLY OFF;

  	IF(@ChequeKey = 0)
	BEGIN
		SET @output = 0
		RETURN;
	END;

	If @ChequeDetailKey = 0
	BEGIN
		Insert into Cheque_Detail(ChequeKey, InvoiceKey, InvAdjAmount, InvAdjDate, 
		CreateUser, CreateDate)
		SELECT @ChequeKey, @InvoiceKey, @InvAdjAmount, @InvAdjDate, @CreateUser, Getdate()

		set @ChequeDetailKey = SCOPE_IDENTITY()

		insert into InvoicePayment (InvoiceKey, PaymentDate, PaidAmount, UserKey, PaymentType, PaymentReference,Note, ChequeKey, ChequeDetailKey)
		Values (@InvoiceKey, @InvAdjDate, @InvAdjAmount, @CreateUser, 'Check', @ChequeNo, 'From Cheque', @chequeKey, @ChequeDetailKey)
		SET @OutPut=1
		return
	END
	Else
	BEGIN
		Update Cheque_Detail
		Set ChequeKey=@ChequeKey, 
			InvoiceKey=@InvoiceKey, 
			InvAdjAmount=@InvAdjAmount,  
			InvAdjDate=@InvAdjDate,
			UpdateDate=Getdate(),
			UpdateUser=@CreateUser
		where ChequeKey=@ChequeKey
		and ChequeDetailKey = @ChequeDetailKey

		declare @TotalInvAdjAmout decimal(18,4)
		select @TotalInvAdjAmout = sum(InvAdjAmount) from Cheque_Detail where ChequeKey = @ChequeKey
		
		update Cheque_Header 
		set Balance = ChequeAmount - @TotalInvAdjAmout
		where ChequeKey = @ChequeKey

		declare @PaymentKey int = 0
		select @PaymentKey = PaymentKey from InvoicePayment where ChequeDetailKey = @ChequeDetailKey and InvoiceKey = @InvoiceKey
		
		if(isnull(@PaymentKey,0) = 0)
		Begin
			insert into InvoicePayment (InvoiceKey, PaymentDate, PaidAmount, UserKey, PaymentType, PaymentReference,Note, ChequeKey, ChequeDetailKey)
			Values (@InvoiceKey, @InvAdjDate, @InvAdjAmount, @CreateUser, 'Check', @ChequeNo, 'From Cheque', @chequeKey, @ChequeDetailKey)
		end
		else
		begin
			update InvoicePayment 
				set PaymentDate = @InvAdjDate,
					PaymentReference = @ChequeNo,
					PaidAmount = @InvAdjAmount,
					Note = Note + ' ' + 'Payment Updated on ' + convert(varchar, getDate(),101)
			where PaymentKey = @PaymentKey
		end
		SET @OutPut=1
		return
	END

		

END
