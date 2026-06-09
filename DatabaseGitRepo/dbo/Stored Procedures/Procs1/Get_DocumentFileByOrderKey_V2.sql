
/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderKey" : 37059}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_DocumentFileByOrderKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_DocumentFileByOrderKey_V2]
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
	@OrderKey INT=0

	SELECT 
		@OrderKey	=	OrderKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderKey		INT		'$.OrderKey'
	)

	SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB, DT.[Description] AS DocType,DT.DocumentTypeKey,D.FilePath
	-- d.DocumentKey
	FROM dbo.Document D WITH(NOLOCK)
		INNER JOIN dbo.OrderheaderDocuments DOD WITH(NOLOCK) ON D.DocumentKey =DOD.DocumentKey 
		INNER JOIN dbo.DocumenType DT WITH(NOLOCK) ON DT.DocumentTypeKey=D.DocumentType
	WHERE dod.OrderKey = @OrderKey AND D.IsDeleted=0
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END;
