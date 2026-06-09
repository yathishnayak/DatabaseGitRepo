/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 38417, "BrokerRefNo" : "RPJ-0024A"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Update_InvoiceBrokerRefNo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[Update_InvoiceBrokerRefNo_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
BEGIN

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@InvoiceKey		int,
	@BrokerRefNo	varchar(20)

	SELECT 
		@InvoiceKey			=		InvoiceKey,
		@BrokerRefNo		=		BrokerRefNo
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey			INT				'$.InvoiceKey',
		BrokerRefNo			VARCHAR(20)		'$.BrokerRefNo'
	) 

	SET @Status = 0
	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM InvoiceHeader with(nolock) WHERE InvoiceKey = @InvoiceKey
	IF(@CNT > 0)
	BEGIN
		UPDATE InvoiceHeader
		SET BrokerRefNo = @BrokerRefNo,  UpdateUserKey = @UserKey
		where InvoiceKey = @InvoiceKey

		UPDATE data_invoiceReport
		SET BrokerRefNo = @BrokerRefNo
		where InvoiceKey = @InvoiceKey

		DECLARE @UserName NVARCHAR(MAX)='', @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0
		SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
		SELECT @InvoiceNo=ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
		SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
		SELECT @OrderDetailKey=OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Broker Ref No changed to ' + @BrokerRefNo + ' for invoice ' + @InvoiceNo
		
		SET @Status = 1
		SET @Reason = 'Success'
	END
END