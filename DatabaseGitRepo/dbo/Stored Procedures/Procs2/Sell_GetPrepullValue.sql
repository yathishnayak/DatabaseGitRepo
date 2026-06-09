

CREATE proc [dbo].[Sell_GetPrepullValue] -- Sell_GetPrepullValue 2, 1, 6
(
	@MarketKey		int,
	@ZoneKey		int,
	@TerminalKey	int,
	@YardType		varchar(20) -- All, Local, Port, IE
)
as
Begin
	Set nocount on
	set fmtonly off

	select isnull(Sc.SellConfigKey,0) as SellConfigKey,  
		max(isnull(isnull(SC.PrePullValue, PP.PrepullCost),0)) as PrepullCost
	from MarketLocation ML 
	LEft join PriceGrouping T on ML.MarketLocationKey = T.MarketLocationKey
	LEft Join COST_CostDataOutput_PrePull PP on ml.MarketLocation = PP.Market and PP.Terminal = T.PriceGrouping
	LEft join cost_Zones Z on PP.Zone = Z.ZoneName and ML.MarketLocationKey = Z.MarketKey
	Left join Sell_Config SC on ML.MarketLocationKey = SC.MarketKey and T.PriceGroupingKey = SC.TerminalKey and Z.ZoneKey = SC.ZoneKey
	--where ML.MarketLocationKey = @MarketKey and T.PriceGroupingKey = @TerminalKey and Z.ZoneKey = @ZoneKey
	where ML.MarketLocationKey = @MarketKey and T.PriceGroupingKey = @TerminalKey and Z.ZoneKey = @ZoneKey and
		PP.Prepulllocation = case when isnull(@YardType,'ALL') = 'ALL' then PP.Prepulllocation else  @YardType end
	group by Sc.SellConfigKey
End
