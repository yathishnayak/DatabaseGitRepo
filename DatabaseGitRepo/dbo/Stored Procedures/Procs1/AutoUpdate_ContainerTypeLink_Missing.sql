

CREATE proc AutoUpdate_ContainerTypeLink_Missing
as
Begin
	select  OD.OrderDetailKey, ODC.CommentKey
	into #PendTransload
	from  orderdetail OD WITH (NOLOCK)
	inner join OrderDetailComments ODC WITH (NOLOCK) on ODC.OrderDetailKey = OD.OrderDetailKey
	inner join comment C  WITH (NOLOCK) on   C.CommentKey = ODC.CommentKey
	LEft join ContainerTypesLink CTL WITH (NOLOCK) on Od.OrderDetailKey = CTL.OrderDetailKey 
		and CTL.CommentKey = C.CommentKey and CTl.ContainerTypeKey = 6
	where C.CreateDate >= convert(datetime, '2024-10-01') and Description like '%Transload%'
	and CTL.CommentKey is null and len(C.Description) < 100

	
	declare @OrdDetailKey	int = 0,
			@CommentKey		Int	 = 0
	declare tempCursor cursor  FOR
	select  orderdetailkey, CommentKey from #PendTransload

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

	Drop table #PendTransload
End