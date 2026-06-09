/*
declare @UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='{"StatusKey":5,"InvoiceKey":191094,"InvoiceType":"0"}',
	@JSONOutput   NVARCHAR(MAX) = '' ,
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = '' 
	exec  InvoicePayment_UpdateStatus	@UserKey,@JSONString,@JSONOutput output,@Status output,@Reason output
select @Status,@Reason
*/

CREATE PROCEDURE [dbo].[InvoicePayment_UpdateStatus]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN
	DECLARE @PaymentKey	INT= 1, @InvoiceKey INT=0, @StatusKey INT, @InvoiceType  VARCHAR(20), @OrderKey INT,
			@UserName VARCHAR(100), @Comment VARCHAR(500)='', @OrderNo VARCHAR(50)='', @InvoiceNo VARCHAR(50)='', @StatusName VARCHAR(50)=''

	SELECT @PaymentKey = PaymentKey, @InvoiceKey = InvoiceKey , @InvoiceType = InvoiceType , @StatusKey = StatusKey
	FROM OPENJSON(@JSONString,'$') 
    WITH (
			PaymentKey		INT			'$.PaymentKey',
			InvoiceKey		INT			'$.InvoiceKey',
			InvoiceType     VARCHAR(20) '$.InvoiceType',
			StatusKey		INT			'$.StatusKey'
		)

	SELECT @UserName = ISNULL(UserName,'') FROM [User] WITH(NOLOCK) WHERE UserKey = @UserKey

	SET @Status=0;
	SET @Reason='Failure';

	UPDATE Invoicepayment 
	SET StatusKey= @StatusKey
	WHERE InvoiceKey= @InvoiceKey --AND PaymentKey = @PaymentKey;

	IF @StatusKey = 5 
	BEGIN
	print 'hi'
		EXEC Invoice_UpdateAsPaid @InvoiceKey, @InvoiceType,@UserKey, 1,@Status OUTPUT
	END
	ELSE
	BEGIN
		EXEC Update_InvoiceStatusFromPayment @InvoiceKey,@StatusKey,@UserKey,@Status OUTPUT
	END

	SELECT @StatusName = Description FROM InvoicePaymentStatus WHERE StatusKey = @StatusKey
	IF @InvoiceType = 'I'
	BEGIN
		SELECT @InvoiceNo = ISNULL(InvoiceNo, '') FROM InvoiceHeader WHERE InvoiceKey = @InvoiceKey
		SELECT @OrderKey = OrderKey FROM InvoiceHeader WHERE InvoiceKey = @InvoiceKey
		SELECT @OrderNo = ISNULL(OrderNo, '') FROM OrderHeader WHERE OrderKey = @OrderKey
	END
	ELSE IF @InvoiceType = 'M'
	BEGIN
		SELECT @InvoiceNo = ISNULL(MInvoiceNo, '') FROM ManualInvoiceHeader WHERE MInvoiceKey = @InvoiceKey
		SELECT @OrderKey = OrderKey FROM ManualInvoiceHeader WHERE MInvoiceKey = @InvoiceKey
		SELECT @OrderNo = ISNULL(OrderNo, '') FROM ManualInvoiceHeader WHERE MInvoiceKey = @InvoiceKey
	END
	ELSE
	BEGIN
		SELECT @InvoiceNo = ISNULL(PPInvoiceNo, '') FROM PrepayInvoiceHeader WHERE PPInvoiceKey = @InvoiceKey
		SELECT @OrderKey = OrderKey FROM PrepayInvoiceHeader WHERE PPInvoiceKey = @InvoiceKey
		SELECT @OrderNo = ISNULL(OrderNo, '') FROM PrepayInvoiceHeader WHERE PPInvoiceKey = @InvoiceKey
	END

	INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
	Select GETDATE(), @UserName, 'Order', @OrderNo, @OrderKey, NULL, 'Text' , 'Invoice Payment status updated for Invoice ' + @InvoiceNo + ' to ' + @StatusName + ' by ' + @UserName

	SET @Status=1;
	SET @Reason='Success';
END