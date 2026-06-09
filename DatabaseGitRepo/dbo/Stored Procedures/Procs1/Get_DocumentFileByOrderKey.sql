

CREATE PROCEDURE [dbo].[Get_DocumentFileByOrderKey]
@OrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,d.DocumentKey,DT.[Description] AS DocType,DT.DocumentTypeKey,D.FilePath
	FROM dbo.Document D 
		INNER JOIN dbo.OrderheaderDocuments DOD ON D.DocumentKey =DOD.DocumentKey 
		INNER JOIN dbo.DocumenType DT ON DT.DocumentTypeKey=D.DocumentType
	WHERE dod.OrderKey = @OrderKey AND D.IsDeleted=0;
END;
