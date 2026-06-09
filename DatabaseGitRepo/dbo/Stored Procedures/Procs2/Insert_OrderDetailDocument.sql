
CREATE PROCEDURE [dbo].[Insert_OrderDetailDocument]
/*
dbo.fn_insert_orderheader_document
Insert Multiple Order Detail Documents 
*/
@DocumentKey	VARCHAR(100),
@OrderDetailKey		INT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT OriginalFileName,DocumentKey INTO #NewFiles
	FROM dbo.Document 
	WHERE DocumentKey IN (
								SELECT [Value] 
								FROM [Fn_SplitParam] ( @DocumentKey)
						 );


	SELECT  OriginalFileName INTO #ExistingFile
	FROM OrderDetailDocuments ODD 
		INNER JOIN dbo.Document D ON D.DocumentKey=ODD.DocumentKey 
	WHERE D.IsDeleted=0 AND ODD.OrderDetailKey=@OrderDetailKey;

	
	INSERT INTO dbo.OrderDetailDocuments(OrderDetailKey, Documentkey)
	SELECT @OrderDetailKey,DocumentKey
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );
END
