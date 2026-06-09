
CREATE Proc Update_InvoicePaymentReceivedDate
(
	@InvoiceKey			int,
	@UserKey			INT,
	@PaymentRecdDate	DateTime,
	@OutPut				BIT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SET @OutPut=0;

	Declare @Comment varchar(500) = '',
			@CommentKey int,
			@PrevPmtRecdDate datetime,
			@UserName varchar(100)

	select @PrevPmtRecdDate = PaymentRecdDate from InvoiceHeader where InvoiceKey = @InvoiceKey
	Select @UserName = UserName from [User] where UserKey = @UserKey
	
	set @Comment = 'Invoice Payment Received Date changed from : ' +  convert(varchar,@PrevPmtRecdDate,101) 
		+ '  to ' +  convert(varchar,@PaymentRecdDate,101) + ' by ' + @UserName + '<br>'

	UPDATE dbo.InvoiceHeader
	SET PaymentRecdDate = @PaymentRecdDate
	WHERE InvoiceKey = @InvoiceKey;
	
	update InvoiceHeader set InternalNote = isnull(InternalNote,'') +  @Comment where InvoiceKey = @InvoiceKey

	SET @OutPut=1;
END
