CREATE PRocEDURE [dbo].[Order_Insert_OrderHeaderDocument] 
@DocumentKeys	VARCHAR(100),
@OrderKey		INT,
@OrderDetailKeys	VARCHAR(300),
@IsOrderScreen	BIT=0
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
								FROM [Fn_SplitParam] ( @DocumentKeys)
						 );


	SELECT  OriginalFileName INTO #ExistingFile
	FROM OrderheaderDocuments OHD 
		INNER JOIN dbo.Document D ON D.DocumentKey=OHD.DocumentKey 
	WHERE D.IsDeleted=0 AND OHD.OrderKey=@OrderKey;

	INSERT INTO dbo.OrderHeaderDocuments(orderKey, Documentkey) 
	SELECT @OrderKey,DocumentKey 
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );

	--change below line
	CREATE TABLE #OrderDetailKeys
	(
		OrderDetailKey	INT
	)
	IF(LEN(ISNULL(@OrderDetailKeys,'')) > 0)
	BEGIN
		INSERT INTO #OrderDetailKeys(OrderDetailKey)
		SELECT VALUE FROM dbo.Fn_SplitParamCol(@OrderDetailKeys)
	END
	SELECT ROW_NUMBER() OVER(ORDER BY OrderDetailKey,DocumentKey) AS SLNo, * INTO #finalTable 
	FROM #OrderDetailKeys OD
	INNER JOIN #NewFiles ON 1=1
	DECLARE @Counter INT=1,@TotalCount INT =0,@OrderDetailKey INT=0,@DocumentKey INT=0
	SET @TotalCount=(SELECT COUNT (*) FROM #finalTable)
	WHILE(@Counter<=@TotalCount)
	BEGIN
		SELECT @OrderDetailKey=OrderDetailKey,@DocumentKey=DocumentKey FROM #finalTable WHERE SLNo=@Counter
		EXEC Insert_OrderDetailDocument @DocumentKey,@OrderDetailKey
		SET @Counter=@Counter+1
	END
END;
