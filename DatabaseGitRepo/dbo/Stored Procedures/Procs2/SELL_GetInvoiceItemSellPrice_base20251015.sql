
/*
Declare @ItemKey int = 18, @InvoiceKey int = 174463,@ContainerNo varchar(50) = 'TCNU2601768',@JsonOutput	nvarchar(max) = '', @IsDebug bit = 1
Exec SELL_GetInvoiceItemSellPrice @itemkey, @InvoiceKey, @ContainerNo, @JsonOutput Output, @IsDebug
Select @InvoiceKey, @ItemKey, @JsonOutput
-- 84, 18, 209, 277, 207, 116, 103
*/
--select * from invoiceheader where invoiceno = '54154'
CREATE PRoc [dbo].[SELL_GetInvoiceItemSellPrice_base20251015]  
(
	@ItemKey				int = 0,
	@InvoiceKey				int = 0,
	@ContainerNo			varchar(50) = '',
	@JsonOutput				nvarchar(max) = '' output,
	@IsDebug				bit = 0
)
As
BEGIN
	Declare  
		

		@InvoiceNo			varchar(60),
		@AddedAccessorialsTotalCost		decimal(18,2),
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
		@TerminalKey		int,
		@ZipCode			varchar(15),
		@CostGroup			varchar(50) = '',
		@IncludeFSF			bit = 0,
		@CustomerSegment	varchar(20) = '',
		@IsSpotOn			bit = 0,
		@IsBobtail			bit = 0,
		@IsDryRun			bit = 0

	SEt @JsonOutput = ''
	select @MarketKey = Case when OH.MarketLocationKey = 0 then C.MarketLocationKey else isnull(OH.MarketLocationKey, C.MarketLocationKey) end,
		@Market = ml.MarketLocation,
		@OrderType = OT.OrderType, @CustKey = IH.CustKey, @CustName = C.CustName, @InvoiceNo = InvoiceNo,
		@IncludeFSF = isnull(C.IncludeFSF,0)
	from InvoiceHeader IH WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
	inner join Customer C WITH (NOLOCK) on ih.CustKey = c.CustKey
	LEft  join MarketLocation ML WITH (NOLOCK) ON 
		Case when OH.MarketLocationKey = 0 then C.MarketLocationKey else isnull(OH.MarketLocationKey, C.MarketLocationKey) end = ml.MarketLocationKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where IH.InvoiceKey =  @InvoiceKey

	if(@IsDebug = 1)
	Begin
		Select @MarketKey as MarketKey, @Market as Market, 
			@OrderType as ORderType, @CustKey as CustKey,
			@CustName  CustName, @InvoiceNo as InvoiceNo
	End
	If(isnull(@Terminal,'') = '')
	Begin
		Select @TerminalKey = case when @MarketKey = 2 then 6 else 4 end
		select @Terminal = PriceGrouping from PriceGrouping where PriceGroupingKey = @TerminalKey
	END
	select RT.Routekey, L.LegID, L.FromLocation, L.ToLocation , 
		isnull(Rt.SourceAddrKey, OH.SourceAddrKey) as SourceAddrKey ,  
		isnull(Rt.DestinationAddrKey,OH.DestinationAddrKey) as DestinationAddrKey,
		City = case when isnull(A.addrkey,0) = 0 then HA.City else A.City end, 
		State = Case when isnull(a.AddrKey,0) = 0 then HA.state else  A.State end, 
		ZipCode = Case when isnull(a.AddrKey,0) = 0 then HA.ZipCode else   A.ZipCode end,  
		D.DriverKey, D.driverID, TT.TruckType, A.AddrName as LocationName, OT.OrderType
	INTO #BaseInfo
	from (Select distinct InvoiceKey, orderdetailkey, Container from InvoiceDetail where InvoiceKey = @InvoiceKey) ID 
	inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
	--inner join OrderDetail OD on ID.OrderDetailKey = OD.OrderDetailKey
	inner join routes RT on ID.OrderDetailKey = RT.OrderDetailKey and  ID.Container = @ContainerNo
	inner join OrderHeader OH on IH.OrderKey = OH.OrderKey
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
	where (@OrderType = 'Import' and L.ToLocation  in ('Shipper','Customer', 'Consignee')) OR
		(@OrderType = 'Export' and  L.FromLocation  in ('Shipper','Customer', 'Consignee')) 

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

	Select @CustomerSegment as CustomerSegment, @IsSpotOn  as Spoton




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

	Select @TerminalKey = PriceGroupingKey from PriceGrouping where PriceGrouping = @Terminal

	if(@IsDebug = 1)
	Begin
		select 'Variables', @City as City, @State as State, @MarketKey as MArket ,@custKey as CustKey, @Terminal as Terminal, @TerminalKey as TerminalKey,
			@Location as Location, @ContainerNo as ContainerNo, @TruckType as TruckType 
	End

	insert into #Items (ItemKey, IDescription, MItemKey, MDescription,CostGroup, IsActive)
	select I.ItemKey, I.[Description],  M.itemkey , M.[Description] , d.DriverNonDriverCostDesc, case when  I.StatusKey  = 1 then 1 else 0 end
	From Item I 
	inner join Item M on isnull(I.MasterItemKey,I.ItemKey) = M.itemkey 
	inner join DriverNonDriverCostItems D on M.CostGrp = D.DriverNonDriverCostKey
	where I.Itemkey = @ItemKey

	if(isnull(@IsBobtail,0) =0)
	Begin
		select @IsBobtail = case when count(1) > 0 then 1 else 0 end from #Items where CostGroup = 'BobTail'
	End

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
				where MarketKey = isnull(@MarketKey,0)  
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
				where MarketKey = isnull(@MarketKey,0)  
				--Order by convert(datetime, effectivedate) desc, OutputDataKey  Desc
				) A --where Rownum = 1
			END
		END

		if(@IsDebug = 1)
		Begin
			select '#Accessorials', * from #Accessorials
		End


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


		set @JsonOutput = (
			select   RecordSL, LineItem, MArket, Terminal,ItemKey, 
				isnull(Rate,0)Rate, isnull(BvsNB,'') BvsNB, isnull(FreeTime,0) FreeTime, isnull(MinCnt,0) MinCnt, 
				isnull(MaxCnt,0) MaxCnt, EffectiveDate, EffectiveDateFrom, @CostGroup as CostGroup,
				IsActive, @IncludeFSF as IncludeFSF, @City as City, @State as State
			from (
				select  B.*, I.IsActive, ROW_NUMBER() over(partition by Lineitem ORder by TotMatch desc) RecNo 
				From #InterRecord B 
				inner join #Items I on 1=1
			) C where RecNo = 1
			For JSON PATH, Without_array_wrapper
		)
		if(@JsonOutput is null)
		Begin
			SEt @JsonOutput = ''
		end
		drop table #InterRecord
		drop table #Accessorials
	End

	if(@CostGroup in ('Drayage','FSF') OR @IsBobtail = 1)
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
			from SELL_NAC_Draybase_FinalDataOutput A
			inner join SELL_NAC_Draybase_FileProcessInfo F on A.FileProcessKey = F.FileProcessKey
			inner join [user] U on F.UserKey = U.UserKey
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					(Zip = @ZipCode OR Zip is null  ) and
					(ltrim(rtrim(LocationName)) = ltrim(rtrim(@Location)) OR LocationName is null) and
					--(LocationName = @Location OR LocationName is null) and  
					MarketKey = @MarketKey and A.Custkey = @CustKey and
					(TerminalKey = @TerminalKey OR TerminalKey is null) AND
					 EffectiveDate <= convert(date,Getdate())
			--ORDER BY convert(datetime, effectivedate) desc, OutputDataKey Desc
			ORDER BY  LocationName DESC, convert(DateTime, EffectiveDate) DESC,city DESC, State DESC, Zip DESC--, OutputDataKey Desc

			update #DrayBase set Margin_Value = 0; -- AS PER COMMUNICATION ON 18/03/2024 - NO MARGIN FOR NACS 
			update #DrayBase set DrayBase_Rate = DrayBase_Value + Margin_Value where ContainerNo = @ContainerNo
			update #DrayBase set FSF_Value = DrayBase_Rate * (isnull(FSF_Percent,0) / 100) where ContainerNo = @ContainerNo
			update #DrayBase set Draybase_Total = DrayBase_Rate + isnull(FSF_Value,0) where ContainerNo = @ContainerNo
			update #DrayBase set NetRevenue = Draybase_Total - DrayBase_Value where ContainerNo = @ContainerNo

		if(@IsDebug = 1)
		Begin
			Select '#DrayBase',* from #DrayBase
		End

		IF OBJECT_ID('tempdb..#Bobtail') IS NOT NULL 
		BEGIN 
			DROP TABLE #Bobtail 
		END

		IF OBJECT_ID('#Bobtail') IS NOT NULL 
		BEGIN 
			DROP TABLE #Bobtail 
		END

		Create table #Bobtail (
			ContainerNo			varchar(50),
			BobtailFormat		varchar(50), 
			BobtailRate			numeric(18,2), 
			BobtailCalc			numeric(18,2),
			EffectiveDate		DateTime,
			EffectiveDateFrom	varchar(50), 
			FileName			varchar(100), 
			DateUploaded		Datetime, 
			UploadedBy			varchar(100), 
			OutputDataKey		int
		)
			
		if(isnull(@IsBobtail,0) = 1)
		Begin
			insert into #Bobtail (ContainerNo, BobtailFormat, BobtailRate, BobtailCalc,
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy ,OutputDataKey )
			select TOP 1 @ContainerNo as ContainerNo, BobtailFormat, BobtailRate, convert(numeric(18,2),0.00) as BobtailCalc,
				EffectiveDate, EffectiveDateFrom, F.FileName, DateUploaded, U.UserName as UploadedBy ,OutputDataKey 
			
			from SELL_NAC_Bobtail_FinalDataOutput A
			inner join SELL_NAC_Bobtail_FileProcessInfo F on A.FileProcessKey = F.FileProcessKey
			inner join [user] U on F.UserKey = U.UserKey
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					(LocationName = @Location OR LocationName is null) and  
					MarketKey = @MarketKey and A.Custkey = @CustKey and
					(TerminalKey = @TerminalKey OR TerminalKey is null)  
					and EffectiveDate <= convert(date,Getdate())
			ORDER BY city DESC, State DESC, LocationName DESC, convert(Datetime, EffectiveDate) DESC, OutputDataKey Desc

			if(@IsDebug = 1)
			Begin
				Select '#Bobtail', *  from #Bobtail 
			End
			update #Bobtail SEt BobtailCalc = DrayBase_Rate from #DrayBase where BobtailFormat like '%Roundtrip%'
			update #Bobtail set BobtailCalc = 0 where BobtailFormat like '%Free%'
			update #Bobtail set BobtailCalc = DrayBase_Rate  * BobtailRate from #DrayBase where BobtailFormat like '%Percentage%'
			update #Bobtail set BobtailCalc = convert(numeric(18,2),BobtailRate) where BobtailFormat like '%Flat Fee%'

			
		End
		

		

		if(@IsDebug = 1)
		Begin
			Select '#Bobtail - 1', *  from #Bobtail 
		end
		set @JsonOutput = (
			select   RecordSL, Mdescription as LineItem, @Market as MArket, @Terminal Terminal,ItemKey,@IncludeFSF  as IncludeFSF ,
				Rate = case when @CostGroup = 'FSF' then FSF_Value
							When @CostGroup = 'Drayage' then
								Case when isnull(@IncludeFSF,0) = 1 then Draybase_Total else DrayBase_Rate end end , 
				'' BvsNB, '0' FreeTime, 0 MinCnt, 0 MaxCnt, EffectiveDate, EffectiveFrom, @CostGroup as CostGroup,
				IsActive, @city as City, @State as State, @CustomerSegment as CustomerSegment
			from (
				select *, ROW_NUMBER() over(order by Mdescription) RecNo 
				From #DrayBase D
				--LEft join #Bobtail  B on 1=1 
				join #Items I on 1=1
				--UNION ALL
				--select  D.*, ROW_NUMBER() over(order by Mdescription) RecNo 
				--From #Bobtail B 
				--LEft join #DrayBase D on 1=1
				--join #Items I on 1=1
			) C where RecNo = 1
			For JSON PATH, Without_array_wrapper
		)
		if(@JsonOutput is null)
		Begin
			SEt @JsonOutput = ''
		end
		drop table #DrayBase
		drop table #Bobtail
	end
	
	
	drop table #BaseInfo
	drop table  #Items 
	
end
