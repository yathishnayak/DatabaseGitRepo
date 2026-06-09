/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"MInvoicelinekey" : 4, "MInvoicekey" : 4}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Delete_ManualInvoiceLine_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Delete_ManualInvoiceLine_V3]
(
	@UserKey		INT = 0,
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
		@MInvoicelinekey		INT,
		@MInvoicekey			INT

	SELECT 
		@MInvoicelinekey		=		MInvoicelinekey,
		@MInvoicekey			=		MInvoicekey	
	FROM OPENJSON(@JSONString)
	WITH
	(
		 MInvoicelinekey		INT		'$.MInvoicelineKey',
		 MInvoicekey			INT		'$.MInvoiceKey'	
	)

	SET @Status=0;

	DELETE 
	FROM dbo.ManualInvoiceDetail
	WHERE MInvoicelinekey = @MInvoicelinekey and MInvoicekey =@MInvoicekey;  

	UPDATE dbo.ManualInvoiceHeader
	SET MInvoiceAmount= ( SELECT SUM(ExtCost) FROM dbo.ManualInvoiceDetail WITH (NOLOCK) WHERE MInvoiceKey=@MInvoicekey )
	WHERE MInvoiceKey=@MInvoicekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @Status=1
		SET @Reason = 'Success'
	END	;

END