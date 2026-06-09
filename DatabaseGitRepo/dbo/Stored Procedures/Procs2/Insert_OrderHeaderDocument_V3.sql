/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DocumentKey" : "596696", "OrderKey" : 38743}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Insert_OrderHeaderDocument_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Insert_OrderHeaderDocument_V3] 
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
	
	--INSERT INTO dbo.OrderHeaderDocuments(orderKey, Documentkey) 
	--SELECT @OrderKey,[Value] 
	--FROM [Fn_SplitParam] ( @DocumentKey );

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@DocumentKey	VARCHAR(100),
		@OrderKey		INT

	SELECT
		@DocumentKey		=		DocumentKey,
		@OrderKey			=		OrderKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
		DocumentKey			VARCHAR(100)		'$.DocumentKey',
		OrderKey			INT					'$.OrderKey'
	)

	SELECT OriginalFileName,DocumentKey INTO #NewFiles
	FROM dbo.Document WITH(NOLOCK)
	WHERE DocumentKey IN (
								SELECT [Value] 
								FROM [Fn_SplitParam] ( @DocumentKey)
						 );


	SELECT  OriginalFileName INTO #ExistingFile
	FROM OrderheaderDocuments OHD WITH(NOLOCK)
		INNER JOIN dbo.Document D WITH(NOLOCK) ON D.DocumentKey=OHD.DocumentKey 
	WHERE D.IsDeleted=0 AND OHD.OrderKey=@OrderKey;

	INSERT INTO dbo.OrderHeaderDocuments(orderKey, Documentkey) 
	SELECT @OrderKey,DocumentKey 
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );

	SET @Status = 1
	SET @Reason = 'Success'
END;
