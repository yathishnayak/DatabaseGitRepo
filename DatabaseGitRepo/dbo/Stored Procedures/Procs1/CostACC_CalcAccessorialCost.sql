
-- CostACC_CalcAccessorialCost  @MarketKey = 2,  @AccessorialsLineItems=',Chassis- JCT,Other,Overweight Surcharge,Pallet Out / Reload,Pallets', @TruckType ='Company - Asset', @YardPort = 'Local',@Terminal = 'LA/LB'

CREATE Proc [dbo].[CostACC_CalcAccessorialCost] 
-- CostACC_CalcAccessorialCost  @MarketKey = 2,  @AccessorialsLineItems='Chassis- JCT', @TruckType ='Company - Asset', @YardPort = 'Local'
(
	@MarketKey			int = 0,
	@AccessorialsLineItems nvarchar(500) = '',
	@Terminal			varchar(50) = '',
	@YardPort			varchar(10) = '',
	@Zone				varchar(10) = '',
	@TruckType			varchar(50) = '',
	@IsDebug			bit = 0
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	Declare  
		@AddedAccessorialsTotalCost		decimal(18,2),
		@Market				varchar(50)

	update COSTACC_FinalDataOutput set terminal = 'LA/LB' where Market = 'Long Beach' and Terminal is null

	select @Market = MarketLocation from MarketLocation where MarketLocationKey = @MarketKey
	if(@IsDebug = 1)
	Begin
		select '@Market', @Market
	end

	select * into #AccesorialItemKeys from dbo.Fn_SplitParam(@AccessorialsLineItems)
	
	if(@IsDebug = 1)
	Begin
		select '#AccesorialItemKeys',* from #AccesorialItemKeys
	end

	select RecordSL, B.Market, B.terminal,TruckType, B.YardPort, B.zone, B.FreePer, B.SplitPercent, B.[Group], B.FixVsNonFix,
	 EffectiveDate, EffectiveDateFrom,
	B.LineItem, B.Per, b.UnitCost , convert(decimal(18,3),b.UnitCost) as TotalCost
	into #Accessorials
	from #AccesorialItemKeys A
	inner join COSTACC_FinalDataOutput B on A.Value = B.LineItem
	inner join MarketLocation M on B.Market = M.MarketLocation and M.MarketLocationKey = @MarketKey

	select @AddedAccessorialsTotalCost = sum(totalCost)  from #Accessorials
	if(@IsDebug = 1)
	Begin
		select '#Accessorials',* from #Accessorials
	end


	

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

	if(@IsDebug = 1)
	Begin
		select '#InterRecord',* from #InterRecord
		select isnull((Select Count(1) from #InterRecord),0)
		select count(1) from #AccesorialItemKeys  where value = 'RETURN'
	end
	
	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'RETURN'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'RETURN') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'RETURN', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',97.55, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Overweight'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Overweight') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Overweight', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',100.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Chassis- JCT'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Chassis- JCT') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Chassis- JCT', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',10.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Chassis- Port'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Chassis- Port') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Chassis- Port', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',35.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'CUSTOMER WAIT TIME (2 HOURS FREE)'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'CUSTOMER WAIT TIME (2 HOURS FREE)') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'CUSTOMER WAIT TIME (2 HOURS FREE)', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',65.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End
	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'CUSTOMER WAIT TIME (2HRS FREE)'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'CUSTOMER WAIT TIME (2HRS FREE)') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'CUSTOMER WAIT TIME (2HRS FREE)', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',65.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'PORT WAIT TIME (2HRS FREE)'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'PORT WAIT TIME (2HRS FREE)') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'PORT WAIT TIME (2HRS FREE)', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',65.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Placard'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Placard') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Placard', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',50.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End
	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Placard Placement'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Placard Placement') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Placard Placement', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',50.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End
	

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Empty Termination'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Empty Termination') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Empty Termination', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',97.55, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem like 'Yard Storage%'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Yard Storage%') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Yard Storage- Empty, Loaded', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',25.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Yard Storage- Empty'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Yard Storage- Empty') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Yard Storage- Empty', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',25.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Yard Storage- Loaded'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Yard Storage- Loaded') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Yard Storage- Loaded', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',25.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	if( isnull((Select Count(1) from #InterRecord where Lineitem = 'Chassis Lift/Flip'),0) = 0)
	Begin
		if((select count(1) from #AccesorialItemKeys  where value = 'Chassis Lift/Flip') = 1)
		Begin
			insert into #InterRecord ( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
				FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,SplitPercent , TotMatch)
			Select 1, 'Chassis Lift/Flip', @Market, @Terminal, @TruckType, @YardPort, @Zone, '',
				'','',65.00, '2020-01-01','Flat Rate', 0, 0, 1
		End
	End

	
	if(@IsDebug = 1)
	Begin
		select '#InterRecord - 2',* from #InterRecord
	end


	select  RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent 
	from (
		select  *, ROW_NUMBER() over(partition by Lineitem ORder by TotMatch desc, Convert(Datetime, (CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) END)) Desc) RecNo From #InterRecord B 
	) C where RecNo = 1

	drop table #InterRecord
	drop table #Accessorials
	drop table  #AccesorialItemKeys 
end
