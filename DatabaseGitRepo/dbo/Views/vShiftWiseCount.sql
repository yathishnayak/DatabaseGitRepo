
CREATE view [dbo].[vShiftWiseCount]
as
--select EffectiveDate, OrderBy, ShiftName,slotName,CountGroup, count(1) as Cnt From (
--select PR.EffectiveDate, S.ShiftName, TS.slotName,TS.timeFrom, TS.timeTo, 
--	case when [TYPE] ='From' then 'From ' + FromLocation 
--		 when [Type] = 'To' Then 'To ' +  ToLocation end as CountGroup, OrderBy
--from (
--select * from vPendingRoutes WITH (NOLOCK)
--where case when [type] ='FROM' then pickupDateFrom else DeliveryDateFrom end >= convert(date,GetDate())
--) PR 
--inner join shiftTimeSlots TS  WITH (NOLOCK) on  PR.Effectivetime BETWEEN ts.timeFrom AND TS.timeTo
--INNER JOIN SHIFTS S WITH (NOLOCK) ON ts.shiftKey = S.ShiftKey
--where EffectiveDate between Getdate()-1 and  getdate() + 8
--) A
--group by EffectiveDate, OrderBy,ShiftName, slotName,CountGroup


select NextDate as EffectiveDate, OrderBy, ShiftName,slotName,CountGroup, count(1) as Cnt From (
select PR.EffectiveDate, S.ShiftName, TS.slotName,TS.timeFrom, TS.timeTo, NextDate,
	case when [TYPE] ='From' then 'From ' + FromLocation 
		 when [Type] = 'To' Then 'To ' +  ToLocation end as CountGroup, OrderBy
from SHIFTS S WITH (NOLOCK)
inner join shiftTimeSlots TS  WITH (NOLOCK) on  ts.shiftKey = S.ShiftKey 
inner join (
	SELECT DATEADD(day, n.number, convert(Date,GetDate())) AS NextDate
FROM (VALUES(0),(1),(2),(3),(4),(5),(6)) n(number)
) Dt on 1=1
LEFT JOIN (
select * from vPendingRoutes WITH (NOLOCK)
where case when [type] ='FROM' then pickupDateFrom else DeliveryDateFrom end >= convert(date,GetDate())
) PR   ON  PR.Effectivetime BETWEEN ts.timeFrom AND TS.timeTo and convert(Date, pr.EffectiveDate) = Dt.NextDate
) A where NextDate between Getdate()-1 and  getdate() + 8
group by NextDate, OrderBy,ShiftName, slotName,CountGroup
