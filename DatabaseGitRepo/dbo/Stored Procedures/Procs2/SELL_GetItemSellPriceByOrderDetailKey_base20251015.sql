
/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '', @IsDebug Bit = 1
set @JsonString = '{"ItemKey":24,"OrderDetailKey":161563}' -- 100, 121, 68

exec [SELL_GetItemSellPriceByOrderDetailKey] @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
-- 84, 18, 209, 277, 207, 116, 103
*/
--select OrderDetailKey from invoiceDetail where invoiceKey = 167895
CREATE PRoc [dbo].[SELL_GetItemSellPriceByOrderDetailKey_base20251015]  
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)
As
BEGIN
	Declare  

		@ItemKey				int = 0,
		@OrderDetailKey			int = 0,
		@JsonOutput				nvarchar(max) = '' ,

		@AddedAccessorialsTotalCost		decimal(18,2),
		@ContainerNo		varchar(50),
		@Market				varchar(50),
		@MarketKey			int,
		@OrderType			varchar(20),
		@CustKey			int,
		@CustName			varchar(100),
		@City				varchar(100),
		@State				varchar(10),
		@country			varchar(5),
		@Location			varchar(100),
		@TruckType			varchar(50),
		@Terminal			varchar(50),
		@ZipCode			varchar(15),
		@CostGroup			varchar(50) = '',
		@IncludeFSF			bit = 0,
		@CustomerSegment	varchar(20) = '',
		@IsSpotOn			bit = 0

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Select @ItemKey = ItemKey, @OrderDetailKey = OrderDetailKey
	from OpenJSON(@JsonString, '$')
	WITH (
		ItemKey			int			'$.ItemKey',
		OrderDetailKey	int			'$.OrderDetailKey'	
	)

	SEt @JsonOutput = ''
	select @MarketKey = Case when OH.MarketLocationKey = 0 then C.MarketLocationKey else isnull(OH.MarketLocationKey, C.MarketLocationKey) end, 
		@Market = ml.MarketLocation, @ContainerNo = OD.ContainerNo,
		@OrderType = OT.OrderType, @CustKey = OH.CustKey, @CustName = C.CustName,
		@IncludeFSF = isnull(C.IncludeFSF,0)
	from OrderDetail OD WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	inner join Customer C WITH (NOLOCK) on OH.CustKey = c.CustKey
	LEft  join MarketLocation ML WITH (NOLOCK) ON 
		Case when OH.MarketLocationKey = 0 then C.MarketLocationKey else isnull(OH.MarketLocationKey, C.MarketLocationKey) end = ml.MarketLocationKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where OD.OrderDetailKey = @OrderDetailKey

	if(@IsDebug = 1)
	Begin
		Select @MarketKey as MarketKey, @Market as Market, 
			@OrderType as ORderType, @CustKey as CustKey,
			@CustName  CustName
	End

	select RT.Routekey, L.LegID, L.FromLocation, L.ToLocation,
		isnull(Rt.SourceAddrKey, OH.SourceAddrKey) as SourceAddrKey ,  
		isnull(Rt.DestinationAddrKey,OH.DestinationAddrKey) as DestinationAddrKey,
		Rt.ChassisCategoryKey as ChassisCategoryKey, YardID,
		City = case when isnull(A.addrkey,0) = 0 then HA.City else A.City end, 
		State = Case when isnull(a.AddrKey,0) = 0 then HA.state else  A.State end, 
		ZipCode = Case when isnull(a.AddrKey,0) = 0 then HA.ZipCode else   A.ZipCode end,  
		D.DriverKey, D.driverID, TT.TruckType, A.AddrName as LocationName, OT.OrderType
	INTO #BaseInfo
	from OrderDetail OD 
	inner join routes RT on OD.OrderDetailKey = RT.OrderDetailKey 
	Left join Yard Y on RT.SourceAddrkey = Y.AddrKey or Rt.DestinationAddrKey = Y.AddrKey
	inner join OrderHeader OH on OD.OrderKey = OH.OrderKey
	inner join Ordertype OT on OH.OrderTypeKey = OT.OrderTypeKey
	inner join Leg L on RT.LegKey = L.LegKey 
	LEft join Address A on  A.AddrKey = case when OH.OrderTypeKey = 1 and  L.ToLocation  in ('Shipper','Customer', 'Consignee') then Rt.DestinationAddrKey
		When OH.OrderTypeKey = 2 and  L.FromLocation in ('Shipper','Customer', 'Consignee') then Rt.SourceAddrKey else 0 end 
	Left join Address HA on  HA.AddrKey  = case when OH.ordertypekey = 1 then OH.DestinationAddrKey 
		when OH.OrderTypeKey = 2 then  OH.SourceAddrKey 
		when OH.OrderTypeKey = 3 then  OH.DestinationAddrKey end 
	LEFT join Driver D on RT.DriverKey = D.DriverKey
	LEft join TruckType TT on D.TruckTypeKey = TT.TruckTypeKey
	LEFT Join Cost_LegTypes LT on L.LegCostType = LT.LegTypeID
	where OD.OrderDetailKey = @OrderDetailKey 
	AND ((@OrderType = 'Import' and L.ToLocation  in ('Shipper','Customer', 'Consignee')) OR
		(@OrderType = 'Export' and  L.FromLocation  in ('Shipper','Customer', 'Consignee')))

	if(@IsDebug = 1)
	Begin
		select '#BaseInfo', * from #BaseInfo 
	End

	select  @CustomerSegment = ISNULL(Cs.CustomerSegment, 'NAC'),
			@IsSpotOn = Case when isnull(CRT.RateType,'NAC') = 'NAC' then 0 else 1 end
	from Customer C
	LEFT join CustomerSegments CS on C.CustomerSegmentKey = CS.CustomerSegmentKey
	LEft join CustomerRateType CRT on C.RateTypeKey = CRT.RateTypeKey
	where CustKey = @CustKey

	SET @CustomerSegment = ISNULL(@CustomerSegment, 'NAC')
	SET @IsSpotOn = isnull(@IsSpotOn,0)

	--Select @CustomerSegment as CustomerSegment, @IsSpotOn  as Spoton

	if(@OrderType = 'Export')
	Begin
		select Top 1 @city = City , @State = State, @Location = LocationName, @ZipCode = ZipCode,
			@TruckType = TruckType
		from #BaseInfo
		where FromLocation in ('Shipper','Customer', 'Consignee')
		order by routekey ASC
	end
	else 
	Begin
		select Top 1 @city = City , @State = State, @Location = LocationName, @ZipCode = ZipCode,
			@TruckType = TruckType
		from #BaseInfo
		where ToLocation in ('Shipper','Customer', 'Consignee')
		order by routekey DESC
	End

	create table #Items
	(
		ItemKey				int,
		IDescription		varchar(100),
		MItemKey			int,
		MDescription		varchar(100),
		CostGroup			varchar(20),
		IsActive			Bit
	)

	if(@IsDebug = 1)
	Begin
		select 'Variables', @City as City, @State as State, @MarketKey as MArket ,@custKey as CustKey, @Terminal as Terminal, 
			@Location as Location, @ContainerNo as ContainerNo, @TruckType as TruckType 
	End

	insert into #Items (ItemKey, IDescription, MItemKey, MDescription,CostGroup, IsActive)
	select I.ItemKey, I.[Description],  M.itemkey , M.[Description] , d.DriverNonDriverCostDesc, case when  I.StatusKey  = 1 then 1 else 0 end
	From Item I 
	inner join Item M on isnull(I.MasterItemKey,I.ItemKey) = M.itemkey 
	inner join DriverNonDriverCostItems D on M.CostGrp = D.DriverNonDriverCostKey
	where I.Itemkey = @ItemKey

	if(@IsDebug = 1)
	Begin
		select' #Items',* from #Items
	end
	select @CostGroup = CostGroup from #Items
	create table #Accessorials
	(
		Rownum				int,
		OutputDataKey		int,
		FileProcessKey		int,
		RecordSL			int,
		CustID				varchar(50),
		CustName			varchar(100),
		RateType			varchar(20),
		Segment				varchar(5),
		MarketLocation		varchar(50),
		Terminal			varchar(50),
		LineItem			varchar(100),
		City				varchar(100),
		State				varchar(50),
		Zip					varchar(20),
		LocationName		varchar(50),
		IsLocationExists	bit,
		Rate				numeric(18,2),
		BvsNB				varchar(5),
		FreeTime			int,
		MinCnt				int,
		MaxCnt				int,
		ContainerSize		varchar(50),
		EffectiveDate		Date,
		EffectiveDateFrom	varchar(50),
		MarketKey			int,
		TerminalKey			int,
		SegmentKey			int,
		CustKey				int,
		ContainerSizeKey	int,
		ItemKey				int
	)

	if(@CostGroup in ('Pre Pull','Stop Off','Shuttle','Accessorial'))
	Begin
		
		insert into #Accessorials (Rownum, OutputDataKey, RecordSL, MarketKey, Terminal, City, State, Zip, LocationName,
			ContainerSize, ContainerSizeKey, CustKey, CustName, EffectiveDate, EffectiveDateFrom, IsLocationExists,
			A.ItemKey, LineItem, MarketLocation, Segment, SegmentKey, TerminalKey,
			Rate, BvsNB, FreeTime, MinCnt, MaxCnt)
		select Rownum, OutputDataKey, RecordSL, MarketKey, Terminal, City, State, Zip, LocationName,
			ContainerSize, ContainerSizeKey, CustKey, CustName, EffectiveDate, EffectiveDateFrom, IsLocationExists,
			A.ItemKey, LineItem, MarketLocation, Segment, SegmentKey, TerminalKey,
			Rate, BvsNB, FreeTime, MinCnt, MaxCnt
		from (
		Select ROW_NUMBER() over (partition by Lineitem order by convert(Datetime, EffectiveDate) Desc, City Desc, State DESC, Terminal DESC, Marketkey Desc, 
				CustName Desc,LocationName Desc, outputdataKey Desc) Rownum,
			OutputDataKey, RecordSL, B.MarketKey, B.Terminal, B.City, B.State, B.Zip, B.LocationName,
			B.ContainerSize, B.ContainerSizeKey, B.CustKey, B.CustName, B.EffectiveDate, B.EffectiveDateFrom, B.IsLocationExists,
			A.ItemKey, b.LineItem, B.MarketLocation, B.Segment, B.SegmentKey, b.TerminalKey,
			Rate, BvsNB, FreeTime, MinCnt, MaxCnt
		from #Items A
		inner join SELL_NAC_Accessorial_FinalDataOutput B on A.MDescription = B.LineItem
		where B.CustKey = @CustKey and MarketKey = isnull(@MarketKey,0) and 
			( A.MDescription = B.LineItem) and
			( State = isnull(@State,'') OR State is null) and 
			( City = isnull(@city,'') OR City is null) and
			( LocationName = isnull(@Location,'') OR LocationName is null) and
			EffectiveDate <= convert(date, getdate())
		--Order by convert(datetime, effectivedate) desc, OutputDataKey  Desc
		) A --where Rownum = 1

		if((Select count(1) from #Accessorials) = 0)
		Begin
			if(@CustomerSegment = 'SMB')
			Begin
				insert into #Accessorials (Rownum, OutputDataKey, RecordSL, MarketKey, Terminal, City, State, Zip, LocationName,
					ContainerSize, ContainerSizeKey, CustKey, CustName, EffectiveDate, EffectiveDateFrom, IsLocationExists,
					A.ItemKey, LineItem, MarketLocation, Segment, SegmentKey, TerminalKey,
					Rate, BvsNB, FreeTime, MinCnt, MaxCnt)
				select Rownum, SellAccRateKey, RecordSL, MarketKey, Terminal, City, State, Zip, LocationName,
					ContainerSize, ContainerSizeKey, CustKey, CustName, EffectiveDate, EffectiveDateFrom, IsLocationExists,
					A.ItemKey, LineItem, MarketLocation, Segment, SegmentKey, TerminalKey,
					Rate, BvsNB, FreeTime, MinCnt, MaxCnt
				from (
				Select 1 Rownum,
					B.SellAccRateKey, 1 as RecordSL, B.MarketKey, '' as Terminal, '' as City, '' as State, 
					'' as Zip, '' as LocationName,
					''  as ContainerSize, 0 as ContainerSizeKey, @CustKey as CustKey, '' CustName, 
					B.SMB_Date EffectiveDate, 'Acc Tariff - SMB' EffectiveDateFrom, 0 IsLocationExists,
					A.ItemKey, b.LineItem, ML.MarketLocation, 'SMB' Segment, 0 SegmentKey, 0 TerminalKey,
					SMB_Rate Rate,SMB_BvsNB BvsNB,SMB_FreeTime FreeTime,SMB_Min MinCnt,SMB_Max MaxCnt
				from #Items A
				inner join Sell_AccessorialRates B on A.MDescription = B.LineItem
				inner join MarketLocation ML on B.MarketKey = ML.MarketLocationKey
				where MarketKey = isnull(@MarketKey,0)  AND
				( A.MDescription = B.LineItem)
				--Order by convert(datetime, effectivedate) desc, OutputDataKey  Desc
				) A --where Rownum = 1
			END

			if(@CustomerSegment = 'ENT')
			Begin
				insert into #Accessorials (Rownum, OutputDataKey, RecordSL, MarketKey, Terminal, City, State, Zip, LocationName,
					ContainerSize, ContainerSizeKey, CustKey, CustName, EffectiveDate, EffectiveDateFrom, IsLocationExists,
					A.ItemKey, LineItem, MarketLocation, Segment, SegmentKey, TerminalKey,
					Rate, BvsNB, FreeTime, MinCnt, MaxCnt)
				select Rownum, SellAccRateKey, RecordSL, MarketKey, Terminal, City, State, Zip, LocationName,
					ContainerSize, ContainerSizeKey, CustKey, CustName, EffectiveDate, EffectiveDateFrom, IsLocationExists,
					A.ItemKey, LineItem, MarketLocation, Segment, SegmentKey, TerminalKey,
					Rate, BvsNB, FreeTime, MinCnt, MaxCnt
				from (
				Select 1 Rownum,
					B.SellAccRateKey, 1 as RecordSL, B.MarketKey, '' as Terminal, '' as City, '' as State, 
					'' as Zip, '' as LocationName,
					'' as ContainerSize, 0 as ContainerSizeKey, @CustKey as CustKey, '' CustName, 
					B.ENT_Date EffectiveDate, 'Acc Tariff - SMB' EffectiveDateFrom, 0 IsLocationExists,
					A.ItemKey, b.LineItem, ML.MarketLocation, 'SMB' Segment, 0 SegmentKey, 0 TerminalKey,
					ENT_Rate Rate,ENT_BvsNB BvsNB,ENT_FreeTime FreeTime,ENT_Min MinCnt,ENT_Max MaxCnt
				from #Items A
				inner join Sell_AccessorialRates B on A.MDescription = B.LineItem
				inner join MarketLocation ML on B.MarketKey = ML.MarketLocationKey
				where MarketKey = isnull(@MarketKey,0)   AND
					( A.MDescription = B.LineItem)
				--Order by convert(datetime, effectivedate) desc, OutputDataKey  Desc
				) A --where Rownum = 1
			END
		END

		if(@IsDebug = 1)
		Begin
			select '#Accessorials', * from #Accessorials
		End
		/*Logic for Century and Steam Begins*/
		DECLARE @IsCenturyULS bit = 0, @IsSteam bit = 0, @IsNonJCTYard bit = 0, @IsNonJCTChassis bit = 0
		set @IsCenturyULS = case when @Custkey in (3402,3435,2567) then 1 else 0 end
		set @IsSteam = case when @Custkey in (2692,3516) then 1 else 0 end --added 3516 for Steam (Amazon) (JCT)
		Set @IsNonJCTYard = Case when (Select count(*) from #BaseInfo Where YardId IN (14, 15, 17, 19)) > 0 then 1 else 0 end
		Set @IsNonJCTChassis = Case when (Select count(*) from #BaseInfo Where ChassisCategoryKey in (2, 3)) > 0 then 1 else 0 end

		If(@IsCenturyULS = 1 or @IsSteam = 1)
		Begin
			UPDATE X
			SET X.Rate = 0, X.BvsNB = 'NB'
			FROM #Accessorials X
			Inner JOIN #Items A ON X.ItemKey = A.ItemKey
			INNER JOIN Item I ON A.ItemKey = I.ItemKey
			INNER JOIN Item M ON I.MasterItemKey = M.ItemKey
			WHERE 
			    (A.ItemKey IN (68, 121, 294) AND @IsNonJCTYard = 1)
			    OR 
			    (A.ItemKey = 100 AND @IsNonJCTChassis = 1);
		End
		/*Logic for Century and Steam Ends*/

		select  RecordSL, LineItem, MarketLocation as MArket, Terminal,itemKey, --TruckType, YardPort, [Zone], [Group], 
			Rate, BvsNB, FreeTime, MinCnt, MaxCnt, EffectiveDate, EffectiveDateFrom, 
			(isYardPort + isTerminal + isMArket + isTruckType + isZone+  isLocation +isCity + isState) as TotMatch,
			isYardPort , isTerminal , isMArket , isTruckType , isZone ,  isLocation, isCity, isState
				
				into #InterRecord
				from (
				select *, 
					isYardPort = 0, -- Case when YardPort = @yardPort then 1 else 0 end , 
					isTerminal = Case when Terminal = @Terminal then 1 else 0 end ,
					isMArket = Case when MarketLocation = @Market then 1 else 0 end,
					isTruckType = 0, -- Case when TruckType = @TruckType then 1 else 0 end,
					isZone = 0, -- Case when Zone = @zone then 1 else 0 end,
					isLocation = Case when LocationName = @Location then 1 else 0 end,
					isState = Case when State = @State then 1 else 0 end,
					isCity = Case when City = @city then 1 else 0 end
					from #Accessorials
					WHERE (Terminal = @Terminal OR isnull(Terminal,'') = '' OR @Terminal is null) AND
						(MarketLocation = @Market OR isnull(MarketLocation,'') = '') 

					) A
		if(@IsDebug = 1)
		Begin
			select '#InterRecord',* from #InterRecord
		end

		if((Select count(1) from #InterRecord) > 0)
		begin
			select   RecordSL, LineItem, MArket, Terminal,ItemKey, 
				isnull(Rate,0)Rate, isnull(BvsNB,'') BvsNB, isnull(FreeTime,0) FreeTime, isnull(MinCnt,0) MinCnt, 
				isnull(MaxCnt,0) MaxCnt, EffectiveDate, EffectiveDateFrom, @CostGroup as CostGroup,
				IsActive, @IncludeFSF as IncludeFSF, @City as City, @State as State, RecNo
			from (
				select  B.*, I.IsActive, ROW_NUMBER() over(partition by Lineitem ORder by TotMatch desc) RecNo 
				From #InterRecord B 
				inner join #Items I on 1=1
			) C where RecNo = 1
			For JSON PATH, Without_array_wrapper

			SEt @Status = 1
			Set @Reason = 'Success'
			return
		End
		Else
		Begin
			SEt @Status = 1
			Set @Reason = 'No Record Found'
			return
		End

		drop table #InterRecord
		drop table #Accessorials
	End

	if(@CostGroup in ('Drayage','FSF'))
	Begin
		Create Table #DrayBase
		(
			ContainerNo			varchar(50),
			DrayBase_Value		decimal(18,2),
			Margin_Percent		decimal(18,2),
			Margin_Value		decimal(18,2),
			DrayBase_Rate		decimal(18,2),
			FSF_Percent			decimal(18,2),
			FSF_Value			decimal(18,2),
			Draybase_Total		decimal(18,2),
			NetRevenue			decimal(18,2),
			EffectiveDate		Datetime,
			EffectiveFrom		varchar(50),
			RecordSL			int
		)
		insert into #DrayBase(ContainerNo, DrayBase_Value, FSF_Percent, Margin_Percent, EffectiveDate, EffectiveFrom, RecordSL)
			select TOP 1 @ContainerNo, DraybaseCost, FSF * 100, 0, EffectiveDate, EffectiveDateFrom, RecordSL
			from SELL_NAC_Draybase_FinalDataOutput 
			--where City = @city and State = @State and 
			--	MarketKey = @MarketKey and Custkey = @CustKey and
			--	EffectiveDate <= convert(date, getdate())
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					(LocationName = @Location OR LocationName is null) and  
					MarketKey = @MarketKey and Custkey = @CustKey and
					(Terminal = @Terminal OR Terminal is null  OR @Terminal is null)   and
					 EffectiveDate <= convert(date,Getdate())
				ORDER BY convert(datetime, EffectiveDate) DESC, OutputDataKey Desc

			update #DrayBase set Margin_Value = 0; -- AS PER COMMUNICATION ON 18/03/2024 - NO MARGIN FOR NACS 
			update #DrayBase set DrayBase_Rate = DrayBase_Value + Margin_Value where ContainerNo = @ContainerNo
			update #DrayBase set FSF_Value = DrayBase_Rate * (isnull(FSF_Percent,0) / 100) where ContainerNo = @ContainerNo
			update #DrayBase set Draybase_Total = DrayBase_Rate + isnull(FSF_Value,0) where ContainerNo = @ContainerNo
			update #DrayBase set NetRevenue = Draybase_Total - DrayBase_Value where ContainerNo = @ContainerNo

		if(@IsDebug = 1)
		Begin
			Select * from #DrayBase
		End

		if((Select count(1) from #DrayBase) >0)
		begin
			select   RecordSL, Mdescription as LineItem, @Market as MArket, @Terminal Terminal,ItemKey,@IncludeFSF  as IncludeFSF ,
				Rate = case when @CostGroup = 'FSF' then FSF_Value
							When @CostGroup = 'Drayage' then
								Case when isnull(@IncludeFSF,0) = 1 then Draybase_Total else DrayBase_Rate end end , 
				'' BvsNB, '0' FreeTime, 0 MinCnt, 0 MaxCnt, EffectiveDate, EffectiveFrom, @CostGroup as CostGroup,
				IsActive, @city as City, @State as State, @CustomerSegment as CustomerSegment, RecNo
			from (
				select  *, ROW_NUMBER() over(order by Mdescription) RecNo 
				From #DrayBase B 
				join #Items I on 1=1
			) C where RecNo = 1
			For JSON PATH, Without_array_wrapper
			SEt @Status = 1
			Set @Reason = 'Success'
			return
		END
		Else
		Begin
			SEt @Status = 1
			Set @Reason = 'No Record Found'
			return
		End
		drop table #DrayBase
	end
	
	SEt @Status = 0
	Set @Reason = 'No Record Found'

	drop table #BaseInfo
	drop table  #Items 
end