CREATE PROCEDURE [dbo].[Update_RevisePrepayInvoiceAsApproved]
@PPInvoiceKey INT,
@UserKey	INT,
@Output		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @STATUSKEY INT = 0,
			@UserName	varchar(50)

	select top 1 @UserName = isnull(UserName,'') from [User] where UserKey = @UserKey

	SET @Output=0;

	UPDATE dbo.PrepayInvoiceHeader
	SET StatusKey = 2, RevisionDate = GETDATE(), RevisionUserKey = @UserKey
	WHERE StatusKey in (3) and PPInvoiceKey = @PPInvoiceKey;

	update PrepayInvoiceHeader 
	set InternalNote = isnull(InternalNote,'') + 'PrepayInvoice Revised as Approved by ' + @UserName + ' on ' 
			+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' + '<br>' 
			+ '[Revised after Payment Received]'
			where PPInvoiceKey = @PPInvoiceKey
	
	SET @Output=1;
END
