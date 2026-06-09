/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DocumentKey" : "596696", "OrderDetailKey" : 47699}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Insert_OrderDetailDocument_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Insert_OrderDetailDocument_V3]
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
	@DocumentKey		VARCHAR(100),
	@OrderDetailKey		INT

	SELECT
		@DocumentKey			=		DocumentKey,
		@OrderDetailKey			=		OrderDetailKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		DocumentKey			VARCHAR(100)		'$.DocumentKey'	,
		OrderDetailKey		INT					'$.OrderDetailKey'
	)

	SELECT OriginalFileName,DocumentKey INTO #NewFiles
	FROM dbo.Document WITH (NOLOCK)
	WHERE DocumentKey IN (
								SELECT [Value] 
								FROM [Fn_SplitParam] ( @DocumentKey)
						 );

	SELECT  OriginalFileName INTO #ExistingFile
	FROM OrderDetailDocuments ODD WITH (NOLOCK)
		INNER JOIN dbo.Document D WITH (NOLOCK) ON D.DocumentKey=ODD.DocumentKey 
	WHERE D.IsDeleted=0 AND ODD.OrderDetailKey=@OrderDetailKey;

	
	INSERT INTO dbo.OrderDetailDocuments(OrderDetailKey, Documentkey)
	SELECT @OrderDetailKey,DocumentKey
	FROM #NewFiles
	WHERE OriginalFileName NOT IN ( SELECT OriginalFileName FROM #ExistingFile );

	DECLARE @UserName NVARCHAR(MAX)='',@ContainerNo VARCHAR(20)=''
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=(SELECT CreateUserKey FROM Document WITH(NOLOCK) WHERE DocumentKey=@DocumentKey)
	SELECT @ContainerNo=ISNULL(ContainerNo, '') FROM OrderDetail WITH(NOLOCK) WHERE OrderDetailKey=@OrderDetailKey
	
	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Document uploaded by ' +@UserName

	SET @Status = 1
	SET @Reason = 'Success'
END
