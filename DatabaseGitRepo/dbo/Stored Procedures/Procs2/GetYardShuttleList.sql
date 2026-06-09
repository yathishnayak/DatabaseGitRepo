
create proc [dbo].[GetYardShuttleList]
as
Begin
	set nocount on
	set fmtonly off
	select YardID, 'From ' + ShortName  as ShuttleName, 100 + YardId as ShuttleCode
	from yard 
	where IsActive = 1 and IsShuttleLocation = 1
	union all
	select YardID, 'To ' + ShortName  as ShuttleName, 200 + YardId as ShuttleCode
	from yard 
	where IsActive = 1 and IsShuttleLocation = 1
End
