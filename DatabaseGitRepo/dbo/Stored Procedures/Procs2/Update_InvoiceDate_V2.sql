/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceDate":"2026-04-26T18:30:00.000Z","InvoiceKey":257389}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Update_InvoiceDate_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_InvoiceDate_V2]
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
		@InvoiceKey		INT,
		@InvoiceDate	DateTime

	SELECT 
		@InvoiceKey		=	InvoiceKey,	
		@InvoiceDate	=	InvoiceDate
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey			INT				'$.InvoiceKey',	
		InvoiceDate			DATETIME		'$.InvoiceDate'
	)

	SET @Status=0;
	declare @PrevInvoicedate datetime;

	select @PrevInvoicedate = InvoiceDate from InvoiceHeader WITH(NOLOCK) where InvoiceKey = @InvoiceKey

	UPDATE dbo.InvoiceHeader
	SET 		
		InvoiceDate		= @InvoiceDate,
		UpdateUserKey	= @UserKey,
		UpdateDate	= GETDATE()
	WHERE InvoiceKey = @InvoiceKey
	AND @InvoiceDate IS NOT NULL;
	print '@InvoiceDate'
	print @InvoiceDate

	print '@InvoiceKey'
	print @InvoiceKey

	Update A set DueDate =  DATEADD (d, C.Days,  A.InvoiceDate ) 
	from InvoiceHeader A WITH(NOLOCK)
	inner join  Customer  B WITH(NOLOCK) on (A.CustKey = B.CustKey)
	inner join  PaymentTerms C WITH(NOLOCK) on (B.PaymentTermsKey = C.PaymentTermsKey)
	WHERE A.InvoiceKey = @InvoiceKey;

	insert into Invoice_Log (InvoiceKey, LogDate, LogText, ActionUserKey)
	select					 @InvoiceKey, GETDATE(), 'Invoice Date changed from ' + convert(varchar,@PrevInvoicedate,101) 
			+ ' to ' + convert(varchar,@InvoiceDate,101) , @UserKey

    DECLARE @UserName NVARCHAR(MAX)='', @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
	SELECT @InvoiceNo=ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
	SELECT @OrderDetailKey=OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey

	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text',
			'Invoice Date changed from ' + convert(varchar,@PrevInvoicedate,101) + ' to ' + convert(varchar,@InvoiceDate,101) + ' for invoice ' + @InvoiceNo

	SET @Status=1
	SET @Reason = 'Success'
END