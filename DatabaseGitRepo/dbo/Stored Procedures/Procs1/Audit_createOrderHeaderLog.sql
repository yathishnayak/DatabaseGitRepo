
create Proc [dbo].[Audit_createOrderHeaderLog]
as
Begin
	select L.*
	into #OHLog
	from  AuditLog L 
	Left Join OrderHeader_AuditLog A on A.MainAuditLogKey = L.MaintAuditLogKey
	where ISNULL(L.orderKey,0) > 0 and A.OrderKey is null

	insert into OrderHeader_AuditLog (OrderKey, LogDate, LogText, ActionUserKey, MainAuditLogKey)
	select L.OrderKey, L.sysdate, 
		case fieldName 
		when 'CsrKey' then ' CSR '
		when 'Arh_Amount' then ' ACH Amount '
		when 'BrokerKey' then ' Broker '
		when 'BookingNo' then ' Booking No '
		when 'SourceAddrKey' then ' Source Address '
		when 'ReturnAddrKey' then ' Return Address '
		when 'DestinationAddrKey' then ' Destination Address '
		when 'BillOfLading' then ' Bill of Lading '
		when 'PriorityKey' then ' Priority '
		when 'BrokerRefNo' then ' Broker Ref No ' else 'NA' end +

		case when Oldvalue is null then 'inserted ' else ' ' end +

		case when isnull(oldvalue,'') = '' then 'as ' + isnull(newvalue, '') else 'changed from ' + oldvalue + ' to ' + newvalue end
		as LogText,
		case when isnumeric(UserId) = 0 then 0 else userid end,
		MaintAuditLogKey
	from #OHLog L

	DROP TABLE #OHLog
END
