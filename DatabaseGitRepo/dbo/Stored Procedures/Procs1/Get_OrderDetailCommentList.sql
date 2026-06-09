CREATE PROCEDURE [dbo].[Get_OrderDetailCommentList]
@OrderDetailKey INT=94686
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderKey INT=0

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
	SELECT OHD.OrderDetailKey,C.Commentkey, ISNULL(U.UserName,'') as UserName, C.[Description] AS HeaderComment, 
	C.CreateDate, C.CreateUserkey,ISNULL(C.ParentCommentKey,0) ParentCommentKey,
	Replies =(
	SELECT OHD1.OrderDetailKey,C1.Commentkey, ISNULL(U1.UserName,'') as UserName, C1.[Description] AS DetailComment, 
	C1.CreateDate, C1.CreateUserkey   
	FROM dbo.comment C1
		INNER JOIN dbo.OrderDetailComments OHD1 ON OHD1.commentkey = C1.commentkey
		LEFT JOIN dbo.[User] U1 ON U1.UserKey=C1.CreateUserKey 
	WHERE OHD1.OrderDetailKey = @OrderDetailKey AND ISNULL(C1.ParentCommentKey,0) <>0 and c1.ParentCommentKey=c.CommentKey 
	and  isnull(isDeleted ,0) = 0 
	order by CommentKey asc
	for json path
	)
	FROM dbo.comment C
		INNER JOIN dbo.OrderDetailComments OHD ON OHD.commentkey = C.commentkey
		LEFT JOIN dbo.[User] U ON U.UserKey=C.CreateUserKey 
	WHERE OHD.OrderDetailKey = @OrderDetailKey AND C.CommentKey NOT IN ( SELECT CommentKey FROM #ContType)
	and  isnull(isDeleted ,0) = 0 AND ISNULL(ParentCommentKey,0)=0

	UNION
	SELECT OHC.Orderkey,C.Commentkey, ISNULL(U.UserName,'') as UserName, C.[Description] AS HeaderComment, 
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
END