/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 188506, "InvoiceCompanyKey" : 2}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Update_InvoiceApproval_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_InvoiceApproval_V3]
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
		@InvoiceKey			INT,
		@InvoiceCompanyKey	INT=0

	SELECT
		@InvoiceKey			=	InvoiceKey			,
		@InvoiceCompanyKey	=	InvoiceCompanyKey	
	FROM OPENJSON(@JSONString)
	With
	(
		InvoiceKey			INT		'$.InvoiceKey',			
		InvoiceCompanyKey	INT		'$.InvoiceCompanyKey'
	)

	DECLARE @STATUSKEY INT = 0,
			@isPaymentReceived  Bit = 0,
			@CustKey	INT=0

	SELECT @STATUSKEY = StatusKey FROM InvoiceStatus WITH(NOLOCK) WHERE Description = 'Approved'
	SELECT @CustKey = CustKey FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey = @InvoiceKey

	Select @isPaymentReceived = isnull(IsPaymentReceived,0) from dbo.InvoiceHeader WITH(NOLOCK) where InvoiceKey = @InvoiceKey
	if(@isPaymentReceived = 1)
	begin
		SELECT @STATUSKEY = StatusKey FROM InvoiceStatus WITH(NOLOCK) WHERE Description = 'Payment Received'
	end
	SET @Status=0;

	UPDATE dbo.InvoiceHeader
	SET IsInvoiceApproved= case when isnull(@isPaymentReceived,0) = 1 then 3 else 2 end ,
		InvoiceApprovedUserKey=@UserKey,InvoiceApprovedDate=GETDATE(),
		StatusKey = @STATUSKEY,InvoiceCompanyKey=@InvoiceCompanyKey
	WHERE InvoiceKey= @InvoiceKey;

	IF(@CustKey IN (1966,2423,2567,3170,3402,3146,3147,3166,3318,3396,3410,3165,1559,1716,1717,1718,1719,1720,1721,1723,1724,1725,1726
					,1727,1728,1729,1730,1739,2778,2851,2899,2979,3032,3033,3042,3201,3312,3374))
	BEGIN
		UPDATE dbo.InvoiceHeader
		SET AprovedReasonCodeKey=1
		WHERE InvoiceKey= @InvoiceKey;
	END

	UPDATE InvoicePayment
	SET StatusKey =1 where Invoicekey=@InvoiceKey

	--********************Order Header And Order Detail Status**************
	UPDATE OD
	SET OD.[Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WITH(NOLOCK) WHERE [Description]='Approved for Invoice/Driver Pay' ),StatusDate=GETDATE()
	FROM DBO.Invoicedetail ID  WITH(NOLOCK)		
		INNER JOIN dbo.OrderDetail OD WITH(NOLOCK) ON OD.OrderDetailKey=ID.OrderDetailKey
		INNER JOIN dbo.OrderHeader OH WITH(NOLOCK) ON Oh.OrderKey=OD.OrderKey
	WHERE ID.InvoiceKey = @InvoiceKey;


	SELECT DISTINCT OD.orderKey INTO #Orders
	FROM dbo.Invoicedetail ID  WITH(NOLOCK)
		INNER JOIN dbo.OrderDetail OD WITH(NOLOCK) ON OD.OrderDetailKey=ID.OrderDetailKey
	WHERE ID.InvoiceKey= @InvoiceKey;

	DELETE FROM #Orders
	WHERE OrderKey IN
	(
		SELECT A.OrderKey 
		FROM #Orders A 
			INNER JOIN dbo.OrderDetail OD WITH(NOLOCK) ON OD.OrderKey=A.OrderKey
			INNER JOIN dbo.OrderDetailStatus ODS WITH(NOLOCK) ON ODS.[Status]=OD.[Status]
		WHERE ODS.[Description]<>'Approved for Invoice/Driver Pay'
	);

	UPDATE dbo.OrderHeader
	SET [Status]= ( SELECT [Status] FROM dbo.OrderStatus WITH(NOLOCK) WHERE [Description]='Invoice Generated' )
	WHERE OrderKey IN ( SELECT OrderKey FROM #Orders );
	--****************************************************************************
	SET @Status=1
	SET @Reason = 'Success'

	DECLARE @UserName NVARCHAR(MAX)='', @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0
	SELECT @UserName = ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
	SELECT @InvoiceNo = ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
	SELECT @OrderDetailKey = OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Invoice ' + @InvoiceNo + ' approved'
END