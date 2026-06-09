CREATE proc [dbo].[Comment_Delete]
(
	@CommentKey		   int = 0,
	@UserKey		   int = 0,
	@IsPermanentDelete bit = 0,
	@Status			   Bit = 0OUTPUT,
	@Reason			   varchar(100) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	Declare @Cnt int = 0
	select @Cnt = COUNT(1) from Comment where CommentKey = @CommentKey

	if(isnull(@Cnt,0) = 0)
	Begin
		set @Status = 0
		SEt @Reason = 'Comment not Exists'
		return
	End

	set @Cnt = 0
	select @Cnt = COUNT(1) from Comment where CommentKey = @CommentKey and isnull(isDeleted ,0) = 1
	if(isnull(@Cnt,0) = 1)
	Begin
		set @Status = 0
		SEt @Reason = 'Comment already deleted'
		return
	End

	DECLARE @OldComment varchar(max) 
    SET @OldComment =( SELECT Description FROM Comment WHERE CommentKey = @CommentKey)

	update Comment set
		isDeleted = 1,
		IsPermanentDelete = @IsPermanentDelete,
		DeleteDate = GETDATE(),
		DeleteUserKey = @UserKey
	where CommentKey = @CommentKey

	insert into CommentLog(CommentKey,OriginalComment,ModifiedComment,CreatedDate,CreatedUserKey,Isdeleted)
	               values(@CommentKey,@OldComment,@OldComment,GETDATE(),@UserKey,1)

	set @Status = 1
		SEt @Reason = 'Comment deleted successfully'
		return
END
