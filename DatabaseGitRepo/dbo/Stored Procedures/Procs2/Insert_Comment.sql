CREATE PROCEDURE [dbo].[Insert_Comment]
/*
dbo.fn_insert_comment
*/
@Description	NVARCHAR(max),
@City			VARCHAR(255),
@CreateUserKey	INT	,
@IsUsercomment  BIT = 0,
@ParentCommentKey INT,
@Commentkey		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

   INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey,IsUsercomment,ParentCommentKey)
	VALUES (@Description, GETDATE(),@CreateUserKey,@IsUsercomment,@ParentCommentKey)

	SET @CommentKey=0;
	SET @CommentKey = ( SELECT SCOPE_IDENTITY());		
END