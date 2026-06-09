


/* --19907, 25335 -- Acc Rate : SMB- 47507, ENT- 47502
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '95737',   @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(500) = '' ,
		@IsSpotOn bit = 0, @CustomerSegment varchar(5) = 'NAC', @Debug bit = 1
	EXEC [Sell_OutputByInvoice] @InvoiceKey, @InvoiceNo, @IsSpotOn, @CustomerSegment, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @Debug
	SELECT @JsonOutput, @Status, @Reason
*/
Create PROC [dbo].[Sell_OutputByInvoice_Base_20241111]
(
	@InvoiceKey			int	= 0,
	@InvoiceNo			varchar(50) = '',
	@IsSpotOn			bit  = 0, -- If 0 Then NAC else SPOT - when Spot, check from Customer Table to Get SMB / ENT Type. Else Provide the SMB/ENT Swtich
	@CustomerSegment	varchar(5) = '', -- Consider only when the IsSpotOn = 1
	@JsonOutput			nvarchar(max) ='' OUTPUT,
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' output,
	@Debug				bit = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	 

	IF OBJECT_ID('tempdb..#AccesorialItemKeys') IS NOT NULL 
	BEGIN 
		DROP TABLE #AccesorialItemKeys 
	END

	IF OBJECT_ID('#AccesorialItemKeys') IS NOT NULL 
	BEGIN 
		DROP TABLE #AccesorialItemKeys 
	END

	declare @DryRunReason varchar(1000) = '',
			@IsBobtail		bit = 0,
			@IsDryRun		bit = 0

	Declare @DrayReason	varchar(500)='',
			@ConfigReason	varchar(500)='',
			@AccessorialReason varchar(500)='',
			@BobtailReason		varchar(500) = ''

	if(isnull(@InvoiceKey,0) = 0 AND ISNULL(@InvoiceNo,'') = '')
	BEGIN
		set @Status = 0
		set @Reason = 'Invoice Parameters not received'
		return
	END
	if(isnull(@InvoiceKey,0) = 0)
	Begin
		select @InvoiceKey = InvoiceKey From InvoiceHeader where InvoiceNo = @InvoiceNo
	End
	print '@InvoiceKey'
	print @InvoiceKey
	SEt @Status = 1
	create table #YardKeys
	(
		YardID		int, 
		YardType	varchar(10)
	)
	create table #StopOff
	(
		Container	varchar(20), 
		StopOfflocation varchar(50), 
		StopOffCost		numeric(18,2)
	)
	create table #Prepull
	(
		Container	varchar(20), 
		PrePulllocation varchar(50), 
		PrepullCost		numeric(18,2)
	)
	create table #YardShuttleFrom
	(
		Container	varchar(20), 
		YardFrom	 varchar(50), 
		YardCost		numeric(18,2)
	)
	create table #YardShuttleTo
	(
		Container	varchar(20), 
		YardTo varchar(50), 
		YardCost		numeric(18,2)
	)
	
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
		EffectiveDate		DateTime, 
		EffectiveDateFrom	varchar(50), 
		FileName			varchar(200), 
		DateUploaded		Datetime, 
		UploadedBy			varchar(100),
		OutputDataKey		int
	)

	Create Table #ContainerSummary
	(
		ContainerNo			varchar(20),
		HeaderText			varchar(100),
		LineItem1			varchar(100),
		LineItem1_Value		decimal(18,3),
		LineItem2			varchar(100),
		LineItem2_Value		decimal(18,3),
		LineItem3			varchar(100),
		LineItem3_Value		decimal(18,3),
		LineItem4			varchar(100),
		LineItem4_Value		decimal(18,3),
		LineItem5			varchar(100),
		LineItem5_Value		decimal(18,3),
		LineItem6			varchar(100), -- DryRun
		LineItem6_Value		decimal(18,3), -- DryRunValue
		LineItem7			varchar(100), -- BobTail
		LineItem7_Value		decimal(18,3), -- BobtailValue
		Total_text			varchar(100),
		Total_value			decimal(18,3)
	)

	select convert(varchar(50),'') as ContainerNo , convert(varchar(20),'') as CostGroup,
	RecordSL, LineItem, MarketLocation, Terminal, ItemKey, Rate, 
	BvsNB, FreeTime, MinCnt, MaxCnt, EffectiveDate, EffectiveDateFrom, convert(varchar(20), '') as Source
	into #AccRercs
	from SELL_NAC_Accessorial_FinalDataOutput where 1=0

	alter table #AccRercs add TotalCost Decimal(18,3) , 
	FileName varchar(200), DateUploaded Datetime, UploadedBy varchar(100), CustSegment varchar(10)


	Declare
		@OrderType						varchar(50),
		@MarketKey						int,
		@TerminalKey					int,
		@ZipCode						varchar(20),
		@DriverTypeKey					int,
		@isPrePull						bit,
		@PrePullLocationKey				int,
		@isYardShuttle					bit,
		@YardShuttleLocationKeys		varchar(50),
		@isStopOff						bit,
		@StopOffLocationKey				int,
		@AccessorialsLineItems			nvarchar(max),
		@UserKey						int,
		@AddedAccessorialsTotalCost		decimal(18,3),
		@City							varchar(50),
		@State							varchar(10),
		@PrePullLocation				varchar(50),
		@StopOffLocation				varchar(50),
		@YardShuttleLocation			varchar(50),
		@DriverType						varchar(50),
		@DrayBaseValue					Decimal(18,2),
		@YardShuttleCost				Decimal(18,2),
		@Terminal						varchar(50),
		@Market							varchar(50),
		@YardPortType					varchar(10),
		@PrePullYardPortType			varchar(10),
		@ShuttleYardPortType			varchar(10),
		@StopOffYardPortType			varchar(10),
		@ZoneKey						int = 0,
		@zoneName						varchar(50),
		@CustKey						int = 0,
		@CustName						varchar(100)='',
		@LocationName					varchar(100),
		@IncludeFSF						bit = 0,
		@CityDryRun						varchar(50),
		@StateDryRun					varchar(10),
		@DrayBaseValueDryRun			Decimal(18,2),
		@FsfValueDryRun					Decimal(18,2),
		@DrayageValueDryRun				Decimal(18,2)
	
	
	
	--// MARKET
	select @MarketKey = isnull(OH.MarketLocationKey, C.MarketLocationKey), @Market = ml.MarketLocation,
		@OrderType = OT.OrderType, @CustKey = IH.CustKey, @CustName = C.CustName, @IncludeFSF = isnull(C.IncludeFSF,0)
	from InvoiceHeader IH WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
	inner join Customer C WITH (NOLOCK) on ih.CustKey = c.CustKey
	LEft  join MarketLocation ML WITH (NOLOCK) ON isnull(OH.MarketLocationKey, C.MarketLocationKey) = ml.MarketLocationKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where IH.InvoiceKey = @InvoiceKey

	print @OrderType
	print @MarketKey
	print @Market
	Print @CustKey

	If(Isnull(@MarketKey ,0) = 0)
	Begin
		set @MarketKey = 2
		select @Market = MarketLocation from MarketLocation where MarketLocationKey = @MarketKey
	End
	
	--/// TERMINAL
	Select @TerminalKey = case when @MarketKey = 2 then 6 else 4 end
	select @Terminal = PriceGrouping from PriceGrouping where PriceGroupingKey = @TerminalKey

	--// YARD, PORT AND CITY, STATE, ZIPCODE
	select OT.OrderType, IH.Invoicekey, IH.InvoiceNo, IH.InvoiceDate,OD.OrderDetailKey,
		OD.ContainerNo, RT.Routekey, L.LegID, L.FromLocation, L.ToLocation , 
		RT.SourceAddrKey, Rt.DestinationAddrKey, Y.ShortName, Y.YardType, Y.yardid,
		P.ShippingPortKey, P.ShippingPortID,
		A.City, A.State, A.ZipCode, D.DriverKey, D.driverID, TT.TruckType, A.AddrName as LocationName,
		L.LegCostType, LT.LegTypeName, RT.IsDryRun, RT.DryRunType as DryRunTypeKey, DRT.DryRunType, isnull(RT.IsBobtail,0) as IsBobtail
	INTO #BaseInfo
	from (Select distinct InvoiceKey, orderdetailkey, Container from InvoiceDetail where InvoiceKey = @InvoiceKey) ID 
	inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
	inner join Orderheader OH on Ih.orderkey = OH.OrderKey
	inner join OrderDetail OD on ID.OrderDetailKey = OD.OrderDetailKey
	inner join routes RT on ID.OrderDetailKey = RT.OrderDetailKey and OD.ContainerNo = ID.Container
	inner join Leg L on RT.LegKey = L.LegKey 
	LEft join Yard Y on case when L.FromLocation  = 'Yard' then Rt.SourceAddrKey
		When L.ToLocation = 'Yard' then Rt.DestinationAddrKey else 0 end = Y.AddrKey
	LEft join ShippingPort P on case when L.FromLocation  = 'Port' then Rt.SourceAddrKey
		When L.ToLocation = 'Port' then Rt.DestinationAddrKey else 0 end = P.AddrKey
	LEft join Address A on  A.AddrKey = case when OH.OrderTypeKey = 1 and  L.ToLocation  in ('Shipper','Customer', 'Consignee') then Rt.DestinationAddrKey
		When OH.OrderTypeKey = 2 and  L.FromLocation in ('Shipper','Customer', 'Consignee') then Rt.SourceAddrKey else 0 end 
	LEFT join Driver D on RT.DriverKey = D.DriverKey
	LEft join TruckType TT on D.TruckTypeKey = TT.TruckTypeKey
	LEFT Join Cost_LegTypes LT on L.LegCostType = LT.LegTypeID
	LEFT Join DryRunType DRT on RT.DryRunType = DRT.DryRunTypeKey
	INNER JOIN OrderType OT  WITH (NOLOCK) ON OT.OrderTypeKey=OH.OrderTypeKey
	order by ContainerNo, RouteKey, Rt.LegNo 

	if(@Debug = 1)
	Begin
		Select '#BaseInfo',* from #BaseInfo
	End

	

	--// Accessorial Items Details
	select ih.InvoiceKey, IH.InvoiceNo, ID.InvoicelineKey,ID.Container, ID.ItemKey,I.ItemID, I.Description, 
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, 
		sum(I.UnitCost) as ItemUnitCost, sum(I.InternalCost) InternalCost,
		sum( ID.qty) qty, C.DriverNonDriverCostDesc,
		I.DryRunType, M.ItemKey as MITemKey, M.Description as MDescription, convert( varchar(10),'') as CustSegment
	into #ItemInfo
	from InvoiceDetail  ID 
	inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
	INNER JOIN ITEM i ON id.ItemKey = I.ItemKey
	inner join ITEM M on i.ItemKey = M.ItemKey
	inner join  DriverNonDriverCostItems C on I.CostGrp = C.DriverNonDriverCostKey
	where ID.InvoiceKey = @InvoiceKey and ID.Container is not null
	group by ih.InvoiceKey, IH.InvoiceNo, ID.InvoicelineKey,ID.Container, ID.ItemKey,I.ItemID, I.Description, 
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, C.DriverNonDriverCostDesc, 
		I.DryRunType, M.ItemKey, M.Description
	

	if(@Debug = 1)
	Begin
		SELECT '#ItemInfo',* FROM #ItemInfo
	End

	select @IsBobtail = case when  count(1) > 0 then 1 else 0 end from #BaseInfo where IsBobtail = 1
	select @IsDryRun = case when  count(1) > 0 then 1 else 0 end from #BaseInfo where IsDryRun  = 1

	select distinct OrderdetailKey, ContainerNo into #ContainerBase from  #BaseInfo
	if(@Debug = 1)
	Begin
		select '#ContainerBase', * from #ContainerBase
	End

	if(isnull(@IsBobtail,0) =0)
	Begin
		select @IsBobtail = case when count(1) > 0 then 1 else 0 end from #ItemInfo where Description like '%bobtail%'
	End

	Declare @_OrderdetailKey int,@_ContainerNo varchar(50)
	declare   _ContainerList Cursor Local
	For Select distinct  OrderdetailKey, ContainerNo from #ContainerBase

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
			

	Open _ContainerList
	Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	WHILE  @@FETCH_STATUS = 0
	BEGIN
		PRINT '------------------'
		PRINT @_ContainerNo

		if(@OrderType = 'Export')
		Begin
			select Top 1 @city = City , @State = State, @LocationName =ltrim(rtrim( LocationName)), @ZipCode = ZipCode, @DriverType = TruckType
			from #BaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and ToLocation in ('Shipper','Customer', 'Consignee')
			order by routekey ASC

			select Top 1 @CityDryRun = City , @StateDryRun = State
			from #BaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and ToLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 1
			order by routekey ASC
		end
		else 
		Begin
			select Top 1 @city = City , @State = State, @LocationName = LocationName, @ZipCode = ZipCode, @DriverType = TruckType
			from #BaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and ToLocation in ('Shipper','Customer', 'Consignee')
			order by routekey DESC

			select Top 1  @CityDryRun = City , @StateDryRun = State
			from #BaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and ToLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 1
			order by routekey DESC
		End
		

		if(isnull(@city,'') = '')
		Begin
			if(@OrderType = 'Import')
			Begin
				select @City = A.City, 
					@State = A.State,
					@ZipCode = A.ZipCode,
					@LocationName = A.AddrName
				from InvoiceHeader IH
				inner join OrderHeader OH on IH.OrderKey = OH.OrderKey
				inner join Address A on OH.DestinationAddrKey = A.AddrKey
				where IH.InvoiceKey = @InvoiceKey
			end
			Else
			Begin
				select @City = A.City, 
					@State = A.State,
					@ZipCode = A.ZipCode,
					@LocationName = A.AddrName
				from InvoiceHeader IH
				inner join OrderHeader OH on IH.OrderKey = OH.OrderKey
				inner join Address A on OH.DestinationAddrKey = A.AddrKey
				where IH.InvoiceKey = @InvoiceKey
			end
		End

		print 'City, State, Zipcode, Zone, Location'
		print @City
		print @State
		print @zipcode
		print @LocationName

		select top 1 @ZoneKey = ZoneKey from ZoneCityMap where MarketKey = @MarketKey and TerminalKey = @TerminalKey and City = @City and State = @State
		if(@Debug = 1)
		Begin
			select @city as City, @State as State, @ZipCode as Zip, @ZoneKey as ZoneKey, @LocationName as Location
			select @CityDryRun as City, @StateDryrun as State, @ZipCode as Zip
		End

		select @zoneName = ZoneName from cost_Zones where ZoneKey = @ZoneKey
		print @ZoneKey
		print @zoneName

		--select top 1 @DriverType = TruckType
		--from #BaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND TruckType is not null and 
		--Case when @OrderType = 'Import' then ToLocation else FromLocation end in ('Consignee','Customer','Shipper')
		select @DriverTypeKey = TruckTypeKey From TruckType where TruckType = @DriverType

		print '@TruckType'
		print @DriverType
		if(isnull(@DriverType,'') = '')
		Begin
			select  @DriverType = TruckType, @DriverTypeKey = TruckTypeKey from TruckType where TruckType = 'Broker Carrier'
			print @DriverType
		end

		Select top 1	@YardPortType = Yardtype
		From #BaseInfo Where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo 
		AND ToLocation in ('Consignee','Customer','Shipper') and Yardtype is not null

		if(isnull(@YardPortType,'') = '')
		Begin
			set @YardPortType = 'Local'
		End
		PRINT '@YardPortType'
		PRINT @YardPortType

		--select distinct Yardid as value into #YardShuttleKeys from #BaseInfo 
		--where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND FromLocation = 'Yard' and ToLocation = 'Yard'

		if(@Debug = 1)
		Begin
			select * from #ItemInfo WHERE Container = @_ContainerNo
		End

		IF OBJECT_ID('tempdb..#AccesorialItemKeys') IS NOT NULL 
		BEGIN 
			DROP TABLE #AccesorialItemKeys 
		END

		IF OBJECT_ID('#AccesorialItemKeys') IS NOT NULL 
		BEGIN 
			DROP TABLE #AccesorialItemKeys 
		END

		select distinct Description as value into #AccesorialItemKeys from #ItemInfo 
		WHERE Container = @_ContainerNo --and DriverNonDriverCostDesc in ('Accessorial','Pre Pull')

		if(@Debug = 1)
		Begin
			select '#AccesorialItemKeys', * from #AccesorialItemKeys
		End
		
		select  @CustomerSegment = ISNULL(Cs.CustomerSegment, 'NAC'),
				@IsSpotOn = Case when isnull(CRT.RateType,'NAC') = 'NAC' then 0 else 1 end
		from Customer C
		inner join CustomerSegments CS on C.CustomerSegmentKey = CS.CustomerSegmentKey
		LEft join CustomerRateType CRT on C.RateTypeKey = CRT.RateTypeKey
		where CustKey = @CustKey

		if(@Debug = 1)
		Begin
			Select @CustomerSegment as CustomerSegment, @IsSpotOn  as Spoton
		End

		SET @CustomerSegment = ISNULL(@CustomerSegment, 'NAC')
		SET @IsSpotOn = isnull(@IsSpotOn,0)

		Declare @RecCount int = 0,  @RecCountDryrun	int = 0, @DryRunItemCount	int = 0
		select @DryRunItemCount = Count(1) from #ItemInfo where DryRunType is not null
		

		--if(Isnull(@CustomerSegment,'NAC')='NAC')
		--Begin
			insert into #DrayBase(ContainerNo, DrayBase_Value, FSF_Percent, Margin_Percent, 
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy, OutputDataKey)
			select TOP 1 @_ContainerNo, DraybaseCost, FSF * 100, 0, 
				EffectiveDate, EffectiveDateFrom, F.FileName, DateUploaded, U.UserName as UploadedBy ,OutputDataKey 
			from SELL_NAC_Draybase_FinalDataOutput A
			inner join SELL_NAC_Draybase_FileProcessInfo F on A.FileProcessKey = F.FileProcessKey
			inner join [user] U on F.UserKey = U.UserKey
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					(Zip = @ZipCode OR Zip is null  ) and
					(ltrim(rtrim(LocationName)) = ltrim(rtrim(@LocationName)) OR LocationName is null) and  
					MarketKey = @MarketKey and A.Custkey = @CustKey and
					(TerminalKey = @TerminalKey OR TerminalKey is null)  
					and EffectiveDate <= convert(date,Getdate())
				ORDER BY city DESC, State DESC, Zip Desc, LocationName DESC, convert(datetime, EffectiveDate) DESC, OutputDataKey Desc

			update #DrayBase set Margin_Value = 0; -- AS PER COMMUNICATION ON 18/03/2024 - NO MARGIN FOR NACS 
			--update #DrayBase set Margin_Value = DrayBase_Value * (Margin_Percent/100) where ContainerNo = @_ContainerNo
			update #DrayBase set DrayBase_Rate = DrayBase_Value + Margin_Value where ContainerNo = @_ContainerNo
			update #DrayBase set FSF_Value = DrayBase_Rate * (isnull(FSF_Percent,0) / 100) where ContainerNo = @_ContainerNo
			update #DrayBase set Draybase_Total = DrayBase_Rate + isnull(FSF_Value,0) where ContainerNo = @_ContainerNo
			update #DrayBase set NetRevenue = Draybase_Total - DrayBase_Value where ContainerNo = @_ContainerNo
				
			Select  @RecCount = count(1) from #DrayBase

			select @RecCountDryrun = count(1) from COST_CostDataOutput where City = @CityDryRun and State = @StateDryRun and 
			Market = @Market and Terminal = @Terminal and DriverType = @DriverType
		--End
		


		IF(@Debug = 1)
		bEGIN
			sELECT '#DrayBase', * FROM #DrayBase
		END
		if(@RecCount = 0)
		Begin
			Set @Status = 0
			set @DrayReason = 'Records not found in Sell Database for the combination of Customer Segment: ' + @CustomerSegment 
				+ ', City:' + isnull(@City,'') + ', State:' + isnull(@State,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') 
			print @Reason
		End

		if(@RecCountDryrun = 0 and @DryRunItemCount > 0)
		Begin
			set @DryRunReason = 'Records not found in sELL Database for DRY RUN and the combination of City:' + isnull(@CityDryRun,'') + 
				', State:' + isnull(@StateDryRun,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') + ', DriverType:' + isnull(@DriverType,'')
			print @DryRunReason
		End

		
		if(isnull(@IsBobtail,0) = 1)
		Begin
			insert into #Bobtail (ContainerNo, BobtailFormat, BobtailRate, BobtailCalc,
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy ,OutputDataKey )
			select TOP 1 @_ContainerNo as ContainerNo, BobtailFormat, BobtailRate, convert(numeric(18,2),0.00) as BobtailCalc,
				EffectiveDate, EffectiveDateFrom, F.FileName, DateUploaded, U.UserName as UploadedBy ,OutputDataKey 
			
			from SELL_NAC_Bobtail_FinalDataOutput A
			inner join SELL_NAC_Bobtail_FileProcessInfo F on A.FileProcessKey = F.FileProcessKey
			inner join [user] U on F.UserKey = U.UserKey
			where (City = @city OR City is null) and 
					(State = @State OR State is null) and 
					(LocationName = @LocationName OR LocationName is null) and  
					MarketKey = @MarketKey and A.Custkey = @CustKey and
					(TerminalKey = @TerminalKey OR TerminalKey is null)  
					and EffectiveDate <= convert(date,Getdate())
			ORDER BY city DESC, State DESC, LocationName DESC, EffectiveDate DESC, OutputDataKey Desc

			if(@Debug = 1)
			Begin
				Select '#Bobtail', *  from #Bobtail 
			End
			update #Bobtail SEt BobtailCalc = @DrayBaseValue where BobtailFormat like '%Roundtrip%'
			update #Bobtail set BobtailCalc = 0 where BobtailFormat like '%Free%'
			update #Bobtail set BobtailCalc = @DrayBaseValue * BobtailRate where BobtailFormat like '%Percentage%'
			update #Bobtail set BobtailCalc = convert(numeric(18,2),BobtailRate) where BobtailFormat like '%Flat Fee%'

			
		End
		

		

		if(@Debug = 1)
		Begin
			Select '#Bobtail - 1', *  from #Bobtail 
		end

		--///*********** ACCESSORIAL COST CALCULATION **************************
		
		if(@Debug = 1)
		Begin
			Select @MarketKey as marketKey, @Terminal as Terminal, @TerminalKey as TerminalKey,  @InvoiceKey  as InvoiceKey, @_ContainerNo as ContainerNo,
				@City as city,	@State as  state, @CustKey as CustKey, @LocationName as Location
		End
		insert into #AccRercs 
			( RecordSL, LineItem, MarketLocation, Terminal, ItemKey, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, 
				EffectiveDate, EffectiveDateFrom, CostGroup, FileName, DateUploaded, UploadedBy)
			exec SELL_CalcAccessorialValue @MarketKey = @marketKey, @InvoiceKey  = @InvoiceKey, 
				@ContainerNo = @_ContainerNo,
					@City = @city,	@State = @state, @CustKey = @CustKey, @Location = @LocationName
		Update #AccRercs set ContainerNo = @_ContainerNo,CustSegment ='NAC'

		update A set CustSegment = 'NAC'
		--Select 'After NAC Process', * 
		from #ItemInfo A
		inner join #AccRercs B on B.ContainerNo =  A.Container and B.ItemKey = A.ItemKey

		if(@Debug = 1)
		Begin
			select '#AccRercs', * from #AccRercs
			select '#ItemInfo2', * from #ItemInfo
		end

		
		if((select count(1) from #AccRercs) = 0)
		Begin

			if(@CustomerSegment = 'SMB')
			BEgin
				insert into #AccRercs 
				( RecordSL, LineItem, MarketLocation, Terminal, ItemKey, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, 
					EffectiveDate, EffectiveDateFrom, CostGroup, FileName, DateUploaded, UploadedBy,CustSegment)
				select SellAccRateKey, AR.LineItem, ML.MarketLocation, '', I.ItemKey, AR.SMB_Rate, AR.SMB_BvsNB,
					AR.SMB_FreeTime, AR.SMB_Min, AR.SMB_Max, SMB_Date, 'Acc. Tariff - SMB',
					'Accessorial','Acc. Tariff - SMB',SMB_Date, 
					U.UserName, 'SMB'
				from #ItemInfo I
				inner join Sell_AccessorialRates AR on I.MDescription = AR.LineItem 
					and AR.MarketKey = @MarketKey 
				inner join MarketLocation ML on AR.MarketKey = ML.MarketLocationKey
				LEft join [user] U on AR.SMB_UserKey = U.UserKey
				where SMB_Rate > 0 and isnull(I.CustSegment,'') = ''
			End
			else if(@CustomerSegment = 'ENT')
			Begin
				insert into #AccRercs 
				( RecordSL, LineItem, MarketLocation, Terminal, ItemKey, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, 
					EffectiveDate, EffectiveDateFrom, CostGroup, FileName, DateUploaded, UploadedBy, CustSegment)
				select SellAccRateKey, AR.LineItem, ML.MarketLocation, '', I.ItemKey, AR.ENT_Rate, AR.ENT_BvsNB,
					AR.ENT_FreeTime, AR.ENT_Min, AR.ENT_Max, ENT_Date, 'Acc. Tariff - ENT',
					'Accessorial','Acc. Tariff - ENT',ENT_Date, 
					U.UserName, CustSegment
				from #ItemInfo I
				inner join Sell_AccessorialRates AR on I.MDescription = AR.LineItem 
					and AR.MarketKey = @MarketKey 
				inner join MarketLocation ML on AR.MarketKey = ML.MarketLocationKey
				LEft join [user] U on AR.ENT_UserKey = U.UserKey
				where ENT_Rate > 0 and  isnull(I.CustSegment,'') = ''
			End
		End
		
		
		if(@Debug = 1)
		Begin
			select '#AccRercs', * from #AccRercs
		end

		
		if(@Debug = 1)
		Begin
			select '#AccRercs', * from #AccRercs
		end
		update #AccRercs set ContainerNo = @_ContainerNo where isnull(ContainerNo ,'') = ''
		
		if((Select count(1) from #AccRercs) = 0 and (Select count(1) from #ItemInfo where ItemCostGroup = 'Accessorial') > 0)
		Begin
			set @AccessorialReason = 'Record not found in ' + 
				Case when @CustomerSegment = 'NAC' then ' NAC Accessorial ' else 'Accessorial Tariff' end + 
				' for the Container: ' + @_ContainerNo 
				+ ', Cust Name: ' + @CustName
				+ ', Market: ' + @Market 
				+ ', City : ' + @city
				+ ', State : ' + @State 
		End

		if((select count(1) from #Bobtail ) = 0)
		Begin
			set @BobtailReason = 'Records not found in Sell - Bobtail Database for the combination of Customer Segment: ' + @CustomerSegment 
			+ ', City:' + isnull(@City,'') + ', State:' + isnull(@State,'') 
			+ ', Market:' + isnull(@Market,'')
			+ ', Terminal:' + isnull(@Terminal,'') 
		End

		Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	End
	Close _ContainerList
	deallocate _ContainerList

	if(@Debug = 1)
	Begin
		select * from #AccRercs
		SElect * from #DrayBase
		
		Select @DrayReason, @AccessorialReason, @ConfigReason
	End

	Select @JsonOutput = (
		Select  @Market as Market, @MarketKey as MarketKey,
				@Terminal as Terminal, @TerminalKey as TerminalKey,
				@ZoneKey as ZoneKey, @zoneName as ZoneName,
				@City as city, @State as State,
				@CustKey as CustKey, @CustName as CustName,
				IsDryRun = convert(bit, Case when isnull(@IsDryRun,0) =0 then 0
								when isnull(@DryRunItemCount,0) = 0 then 0
								when @IsDryRun = 1 then 1 
								When @DryRunItemCount > 0 then 1 else 0 end),
				IsBobTail = convert(bit, case when isnull(@IsBobtail,0) = 0 then 0  else 1 end),
				Customersegment = @CustomerSegment,
			Accessorials = (Select 
				ContainerNo , RecordSL, LineItem, MarketLocation, Terminal, ItemKey, Rate, BvsNB, 
				FreeTime, MinCnt, MaxCnt, EffectiveDate, EffectiveDateFrom, CostGroup,  
				FileName, DateUploaded, UploadedBy, CustSegment
				from #AccRercs
				For JSON PATH),
			DrayBase = (Select 
				ContainerNo, DrayBase_Value, Margin_Percent, Margin_Value, DrayBase_Rate, 
				FSF_Percent, FSF_Value, Draybase_Total, NetRevenue,
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy, OutputDataKey
				from #DrayBase 
				For JSON PATH),
			Bobtail = (
			Select ContainerNo, BobtailFormat, BobtailRate, BobtailCalc,
				EffectiveDate, EffectiveDateFrom,FileName, DateUploaded, UploadedBy ,OutputDataKey 
			from #Bobtail
			For JSON PATH),
			Error = (Select @DrayReason as DrayReason,
				@AccessorialReason as AccessorialReason,
				@ConfigReason as ConfigReason,
				@BobtailReason  as BobtailReason
				For JSON PATH
				)
			For JSON PATH
	)
	If @Status = 1
	Begin
		Set @Reason = 'SUCCESS'
	End

	IF OBJECT_ID('#AccesorialItemKeys') IS NOT NULL 
	BEGIN 
		DROP TABLE #AccesorialItemKeys 
	END

	drop table #AccRercs
	drop table #YardKeys
	--Drop table #AccesorialItemKeys
	--DROP TABLE #Summary
	drop table #BaseInfo
	drop table #ItemInfo
	--drop table #Terminal
	--drop table #LegTypeList
	drop table #Prepull
	drop table #StopOff
	drop table #YardShuttleFrom
	drop table #YardShuttleTo
	drop table #ContainerSummary
	drop table #Bobtail
END
