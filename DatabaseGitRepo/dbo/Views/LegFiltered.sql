
CREATE view [dbo].[LegFiltered]
as
select *  from (
select L.LegKey, replace(Replace(L.LEgID,'(Live)',''),'(Drop)','') as LegID, L.FromLocation, L.ToLocation,
	ROW_NUMBER() over (partition by  FromLocation, ToLocation order by FromLocation, ToLocation) row_num
from Leg L -- (Select B.*, DropOrLive = case when LegID like '%Live%' then 'Live' else 'Drop' end from Leg B)  L
--inner join LegType LT on L.LegTypeKey = LT.LegtypeKey
) A where A.row_num = 1