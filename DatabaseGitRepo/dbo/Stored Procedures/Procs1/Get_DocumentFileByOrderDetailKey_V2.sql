/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey" : 48878}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_DocumentFileByOrderDetailKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_DocumentFileByOrderDetailKey_V2]
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
	@OrderDetailKey INT=0

	SELECT 
		@OrderDetailKey	=	OrderDetailKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey		INT		'$.OrderDetailKey'
	)


	SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,DT.[Description] AS DocType,DT.DocumentTypeKey
	-- d.DocumentKey,
	FROM dbo.Document D WITH (NOLOCK)
		INNER JOIN dbo.OrderDetailDocuments ODD WITH (NOLOCK) ON D.DocumentKey =ODD.DocumentKey 
		INNER JOIN dbo.DocumenType DT WITH (NOLOCK) ON DT.DocumentTypeKey=D.DocumentType
	WHERE ODD.OrderDetailKey = @OrderDetailKey AND D.IsDeleted=0
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END;
