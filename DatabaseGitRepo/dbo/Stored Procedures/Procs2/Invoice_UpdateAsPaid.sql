
CREATE Proc [dbo].[Invoice_UpdateAsPaid]
(
	@InvoiceKey		int,
	@InvoiceType	char(1),
	@UserKey		int,
	@IsPaid			bit = 1,
	@Output			Bit = 0 OUTPUT
)
AS
BEGIN
	set nocount on
	set fmtonly off

	set @Output = convert(bit,0)

	if(@InvoiceType = 'I')
	BEGIN
		if(isnull(@IsPaid,0) = 1)
		Begin
			exec dbo.Update_InvoiceAsPaid @InvoiceKey, @UserKey,@Output OUTPUT
			return @output
		end
		else
		begin
			exec dbo.[Update_InvoiceAsApproved] @InvoiceKey, @UserKey,@Output OUTPUT
			return @output
		end
	END
	ELSE IF (@InvoiceType = 'P')
	BEGIN
		if(isnull(@ispaid,0) = 1)
		Begin
			EXEC dbo.PrePayInvoice_UpdatePaid @InvoiceKey, @UserKey,@Output OUTPUT
			return @output
		end
		else
		begin
			EXEC dbo.[PrepayInvoice_UpdateSent] @InvoiceKey, @UserKey,@Output OUTPUT
			return @output
		end
	END
	ELSE IF (@InvoiceType = 'M')
	BEGIN
		if(isnull(@IsPaid,0) = 1)
		begin
			EXEC dbo.ManualInvoice_UpdatePaid @InvoiceKey, @UserKey,@Output OUTPUT
			return @output
		end
		else
		begin
			exec [ManualInvoice_UpdateSent] @InvoiceKey, @UserKey, @output OUTPUT
			return @output
		end
	END
END
