
CREATE Proc [dbo].[Cost_BaseCostForSell]
as
Begin
	select * from COST_CostDataOutput
	order by MArket, Terminal, City, State, Zone, DriverType, YardPortType

	select * 
	INTO #Cost_DrayBase
	from (
		select Market, Terminal, Zone, cost, fsf, DrayBase, CostOutputDataKey,
			ROW_NUMBER() Over (partition by Market, Terminal, Zone  order by Market, Terminal, Zone, draybase desc ) as RowNum
		from COST_CostDataOutput
	) a where RowNum = 1

	select * 
	INTO #Cost_Prepull
	from (
		select Market, Terminal, Zone, PrepullCost,
			ROW_NUMBER() Over (partition by Market, Terminal, Zone  order by Market, Terminal, Zone, PrepullCost desc ) as RowNum
		from COST_CostDataOutput_PrePull
	) a where RowNum = 1


	select * 
	INTO #Cost_StopOff
	from (
		select Market, Terminal, Zone, StopOffCost,
			ROW_NUMBER() Over (partition by Market, Terminal, Zone  order by Market, Terminal, Zone, StopOffCost desc ) as RowNum
		from COST_CostDataOutput_StopOff
	) a where RowNum = 1

	if(((select count(1) from #Cost_DrayBase) > 0) and
		((Select count(1) from #Cost_Prepull) > 0) and
		((Select Count(1) from #Cost_StopOff) > 0))
	Begin
		TRUNCATE TABLE Cost_BaseCostForSellDatabase
	End

	insert into Cost_BaseCostForSellDatabase (MarketKey, TerminalKey, zone, Cost, FSF, Draybase, PrepullCost, StopOffCost, DateCreated)
	select Ml.MarketLocationKey, T.PriceGroupingKey, DB.Zone, DB.Cost, DB.FSF, DB.DrayBase, PP.PrepullCost, SO.StopOffCost, GetDate()
	--DB.Market, Db.Terminal, DB.Zone, DB.Cost, DB.FSF, DB.DrayBase, PP.PrepullCost, SO.StopOffCost
	from #Cost_DrayBase DB
	Left join #Cost_Prepull PP on DB.Market = PP.Market and DB.Terminal = PP.Terminal and DB.Zone = PP.Zone
	Left join #Cost_StopOff SO on DB.Market = SO.Market and DB.Terminal = SO.Terminal and DB.Zone = SO.Zone
	Inner join MarketLocation ML on Db.Market = ML.MarketLocation
	inner join PriceGrouping T on DB.Terminal = T.PriceGrouping -- Terminal
	order by DB.Market, Db.Terminal, DB.Zone
END
