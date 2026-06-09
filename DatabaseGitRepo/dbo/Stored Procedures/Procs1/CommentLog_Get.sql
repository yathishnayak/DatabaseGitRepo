

CREATE procedure [dbo].[CommentLog_Get] 
(
	@CommentKey int = 0	
)
as
begin
  set nocount on
  set fmtonly off

    select LogKey,CommentKey,OriginalComment,ModifiedComment,CreatedDate,CreatedUserKey,Isdeleted,u.UserName as CreatedUserName 
	from CommentLog c 
	inner join [user] U with(nolock) on U.UserKey = c.CreatedUserKey
	where c.CommentKey = @CommentKey
	for json path
end
