/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"InvoiceKey":0, "ReasoncodeKey":0}'
 
EXEC [InvoiceReasonCode_Update_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[InvoiceReasonCode_Update_V2]
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
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	DECLARE @InvoiceKey		INT = 0,
			@ReasoncodeKey	INT = 0

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Reason  = 'JSONString cannot be blank';
		SET @Status = 0;
	END
	ELSE
	BEGIN
		SELECT @InvoiceKey		=  InvoiceKey,
			   @ReasoncodeKey   =  ReasoncodeKey
		FROM OpenJSON(@JSONString, '$')
		WITH (
			InvoiceKey			INT				'$.InvoiceKey',
			ReasoncodeKey		INT				'$.ReasoncodeKey'
		)
	END
 
	-- ================================
	-- Main Business Logic goes here
	-- ================================

	UPDATE  InvoiceHeader 
	SET ReasoncodeKey =  @ReasoncodeKey
	WHERE InvoiceKey =  @InvoiceKey

	DECLARE @UserName NVARCHAR(MAX)='', @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0
	SELECT @UserName = ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
	SELECT @InvoiceNo = ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
	SELECT @OrderDetailKey = OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
	
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Reason Code changed for invoice ' + @InvoiceNo

	SET @Status = 1;
	SET @Reason = 'Success';

END