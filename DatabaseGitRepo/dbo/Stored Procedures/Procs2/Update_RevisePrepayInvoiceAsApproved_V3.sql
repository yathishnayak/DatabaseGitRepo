/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 21}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Update_RevisePrepayInvoiceAsApproved_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_RevisePrepayInvoiceAsApproved_V3]
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
		@PPInvoiceKey			INT

	SELECT 
		@PPInvoiceKey		=		PPInvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		PPInvoiceKey		INT		'$.InvoiceKey'
	)

	DECLARE @STATUSKEY INT = 0,
			@UserName	varchar(50)

	select top 1 @UserName = isnull(UserName,'') from [User] WITH(NOLOCK) where UserKey = @UserKey

	SET @Status=0;

	UPDATE dbo.PrepayInvoiceHeader
	SET StatusKey = 2, RevisionDate = GETDATE(), RevisionUserKey = @UserKey
	WHERE StatusKey in (3) and PPInvoiceKey = @PPInvoiceKey;

	update PrepayInvoiceHeader 
	set InternalNote = isnull(InternalNote,'') + 'PrepayInvoice Revised as Approved by ' + @UserName + ' on ' 
			+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' + '<br>' 
			+ '[Revised after Payment Received]'
			where PPInvoiceKey = @PPInvoiceKey
	
	SET @Status=1
	SET @Reason = 'Success'

	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Order',IH.OrderNo,IH.OrderKey,null,'Text','PrePay Invoice ' + IH.PPInvoiceNo + ' Revised as Approved'
	FROM PrepayInvoiceHeader IH WITH(NOLOCK) WHERE IH.PPInvoiceKey = @PPInvoiceKey
END