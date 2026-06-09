
CREATE PROCEDURE [dbo].[Get_DriverOrderDetailDocuments] -- [Get_DriverOrderDetailDocuments] 5, 166
@DriverKey INT=0,
@OrderDetailKey INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT D.DocumentKey,OriginalFileName, OriginalFileType ,FileSizeinMB,
	DT.[Description] AS DocType,DT.DocumentTypeKey, 
	d.FilePath,  d.FilePath + OriginalFileName as Fullfilepath, d.CreateDate
	FROM dbo.Document D 
		inner join OrderDetailDocuments ODD on D.documentKey = ODD.documentKey
		INNER JOIN dbo.DriverDocuments DD ON D.DocumentKey =DD.DocumentKey 
		INNER JOIN dbo.DocumenType DT ON DT.DocumentTypeKey=D.DocumentType
	WHERE DD.DriverKey = @DriverKey AND ODD.OrderDetailKey = @OrderDetailKey AND D.IsDeleted=0
	order by d.DocumentKey desc
END;
