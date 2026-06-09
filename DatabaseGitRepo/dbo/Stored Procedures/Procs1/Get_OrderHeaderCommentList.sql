CREATE PROCEDURE [dbo].[Get_OrderHeaderCommentList]
@OrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT OHC.Orderkey,C.Commentkey, ISNULL(U.UserName,'') as UserName, C.[Description] AS HeaderComment, 
	C.CreateDate, C.CreateUserkey,ISNULL(C.ParentCommentKey,0) ParentCommentKey,
	Replies =(
	SELECT OHD1.OrderKey,C1.Commentkey, ISNULL(U1.UserName,'') as UserName, C1.[Description] AS DetailComment, 
	C1.CreateDate, C1.CreateUserkey   
	FROM dbo.comment C1
		INNER JOIN dbo.OrderHeaderComments OHD1 ON OHD1.commentkey = C1.commentkey
		LEFT JOIN dbo.[User] U1 ON U1.UserKey=C1.CreateUserKey 
	WHERE OHD1.OrderKey = @OrderKey AND ISNULL(C1.ParentCommentKey,0) <>0 and c1.ParentCommentKey=c.CommentKey 
	and  isnull(isDeleted ,0) = 0 
	order by CommentKey asc
	for json path
	)
	FROM dbo.comment C
		INNER JOIN dbo.OrderHeaderComments OHC ON OHC.commentkey = C.commentkey
		LEFT JOIN dbo.[User] U ON U.UserKey=C.CreateUserKey 
	WHERE OHC.Orderkey = @OrderKey and  isnull(isDeleted ,0) = 0 AND ISNULL(ParentCommentKey,0)=0
	order by  C.CreateDate desc
END