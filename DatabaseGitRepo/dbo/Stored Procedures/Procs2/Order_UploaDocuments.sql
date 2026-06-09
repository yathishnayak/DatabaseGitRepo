CREATE PRoc [dbo].[Order_UploaDocuments] -- Get_ContainerAllDocuments 49
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
	
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	
	IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter missing';
	END

	SET @Status=1;
	SET @Reason='SUCCESS';

	DECLARE @DocumentType		INT,
			@createuserKey		INT,
			@OriginalFileName	VARCHAR(500),
			@CustomerGroup		SMALLINT,
			@OriginalFileType	VARCHAR(50),
			@FileSizeinMB		SMALLINT,
			@PaymentTerms		SMALLINT,
			@FilePath			VARCHAR(500),
			@DocumnetKey		INT ,--OUTPUT,
			@OrderKey		    INT,
			@OrderDetailKey		INT

	SELECT @DocumentType = DocumentType
	FROM OPENJSON(@JSONString,'$')
    WITH (
			DocumentType		INT				'$.DocumentType',
			CreateuserKey		INT				'$.CreateuserKey',
			OriginalFileName	VARCHAR(500)	'$.OriginalFileName',
			CustomerGroup		SMALLINT		'$.CustomerGroup',
			OriginalFileType	VARCHAR(50)		'$.OriginalFileType',
			FileSizeinMB		SMALLINT		'$.FileSizeinMB',
			PaymentTerms		SMALLINT		'$.PaymentTerms',
			FilePath			VARCHAR(500)	'$.FilePath',
			DocumnetKey			INT				'$.DocumnetKey',--OUTPUT,
			OrderKey		    INT				'$.OrderKey',
			OrderDetailKey		INT				'$.OrderDetailKey'
		 )

	EXEC Insert_Document	@DocumentType,	@createuserKey,	@OriginalFileName,	@CustomerGroup,	@OriginalFileType,
							@FileSizeinMB,	@PaymentTerms,	@FilePath,	@DocumnetKey OUTPUT

	EXEC Insert_OrderHeaderDocument @DocumnetKey, @OrderKey

END
