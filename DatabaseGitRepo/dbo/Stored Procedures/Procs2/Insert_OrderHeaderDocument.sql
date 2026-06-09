CREATE PROCEDURE [dbo].[Insert_OrderHeaderDocument] 
@DocumentKey	VARCHAR(100),
@OrderKey		INT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	--INSERT INTO dbo.OrderHeaderDocuments(orderKey, Documentkey) 
	--SELECT @OrderKey,[Value] 
	--FROM [Fn_SplitParam] ( @DocumentKey );

	SELECT OriginalFileName,DocumentKey INTO #NewFiles
	FROM dbo.Document 
	WHERE DocumentKey IN (
								SELECT [Value] 
								FROM [Fn_SplitParam] ( @DocumentKey)
						 );


	SELECT  OriginalFileName INTO #ExistingFile
	FROM OrderheaderDocuments OHD 
		INNER JOIN dbo.Document D ON D.DocumentKey=OHD.DocumentKey 
	WHERE D.IsDeleted=0 AND OHD.OrderKey=@OrderKey;

	INSERT INTO dbo.OrderHeaderDocuments(orderKey, Documentkey) 
	SELECT @OrderKey,DocumentKey 
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );
END;
