create proc AutoUpdate_ContainerStatus
as
declare @OrdDetailKey int = 0
declare tempCursor cursor  FOR
select orderdetailkey from orderdetail

Open tempcursor
Fetch next from TempCursor into @OrdDetailKey

while @@FETCH_STATUS = 0
begin
	print '-------'
	print @OrdDetailKey
	exec UpdateContainerStatus @OrdDetailKey
	Fetch next from TempCursor into @OrdDetailKey
end

close TempCursor
deallocate TempCursor
