/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 38393}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Update_InvoiceRevised_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_InvoiceRevised_V2]
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
		@InvoiceKey		=		InvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey			INT				'$.InvoiceKey'
	)

	DECLARE @STATUSKEY INT = 0,
			@UserName	varchar(50)

	select top 1 @UserName = isnull(UserName,'') from [User] WITH(NOLOCK) where UserKey = @UserKey

	SET @Status=0;

	update dbo.InvoiceHeader set IsPaymentReceived = 1
	where StatusKey = 3 and InvoiceKey = @InvoiceKey;

	UPDATE dbo.InvoiceHeader
	SET StatusKey = 1, RevisionDate = GETDATE(), RevisionUserKey = @UserKey, IsPrinted = 0
	WHERE StatusKey in (2,3) and InvoiceKey = @InvoiceKey;

	--update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice Revised by ' + @UserName + ' on ' 
	--		+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' + '<br>' 
	--		+ case when isnull(IsPaymentReceived,0) = 1 then '[Revised after Payment Received]' else '' end
	--		where InvoiceKey = @InvoiceKey

	update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice status chnage by ' + @UserName + ' on ' 
			+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' + '<br>' 
			+ case when isnull(IsPaymentReceived,0) = 1 then '[Status changed after Payment Received]' else '' end
			where InvoiceKey = @InvoiceKey

	UPDATE InvoicePayment
	SET StatusKey =1 where InvoiceKey=  @InvoiceKey;
	
	SET @Status=1
	SET @Reason = 'Success'

	DECLARE @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0
	SELECT @InvoiceNo = ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
	SELECT @OrderDetailKey = OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Invoice ' + @InvoiceNo + ' marked for revision'
END