-- CostACC_CalcAccessorialCost_Delete  @MarketKey = 2,  @AccessorialsLineItems='Chassis Split', @TruckType ='Company - Asset', @YardPort = 'Local',@Terminal = 'LA/LB'

CREATE Proc [dbo].[CostACC_CalcAccessorialCost_Delete] 
-- CostACC_CalcAccessorialCost  @MarketKey = 2,  @AccessorialsLineItems='Chassis- JCT', @TruckType ='Company - Asset', @YardPort = 'Local'
(
	@MarketKey			int = 0,
	@AccessorialsLineItems nvarchar(500) = '',
	@Terminal			varchar(50) = '',
	@YardPort			varchar(10) = '',
	@Zone				varchar(10) = '',
	@TruckType			varchar(50) = ''
)
As
BEGIN
	Declare  
		@AddedAccessorialsTotalCost		decimal(18,2),
		@Market				varchar(50)

	

	select @Market = MarketLocation from MarketLocation where MarketLocationKey = @MarketKey
	--select '@Market', @Market

	select * into #AccesorialItemKeys from dbo.Fn_SplitParam(@AccessorialsLineItems)
	--select '#AccesorialItemKeys',* from #AccesorialItemKeys


	select RecordSL, B.Market, B.terminal,TruckType, B.YardPort, B.zone, B.FreePer, B.SplitPercent, B.[Group], B.FixVsNonFix,
	 EffectiveDate, EffectiveDateFrom,
	B.LineItem, B.Per, b.UnitCost , convert(decimal(18,3),b.UnitCost) as TotalCost
	into #Accessorials
	from #AccesorialItemKeys A
	inner join COSTACC_FinalDataOutput B on A.Value = B.LineItem
	inner join MarketLocation M on B.Market = M.MarketLocation and M.MarketLocationKey = @MarketKey

	select @AddedAccessorialsTotalCost = sum(totalCost)  from #Accessorials
	--select '#Accessorials',* from #Accessorials

	select  RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent , (isYardPort + isTerminal + isMArket + isTruckType + isZone) as TotMatch
			into #InterRecord
			from (
			select *, 
				isYardPort = Case when YardPort = @yardPort then 1 else 0 end , 
				isTerminal = Case when Terminal = @Terminal then 1 else 0 end ,
				isMArket = Case when MArket = @Market then 1 else 0 end,
				isTruckType = Case when TruckType = @TruckType then 1 else 0 end,
				isZone = Case when Zone = @zone then 1 else 0 end
				from #Accessorials
				WHERE (Terminal = @Terminal OR isnull(Terminal,'') = '') AND
					(MArket = @Market OR isnull(Market,'') = '') AND
					(YardPort = @YardPort OR isnull(YardPort,'') = '') AND
					(TruckType = @TruckType OR isnull(TruckType,'') = '' )
				) A
	select '#InterRecord',* from #InterRecord

	select  RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent 
	from (
		select  *, ROW_NUMBER() over(partition by Lineitem ORder by TotMatch desc) RecNo From #InterRecord B 
	) C where RecNo = 1

	drop table #InterRecord
	drop table #Accessorials
	drop table  #AccesorialItemKeys 
end
