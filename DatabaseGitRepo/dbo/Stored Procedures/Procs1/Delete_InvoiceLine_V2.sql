/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"InvoiceKey":192284, "Invoicelinekey":670654}'
 
EXEC [Delete_InvoiceLine_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Delete_InvoiceLine_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;
 
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	DECLARE @InvoiceKey		INT ,
			@Invoicelinekey	INT

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Reason  = 'JSONString cannot be blank';
		SET @Status = 0;
	END
	ELSE
	BEGIN
		SELECT @InvoiceKey		=  InvoiceKey,
			   @Invoicelinekey   =  Invoicelinekey
		FROM OpenJSON(@JSONString, '$')
		WITH (
			InvoiceKey			INT				'$.InvoiceKey',
			Invoicelinekey		INT				'$.Invoicelinekey'
		)
	END
 

	DECLARE @InvoiceTotal DECIMAL(18,5) = 0, @NewInvoiceAmount DECIMAL(18,5) = 0, @IsPayReceived BIT = 0, @Item VARCHAR(50) = ''
	SELECT @InvoiceTotal = InvoiceAmount, @IsPayReceived = IsPaymentReceived FROM InvoiceHeader WHERE InvoiceKey = @Invoicekey
	SELECT @Item = Description FROM Item WITH(NOLOCK) WHERE ItemKey = (SELECT ItemKey FROM Invoicedetail WITH(NOLOCK)
																	   WHERE Invoicelinekey = @Invoicelinekey AND Invoicekey =@Invoicekey)
	DECLARE @UserName NVARCHAR(MAX)='', @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0
	SELECT @UserName = ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
	SELECT @InvoiceNo = ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
	SELECT @OrderDetailKey = OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey

	DELETE FROM dbo.Invoicedetail
	WHERE Invoicelinekey = @Invoicelinekey AND Invoicekey = @Invoicekey;  
	SELECT @NewInvoiceAmount = SUM(ExtAmt) FROM dbo.Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@Invoicekey

	UPDATE dbo.InvoiceHeader
	SET InvoiceAmount= @NewInvoiceAmount,
		IsPaymentReceived = CASE WHEN @InvoiceTotal = @NewInvoiceAmount THEN @IsPayReceived ELSE 0 END,
		StatusKey = CASE WHEN @InvoiceTotal <> @NewInvoiceAmount AND StatusKey = 3 THEN 2 ELSE StatusKey END,
		PaymentRecdDate = CASE WHEN @InvoiceTotal <> @NewInvoiceAmount AND StatusKey = 3 THEN null ELSE PaymentRecdDate END,
		PaymentRecdUserKey = CASE WHEN @InvoiceTotal <> @NewInvoiceAmount AND StatusKey = 3 THEN null ELSE PaymentRecdUserKey END
	WHERE InvoiceKey=@Invoicekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @Status = 1;
		SET @Reason = 'Success';
	END	;
	
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Invoice line item ' + @Item + ' deleted for invoice ' + @InvoiceNo

END