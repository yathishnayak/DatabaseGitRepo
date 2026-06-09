

CREATE View [dbo].[vDriver_GrossIncomeReportByWeek]
AS
select --a.voucherno,b.voucherkey,a.VoucherDate,
d.FirstName,d.LastName,d.DriverID,
--c.ActualArrival, 
isnull(convert(varchar,datepart(ISO_WEEK, c.ActualArrival)),'') as Weeknum,
convert(decimal(18,2),sum(b.ExtCost)) as GrossIncome
from VoucherHeader(nolock) a
inner join Voucherdetail(nolock) b
ON a.VoucherKey=b.Voucherkey
Inner Join Routes c
ON b.RouteKey=c.RouteKey
Inner join Driver d
ON c.DriverKey=d.DriverKey
Where isnull(convert(varchar,datepart(ISO_WEEK,c.ActualArrival)),'')= 23 and a.StatusKey<>1
--and DriverID like '05%'
group by --a.voucherno,b.Voucherkey,a.VoucherDate,
d.FirstName,d.LastName,d.DriverID,--c.ActualArrival, 
isnull(convert(varchar,datepart(ISO_WEEK, c.ActualArrival)),'')
--order by d.DriverID
