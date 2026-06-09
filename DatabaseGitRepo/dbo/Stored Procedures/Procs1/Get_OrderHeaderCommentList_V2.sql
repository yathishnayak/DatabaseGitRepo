/*

DECLARE 
	@UserKey		INT				=952,
	@JSONString		NVARCHAR(MAX)	='{"OrderKey":185658}',
	@Status			BIT				=0,
	@Reason			VARCHAR(100)	=''
EXEC [Get_OrderHeaderCommentList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/

CREATE PROCEDURE [dbo].[Get_OrderHeaderCommentList_V2]
(
	@UserKey      INT			= 952,
	@JSONString   NVARCHAR(MAX)	= '',
	@Status       BIT			= 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderKey	INT	=	0;
	DECLARE @RowCount	INT	=	0;

	SELECT @OrderKey = OrderKey
	FROM OPENJSON(@JSONString, '$')
		WITH(
				OrderKey	INT	'$.OrderKey'
			);

	SELECT 
		OHC.Orderkey,
		C.Commentkey, 
		ISNULL(U.UserName,'') as UserName, 
		C.[Description] AS HeaderComment, 
		C.CreateDate, 
		C.CreateUserkey,
		ISNULL(C.ParentCommentKey,0) ParentCommentKey,
	
		JSON_QUERY((
				SELECT
					OHD1.OrderKey,C1.Commentkey, 
					ISNULL(U1.UserName,'') as UserName, 
					C1.[Description] AS DetailComment, 
					C1.CreateDate, 
					C1.CreateUserkey   
				FROM dbo.Comment C1 WITH(NOLOCK)
				INNER JOIN dbo.OrderHeaderComments OHD1 WITH(NOLOCK) ON OHD1.CommentKey = C1.CommentKey
				LEFT JOIN dbo.[User] U1 WITH(NOLOCK) ON U1.UserKey=C1.CreateUserKey 
			WHERE OHD1.OrderKey = @OrderKey AND ISNULL(C1.ParentCommentKey,0) <>0 and C1.ParentCommentKey=C.CommentKey 
	and  ISNULL(C1.isDeleted ,0) = 0 
	ORDER BY C1.CommentKey ASC
	FOR JSON PATH
				)) AS Replies
	FROM dbo.Comment C WITH(NOLOCK)
		INNER JOIN dbo.OrderHeaderComments OHC WITH(NOLOCK) ON OHC.commentkey = C.commentkey
		LEFT JOIN dbo.[User] U WITH(NOLOCK) ON U.UserKey=C.CreateUserKey 
	WHERE OHC.Orderkey = @OrderKey and  ISNULL(C.isDeleted ,0) = 0 AND ISNULL(C.ParentCommentKey,0)=0
	ORDER BY  C.CreateDate DESC FOR JSON PATH;

	SET @RowCount = @@ROWCOUNT;

	IF @RowCount > 0
	BEGIN
		SET @Status = 1;
		SET @Reason = 'Success';
	END
	ELSE
	BEGIN
		SET @Status = 0;
		SET @Reason = 'No data found';
	END
END