

CREATE View [dbo].[vVoucherWeekNums]
as
Select A.VoucherKey, A.MinArrival,
--DATEADD(DAY, 2 - (case when (DATEPART(WEEKDAY, convert(date,A.MinArrival))) = 1 then 7 else (DATEPART(WEEKDAY, convert(date,A.MinArrival))) end), CAST(A.MinArrival AS DATE)) [Week_Start_Date],
--DATEADD(DAY, 8 - (case when (DATEPART(WEEKDAY, convert(date,A.MinArrival))) = 1 then 8 else (DATEPART(WEEKDAY, convert(date,A.MinArrival))) end), CAST(A.MinArrival AS DATE)) [Week_End_Date] 

	DATEADD(DAY, 2 - DATEPART(WEEKDAY, convert(date,MinArrival)), CAST(MinArrival AS DATE)) [Week_Start_Date],
	DATEADD(DAY, 8 - DATEPART(WEEKDAY, convert(Date, MinArrival)), CAST(MinArrival AS DATE)) [Week_End_Date] 

--B.Week_Start_Date, B.Week_End_Date 
from 
			(
				select VH.VoucherKey, min(RT.ActualArrival ) as MinArrival --, A.Week_Start_Date, A.Week_End_Date
				from VoucherHeader VH WITH (NOLOCK) 
				inner join VoucherDetail VD WITH (NOLOCK) on VH.VoucherKey = VD.Voucherkey
				inner join Routes RT		WITH (NOLOCK) on VD.RouteKey = RT.RouteKey
				--inner join RouteStatus RTS	WITH (NOLOCK) on RT.Status = RTS.Status
				where --RTS.Description='Leg Completed' and 
					RT.Status = 5 -- Leg completed
					AND rt.ActualArrival is not null
				Group by VH.VoucherKey
				having min(RT.ActualArrival) is not null
			) A
	--		cross apply dbo.fn_getIsoWeekStartEndDates( isnull(A.MinArrival,'2022-01-01')) B
