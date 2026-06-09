
CREATE Proc [dbo].[Comment_EditUpdate]
(
	@CommentKey		int = 0,
	@Comment		nvarchar(max) = '',
	@UserKey		int = 0,
	@Status			Bit = 0OUTPUT,
	@Reason			varchar(100) = '' OUTPUT
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

	if(LEN(isnull(replace(@Comment,' ',''),'')) = 0)
	Begin
		set @Status = 0
		SEt @Reason = 'Comment can''t be blank'
		return
	end
	declare @OldComment varchar(max) 
    set @OldComment =( select description from Comment where CommentKey = @CommentKey)

	Update Comment Set
		OriginalComment = case when isnull(OriginalComment,'') = '' then Description else OriginalComment end,
		Description = @Comment,
		UpdateDate = GETDATE(),
		UpdateUserKey = @UserKey
	where CommentKey = @CommentKey
	set @Status = 1
	SEt @Reason = 'Comment updated successfully'

	insert into CommentLog(CommentKey,OriginalComment,ModifiedComment,CreatedDate,CreatedUserKey,Isdeleted)
	               values(@CommentKey,@OldComment,@Comment,GETDATE(),@UserKey,0)
END
