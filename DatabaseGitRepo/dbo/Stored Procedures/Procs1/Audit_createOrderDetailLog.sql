
create Proc [dbo].[Audit_createOrderDetailLog]
as
Begin
	select L.*
	into #OHLog
	from  AuditLog L 
	Left Join OrderDetail_AuditLog A on A.MainAuditLogKey = L.MaintAuditLogKey
	where ISNULL(L.OrderdetailKey,0) > 0 and A.OrderdetailKey is null

	insert into OrderDetail_AuditLog (OrderdetailKey, LogDate, LogText, ActionUserKey, MainAuditLogKey)
	select L.OrderdetailKey, L.sysdate, 
		case fieldName 
		when 'ContainerSizeKey' then ' Container Size '
		when 'ContainerNo' then ' Container No '
		when 'Weight' then ' Weight '
		else 'NA' end +

		case when Oldvalue is null then 'inserted ' else ' ' end +

		case when isnull(oldvalue,'') = '' then 'as ' + isnull(newvalue, '') else 'changed from ' + oldvalue + ' to ' + newvalue end
		as LogText,
		case when isnumeric(UserId) = 0 then 0 else userid end,
		MaintAuditLogKey
	from #OHLog L

	DROP TABLE #OHLog
END
