/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceLineKey" : 165, "InvoiceKey" : 6}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Delete_PrepayInvoiceLine_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Delete_PrepayInvoiceLine_V3]
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
		@PPInvoicelinekey	INT,
		@PPInvoicekey			INT

	SELECT 
		@PPInvoicelinekey		=	PPInvoicelinekey	,
		@PPInvoicekey			=	PPInvoicekey		
	FROM OPENJSON(@JSONString)
	WITH
	(
		PPInvoicelinekey		INT			'$.InvoiceLineKey',
		PPInvoicekey			INT			'$.InvoiceKey'
	)

	SET @Status=0;

	DELETE 
	FROM dbo.PrepayInvoiceDetail
	WHERE PPInvoicelinekey = @PPInvoicelinekey and PPInvoicekey =@PPInvoicekey;  

	UPDATE dbo.PrepayInvoiceHeader
	SET PPInvoiceAmount= ( SELECT SUM(ExtCost) FROM dbo.PrepayInvoiceDetail WITH(NOLOCK) WHERE PPInvoiceKey=@PPInvoicekey )
	WHERE PPInvoiceKey=@PPInvoicekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @Status=1
		SET @Reason = 'Success'
	END	;

END