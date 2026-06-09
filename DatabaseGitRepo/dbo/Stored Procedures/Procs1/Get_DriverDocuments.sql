
CREATE PROCEDURE [dbo].[Get_DriverDocuments]
@DriverKey INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,d.DocumentKey,DT.[Description] AS DocType,DT.DocumentTypeKey
	FROM dbo.Document D 
		INNER JOIN dbo.DriverDocuments ODD ON D.DocumentKey =ODD.DocumentKey 
		INNER JOIN dbo.DocumenType DT ON DT.DocumentTypeKey=D.DocumentType
	WHERE ODD.DriverKey = @DriverKey AND D.IsDeleted=0;
END;
