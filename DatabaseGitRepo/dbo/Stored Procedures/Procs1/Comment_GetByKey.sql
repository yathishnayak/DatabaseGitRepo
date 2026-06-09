Create Proc Comment_GetByKey
(
	@CommentKey		int = 0,
	@Comment		nvarchar(max) = '',
	@Status			Bit = 0 OUTPUT,
	@Reason			varchar(100) = '' OUTPUT
)
as
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

	select @Comment = Description
	from Comment
	where CommentKey = @CommentKey
	set @Status = 1
	set @Reason = 'Comment retrieved'
END
