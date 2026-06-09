/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 38388, "PaymentRecdDate" : "2026-03-23 10:36:00"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Update_InvoicePaymentReceivedDate_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_InvoicePaymentReceivedDate_V2]
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
		@InvoiceKey			int,
		@PaymentRecdDate	DateTime

	SELECT 
		@InvoiceKey				=		InvoiceKey,
		@PaymentRecdDate		=		PaymentRecdDate
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey					INT				'$.InvoiceKey',
		PaymentRecdDate				DATETIME		'$.PaymentReceivedDate'
	)
	
	SET @Status=0;

	Declare @Comment varchar(500) = '',
			@CommentKey int,
			@PrevPmtRecdDate datetime,
			@UserName varchar(100)

	select @PrevPmtRecdDate = PaymentRecdDate from InvoiceHeader WITH(NOLOCK) where InvoiceKey = @InvoiceKey
	Select @UserName = UserName from [User] WITH(NOLOCK) where UserKey = @UserKey
	
	set @Comment = 'Invoice Payment Received Date changed from : ' +  convert(varchar,@PrevPmtRecdDate,101) 
		+ '  to ' +  convert(varchar,@PaymentRecdDate,101) + ' by ' + @UserName 

	UPDATE dbo.InvoiceHeader
	SET PaymentRecdDate = @PaymentRecdDate
	WHERE InvoiceKey = @InvoiceKey;
	
	update InvoiceHeader set InternalNote = isnull(InternalNote,'') +  @Comment where InvoiceKey = @InvoiceKey

	SET @Status=1
	SET @Reason = 'Success'

	DECLARE @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0
	SELECT @InvoiceNo = ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
	SELECT @OrderDetailKey = OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text',@Comment + ' for Invoice ' + @InvoiceNo
END