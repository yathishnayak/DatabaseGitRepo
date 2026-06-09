/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DocumentKey" : "596696,596697", "OrderKey" : 38743, "OrderDetailKeys" : "47699", "IsOrderScreen" :1 }',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Order_Insert_OrderHeaderDocument_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Order_Insert_OrderHeaderDocument_V3] 
(
	@UserKey		INT = 0,
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
		@DocumentKeys	VARCHAR(100),
		@OrderKey		INT,
		@OrderDetailKeys	VARCHAR(300),
		@IsOrderScreen	BIT=0

	SELECT
		@DocumentKeys			=		DocumentKeys	,
		@OrderKey				=		OrderKey		,
		@OrderDetailKeys		=		OrderDetailKeys,
		@IsOrderScreen			=		IsOrderScreen	
	FROM OPENJSON(@JSONString)
	WITH
	(
		DocumentKeys			VARCHAR(100)		'$.DocumentKey'	,
		OrderKey				INT					'$.OrderKey'		,
		OrderDetailKeys			VARCHAR(300)		'$.OrderDetailKeys'	,
		IsOrderScreen			BIT					'$.IsOrderScreen'	
	)


	
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
	DECLARE @JSON NVARCHAR(MAX),
        @DocumentStatus BIT,
        @DocumentReason VARCHAR(1000)

	WHILE(@Counter<=@TotalCount)
	BEGIN
		SELECT @OrderDetailKey=OrderDetailKey,@DocumentKey=DocumentKey FROM #finalTable WHERE SLNo=@Counter
		-- EXEC Insert_OrderDetailDocument @DocumentKey,@OrderDetailKey
		SET @JSON = '{
			"DocumentKey": "' + CAST(@DocumentKey AS VARCHAR) + '",
			"OrderDetailKey": ' + CAST(@OrderDetailKey AS VARCHAR) + '
		}'

    EXEC Insert_OrderDetailDocument_V3
        @UserKey = @UserKey,
        @JSONString = @JSON,
        @Status = @DocumentStatus OUTPUT,
        @Reason = @DocumentReason OUTPUT,
        @IsDebug = 0

		SET @Counter=@Counter+1
	END

	SET @Status = 1
	SET @Reason = 'Success'
END;
