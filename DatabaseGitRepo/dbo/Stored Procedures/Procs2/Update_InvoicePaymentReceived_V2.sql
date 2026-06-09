/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKeySTR" : 43641}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Update_InvoicePaymentReceived_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_InvoicePaymentReceived_V2]
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
	@InvoiceKeySTR varchar(2000)

	SELECT 
		@InvoiceKeySTR		=		InvoiceKeySTR
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKeySTR			VARCHAR(2000)				'$.InvoiceKeySTR'
	)

	DECLARE @STATUSKEY INT = 0

	SET @Status=0;

	SELECT Value AS InvoiceKey INTO #InvoiceKeys  FROM dbo.Fn_SplitParamCol(@InvoiceKeySTR)

	SELECT @STATUSKEY = StatusKey FROM InvoiceStatus WITH(NOLOCK) WHERE Description = 'Payment Received'

	UPDATE dbo.InvoiceHeader
	SET IsPaymentReceived = 1, PaymentRecdDate = GETDATE(), PaymentRecdUserKey = @UserKey,
		StatusKey = @STATUSKEY
	WHERE StatusKey = 2 and InvoiceKey in (SELECT InvoiceKey FROM #InvoiceKeys);
	
	UPDATE InvoicePayment
	SET StatusKey =5 where InvoiceKey in (SELECT InvoiceKey FROM #InvoiceKeys)
	
	SET @Status = 1
	SET @Reason = 'Success'

	DECLARE @UserName VARCHAR(50)=''
	SELECT @UserName = ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey

	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT
		GETDATE(),
		@UserName,
		'Container',
		(SELECT TOP 1 ContainerNo FROM InvoiceContainers WITH(NOLOCK) WHERE InvoiceKey = K.InvoiceKey),
		(SELECT TOP 1 OrderDetailKey FROM InvoiceDetail WITH(NOLOCK) WHERE InvoiceKey = K.InvoiceKey),
		NULL,
		'Text',
		'Invoice ' + IH.InvoiceNo + ' marked as Payment Received'
	FROM #InvoiceKeys K
	INNER JOIN InvoiceHeader IH WITH(NOLOCK) ON IH.InvoiceKey = K.InvoiceKey;
END