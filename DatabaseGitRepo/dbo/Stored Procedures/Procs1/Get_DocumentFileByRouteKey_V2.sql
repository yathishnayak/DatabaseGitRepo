/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"RouteKey" : 199516}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_DocumentFileByRouteKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_DocumentFileByRouteKey_V2] 
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
	@RouteKey INT=0

	SELECT 
		@RouteKey	=	RouteKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		RouteKey		INT		'$.RouteKey'
	)

	SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,DT.[Description] AS DocType,DT.DocumentTypeKey,'' DocSource--,DD.DocSource
	FROM dbo.Document D WITH (NOLOCK)
	INNER JOIN dbo.ContainerLegDocuments CLD WITH (NOLOCK) ON D.DocumentKey =CLD.DocumentKey 
	INNER JOIN dbo.DocumenType DT WITH (NOLOCK) ON DT.DocumentTypeKey=D.DocumentType
	--LEFT JOIN driverdocuments DD WITH (NOLOCK) ON DD.DocumentKey=D.DocumentKey
	WHERE CLD.RouteKey = @RouteKey AND D.IsDeleted=0
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END;

