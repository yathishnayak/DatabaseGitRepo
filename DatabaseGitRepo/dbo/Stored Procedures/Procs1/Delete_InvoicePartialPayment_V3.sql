/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"PaymentKey" : 5168}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Delete_InvoicePartialPayment_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Delete_InvoicePartialPayment_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE
		@PaymentKey		INT

	SELECT 
		@PaymentKey			= PaymentKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		PaymentKey		INT		'$.PaymentKey'
	)

	DECLARE @CNT INT = 0,
			@UserName	VARCHAR(50)

	SELECT TOP 1 @UserName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey

	SET @Status = 0

	SELECT @CNT = COUNT(1) FROM InvoicePayment WITH (NOLOCK) WHERE PaymentKey = @PaymentKey

	IF(@CNT > 0)
	BEGIN
		INSERT INTO InvoicePaymentDeleted (PaymentKey, InvoiceKey, PaymentDate, PaidAmount, UserKey, 
			PaymentType, PaymentReference, Note, ChequeKey, DeleteUserKey, DeleteDate)
		select PaymentKey, InvoiceKey, PaymentDate, PaidAmount, UserKey, 
			PaymentType, PaymentReference, Note, ChequeKey, @UserKey, GETDATE()
		from InvoicePayment WITH (NOLOCK)
		where PaymentKey = @PaymentKey

		declare @chequeKey int = 0,
				@ChequeDetailKey int = 0,
				@InvoiceKey		int = 0
		select @chequeKey = ChequeKey, @ChequeDetailKey = ChequeDetailKey , @InvoiceKey = InvoiceKey
		from InvoicePayment WITH (NOLOCK) where PaymentKey = @PaymentKey and isnull(ChequeKey,0) > 0
		if( isnull(@chequeKey,0) > 0)
		begin
			delete from Cheque_Detail
			where ChequeKey = @chequeKey and invoicekey = @InvoiceKey and ChequeDetailKey = @ChequeDetailKey
		end
		DELETE FROM InvoicePayment WHERE PAYMENTKEY = @PaymentKey

		print 'update'
		Select isnull(InternalNote,'') + 'Invoice Revised as sent by ' + ISNULL(@UserName, '') + ' on ' 
				+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' from InvoiceHeader where InvoiceKey = @InvoiceKey
		print @InvoiceKey
		update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice Revised as sent by ' + ISNULL(@UserName, '') + ' on ' 
				+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; '
				where InvoiceKey = @InvoiceKey

		print 'end'

		SET @Status = 1
		SET @Reason = 'Success'
	END
	RETURN
END