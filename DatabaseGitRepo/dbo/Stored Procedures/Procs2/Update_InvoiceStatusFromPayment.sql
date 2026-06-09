



CREATE PROCEDURE [dbo].[Update_InvoiceStatusFromPayment]
(
	@InvoiceKey			INT,
	@PaymentStatusKey	INT=0,
	@UserKey			INT,
	@Output				BIT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	DECLARE @STATUSKEY INT = 0,
			@UserName	varchar(50)
			

	select top 1 @UserName = isnull(UserName,'') from [User] where UserKey = @UserKey	
	SET @STATUSKEY=CASE WHEN @PaymentStatusKey=1 THEN 2
					WHEN @PaymentStatusKey=2 THEN 2
					WHEN @PaymentStatusKey=3 THEN 3
					WHEN @PaymentStatusKey=4 THEN 3
					WHEN @PaymentStatusKey=6 THEN 2
					WHEN @PaymentStatusKey=8 THEN 2
					WHEN @PaymentStatusKey=9 THEN 2 END

	SET @Output=0;
	print '@statusKey'
	print @statusKey
	--if(isnull(@cnt,0) > 0)
	--Begin
		UPDATE dbo.InvoiceHeader
		SET StatusKey = @STATUSKEY, RevisionDate = GETDATE(), RevisionUserKey = @UserKey, IsPrinted = 0--,
		--InvoiceApprovedUserKey=@UserKey,InvoiceApprovedDate=GETDATE(),IsInvoiceApproved=1
		WHERE InvoiceKey = @InvoiceKey;

		--update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice Revised as sent by ' + @UserName + ' on ' 
		--		+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; '
		--		where InvoiceKey = @InvoiceKey
	
		SET @Output=1;
	--End
END
