
CREATE proc [dbo].[AutoUpdate_ContainerTypeLink]
as
declare @OrdDetailKey	int = 0,
		@CommentKey		Int	 = 0
declare tempCursor cursor  FOR
select orderdetailkey, CommentKey from OrderDetailComments

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
