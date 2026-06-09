
CREATE PROCEDURE [dbo].[Update_InvoiceAsPaid]
@InvoiceKey INT,
@UserKey	INT,
@Output		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @STATUSKEY INT = 0,
			@UserName	varchar(50),
			@cnt	int = 0

	select top 1 @UserName = isnull(UserName,'') from [User] where UserKey = @UserKey
	select @cnt =  count(1) from InvoiceHeader WHERE StatusKey in (2) and InvoiceKey = @InvoiceKey;

	SET @Output=0;

	if(isnull(@cnt,0) > 0)
	Begin
		UPDATE dbo.InvoiceHeader
		SET StatusKey = 3, RevisionDate = GETDATE(), RevisionUserKey = @UserKey, IsPrinted = 0
		WHERE StatusKey in (2) and InvoiceKey = @InvoiceKey;

		update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice Revised as Paid by ' + @UserName + ' on ' 
				+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; '
				where InvoiceKey = @InvoiceKey
	
		SET @Output=1;
	End
END
