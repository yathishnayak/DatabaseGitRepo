
CREATE PROC [dbo].[Delete_InvoicePartialPayment]
(
	@PaymentKey		INT,
	@DeleteUserKey	INT,
	@OUTPUT			BIT = 0 OUTPUT
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @CNT INT = 0

	SET @OUTPUT = 0

	SELECT @CNT = COUNT(1) FROM InvoicePayment	WHERE PaymentKey = @PaymentKey

	IF(@CNT > 0)
	BEGIN
		INSERT INTO InvoicePaymentDeleted (PaymentKey, InvoiceKey, PaymentDate, PaidAmount, UserKey, 
			PaymentType, PaymentReference, Note, ChequeKey, DeleteUserKey, DeleteDate)
		select PaymentKey, InvoiceKey, PaymentDate, PaidAmount, UserKey, 
			PaymentType, PaymentReference, Note, ChequeKey, @DeleteUserKey, GETDATE()
		from InvoicePayment
		where PaymentKey = @PaymentKey

		declare @chequeKey int = 0,
				@ChequeDetailKey int = 0,
				@InvoiceKey		int = 0
		select @chequeKey = ChequeKey, @ChequeDetailKey = ChequeDetailKey , @InvoiceKey = InvoiceKey
		from InvoicePayment where PaymentKey = @PaymentKey and isnull(ChequeKey,0) > 0
		if( isnull(@chequeKey,0) > 0)
		begin
			delete from Cheque_Detail
			where ChequeKey = @chequeKey and invoicekey = @InvoiceKey and ChequeDetailKey = @ChequeDetailKey
		end
		DELETE FROM InvoicePayment WHERE PAYMENTKEY = @PaymentKey

		SET @OUTPUT = 1
	END
	RETURN
END
