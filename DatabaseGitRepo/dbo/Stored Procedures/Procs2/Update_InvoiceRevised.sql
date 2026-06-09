


CREATE PROCEDURE [dbo].[Update_InvoiceRevised]
@InvoiceKey INT,
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

	update dbo.InvoiceHeader set IsPaymentReceived = 1
	where StatusKey = 3 and InvoiceKey = @InvoiceKey;

	UPDATE dbo.InvoiceHeader
	SET StatusKey = 1, RevisionDate = GETDATE(), RevisionUserKey = @UserKey, IsPrinted = 0
	WHERE StatusKey in (2,3) and InvoiceKey = @InvoiceKey;

	update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice Revised by ' + @UserName + ' on ' 
			+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' + '<br>' 
			+ case when isnull(IsPaymentReceived,0) = 1 then '[Revised after Payment Received]' else '' end
			where InvoiceKey = @InvoiceKey

	UPDATE InvoicePayment
	SET StatusKey =1 where InvoiceKey=  @InvoiceKey;
	
	SET @Output=1;
END
