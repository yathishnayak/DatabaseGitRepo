CREATE proc [dbo].[AutoUpdate_ContainerTypeLink_ForADate]
as
declare @OrdDetailKey	int = 0,
		@CommentKey		Int	 = 0
declare tempCursor cursor  FOR
	select orderdetailkey, ODC.CommentKey 
	from OrderDetailComments ODC WITH (NOLOCK)
	inner join Comment C WITH (NOLOCK) ON ODC.CommentKey = C.CommentKey
	where createdate > getdate() -1 

Open tempcursor
Fetch next from TempCursor into @OrdDetailKey, @CommentKey

while @@FETCH_STATUS = 0
begin
	print '-------'
	print @OrdDetailKey
	exec Container_TypeInsert @OrdDetailKey, @CommentKey
	Fetch next from TempCursor into @OrdDetailKey, @CommentKey
end

close TempCursor
deallocate TempCursor
