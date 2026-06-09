

create Proc [dbo].[Audit_CreateVoucherLineLog]
as
Begin
	select L.*
	into #OHLog
	from  AuditLog L 
	Left Join VoucherLine_AuditLog A on A.MainAuditLogKey = L.MaintAuditLogKey
	where ISNULL(L.VoucherKey,0) > 0 and A.VoucherLineKey is null and L.VoucherLineKey is not null

	insert into VoucherLine_AuditLog (VoucherLineKey, LogDate, LogText, ActionUserKey, MainAuditLogKey)
	select L.VoucherLineKey, L.sysdate, 
		case fieldName 
		when 'UnitCost' then 'Unit Cost '
		when 'Qty' then ' Quantity '
		else 'NA' end +

		case when Oldvalue is null then 'inserted ' else ' ' end +

		case when isnull(oldvalue,'') = '' then 'as ' + isnull(newvalue, '') else 'changed from ' + oldvalue + ' to ' + newvalue end
		as LogText,
		case when isnumeric(UserId) = 0 then 0 else userid end,
		MaintAuditLogKey
	from #OHLog L

	DROP TABLE #OHLog
END
