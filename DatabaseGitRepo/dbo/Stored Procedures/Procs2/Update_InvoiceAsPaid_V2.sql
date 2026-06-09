/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 43722}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Update_InvoiceAsPaid_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_InvoiceAsPaid_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE 
	@InvoiceKey INT

	SELECT 
		@InvoiceKey =  InvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey		INT		'$.InvoiceKey'
	)


	DECLARE @STATUSKEY INT = 0,
			@UserName	varchar(50),
			@cnt	int = 0

	select top 1 @UserName = isnull(UserName,'') from [User] WITH(NOLOCK) where UserKey = @UserKey
	select @cnt =  count(1) from InvoiceHeader WITH(NOLOCK) WHERE StatusKey in (2) and InvoiceKey = @InvoiceKey;

	SET @Status=0;

	if(isnull(@cnt,0) > 0)
	Begin
		UPDATE dbo.InvoiceHeader
		SET StatusKey = 3, RevisionDate = GETDATE(), RevisionUserKey = @UserKey, IsPrinted = 0
		WHERE StatusKey in (2) and InvoiceKey = @InvoiceKey;

		update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice Revised as Paid by ' + @UserName + ' on ' 
				+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; '
				where InvoiceKey = @InvoiceKey
	
		SET @Status = 1
		SET @Reason = 'Success'
	End
END