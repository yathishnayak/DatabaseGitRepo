/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"OrderDetailKey" : 226001}'
	EXEC [Get_OrderDetailCommentList_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_OrderDetailCommentList_V2]
-- @OrderDetailKey INT = 94686
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@OrderDetailKey INT = 94686,
		@OrderKey INT=0

	SELECT 
		@OrderDetailKey = OrderDetailKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey			INT			'$.OrderDetailKey'
	)

	SELECT @OrderKey=OrderKey FROM OrderDetail WHERE OrderDetailKey=@OrderDetailKey

	CREATE TABLE #ContType
	(
		OrderDetailKey	INT,
		CommentKey		INT,
		ContType		VARCHAR(50),
		ContainerNo		VARCHAR(20),
		ShortCmnt		VARCHAR(20)		
	)


	INSERT INTO #ContType (OrderDetailKey,CommentKey,ContType,ContainerNo,ShortCmnt)
	EXECUTE Get_ContainerTypeForContainer @OrderDetailKey, ''

	SELECT * FROM (
	SELECT OHD.OrderDetailKey,C.Commentkey as CommentKey, ISNULL(U.UserName,'') as UserName, C.[Description] AS HeaderComment, 
	C.CreateDate, C.CreateUserkey as CreateUserKey,ISNULL(C.ParentCommentKey,0) ParentCommentKey,
	Replies =(
	SELECT OHD1.OrderDetailKey,C1.Commentkey as CommentKey, ISNULL(U1.UserName,'') as UserName, C1.[Description] AS DetailComment, 
	C1.CreateDate, C1.CreateUserkey as CreateUserKey   
	FROM dbo.comment C1 WITH (NOLOCK)
		INNER JOIN dbo.OrderDetailComments OHD1 WITH (NOLOCK) ON OHD1.commentkey = C1.commentkey
		LEFT JOIN dbo.[User] U1 WITH (NOLOCK) ON U1.UserKey=C1.CreateUserKey 
	WHERE OHD1.OrderDetailKey = @OrderDetailKey AND ISNULL(C1.ParentCommentKey,0) <>0 and c1.ParentCommentKey=c.CommentKey 
	and  isnull(isDeleted ,0) = 0 
	order by CommentKey asc
	for json path
	)
	FROM dbo.comment C WITH (NOLOCK)
		INNER JOIN dbo.OrderDetailComments OHD WITH (NOLOCK) ON OHD.commentkey = C.commentkey
		LEFT JOIN dbo.[User] U WITH (NOLOCK) ON U.UserKey=C.CreateUserKey 
	WHERE OHD.OrderDetailKey = @OrderDetailKey AND C.CommentKey NOT IN ( SELECT CommentKey FROM #ContType)
	and  isnull(isDeleted ,0) = 0 AND ISNULL(ParentCommentKey,0)=0
	
	UNION
	SELECT @OrderDetailKey OrderDetailKey,C.Commentkey, ISNULL(U.UserName,'') as UserName, C.[Description] AS HeaderComment, 
	C.CreateDate, C.CreateUserkey,ISNULL(C.ParentCommentKey,0) ParentCommentKey,
	Replies =(
	SELECT OHD1.OrderKey,C1.Commentkey, ISNULL(U1.UserName,'') as UserName, C1.[Description] AS DetailComment, 
	C1.CreateDate, C1.CreateUserkey   
	FROM dbo.comment C1 WITH(NOLOCK)
		INNER JOIN dbo.OrderHeaderComments OHD1 WITH(NOLOCK) ON OHD1.commentkey = C1.commentkey
		LEFT JOIN dbo.[User] U1 WITH(NOLOCK) ON U1.UserKey=C1.CreateUserKey 
	WHERE OHD1.OrderKey = @OrderKey AND ISNULL(C1.ParentCommentKey,0) <>0 and c1.ParentCommentKey=c.CommentKey 
	and  isnull(isDeleted ,0) = 0 
	order by CommentKey asc
	for json path
	)
	FROM dbo.comment C WITH(NOLOCK)
		INNER JOIN dbo.OrderHeaderComments OHC WITH(NOLOCK) ON OHC.commentkey = C.commentkey
		LEFT JOIN dbo.[User] U WITH(NOLOCK) ON U.UserKey=C.CreateUserKey 
	WHERE OHC.Orderkey = @OrderKey and  isnull(isDeleted ,0) = 0 AND ISNULL(ParentCommentKey,0)=0
	)A 
	order by CommentKey desc
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END