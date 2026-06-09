


CREATE proc [dbo].[Sell_ReinsertSellConfig]
as
TRUNCATE TABLE Sell_Config

insert into Sell_Config (MarketKey, ZoneKey, TerminalKey, IsPrePull, PrePullValue, IsStopOff, StopOffValue, HighestOff, 
		DrayBaseValue, Effective_date, EffectiveFromKey, YardType, CreateDate, CreateUser, UpdateDate, UpdateUser)
Select DRAY.MarketLocationKey, DRAY.ZoneKey, DRAY.TerminalKey,  
	z.IsPrePull, case when z.IsPrePull = 1 then prepull.PrepullCost else 0 end as PrePullvalue,
	Z.IsStopOff, case when z.IsStopOff = 1 then StopOff.StopOffCost else 0 end as StopOffValue,
	Dray.TruckType as HighestOff, DrayBase, Dray.EffectiveDate, EF.EffectiveKey, case when PrePull.PPHighestOff = 'ALL' then 'All' else prepull.PPHighestOff end, 
	GetDate(), 1, null, null
from (
	select * from (
		select *, ROW_NUMBER() over(partition by marketLocationkey, zonekey, TerminalKey order by draybase + fsf desc) as RecRank
		from (
			select ML.MarketLocationKey, Z.ZoneKey, T.PriceGroupingKey as TerminalKey, DrayBase, FSF, FSFCost, EffectiveDate, TT.TruckType, 
			EffectiveDateFrom
			from COST_CostDataOutput CO WITH (NOLOCK)
			inner join MarketLocation ML  WITH (NOLOCK) on CO.Market = ML.MarketLocation
			inner join cost_Zones Z  WITH (NOLOCK) on CO.Zone = Z.ZoneName
			inner join PriceGrouping T  WITH (NOLOCK) on CO.Terminal = T.PriceGrouping
			inner  join TruckType TT  WITH (NOLOCK) on CO.DriverType = TT.TruckType
		) A
	) B 
	where RecRank  = 1
) Dray 
LEft join (
	select * from (
		select *, ROW_NUMBER() over(partition by marketLocationkey, zonekey, TerminalKey order by ToConsider, PrepullCost desc) as RecRank
		from (
			select ML.MarketLocationKey, Z.ZoneKey, T.PriceGroupingKey as TerminalKey, Prepulllocation, PrepullCost, EffectiveDate, 
			Z.HighestOf as PPHighestOff,
			Case when Z.HighestOf = Prepulllocation then 1
				 when Z.HighestOf = 'All' then  2 else 9 end as ToConsider
			from COST_CostDataOutput_PrePull CO WITH (NOLOCK)
			inner join MarketLocation ML WITH (NOLOCK) on CO.Market = ML.MarketLocation
			inner join cost_Zones Z WITH (NOLOCK) on CO.Zone = Z.ZoneName
			inner join PriceGrouping T WITH (NOLOCK) on CO.Terminal = T.PriceGrouping
			--order by Prepulllocation
		) A
	) B 
	where RecRank  = 1
) PrePull on Dray.MarketLocationKey = prepull.MarketLocationKey and dray.ZoneKey = prepull.ZoneKey and dray.TerminalKey = PrePull.TerminalKey
LEft join (
	select * from (
		select *, ROW_NUMBER() over(partition by marketLocationkey, zonekey, TerminalKey order by ToConsider, StopOffCost desc) as RecRank
		from (
			select ML.MarketLocationKey, Z.ZoneKey, T.PriceGroupingKey as TerminalKey, StopOfflocation, StopOffCost, EffectiveDate, Z.HighestOf,
			Case when Z.HighestOf = StopOfflocation then 1
				 when Z.HighestOf = 'All' then  2 else 9 end as ToConsider
			from COST_CostDataOutput_StopOff CO WITH (NOLOCK)
			inner join MarketLocation ML WITH (NOLOCK) on CO.Market = ML.MarketLocation
			inner join cost_Zones Z WITH (NOLOCK) on CO.Zone = Z.ZoneName
			inner join PriceGrouping T WITH (NOLOCK) on CO.Terminal = T.PriceGrouping
			--order by StopOfflocation
		) A
	) B 
	where RecRank  = 1
) StopOff on dray.MarketLocationKey = StopOff.MarketLocationKey and Dray.ZoneKey = StopOff.ZoneKey and Dray.TerminalKey = StopOff.TerminalKey
Left join cost_Zones Z  on Dray.ZoneKey = Z.ZoneKey 
left join Cost_EffectiveFrom EF on Dray.EffectiveDateFrom = EF.EffectiveFrom

