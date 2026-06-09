
CREATE PROC [dbo].[Sell_GetDraybaseValue] -- Sell_GetDraybaseValue 2, 2, 6, 'IE'
(
	@MarketKey		int,
	@ZoneKey		int,
	@TerminalKey	int,
	@HighestOff		varchar(20) -- All, Local, Port, IE
)
as
Begin
	Set nocount on
	set fmtonly off

	select isnull(Sc.SellConfigKey,0) as SellConfigKey,  
		max(isnull(isnull(SC.DrayBaseValue, PP.DrayBase),0)) as DrayBaseCost
	from MarketLocation ML 
	LEft join PriceGrouping T on ML.MarketLocationKey = T.MarketLocationKey
	LEft Join COST_CostDataOutput PP on ml.MarketLocation = PP.Market and PP.Terminal = T.PriceGrouping
	LEft join cost_Zones Z on PP.Zone = Z.ZoneName and ML.MarketLocationKey = Z.MarketKey
	Left join Sell_Config SC on ML.MarketLocationKey = SC.MarketKey and T.PriceGroupingKey = SC.TerminalKey and Z.ZoneKey = SC.ZoneKey
	where ML.MarketLocationKey = @MarketKey and T.PriceGroupingKey = @TerminalKey and Z.ZoneKey = @ZoneKey and
		--PP.YardPortType = case when isnull(@HighestOff,'ALL') = 'ALL' then PP.YardPortType else  @HighestOff end
		PP.DriverType = case when isnull(@HighestOff,'ALL') = 'ALL' then PP.DriverType else  @HighestOff end
	group by Sc.SellConfigKey
End
