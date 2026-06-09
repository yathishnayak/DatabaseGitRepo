/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DocumentType" : 12, "OriginalFileName" : "Email_Documents_IMPT2612349_20260415_112233.pdf", "OriginalFileType" : "pdf", "FileSizeinMB" : 33, "FilePath" : "184\\183401//"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Insert_Document_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Insert_Document_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
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
	@DocumentType		INT,
	-- @createuserKey		INT,
	@OriginalFileName	VARCHAR(500),
	-- @CustomerGroup		SMALLINT,
	@OriginalFileType	VARCHAR(50),
	@FileSizeinMB		SMALLINT,
	-- @PaymentTerms		SMALLINT,
	@FilePath			VARCHAR(500),
	@DocumentKey		INT

	SELECT
	@DocumentType				=	DocumentType		,
	-- @createuserKey			=	createuserKey		,
	@OriginalFileName			=	OriginalFileName	,
	-- @CustomerGroup				=	CustomerGroup		,
	@OriginalFileType			=	OriginalFileType	,
	@FileSizeinMB				=	FileSizeinMB		,
	-- @PaymentTerms				=	PaymentTerms		,
	@FilePath					=	FilePath,			
	@DocumentKey				=	DocumentKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
	DocumentType			INT					'$.DocumentType',			
	OriginalFileName		VARCHAR(500)		'$.OriginalFileName',
	-- CustomerGroup			SMALLINT			'$.CustomerGroup',	
	OriginalFileType		VARCHAR(50)			'$.OriginalFileType',
	FileSizeinMB			SMALLINT			'$.FileSizeinMB',	
	-- PaymentTerms			SMALLINT			'$.PaymentTerms',	
	FilePath				VARCHAR(500)		'$.FilePath',
	DocumentKey				INT					'$.DocumentKey'
	)

	INSERT INTO dbo.Document ( DocumentType,CreateDate,CreateUserKey,OriginalFileName,OriginalFileType,FileSizeinMB,IsDeleted,DeletedDate,FilePath  ) 
	VALUES ( @DocumentType, GETDATE(), @UserKey,@OriginalFileName,@OriginalFileType,@FileSizeinMB,0,NULL,@FilePath)

	SET @DocumentKey= ( SELECT SCOPE_IDENTITY() )

	SET @Status = 1
	SET @Reason = 'Success'

	SELECT @DocumentKey AS DocumentKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
