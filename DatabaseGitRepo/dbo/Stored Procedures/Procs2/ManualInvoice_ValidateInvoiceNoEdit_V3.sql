/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"MInvoiceNo" : "M-100713", "MInvoiceKey" : 4}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [ManualInvoice_ValidateInvoiceNoEdit_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[ManualInvoice_ValidateInvoiceNoEdit_V3]  -- ManualInvoice_ValidateInvoiceNoEdit 'M-100713', 4
(
	@UserKey		INT = 1144,
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
		@MInvoiceNo		varchar(50),
		@MInvoiceKey	int

	SELECT 
		@MInvoiceNo			=		MInvoiceNo	,
		@MInvoiceKey		=		MInvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		MInvoiceNo		VARCHAR(50)		'$.MInvoiceNo',	
		MInvoiceKey		INT				'$.MInvoiceKey'
	)

	SET @Status = 0 

	IF(ISNULL(@MInvoiceNo,'') = '')
	BEGIN
		RETURN @Status
	END
	ELSE IF (ISNULL(@MInvoiceKey,0) = 0)
	BEGIN
		return @Status
	END
	ELSE IF(LEFT(@MInvoiceNo,2) <> 'M-')
	BEGIN
		return @Status
	END
	BEGIN
		DECLARE @CNT INT = 0
		
		SELECT @CNT = COUNT(1)
		FROM ManualInvoiceHeader WITH (NOLOCK)
		WHERE MInvoiceNo = @MInvoiceNo and MInvoiceKey <> @MInvoiceKey

		IF(ISNULL(@CNT,0) = 0)
		BEGIN
			update ManualInvoiceHeader Set MInvoiceNo = @MInvoiceNo
			where MInvoiceKey = @MInvoiceKey
			SET @Status = 1
			SET @Reason = 'Success'
		END
		ELSE
			BEGIN
				SET @Status = 0
				SET @Reason = 'Duplicate Invoice No'
			END
					--RETURN @CNT
	END
END