
CREATE PROCEDURE [dbo].[Update_ReviseManualInvoiceAsOpen]
@MInvoiceKey INT,
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

	UPDATE dbo.ManualInvoiceHeader
	SET StatusKey = 1, RevisionDate = GETDATE(), RevisionUserKey = @UserKey
	WHERE StatusKey in (2) and MInvoiceKey = @MInvoiceKey;

	update ManualInvoiceHeader 
	set InternalNote = isnull(InternalNote,'') + 'Manual Invoice Revised as Open by ' + @UserName + ' on ' 
			+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' + '<br>' 
			where MInvoiceKey = @MInvoiceKey
	
	SET @Output=1;
END
