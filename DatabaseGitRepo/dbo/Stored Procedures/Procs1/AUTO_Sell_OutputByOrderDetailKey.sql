

/* --48771, 49931, 50711, 54878, 54894, 56302, 56694, 56937, 57007, 57576, 61389, 65844, 65908, 67605, 83754
	Exec [AUTO_Sell_OutputByOrderDetailKey]  272426, 1
*/
CREATE PRoc [dbo].[AUTO_Sell_OutputByOrderDetailKey]
(
	@OrderDetailKey		int	= 0,
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
			@IsBobtail				bit = 0,
			@IsDryRun				bit = 0,
			@CustomerSegment		varchar(10),
			@IsSpotOn				Bit = 0

	Declare @DrayReason	varchar(500)='',
			@ConfigReason	varchar(500)='',
			@AccessorialReason varchar(500)='',
			@BobtailReason		varchar(500) = ''
			
	DECLARE @InvoiceDate		DATETIME

	if(isnull(@OrderDetailKey,0) = 0 )
	BEGIN
		return
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
		FSF_Percent			decimal(18,8),
		FSF_Value			decimal(18,8),
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
		@FsfValueDryRun					Decimal(18,8),
		@DrayageValueDryRun				Decimal(18,2)
	
	--added for invoice date
	SELECT @InvoiceDate=ISNULL(InvoiceDate,GETDATE()) FROM InvoiceHeader IH WITH (NOLOCK)
	OUTER APPLY (SELECT TOP 1 *
                    FROM   Invoicedetail IDI
                    WHERE  IDI.InvoiceKey=IH.InvoiceKey and OrderDetailKey=@OrderDetailKey
                    ORDER  BY IDI.InvoiceLineKey) ID
	
	--// MARKET
	select @MarketKey = isnull(OH.MarketLocationKey, C.MarketLocationKey), @Market = ml.MarketLocation,
		@OrderType = OT.OrderType, @CustKey = OH.CustKey, @CustName = C.CustName, @IncludeFSF = isnull(C.IncludeFSF,0)
	from ORderDetail OD WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	inner join Customer C WITH (NOLOCK) on OH.CustKey = c.CustKey
	LEft  join MarketLocation ML WITH (NOLOCK) ON isnull(OH.MarketLocationKey, C.MarketLocationKey) = ml.MarketLocationKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where OD.OrderDetailKey = @OrderDetailKey

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
	select OD.OrderDetailKey,
		OD.ContainerNo, RT.Routekey, L.LegID, L.FromLocation, L.ToLocation , 
		RT.SourceAddrKey, Rt.DestinationAddrKey, Y.ShortName, Y.YardType, Y.yardid,
		P.ShippingPortKey, P.ShippingPortID,
		A.City, A.State, A.ZipCode, D.DriverKey, D.driverID, TT.TruckType, TRIM(A.AddrName) as LocationName,
		L.LegCostType, LT.LegTypeName, RT.IsDryRun, RT.DryRunType as DryRunTypeKey, DRT.DryRunType, isnull(RT.IsBobtail,0) as IsBobtail
	INTO #BaseInfo
	from ORderDetail OD 
	inner join Orderheader OH WITH (NOLOCK) on OD.orderkey = OH.OrderKey
	inner join routes RT WITH (NOLOCK) on OD.OrderDetailKey = RT.OrderDetailKey 
	inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey 
	LEft join Yard Y WITH (NOLOCK) on case when L.FromLocation  = 'Yard' then Rt.SourceAddrKey
		When L.ToLocation = 'Yard' then Rt.DestinationAddrKey else 0 end = Y.AddrKey
	LEft join ShippingPort P WITH (NOLOCK) on case when L.FromLocation  = 'Port' then Rt.SourceAddrKey
		When L.ToLocation = 'Port' then Rt.DestinationAddrKey else 0 end = P.AddrKey
	LEft join Address A WITH (NOLOCK) on  A.AddrKey = case when OH.OrderTypeKey = 1 and  L.ToLocation  in ('Shipper','Customer', 'Consignee') then Rt.DestinationAddrKey
		When OH.OrderTypeKey = 2 and  L.FromLocation in ('Shipper','Customer', 'Consignee') then Rt.SourceAddrKey else 0 end 
	LEFT join Driver D WITH (NOLOCK) on RT.DriverKey = D.DriverKey
	LEft join TruckType TT WITH (NOLOCK) on D.TruckTypeKey = TT.TruckTypeKey
	LEFT Join Cost_LegTypes LT WITH (NOLOCK) on L.LegCostType = LT.LegTypeID
	LEFT Join DryRunType DRT WITH (NOLOCK) on RT.DryRunType = DRT.DryRunTypeKey
	where OD.OrderDetailKey = @OrderDetailKey
	order by ContainerNo, RouteKey, Rt.LegNo 

	if(@Debug = 1)
	Begin
		Select '#BaseInfo',* from #BaseInfo
	End

	--// Accessorial Items Details
	select OE.orderDetailKey, OE.ItemKey,I.ItemID, I.Description, OD.ContainerNo,
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, 
		sum(I.UnitCost) as ItemUnitCost, sum(I.InternalCost) InternalCost,
		sum( OE.qty) qty, C.DriverNonDriverCostDesc,
		I.DryRunType, M.ItemKey as MITemKey, M.Description as MDescription, convert( varchar(10),'') as CustSegment
	into #ItemInfo
	from OrderExpense  OE 
	inner join  ORDERDETAIL OD WITH (NOLOCK) on OE.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN ITEM i WITH (NOLOCK) ON OE.ItemKey = I.ItemKey
	inner join ITEM M WITH (NOLOCK) on i.ItemKey = M.ItemKey
	inner join  DriverNonDriverCostItems C WITH (NOLOCK) on I.CostGrp = C.DriverNonDriverCostKey
	where OE.OrderDetailKey = @OrderDetailKey 
	group by OE.OrderDetailKey, OE.ItemKey,I.ItemID, I.Description, 
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, C.DriverNonDriverCostDesc, 
		I.DryRunType, M.ItemKey, M.Description, OD.ContainerNo
	

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

	Open _ContainerList
	Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	WHILE  @@FETCH_STATUS = 0
	BEGIN
		PRINT '------------------'
		PRINT @_ContainerNo

		if(@OrderType = 'Export')
		Begin
			select Top 1 @city = City , @State = State, @LocationName = LocationName, @ZipCode = ZipCode, @DriverType = TruckType
			from #BaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and FromLocation in ('Shipper','Customer', 'Consignee')
			order by routekey ASC

			select Top 1 @CityDryRun = City , @StateDryRun = State
			from #BaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and FromLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 1
			order by routekey ASC
		end
		else 
		Begin
			select Top 1 @city = City , @State = State, @LocationName = LocationName, @ZipCode = ZipCode, @DriverType = TruckType
			from #BaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and FromLocation in ('Shipper','Customer', 'Consignee')
			order by routekey DESC

			select Top 1  @CityDryRun = City , @StateDryRun = State
			from #BaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and FromLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 1
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
				from ORderDetail OD
				inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
				inner join Address A WITH (NOLOCK) on OH.DestinationAddrKey = A.AddrKey
				where OD.OrderDetailKey = @OrderDetailKey
			end
			Else
			Begin
				select @City = A.City, 
					@State = A.State,
					@ZipCode = A.ZipCode,
					@LocationName = A.AddrName
				from ORderDetail OD
				inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
				inner join Address A WITH (NOLOCK) on OH.DestinationAddrKey = A.AddrKey
				where OD.OrderDetailKey = @OrderDetailKey
			end
		End

		Select Top 1 @City = City, @State = State, @Zipcode = Zipcode, @LocationName = LocationName from #BaseInfo where ToLocation = 'Consignee'

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

		if(@Debug = 1)
		Begin
			select * from #ItemInfo WHERE ContainerNo = @_ContainerNo
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
		WHERE ContainerNo = @_ContainerNo --and DriverNonDriverCostDesc in ('Accessorial','Pre Pull')

		if(@Debug = 1)
		Begin
			select '#AccesorialItemKeys', * from #AccesorialItemKeys
		End
		
		select  @CustomerSegment = ISNULL(Cs.CustomerSegment, 'NAC'),
				@IsSpotOn = Case when isnull(CRT.RateType,'NAC') = 'NAC' then 0 else 1 end
		from Customer C
		inner join CustomerSegments CS WITH (NOLOCK) on C.CustomerSegmentKey = CS.CustomerSegmentKey
		LEft join CustomerRateType CRT WITH (NOLOCK) on C.RateTypeKey = CRT.RateTypeKey
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
			inner join SELL_NAC_Draybase_FileProcessInfo F WITH (NOLOCK) on A.FileProcessKey = F.FileProcessKey
			inner join [user] U WITH (NOLOCK) on F.UserKey = U.UserKey
			where (City = @city OR ISNULL(City,'')='') and 
					(State = @State OR ISNULL(State,'')='') and 
					(LocationName = @LocationName OR ISNULL(LocationName,'') ='') and  
					MarketKey = @MarketKey and A.Custkey = @CustKey and
					(TerminalKey = @TerminalKey OR ISNULL(TerminalKey,0)=0)  
					and (CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) end) <= convert(date,@InvoiceDate)
					and ISNULL(A.IsArchived,0) = 0 and 
					(CASE 
        WHEN ISDATE(ExpiryDate) = 1 
            THEN CONVERT(varchar(10), CAST(ExpiryDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, ExpiryDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, ExpiryDate, 103), 101) end) >= convert(date, @InvoiceDate)
				ORDER BY city DESC, State DESC, LocationName DESC, CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) end DESC, OutputDataKey Desc

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
		BEGIN
			SELECT '#DrayBase', * FROM #DrayBase
		END
		if(@RecCount = 0)
		Begin
			set @DrayReason = 'Records not found in Sell Database for the combination of Customer Segment: ' + @CustomerSegment 
				+ ', City:' + isnull(@City,'') + ', State:' + isnull(@State,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') 
			print @DrayReason
		End

		if(@RecCountDryrun = 0 and @DryRunItemCount > 0)
		Begin
			set @DryRunReason = 'Records not found in sELL Database for DRY RUN and the combination of City:' + isnull(@CityDryRun,'') + 
				', State:' + isnull(@StateDryRun,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') + ', DriverType:' + isnull(@DriverType,'')
			print @DryRunReason
		End

		--IF OBJECT_ID('tempdb..#Bobtail') IS NOT NULL 
		--BEGIN 
		--	DROP TABLE #Bobtail 
		--END

		--IF OBJECT_ID('#Bobtail') IS NOT NULL 
		--BEGIN 
		--	DROP TABLE #Bobtail 
		--END

		
			
		if(isnull(@IsBobtail,0) = 1)
		Begin
			insert into #Bobtail (ContainerNo, BobtailFormat, BobtailRate, BobtailCalc,
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy ,OutputDataKey )
			select TOP 1 @_ContainerNo as ContainerNo, BobtailFormat, BobtailRate, convert(numeric(18,2),0.00) as BobtailCalc,
				EffectiveDate, EffectiveDateFrom, F.FileName, DateUploaded, U.UserName as UploadedBy ,OutputDataKey 
			
			from SELL_NAC_Bobtail_FinalDataOutput A
			inner join SELL_NAC_Bobtail_FileProcessInfo F WITH (NOLOCK) on A.FileProcessKey = F.FileProcessKey
			inner join [user] U WITH (NOLOCK) on F.UserKey = U.UserKey
			where (City = @city OR ISNULL(City,'')='') and 
					(State = @State OR ISNULL(State,'')='') and 
					(LocationName = @LocationName OR ISNULL(LocationName,'') ='') and  
					MarketKey = @MarketKey and A.Custkey = @CustKey and
					(TerminalKey = @TerminalKey OR ISNULL(TerminalKey,0)=0)  
					and (CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) end) <= convert(date,@InvoiceDate)
					and ISNULL(A.IsArchived,0) = 0 and 
					(CASE 
        WHEN ISDATE(A.ExpiryDate) = 1 
            THEN CONVERT(varchar(10), CAST(A.ExpiryDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, A.ExpiryDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, A.ExpiryDate, 103), 101) end) >= convert(Date, @InvoiceDate)
			ORDER BY city DESC, State DESC, LocationName DESC, CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) end DESC, OutputDataKey Desc

			if(@Debug = 1)
			Begin
				Select '#Bobtail', *  from #Bobtail 
			End
			update #Bobtail SEt BobtailCalc = @DrayBaseValue where BobtailFormat like '%Roundtrip%'
			update #Bobtail set BobtailCalc = 0 where BobtailFormat like '%Free%'
			update #Bobtail set BobtailCalc = @DrayBaseValue * BobtailRate where BobtailFormat like '%Percentage%'
			update #Bobtail set BobtailCalc = convert(numeric(18,2),BobtailRate) where BobtailFormat like '%Flat Fee%'

			if((select count(1) from #Bobtail ) = 0)
			Begin
				set @BobtailReason = 'Records not found in Sell - Bobtail Database for the combination of Customer Segment: ' + @CustomerSegment 
				+ ', City:' + isnull(@City,'') + ', State:' + isnull(@State,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') 
			End
		End
		

		

		if(@Debug = 1)
		Begin
			Select '#Bobtail - 1', *  from #Bobtail 
		end

		--///*********** ACCESSORIAL COST CALCULATION **************************
		
		if(@Debug = 1)
		Begin
			Select @MarketKey as marketKey, @OrderDetailKey  as ORderDetailKey, @_ContainerNo as ContainerNo,
				@City as city,	@State as  state, @CustKey as CustKey, @LocationName as Location
		End
		

		Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	End
	Close _ContainerList
	deallocate _ContainerList

	if(@Debug = 1)
	Begin
		SElect * from #DrayBase
		
		Select @DrayReason, @AccessorialReason, @ConfigReason
	End
	Declare @JsonOutput nvarchar(max) = ''
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
	select @JsonOutput

	
	drop table #YardKeys
	IF OBJECT_ID('#AccesorialItemKeys') IS NOT NULL 
	BEGIN 
		DROP TABLE #AccesorialItemKeys 
	END

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
	DROP TABLE #ContainerBase
	DROP TABLE #DrayBase

END
