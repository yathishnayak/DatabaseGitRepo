

create Proc [dbo].[Audit_CreateRoutesLog]
as
Begin
	select L.*
	into #OHLog
	from  AuditLog L 
	Left Join Routes_AuditLog A on A.MainAuditLogKey = L.MaintAuditLogKey
	where ISNULL(L.RouteKey,0) > 0 and A.RouteKey is null

	insert into Routes_AuditLog (RouteKey, LogDate, LogText, ActionUserKey, MainAuditLogKey)
	select L.RouteKey, L.sysdate, 
		case fieldName 
		when 'DeliveryDateFrom' then 'Delivery Date From '
		when 'LastFreeDay' then ' Last Free Day '
		when 'ActualArrival' then ' Actual Delivery Date '
		when 'ConfirmationNo' then ' Confirmation No '
		when 'SourceAddrKey' then ' Source Address '
		when 'CutOffDate' then ' Cut Off Date '
		when 'DriverKey' then ' Driver '
		when 'DeliveryDateTo' then ' Delivery Date To '
		when 'DestinationAddrKey' then ' Destination Addres '
		when 'ActualDeparture' then ' Actual Pickup '
		when 'PickupDate' then ' Pickup Date '
		else 'NA' end +

		case when Oldvalue is null then 'inserted ' else ' ' end +

		case when isnull(oldvalue,'') = '' then 'as ' + isnull(newvalue, '') else 'changed from ' + oldvalue + ' to ' + newvalue end
		as LogText,
		case when isnumeric(UserId) = 0 then 0 else userid end,
		MaintAuditLogKey
	from #OHLog L

	DROP TABLE #OHLog
END
