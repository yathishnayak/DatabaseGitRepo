
CREATE PROCEDURE [dbo].[Get_DocumentFilebyOrderNo]
@OrderNo VARCHAR(20)=''
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT D.DocumentKey,D.OriginalFileName,D.FileSizeinMB, D.OriginalFileType ,DT.[Description] AS DocType,DT.DocumentTypeKey
	FROM dbo.Document D
		INNER JOIN dbo.OrderheaderDocuments DOD ON D.DocumentKey =DOD.DocumentKey 
		INNER JOIN OrderHeader OH ON OH.OrderKey=DOD.OrderKey
		INNER JOIN dbo.DocumenType DT ON DT.DocumentTypeKey=D.DocumentType
	WHERE OH.OrderNo = @OrderNo and D.IsDeleted =0;
END;
