/*
Declare @UserKey int = 512, @IsDebug				bit = 1,
@JSONString NVARCHAR(MAX) = '{"ItemKey":"18","InvoiceKey":146231,"ContainerNo":"TCKU472696"}', @Status bit = 1,@Reason       VARCHAR(1000) = ''
Exec Cost_GetInvoiceItemCostPrice @UserKey, @JSONString, @Status output,  @Reason output, @IsDebug
Select @Status, @Reason
-- 84, 18, 209, 277, 207, 116, 103
*/
--select * from invoiceheader where invoiceno = '54154'
CREATE PRoc [dbo].[Cost_GetInvoiceItemCostPrice]  
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT,
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
		@IsDryRun			bit = 0,
		@JsonOutput				nvarchar(max) = '',
		@ItemKey				int = 0,
		@InvoiceKey				int = 0,
		@ContainerNo			varchar(50) = ''
	
		


		sET @Status=0
		SET @Reason='Failure'
		SELECT @ItemKey = ItemKey, @InvoiceKey = InvoiceKey, @ContainerNo= ContainerNo
		FROM OPENJSON(@JSONString,'$')
		WITH (
			ItemKey		INT				'$.ItemKey',
			InvoiceKey	INT				'$.InvoiceKey',
			ContainerNo	NVARCHAR(20)	'$.ContainerNo'
			)

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
		select @Terminal = PriceGrouping from PriceGrouping WITH(NOLOCK) where PriceGroupingKey = @TerminalKey
	END
	select RT.Routekey, L.LegID, L.FromLocation, L.ToLocation , 
		isnull(Rt.SourceAddrKey, OH.SourceAddrKey) as SourceAddrKey ,  
		isnull(Rt.DestinationAddrKey,OH.DestinationAddrKey) as DestinationAddrKey,
		City = case when isnull(A.addrkey,0) = 0 then HA.City else A.City end, 
		State = Case when isnull(a.AddrKey,0) = 0 then HA.state else  A.State end, 
		ZipCode = Case when isnull(a.AddrKey,0) = 0 then HA.ZipCode else   A.ZipCode end,  
		D.DriverKey, D.driverID, TT.TruckType, A.AddrName as LocationName, OT.OrderType
	INTO #BaseInfo
	from (Select distinct InvoiceKey, orderdetailkey, Container from InvoiceDetail WITH(NOLOCK) where InvoiceKey = @InvoiceKey) ID 
	inner join InvoiceHeader IH WITH(NOLOCK) on ID.InvoiceKey = IH.InvoiceKey
	--inner join OrderDetail OD on ID.OrderDetailKey = OD.OrderDetailKey
	inner join routes RT WITH(NOLOCK) on ID.OrderDetailKey = RT.OrderDetailKey and  ID.Container = @ContainerNo
	inner join OrderHeader OH WITH(NOLOCK) on IH.OrderKey = OH.OrderKey
	inner join Ordertype OT WITH(NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	inner join Leg L WITH(NOLOCK) on RT.LegKey = L.LegKey 
	LEft join Address A WITH(NOLOCK) on  A.AddrKey = case when OH.OrderTypeKey = 1 and  L.ToLocation  in ('Shipper','Customer', 'Consignee') then Rt.DestinationAddrKey
		When OH.OrderTypeKey = 2 and  L.FromLocation in ('Shipper','Customer', 'Consignee') then Rt.SourceAddrKey else 0 end 
	Left join Address HA  WITH(NOLOCK) on  HA.AddrKey  = case when OH.ordertypekey = 1 then OH.DestinationAddrKey 
		when OH.OrderTypeKey = 2 then  OH.SourceAddrKey 
		when OH.OrderTypeKey = 3 then  OH.DestinationAddrKey end 
	LEFT join Driver D WITH(NOLOCK) on RT.DriverKey = D.DriverKey
	LEft join TruckType TT WITH(NOLOCK) on D.TruckTypeKey = TT.TruckTypeKey
	LEFT Join Cost_LegTypes LT WITH(NOLOCK) on L.LegCostType = LT.LegTypeID
	where (@OrderType = 'Import' and L.ToLocation  in ('Shipper','Customer', 'Consignee')) OR
		(@OrderType = 'Export' and  L.FromLocation  in ('Shipper','Customer', 'Consignee')) 

	if(@IsDebug = 1)
	Begin
		select '#BaseInfo', * from #BaseInfo 
	End

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

	Select @TerminalKey = PriceGroupingKey from PriceGrouping WITH(NOLOCK) where PriceGrouping = @Terminal

	if(@IsDebug = 1)
	Begin
		select 'Variables', @City as City, @State as State, @MarketKey as MArket ,@custKey as CustKey, @Terminal as Terminal, @TerminalKey as TerminalKey,
			@Location as Location, @ContainerNo as ContainerNo, @TruckType as TruckType 
	End

	insert into #Items (ItemKey, IDescription, MItemKey, MDescription,CostGroup, IsActive)
	select I.ItemKey, I.[Description],  M.itemkey , M.[Description] , d.DriverNonDriverCostDesc, case when  I.StatusKey  = 1 then 1 else 0 end
	From Item I 
	inner join Item M WITH(NOLOCK) on isnull(I.MasterItemKey,I.ItemKey) = M.itemkey 
	inner join DriverNonDriverCostItems D WITH(NOLOCK) on M.CostGrp = D.DriverNonDriverCostKey
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

	CREATE TABLE #Accessorials
	(
    Rownum              INT,
    OutputDataKey       INT,
    FileProcessKey      INT,
    RecordSL            INT,
	ItemKey				INT,
    LineItem            VARCHAR(100),
    Market              VARCHAR(100),
    Terminal            VARCHAR(100),
    TruckType           VARCHAR(100),
    YardPort            VARCHAR(100),
    [Zone]              VARCHAR(100),
    [Group]             VARCHAR(100), 
    FixVsNonFix         VARCHAR(100),
    Per                 VARCHAR(100),
    UnitCost            VARCHAR(100),
    EffectiveDate       VARCHAR(100),
    EffectiveDateFrom   VARCHAR(100),
    FreePer             INT,
    SplitPercent        DECIMAL(18,2)
	)

	if(@CostGroup = 'Accessorial')
	Begin
		
		INSERT INTO #Accessorials
		(Rownum, OutputDataKey, FileProcessKey, RecordSL, ItemKey, LineItem, Market, Terminal, 
		TruckType, YardPort, [Zone], [Group], FixVsNonFix, Per, UnitCost, EffectiveDate, 
		EffectiveDateFrom, FreePer, SplitPercent)
		select Rownum, OutputDataKey, FileProcessKey, RecordSL, ItemKey, LineItem, Market, Terminal, 
		TruckType, YardPort, [Zone], [Group], FixVsNonFix, Per, UnitCost, EffectiveDate, 
		EffectiveDateFrom, FreePer, SplitPercent
		from (
		Select ROW_NUMBER() over (partition by Lineitem order by convert(Datetime, EffectiveDate) Desc, outputdataKey Desc) Rownum,
			OutputDataKey, FileProcessKey, RecordSL, A.ItemKey, LineItem, Market, Terminal, 
			TruckType, YardPort, [Zone], [Group], FixVsNonFix, Per, UnitCost, EffectiveDate, 
			EffectiveDateFrom, FreePer, SplitPercent
		from #Items A
		inner join COSTACC_FinalDataOutput B on A.MDescription = B.LineItem
		--where B.CustKey = @CustKey and MarketKey = isnull(@MarketKey,0) and 
		--	( State = isnull(@State,'') OR State is null) and 
		--	( City = isnull(@city,'') OR City is null) and
		--	( LocationName = isnull(@Location,'') OR LocationName is null) and
		--	EffectiveDate <= convert(date, getdate())
		--Order by convert(datetime, effectivedate) desc, OutputDataKey  Desc
		) A where Rownum = 1

		if(@IsDebug = 1)
		Begin
			select '#Accessorials', * from #Accessorials
		End

		select  RecordSL, A.ItemKey, LineItem, Market, Terminal, 
			TruckType, YardPort, [Zone], [Group], FixVsNonFix, Per, UnitCost, EffectiveDate, 
			EffectiveDateFrom, isYardPort , isTerminal , isMArket , isTruckType , isZone ,  isLocation, isCity, isState, 
			(isYardPort + isTerminal + isMarket + isTruckType + isZone+  isLocation +isCity + isState) as TotMatch
				into #InterRecord
				from (
				select *,
					isYardPort = 0, -- Case when YardPort = @yardPort then 1 else 0 end , 
					isTerminal = Case when Terminal = @Terminal then 1 else 0 end ,
					isMarket = Case when Market = @Market then 1 else 0 end,
					isTruckType = 0, -- Case when TruckType = @TruckType then 1 else 0 end,
					isZone = 0, -- Case when Zone = @zone then 1 else 0 end,
					isLocation = 0, --Case when LocationName = @Location then 1 else 0 end,
					isState = 0, --Case when State = @State then 1 else 0 end,
					isCity = 0 --Case when City = @city then 1 else 0 end
					from #Accessorials
					WHERE (Terminal = @Terminal OR isnull(Terminal,'') = '' OR @Terminal is null) AND
						(Market = @Market OR isnull(Market,'') = '') 
					) A
		if(@IsDebug = 1)
		Begin
			select '#InterRecord',* from #InterRecord
		end


		set @JsonOutput = (
			select RecordSL, LineItem, Market, Terminal, ItemKey, 
				TruckType, YardPort, [Zone], [Group], FixVsNonFix, Per, UnitCost, EffectiveDate, 
				EffectiveDateFrom, @CostGroup as CostGroup,
				IsActive, @IncludeFSF as IncludeFSF
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
			EffectiveFrom		varchar(50)
		)
		insert into #DrayBase(ContainerNo, DrayBase_Value, FSF_Percent, Margin_Percent, EffectiveDate, EffectiveFrom)
			select TOP 1 @ContainerNo, Cost, FSFCost * 100, 0, EffectiveDate, EffectiveDateFrom
			from COST_CostDataOutput A WITH(NOLOCK)
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					Market = @Market and 
					(DriverType = @TruckType OR DriverType is null ) AND
					(Terminal = @Terminal OR Terminal is null) AND
					 EffectiveDate <= convert(date,Getdate())
			--ORDER BY convert(datetime, effectivedate) desc, OutputDataKey Desc
			ORDER BY convert(DateTime, EffectiveDate) DESC, CostOutputDataKey Desc, city DESC, State DESC

			update #DrayBase set Margin_Value = 0; -- AS PER COMMUNICATION ON 18/03/2024 - NO MARGIN FOR NACS 
			update #DrayBase set DrayBase_Rate = DrayBase_Value + Margin_Value where ContainerNo = @ContainerNo
			update #DrayBase set FSF_Value = DrayBase_Rate * (isnull(FSF_Percent,0) / 100) where ContainerNo = @ContainerNo
			update #DrayBase set Draybase_Total = DrayBase_Rate + isnull(FSF_Value,0) where ContainerNo = @ContainerNo
			update #DrayBase set NetRevenue = Draybase_Total - DrayBase_Value where ContainerNo = @ContainerNo

		if(@IsDebug = 1)
		Begin
			Select '#DrayBase',* from #DrayBase
		End

		set @JsonOutput = (
			select Null as RecordSL, Mdescription as LineItem, @Market as Market, @Terminal Terminal, ItemKey, @IncludeFSF as IncludeFSF,
				Rate = case when @CostGroup = 'FSF' then FSF_Value
							When @CostGroup = 'Drayage' then
								Case when isnull(@IncludeFSF,0) = 1 then Draybase_Total else DrayBase_Rate end end , 
				'' BvsNB, '0' FreeTime, 0 MinCnt, 0 MaxCnt, EffectiveDate, EffectiveFrom, @CostGroup as CostGroup,
				IsActive, @city as City, @State as State
			from (
				select *, ROW_NUMBER() over(order by Mdescription) RecNo
				From #DrayBase D
				--LEft join #Bobtail  B on 1=1 
				join #Items I on 1=1
			) C where RecNo = 1
			For JSON PATH, Without_array_wrapper
		)
		if(@JsonOutput is null)
		Begin
			SEt @JsonOutput = ''
		end
		Drop Table #DrayBase
	END
		--COST_CostDataOutput_PrePull
	if(@CostGroup = 'Pre Pull')
	Begin
		Create Table #PrePull
		(
			ContainerNo			varchar(50),
			PrepullCost			decimal(18,2),
			EffectiveDate		Datetime,
			EffectiveFrom		varchar(50)
		)
		insert into #PrePull(ContainerNo, PrepullCost, EffectiveDate, EffectiveFrom)
			select TOP 1 @ContainerNo, PrepullCost, EffectiveDate, EffectiveDateFrom
			from COST_CostDataOutput_PrePull A WITH(NOLOCK)
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					Market = @Market and 
					(Terminal = @Terminal OR Terminal is null) AND
					 EffectiveDate <= convert(date,Getdate())
			--ORDER BY convert(datetime, effectivedate) desc, OutputDataKey Desc
			ORDER BY convert(DateTime, EffectiveDate) DESC,  city DESC, State DESC

		if(@IsDebug = 1)
		Begin
			select '#PrePull', * from #PrePull 
		End

		set @JsonOutput = (
			select Null as RecordSL, Mdescription as LineItem, @Market as Market, @Terminal Terminal, ItemKey, @IncludeFSF as IncludeFSF,
				Rate = PrepullCost, 
				'' BvsNB, '0' FreeTime, 0 MinCnt, 0 MaxCnt, EffectiveDate, EffectiveFrom, @CostGroup as CostGroup,
				IsActive, @city as City, @State as State
			from (
				select *, ROW_NUMBER() over(order by Mdescription) RecNo
				From #Prepull
				join #Items I on 1=1
			) C where RecNo = 1
			For JSON PATH, Without_array_wrapper
		)
		Drop Table #PrePull
	End
		--COST_CostDataOutput_YardShuttle
	If(@CostGroup = 'Shuttle')
	Begin
		Create table #YardShuttle
		(
			ContainerNo			varchar(50),
			YardCost			decimal(18,2),
			EffectiveDate		Datetime,
			EffectiveFrom		varchar(50)
		)

		insert into #YardShuttle(ContainerNo, YardCost, EffectiveDate, EffectiveFrom)
			select TOP 1 @ContainerNo, YardCost, EffectiveDate, EffectiveDateFrom
			from COST_CostDataOutput_YardShuttle A WITH(NOLOCK)
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					Market = @Market and 
					(Terminal = @Terminal OR Terminal is null) AND
					 EffectiveDate <= convert(date,Getdate())
			--ORDER BY convert(datetime, effectivedate) desc, OutputDataKey Desc
			ORDER BY convert(DateTime, EffectiveDate) DESC,  city DESC, State DESC

		if(@IsDebug = 1)
		Begin
			select '#YardShuttle', * from #YardShuttle 
		End

		set @JsonOutput = (
			select Null as RecordSL, Mdescription as LineItem, @Market as Market, @Terminal Terminal, ItemKey, @IncludeFSF as IncludeFSF,
				Rate = YardCost, 
				'' BvsNB, '0' FreeTime, 0 MinCnt, 0 MaxCnt, EffectiveDate, EffectiveFrom, @CostGroup as CostGroup,
				IsActive, @city as City, @State as State
			from (
				select *, ROW_NUMBER() over(order by Mdescription) RecNo
				From #YardShuttle
				join #Items I on 1=1
			) C where RecNo = 1
			For JSON PATH, Without_array_wrapper
		)
		Drop Table #YardShuttle
	End
		--COST_CostDataOutput_StopOff
	If(@CostGroup = 'Stop Off')
	Begin
		Create table #StopOff
		(
			ContainerNo			varchar(50),
			StopOffCost			decimal(18,2),
			EffectiveDate		Datetime,
			EffectiveFrom		varchar(50)
		)

		insert into #StopOff(ContainerNo, StopOffCost, EffectiveDate, EffectiveFrom)
			select TOP 1 @ContainerNo, StopOffCost, EffectiveDate, EffectiveDateFrom
			from COST_CostDataOutput_StopOff A WITH(NOLOCK)
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					Market = @Market and 
					(Terminal = @Terminal OR Terminal is null) AND
					 EffectiveDate <= convert(date,Getdate())
			--ORDER BY convert(datetime, effectivedate) desc, OutputDataKey Desc
			ORDER BY convert(DateTime, EffectiveDate) DESC,  city DESC, State DESC

		if(@IsDebug = 1)
		Begin
			select '#StopOff', * from #StopOff 
		End
		
		set @JsonOutput = (
			select Null as RecordSL, Mdescription as LineItem, @Market as Market, @Terminal Terminal, ItemKey, 
			@IncludeFSF as IncludeFSF,
				Rate = StopOffCost, 
				'' BvsNB, '0' FreeTime, 0 MinCnt, 0 MaxCnt, EffectiveDate, EffectiveFrom, @CostGroup as CostGroup,
				IsActive, @city as City, @State as State
			from (
				select *, ROW_NUMBER() over(order by Mdescription) RecNo
				From #StopOff
				join #Items I on 1=1
			) C where RecNo = 1
			For JSON PATH, Without_array_wrapper
		)

		Drop Table #StopOff
	End

		if(@JsonOutput is null)
		Begin
			SEt @JsonOutput = ''
		end
	sET @Status=1
	SET @Reason='Success'
	SELECT @JsonOutput
	drop table #BaseInfo
	drop table #Items 
	
end