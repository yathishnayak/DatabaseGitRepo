/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DocumentKey" : "596696", "OrderDetailKey" : 47704, "ItemKey" : 18, "RouteKey" : 177973}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Insert_OrderExpenseDocument_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Insert_OrderExpenseDocument_V3]
/*
dbo.fn_insert_orderheader_document
Insert Multiple Order Detail Documents 
*/
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
		@DocumentKey	VARCHAR(100),
		@OrderDetailKey		INT,
		@ItemKey			Int,
		@RouteKey			Int
	SELECT 
		
		@DocumentKey		=	DocumentKey		,
		@OrderDetailKey		=	OrderDetailKey	,
		@ItemKey			=	ItemKey			,
		@RouteKey			=	RouteKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		DocumentKey			VARCHAR(100)		'$.DocumentKey',		
		OrderDetailKey		INT					'$.OrderDetailKey',	
		ItemKey				INT					'$.ItemKey',			
		RouteKey			INT					'$.RouteKey'
	)

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

	SET @Status = 1
	SET @Reason = 'Success'
END
