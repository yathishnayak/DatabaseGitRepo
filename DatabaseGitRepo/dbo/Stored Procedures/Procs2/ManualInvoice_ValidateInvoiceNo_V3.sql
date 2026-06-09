/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"MInvoiceNo" : "M-102837-B"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [ManualInvoice_ValidateInvoiceNo_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[ManualInvoice_ValidateInvoiceNo_V3]  -- ManualInvoice_ValidateInvoiceNo 'M-102837-A'
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@MInvoiceNo VARCHAR(50)

	SELECT 
		@MInvoiceNo	=	MInvoiceNo
	FROM OPENJSON(@JSONString)
	WITH
	(
		MInvoiceNo			VARCHAR(50)		'$.MInvoiceNo'
	)

	SET @Status = 0 
	SET @Reason = 'MInvoiceNo Already Exists'


	IF(ISNULL(@MInvoiceNo,'') = '')
	BEGIN
		RETURN @Status
	END
	ELSE
	BEGIN
		DECLARE @CNT INT = 0
		
			SELECT @CNT = COUNT(1)
			FROM ManualInvoiceHeader WITH (NOLOCK)
			WHERE MInvoiceNo = @MInvoiceNo

			IF(ISNULL(@CNT,0) = 0)
			BEGIN
				SET @Status = 1
				SET @Reason = 'Success'
			END
			RETURN @CNT
	END
END