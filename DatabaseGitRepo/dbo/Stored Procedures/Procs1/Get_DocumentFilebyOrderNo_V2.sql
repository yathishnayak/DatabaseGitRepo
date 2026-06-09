/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"OrderNo" : "PRIMOLFS230304"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_DocumentFilebyOrderNo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_DocumentFilebyOrderNo_V2]
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
	@OrderNo VARCHAR(20)=''

	SELECT 
		@OrderNo	=	OrderNo
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderNo		VARCHAR(20)		'$.OrderNo'
	)


	SELECT D.DocumentKey,D.OriginalFileName,D.FileSizeinMB, D.OriginalFileType ,DT.[Description] AS DocType,DT.DocumentTypeKey
	FROM dbo.Document D  WITH(NOLOCK)
		INNER JOIN dbo.OrderheaderDocuments DOD WITH(NOLOCK) ON D.DocumentKey =DOD.DocumentKey 
		INNER JOIN OrderHeader OH WITH(NOLOCK) ON OH.OrderKey=DOD.OrderKey
		INNER JOIN dbo.DocumenType DT WITH(NOLOCK) ON DT.DocumentTypeKey=D.DocumentType
	WHERE OH.OrderNo = @OrderNo and D.IsDeleted =0
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END;
