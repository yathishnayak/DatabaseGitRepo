/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"MInvoiceKey" : 55}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Update_ReviseManualInvoiceAsApproved_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_ReviseManualInvoiceAsApproved_V3]
(
	@UserKey		INT = 0,
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
		@MInvoiceKey INT

	SELECT 
		@MInvoiceKey	=	MInvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		MInvoiceKey			INT		'$.MInvoiceKey'
	)

	DECLARE @STATUSKEY INT = 0,
			@UserName	varchar(50)

	select top 1 @UserName = isnull(UserName,'') from [User] WITH(NOLOCK) where UserKey = @UserKey

	SET @Status = 0;

	UPDATE dbo.ManualInvoiceHeader
	SET StatusKey = 2, RevisionDate = GETDATE(), RevisionUserKey = @UserKey
	WHERE StatusKey in (3) and MInvoiceKey = @MInvoiceKey;

	update ManualInvoiceHeader 
	set InternalNote = isnull(InternalNote,'') + 'Manual Invoice Revised as Approved by ' + @UserName + ' on ' 
			+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' + '<br>' 
			+ '[Revised after Payment Received]'
			where MInvoiceKey = @MInvoiceKey
	
	SET @Status = 1
	SET @Reason = 'Success'

	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Order',ISNULL(IH.OrderNo, ''),IH.OrderKey,null,'Text','Manual Invoice ' + IH.MInvoiceNo + ' Revised as Approved by ' +@UserName
	FROM ManualInvoiceHeader IH WHERE IH.MInvoiceKey = @MInvoiceKey
END