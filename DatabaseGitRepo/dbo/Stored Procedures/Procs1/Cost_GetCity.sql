CREATE proc [dbo].[Cost_GetCity] -- Cost_GetCity 3
		(
			@MarketKey		int
		)
		as
		begin
			set nocount on
			set fmtonly off

			select CityKey, Country, State, City, ZipCode
			from LocationData
			where state in (
				select distinct state 
				from COST_CostDataOutput CO
				inner join MarketLocation ML on CO.Market = ML.MarketLocation
				where MarketLocationKey = @MarketKey)
		end
