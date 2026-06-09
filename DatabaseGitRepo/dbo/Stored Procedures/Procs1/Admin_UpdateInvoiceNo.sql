/*
DECLARE 
	@UserKey INT=897,
	@JSONString		NVARCHAR(MAX)=  '{"OldInvoiceNo":"12","NewInvoiceNo":"0"}',
	@Status			BIT=0, 
	@IsDebug		BIT = 1, 
	@Reason			VARCHAR(100)=''
	EXec [InvoiceUpdate] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Admin_UpdateInvoiceNo]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(100) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	Declare
		@OldInvoiceNo VARCHAR(30),
		@NewInvoiceNo VARCHAR(30)
	--	@InvoiceKey INT 
	
	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END

	SELECT 
		@OldInvoiceNo=OldInvoiceNo,
		@NewInvoiceNo=NewInvoiceNo
	FROM OPENJSON(@JsonString, '$')
	WITH (
		OldInvoiceNo	VARCHAR(30)		'$.OldInvoiceNo',
		NewInvoiceNo	VARCHAR(30)		'$.NewInvoiceNo'
		)

	IF(@IsDebug = 1)
	BEGIN
		SELECT 'Parameters' AS Params,
		@OldInvoiceNo AS OldInvoiceNo,	
		@NewInvoiceNo AS NewInvoiceNo
	END

	---IF SAME
	IF @OldInvoiceNo=@NewInvoiceNo
	BEGIN
			PRINT 'Both Invoice Numbers are same'
			SET @Status=0
			SET @Reason='Both Invoice Numbers are same'
			RETURN
	END

	
	IF  NOT EXISTS(
	SELECT 1 from InvoiceHeader 
	WHERE InvoiceNo=@OldInvoiceNo
	)
	BEGIN 
			PRINT 'Invoice Number Not Found'
			SET @Status=0
			Set @Reason='Invoice Number Not Found'
			RETURN
	END

	---EXISTS
	--SELECT COUNT(*) FROM InvoiceHeader WHERE InvoiceNo = @NewInvoiceNo;
	--BEGIN
	--		PRINT 'Invoice Number Already Exists'
	--		SET @Status=0
	--		SET @Reason ='Invoice Number Already Exists'
	--		RETURN 
	--END


	--IF @NewInvoiceNo < 0
	--BEGIN
	--	PRINT 'Invoice number cannot be negative.'
	--	SET @Status = 0
	--	SET @Reason = 'Invoice number cannot be negative.'
	--	RETURN
	--END

	--IF @NewInvoiceNo = 0
	--BEGIN
	--	PRINT 'Invoice number cannot be zero.'
	--	SET @Status = 0
	--	SET @Reason = 'Invoice number cannot be zero.'
	--	RETURN
	--END


	IF EXISTS (
		SELECT 1 
		FROM InvoiceHeader
		WHERE InvoiceNo = @NewInvoiceNo
	)
	BEGIN
		PRINT 'New invoice number already exists.'
		SET @Status = 0
		SET @Reason = 'New invoice number already exists.'
		RETURN
	END

	
    UPDATE InvoiceHeader
    SET InvoiceNo = @NewInvoiceNo
    WHERE InvoiceNo = @OldInvoiceNo


	--UPDATE InvoiceHeader 
	--SET InvoiceNo=@NewInvoiceNo Where InvoiceNo=@OldInvoiceNo;

	SET @Status = 1
	SET @Reason = 'Success'
	
END


