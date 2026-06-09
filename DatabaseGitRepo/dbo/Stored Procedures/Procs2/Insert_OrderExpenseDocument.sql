
CREATE PROCEDURE [dbo].[Insert_OrderExpenseDocument]
/*
dbo.fn_insert_orderheader_document
Insert Multiple Order Detail Documents 
*/
(
	@DocumentKey	VARCHAR(100),
	@OrderDetailKey		INT,
	@ItemKey			Int,
	@RouteKey			Int
)
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
	FROM OrderExpenseDocuments ODD 
		INNER JOIN dbo.Document D ON D.DocumentKey=ODD.DocumentKey 
	WHERE D.IsDeleted=0 AND ODD.OrderDetailKey=@OrderDetailKey and ItemKey = @ItemKey and RouteKey = @RouteKey

	
	INSERT INTO dbo.OrderExpenseDocuments(OrderDetailKey, Documentkey, ItemKey, RouteKey)
	SELECT @OrderDetailKey,DocumentKey, @ItemKey, @RouteKey
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );
END
