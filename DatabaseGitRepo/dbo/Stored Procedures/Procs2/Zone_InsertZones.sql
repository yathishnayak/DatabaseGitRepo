
CREATE proc [dbo].[Zone_InsertZones]
as
insert into ZoneCityMap ( MarketKey, TerminalKey, City, State, ZoneKey)
select distinct ML.MarketLocationKey, PriceGroupingKey, CO.city, CO.State, Z.ZoneKey  
from COST_CostDataOutput CO WITH (NOLOCK)
inner join MarketLocation ML WITH (NOLOCK) on co.Market = ML.MarketLocation
inner join PriceGrouping T WITH (NOLOCK) on Co.Terminal = T.PriceGrouping
inner join cost_Zones Z WITH (NOLOCK) on Co.Zone = Z.ZoneName and z.MarketKey = ML.MarketLocationKey
left join ZoneCityMap ZM WITH (NOLOCK) on z.ZoneKey = ZM.ZoneKey and Z.MarketKey = ZM.MarketKey and T.PriceGroupingKey = ZM.TerminalKey and
	CO.city = ZM.City and CO.State = ZM.State
where isnull(CO.city,'') <>  ''and isnull(CO.state,'') <> '' and ZM.ZoneKey is null

