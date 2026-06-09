
CREATE proc [dbo].[Sell_GetConfigData]
as
Begin
select distinct isnull(SC.SellConfigKey,0) as SellConfigKey, 
	ML.MarketLocationKey, ML.MarketLocation, 
	T.PriceGroupingKey as TerminalKey, T.PriceGrouping as Terminal,
	ZO.ZoneKey, ZO.ZoneName,
	isnull(SC.IsPrePull,0) as IsPrePull, isnull(SC.PrePullValue,0) as PrePullValue,
	isnull(SC.IsStopOff,0) as IsStopOff, isnull(SC.StopOffValue,0) as StopOffValue,
	isnull(SC.HighestOff,0) as HighestOff, isnull(SC.DrayBaseValue,0) as DrayBaseValue,
	TotalValue = Case when isnull(SC.IsPrePull,0) = 1 then isnull(SC.PrePullValue,0) else 0 end +
				Case when isnull(SC.IsStopOff,0) = 1 then isnull(SC.StopOffValue,0) else 0 end + 
				isnull(SC.DrayBaseValue,0),
	SC.Effective_date EffectiveDate, SC.EffectiveFromKey, CEF.EffectiveFrom, YardType
from MarketLocation ML 
Inner join PriceGrouping T on ML.MarketLocationKey = T.MarketLocationKey
Inner join cost_Zones ZO on  ML.MarketLocationKey =ZO.MarketKey
left join COST_CostDataOutput CO on CO.Market = ML.MarketLocation and CO.Zone = ZO.ZoneName and CO.Terminal = T.PriceGrouping
Left join Sell_Config SC on ML.MarketLocationKey = SC.MarketKey and T.PriceGroupingKey = SC.TerminalKey and ZO.ZoneKey = SC.ZoneKey
LEft join Cost_EffectiveFrom CEF on SC.EffectiveFromKey = CEF.EffectiveKey
Order by ML.MarketLocation,  ZO.ZoneName , T.PriceGrouping
End
