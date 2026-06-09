
CREATE PROCEDURE [dbo].[Get_DocumentFileByRouteKey] 
@RouteKey INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,DT.[Description] AS DocType,DT.DocumentTypeKey,'' DocSource--,DD.DocSource
	FROM dbo.Document D 
	INNER JOIN dbo.ContainerLegDocuments CLD ON D.DocumentKey =CLD.DocumentKey 
	INNER JOIN dbo.DocumenType DT ON DT.DocumentTypeKey=D.DocumentType
	--LEFT JOIN driverdocuments DD WITH (NOLOCK) ON DD.DocumentKey=D.DocumentKey
	WHERE CLD.RouteKey = @RouteKey AND D.IsDeleted=0;
END;

