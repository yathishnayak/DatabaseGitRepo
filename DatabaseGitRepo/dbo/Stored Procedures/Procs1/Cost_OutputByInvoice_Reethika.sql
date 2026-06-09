

/*
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '87417',   @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(500) = '' 
	EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT
	SELECT @JsonOutput, @Status, @Reason
*/

/*
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '91974',   @JsonOutput nvarchar(max) ='',
			@Status	bit = 0 , @Reason	varchar(500) = '', @debug			bit = 1
	EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug
	SELECT @JsonOutput, @Status, @Reason
*/
create PRoc [dbo].[Cost_OutputByInvoice_Reethika]
(
	@InvoiceKey		int	= 0,
	@InvoiceNo		varchar(50) = '',
	@JsonOutput		nvarchar(max) ='' OUTPUT,
	@Status			bit = 0 output,
	@Reason			varchar(500) = '' output,
	@debug			bit = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	declare @DryRunReason varchar(1000) = '',
			@IsBobtail		bit = 0,
			@IsDryRun		bit = 0,
			@IsDraybase		bit = 0,
			@DryRunType		varchar(20) = ''

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
		LineItem8			varchar(100), -- FSF
		LineItem8_Value		decimal(18,3), -- FSFValue
		Total_text			varchar(100),
		Total_value			decimal(18,3),
		IsFSFExists			bit default 0
	)

	select convert(varchar(50),'') as ContainerNo, RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent 
	into #AccRercs
	from COSTACC_FinalDataOutput where 1=0
	alter table #AccRercs add TotalCost Decimal(18,3) 

	

	Declare
		@OrderType						varchar(50),
		@MarketKey						int,
		@TerminalKey					int,
		@ZipCode						varchar(20),
		@DriverTypeKey					int,
		@isPrePull						bit =0,
		@PrePullLocationKey				int,
		@isYardShuttle					bit =0 ,
		@YardShuttleLocationKeys		varchar(50),
		@isStopOff						bit =0,
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
		@combinedString					varchar(max) = '',
		@CityDryRun						varchar(50),
		@StateDryRun					varchar(10),
		@DrayBaseValueDryRun			Decimal(18,2),
		@FsfValueDryRun					Decimal(18,2),
		@DrayageValueDryRun				Decimal(18,2),
		@CustKey						int = 0
	
		
	--// MARKET
	select @MarketKey = isnull(OH.MarketLocationKey, C.MarketLocationKey), @Market = ml.MarketLocation,
		@OrderType = OT.OrderType, @CustKey = oh.CustKey
	from InvoiceHeader IH WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
	inner join Customer C WITH (NOLOCK) on ih.CustKey = c.CustKey
	LEft  join MarketLocation ML WITH (NOLOCK) ON isnull(OH.MarketLocationKey, C.MarketLocationKey) = ml.MarketLocationKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where IH.InvoiceKey = @InvoiceKey

	print @OrderType
	print @MarketKey
	print @Market

	If(Isnull(@MarketKey ,0) = 0)
	Begin
		set @MarketKey = 2
		select @Market = MarketLocation from MarketLocation WITH (NOLOCK) where MarketLocationKey = @MarketKey
	End
	
	--/// TERMINAL
	Select @TerminalKey = case when @MarketKey = 2 then 6 else 4 end
	select @Terminal = PriceGrouping from PriceGrouping where PriceGroupingKey = @TerminalKey

	--// YARD, PORT AND CITY, STATE, ZIPCODE
	--Creation of Temp Table Structure/Skeleton
	SELECT * INTO #BaseInfo1_Auto_ReturnBaseInfo FROM BaseInfo_WRK WHERE 1= 0

	--Insertion to temp table from procedure
	INSERT
	INTO #BaseInfo1_Auto_ReturnBaseInfo
	EXEC Auto_ReturnBaseInfo @InvoiceKey

	if(@debug = 1)
	Begin
		Select '#BaseInfo1_Auto_ReturnBaseInfo',* from #BaseInfo1_Auto_ReturnBaseInfo
	end
	
	select @IsBobtail = case when  count(1) > 0 then 1 else 0 end from #BaseInfo1_Auto_ReturnBaseInfo where IsBobtail = 1
	select @IsDryRun = case when  count(1) > 0 then 1 else 0 end from #BaseInfo1_Auto_ReturnBaseInfo where IsDryRun  = 1
	select @DryRunType = DryRunType from #BaseInfo1_Auto_ReturnBaseInfo where IsDryRun = 1
	Select @IsDraybase = case when  count(1) > 0 then 1 else 0 end from #BaseInfo1_Auto_ReturnBaseInfo where LegTypeName = 'Dray Base'

	
	--// Accessorial Items Details
	select ih.InvoiceKey, IH.InvoiceNo, ID.InvoicelineKey,ID.Container, ID.ItemKey,I.ItemID, I.Description, 
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, 
		sum(I.UnitCost) as ItemUnitCost, sum(I.InternalCost) InternalCost,sum( ID.qty) qty, C.DriverNonDriverCostDesc,
		I.DryRunType
	into #ItemInfo
	from InvoiceDetail  ID  WITH (NOLOCK)
	inner join InvoiceHeader IH WITH (NOLOCK) on ID.InvoiceKey = IH.InvoiceKey
	INNER JOIN ITEM i WITH (NOLOCK) ON id.ItemKey = I.ItemKey
	inner join  DriverNonDriverCostItems C WITH (NOLOCK) on I.CostGrp = C.DriverNonDriverCostKey
	where ID.InvoiceKey = @InvoiceKey and ID.Container is not null
	group by ih.InvoiceKey, IH.InvoiceNo, ID.InvoicelineKey,ID.Container, ID.ItemKey,I.ItemID, I.Description, 
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, C.DriverNonDriverCostDesc, I.DryRunType
	
	if(@debug = 1)
	Begin
		SELECT '#ItemInfo',* FROM #ItemInfo
	end 

	if(isnull(@IsBobtail,0) =0)
	Begin
		select @IsBobtail = case when count(1) > 0 then 1 else 0 end from #ItemInfo where DriverNonDriverCostDesc = 'BobTail'
	End
	if(isnull(@IsDraybase,0) = 0)
	Begin
		select @IsDraybase = 1 
			from #ItemInfo 
			where DriverNonDriverCostDesc = 'Drayage'
	End

	select distinct OrderdetailKey, ContainerNo into #ContainerBase from  #BaseInfo1_Auto_ReturnBaseInfo

	Declare @_OrderdetailKey int,@_ContainerNo varchar(50)
	declare   _ContainerList Cursor Local
	For Select OrderdetailKey, ContainerNo from #ContainerBase

	Open _ContainerList
	Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	WHILE  @@FETCH_STATUS = 0
	BEGIN
		PRINT '------------------'
		PRINT @_ContainerNo
		Declare @IsFSFExists	bit = 0

		if(@OrderType = 'Export')
		Begin
			select Top 1 @city = City , @State = State,  @ZipCode = ZipCode, @DriverType = TruckType , @YardPortType = YardType
			from #BaseInfo1_Auto_ReturnBaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and FromLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 0
			order by LEgNo ASC

			select Top 1 @CityDryRun = City , @StateDryRun = State
			from #BaseInfo1_Auto_ReturnBaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and FromLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 1
			order by LEgNo ASC
		end
		else 
		Begin
			select Top 1 @city = City , @State = State,  @ZipCode = ZipCode, @DriverType = TruckType, @YardPortType = YardType
			from #BaseInfo1_Auto_ReturnBaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and ToLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 0 and 
				NOT (LEft(ltrim(rtrim(Address1)),19) = '2850 E Del Amo Blvd' OR LEft(ltrim(rtrim(Address1)),13) ='3400 New Dock')
			order by LEgNo DESC

			select Top 1  @CityDryRun = City , @StateDryRun = State
			from #BaseInfo1_Auto_ReturnBaseInfo
			where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null
				and ToLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 1
			order by LEgNo DESC
		End
		

		if(isnull(@city,'') = '')
		Begin
			if(@OrderType = 'Import')
			Begin
				select @City = A.City, 
					@State = A.State,
					@ZipCode = A.ZipCode
				from InvoiceHeader IH WITH (NOLOCK)
				inner join OrderHeader OH WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
				inner join Address A WITH (NOLOCK) on OH.DestinationAddrKey = A.AddrKey
				where IH.InvoiceKey = @InvoiceKey
			end
			Else
			Begin
				select @City = A.City, 
					@State = A.State,
					@ZipCode = A.ZipCode
				from InvoiceHeader IH WITH (NOLOCK)
				inner join OrderHeader OH WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
				inner join Address A WITH (NOLOCK) on OH.DestinationAddrKey = A.AddrKey
				where IH.InvoiceKey = @InvoiceKey
			end
		End

		

		if(@debug = 1)
		Begin
			select @city as City, @State as State, @ZipCode as Zip
			select @CityDryRun as City, @StateDryrun as State, @ZipCode as Zip
			select @DryRunType as DryRunType
		end

		select top 1 @DriverType = TruckType
		from #BaseInfo1_Auto_ReturnBaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND TruckType is not null and 
		Case when @OrderType = 'Import' then ToLocation else FromLocation end in ('Consignee','Customer','Shipper')

		print '@TruckType'
		print @DriverType
		if(isnull(@DriverType,'') = '')
		Begin
			select  @DriverType = TruckType, @DriverTypeKey = TruckTypeKey from TruckType where TruckType = 'Broker Carrier'
			print @DriverType
		end

		if(isnull(@YardPortType,'') = '')
		Begin
			Select top 1	@YardPortType = Yardtype
			From #BaseInfo1_Auto_ReturnBaseInfo Where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo 
			AND ToLocation in ('Consignee','Customer','Shipper') and Yardtype is not null
			order by LegNo 
		End

		if(@debug =1)
		Begin
			select	@_OrderDetailKey as OrderDetailKey,@MarketKey as MarketLocationKey, @Market as Market,  
				@Terminal as Terminal,@City as City, @State as State, @YardPortType as YardPortType,
				@_ContainerNo as ContainerNo, @DriverType as TruckType, 
				@custKey as CustKey, 
				@DryRunType as DryRunType, @CityDryRun as CityDryRun, @StateDryRun as StateDryRun
		End

		--if(isnull(@YardPortType,'') = '')
		--Begin
		--	set @YardPortType = 'Local'
		--End
		PRINT '@YardPortType'
		PRINT @YardPortType

		select distinct Yardid as value into #YardShuttleKeys from #BaseInfo1_Auto_ReturnBaseInfo 
		where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND FromLocation = 'Yard' and ToLocation = 'Yard'

		if(@debug = 1)
		Begin
			select '#ItemInfo',* from #ItemInfo WHERE Container = @_ContainerNo
		end

		select distinct Description as value into #AccesorialItemKeys from #ItemInfo 
		WHERE Container = @_ContainerNo and DriverNonDriverCostDesc in ( 'Accessorial','Dry Run','BobTail')
		--select '#AccesorialItemKeys', * from #AccesorialItemKeys

		Declare @RecCount int = 0, @RecCountDryrun	int = 0, @DryRunItemCount	int = 0
		select @DryRunItemCount = Count(1) from #ItemInfo where DryRunType is not null
		if(@DryRunItemCount > 0)
		Begin
			Select @DryRunType = Case when DryRunType = 'Dry Run (PORT)' then 'Pre-Pull' else @DryRunType end from #ItemInfo where DryRunType is not null
			print '@DryRunType - After Change'
			print @DryRunType
		End

		select @RecCount = count(1) from COST_CostDataOutput where City = @city and State = @State and 
			Market = @Market and Terminal = @Terminal and DriverType = @DriverType
		select @RecCountDryrun = count(1) from COST_CostDataOutput where City = @CityDryRun and State = @StateDryRun and 
			Market = @Market and Terminal = @Terminal and DriverType = @DriverType

		if(@RecCount = 0)
		Begin
			Set @Status = 0
			set @Reason = 'Records not found in Cost Database for the combination of City:' + isnull(@City,'') + ', State:' + isnull(@State,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') + ', DriverType:' + isnull(@DriverType,'')
			print @Reason
		End

		if(@RecCountDryrun = 0 and @DryRunItemCount > 0)
		Begin
			set @DryRunReason = 'Records not found in Cost Database for DRY RUN and the combination of City:' + isnull(@CityDryRun,'') + ', State:' + isnull(@StateDryRun,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') + ', DriverType:' + isnull(@DriverType,'')
			print @DryRunReason
		End

		if((Select count(1) from #BaseInfo1_Auto_ReturnBaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND LegCostType = '1')>0)
		Begin
			SEt @isPrePull = 1
			SElect @PrePullYardPortType = YardType, @PrePullLocationKey = YardId, @PrePullLocation = ShortName 
				from #BaseInfo1_Auto_ReturnBaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND LegCostType = '1'
			print '@PrePullYardPortType'
			print @PrePullYardPortType
		End
		else
		if(isnull(@IsDryRun,0) = 1)
		Begin
			SEt @isPrePull = 1
			SElect @PrePullYardPortType = 'Port', @PrePullLocationKey = YardId, @PrePullLocation = ShortName 
				from #BaseInfo1_Auto_ReturnBaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND IsDryRun = 1
			print '@PrePullYardPortType'
			print @PrePullYardPortType
		End
		if(@isPrePull = 0 and (select count(1) from #ItemInfo where DriverNonDriverCostDesc = 'Pre Pull') = 1)
		Begin
			set @isPrePull = 1
		End
		

		if((Select count(1) from #BaseInfo1_Auto_ReturnBaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND LegCostType = '4a')>0)
		Begin
			SEt @isStopOff  = 1
			SElect @StopOffYardPortType = YardType, @StopOffLocationKey = YardId, @StopOffLocation = ShortName 
			from #BaseInfo1_Auto_ReturnBaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND LegCostType = '4a'
			print '@StopOffYardPortType'
			print @StopOffYardPortType
		End

		if(@isStopOff = 0 and (select count(1) from #ItemInfo where DriverNonDriverCostDesc = 'Stop Off') = 1)
		Begin
			set @isStopOff = 1

		End
		Declare @DrayageValue numeric(18,2), @FSFValue numeric(18,2)

		

		select top 1 @DrayBaseValue = Cost + fsf  , @DrayageValue = Cost  , @FSFValue = fsf 
			from COST_CostDataOutput  WITH (NOLOCK)
			where city = @city and State = @State and DriverType =@DriverType 
				and Terminal = @Terminal and Market = @Market  
				and (YardPortType = @YArdPortType OR @YArdPortType is null)
			order by EffectiveDate desc

		if(@debug = 1)
		begin
			select 'DRAYBASE', *
			from COST_CostDataOutput  WITH (NOLOCK)
			where city = @city and State = @State and DriverType =@DriverType 
				and Terminal = @Terminal and Market = @Market  
				and (YardPortType = @YArdPortType OR @YArdPortType is null)
			order by EffectiveDate desc
		End
		

		select top 1 @DrayBaseValueDryRun = Cost + fsf ,  @DrayageValueDryRun = Cost, @FsfValueDryRun = fsf  
			from COST_CostDataOutput  WITH (NOLOCK)
			where city = @CityDryRun and State = @StateDryRun and DriverType =@DriverType 
				and Terminal = @Terminal and Market = @Market 
				and (YardPortType = @YArdPortType OR @YArdPortType is null)
			order by EffectiveDate desc
		

		print '@DrayBaseValue'
		print @DrayBaseValue
		if(@debug = 1)
		Begin
			select @DrayBaseValue as DrayBaseValue, @DrayageValue as DrayageValue, @FSFValue as FSFValue,
				@DrayBaseValueDryRun as DrayBaseValueDryRun, @DrayageValueDryRun as DrayageValueDryRun,
				@FsfValueDryRun as FsfValueDryRun
		End
		TRUNCATE TABLE #YardKeys
		
		if(@debug = 1)
		Begin
			select '#YardShuttleKeys', * from #YardShuttleKeys
		end

		if((Select count(1) from #YardShuttleKeys) > 0)
		Begin
			Insert into #YardKeys
			select Distinct Yardid , YardType
			from #YardShuttleKeys A
			inner join Yard Y WITH (NOLOCK) on A.Value = Y.YardId
		
			set @isYardShuttle = 1
		End
		if(@isYardShuttle = 0 and (Select count(1) from #ItemInfo where DriverNonDriverCostDesc = 'Shuttle') > 0)
		Begin
			SEt @isYardShuttle = 1
		End
		
		if(@debug =1)
		Begin
			Select @isPrePull as IsPrepull,
					@isStopOff as IsStopOff,
					@IsBobtail as IsBobTail,
					@IsDraybase as IsDraybase,
					@isYardShuttle as IsYardShuttle,
					@IsFSFExists as IsFSFExists,
					@IsDryRun as IsDryRun
		End
		print '-----------------------'
		print '@PrePullLocationKey'
		print @PrePullLocationKey

		print '------------------'
		print '@StopOffLocationKey'
		print @StopOffLocationKey

		if(@debug = 1)
		Begin
			select '#YardKeys',* from #YardKeys
		end

		insert into #Prepull (Container, Prepulllocation, PrepullCost)
		SELECT @_ContainerNo AS Container, A.Prepulllocation, A.PrepullCost
			FROM COST_CostDataOutput_PrePull A WITH (NOLOCK)
			inner join Yard Y WITH (NOLOCK) on  A.Prepulllocation = YardType --Y.ShortName
			where Y.YardId = @PrePullLocationKey and A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal

		if(@IsDryRun = 1 and @DryRunType in ('Dry Run (PORT)','Dry Run-Port'))
		Begin
			insert into #Prepull (Container, Prepulllocation, PrepullCost)
			SELECT top 1 @_ContainerNo AS Container, A.Prepulllocation, A.PrepullCost
			FROM COST_CostDataOutput_PrePull A WITH (NOLOCK)
			where Prepulllocation in ('Local','IE') and  A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal
		end

		insert into #StopOff (Container, StopOfflocation, StopOffCost)
		SELECT  @_ContainerNo AS Container, A.StopOfflocation, A.StopOffCost
			FROM COST_CostDataOutput_StopOff A WITH (NOLOCK)
			inner join Yard Y WITH (NOLOCK) on A.StopOfflocation =  YardType --Y.ShortName
			where Y.YardId = @StopOffLocationKey and A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal

		insert into #YardShuttleFrom (Container, YardFrom, YardCost)
		SELECT Top 1  @_ContainerNo AS Container, A.YardFrom, A.YardCost
			FROM COST_CostDataOutput_YardShuttle A WITH (NOLOCK)
			inner join Yard Y WITH (NOLOCK) on Y.YardType = A.YardFrom -- Y.ShortName like '%' + A.YardFrom + '%'
			inner join #YardKeys K on Y.YardId = K.YardID -- and Market = @Market and Terminal = @Terminal
			where A.City = @city and A.State = @State

		insert into #YardShuttleTo (Container, YardTo, YardCost)
		SELECT top 1  @_ContainerNo AS Container, A.YardTo, A.YardCost
			FROM COST_CostDataOutput_YardShuttle A WITH (NOLOCK)
			inner join Yard Y WITH (NOLOCK) on Y.YardType = A.YardTo --Y.ShortName like '%' + A.YardTo + '%'
			inner join #YardKeys K on Y.YardId = K.YardID -- and Market = @Market and Terminal = @Terminal
			where A.City = @city and A.State = @State

		select @YardShuttleCost =  convert(decimal(18,3),isnull((select YardCost from #YardShuttleFrom),0)) 
		--Select '@YardShuttleCost', @YardShuttleCost

		--///*********** ACCESSORIAL COST CALCULATION **************************
		set @AddedAccessorialsTotalCost = 0
		set @combinedString = ''
		select @combinedString = COALESCE(@combinedString + ',', ',') + value from #AccesorialItemKeys
		--select '@combinedString', @combinedString

		if(@debug = 1)
		Begin
			Select @MarketKey as marketKey,
				@combinedString as AccessorialsLineItems,
				@Terminal as Terminal,
				@YardPortType as YardPortType,
				@DriverType as DriverType
		end

		insert into #AccRercs 
		( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
			FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
			SplitPercent)
		exec CostACC_CalcAccessorialCost @MarketKey = @marketKey,
				@AccessorialsLineItems = @combinedString,
				@Terminal = @Terminal,
				@YardPort = @YardPortType,
				@TruckType = @DriverType
		
		update #AccRercs set ContainerNo = @_ContainerNo where isnull(ContainerNo ,'') = ''

		if(@debug = 1)
		Begin
			select '#AccRercs - 1', * from #AccRercs
		end

		--if((Select count(1) from #AccRercs where LineItem = 'Yard Storage- Empty' and isnull(unitcost,'0') = '0') > 0)
		--Begin
		--	update #AccRercs set UnitCost = '25' where LineItem = 'Yard Storage- Empty' and isnull(unitcost,'0') = '0'
		--	update #ItemInfo set ItemUnitCost = 25, InternalCost = 25 
		--		where itemkey = 227 and isnull(InternalCost,0) <= 0 -- Description = 'Yard Storage- Empty, Loaded'
		--End

		--update #AccRercs set UnitCost = '25' where LineItem = 'Yard Storage- Empty' and isnull(unitcost,'0') = '0'
		--update #ItemInfo set ItemUnitCost = 25, InternalCost = 25.0000 where itemkey = 227 and isnull(InternalCost,0) <= 0 

		ALter table #AccRercs add CostGroup Varchar(50)
		--select * 
		Update A Set CostGroup = drivernondrivercostdesc
		from #AccRercs A
		Inner Join #ItemInfo I ON A.LineItem = I.Description

		if(@isbobtail = 1 and (select count(1) from #iteminfo where drivernondrivercostdesc = 'BobTail') >0)
		BEGIN
			Update #AccRercs SET UnitCost = isnull(@DrayBaseValue,0)/2 
			WHERE CostGroup = 'BobTail'
		END

		update A set TotalCost = convert(decimal(18,3),UnitCost) * B.qty
		from #AccRercs A
		LEft join #ItemInfo B on A.LineItem = B.Description
		where ContainerNo = @_ContainerNo

		if(@debug = 1)
		Begin
			select '#AccRercs - 2', * from #AccRercs
		end

		select @AddedAccessorialsTotalCost = sum(totalCost)  from #AccRercs where ContainerNo = @_ContainerNo

		--///*********** END OF ACCESSORIAL COST CALCULATION **************************

		/* CHANGES FOR CENTURY AND ULS */
		DECLARE @IsCenturyULS		bit = 0
		set @IsCenturyULS = case when @Custkey in (3402, 3435,2567) then 1 else 0 end 

		IF(@IsCenturyULS = 1)
		BEGIN
			DECLARE @IsCent_PrePull					bit = 0,
					@ConsigneeToConsigneeExists		bit = 0,
					@ConsToConsLegNo				int = 0,
					@PrevFromLocation				varchar(50) = '',
					@PortToLegRouteKey				int = 0		,
					@Address1						varchar(200) = '',
					@IsDraybaseItemExists			bit = 0,
					@IsPrePullItemExists			bit = 0

			set @IsDraybaseItemExists = @IsDraybase

			select @IsPrePullItemExists = 1 
			from #ItemInfo 
			where DriverNonDriverCostDesc = 'Pre Pull'

			Select @ConsigneeToConsigneeExists = 1, @ConsToConsLegNo = LegNo 
			from #BaseInfo1_Auto_ReturnBaseInfo where FromLocation in ('Customer','Consignee','Shipper') and ToLocation in ('Customer','Consignee','Shipper')
				and ( LEft(ltrim(rtrim(Address1)),19) = '2850 E Del Amo Blvd' OR LEft(ltrim(rtrim(Address1)),13) ='3400 New Dock')

			select  @PortToLegRouteKey = RouteKey, @Address1 = Address1
			from #BaseInfo1_Auto_ReturnBaseInfo Where FromLocation = 'Port' and 
				 ( LEft(ltrim(rtrim(Address1)),19) = '2850 E Del Amo Blvd' OR LEft(ltrim(rtrim(Address1)),13) ='3400 New Dock')

			select @PrevFromLocation = FromLocation 
			from #BaseInfo1_Auto_ReturnBaseInfo where LegNo = @ConsToConsLegNo - 1

			if(isnull(@IsDraybaseItemExists ,0) = 0)
			Begin
				Set @DrayageValue = 0
				SEt @DrayBaseValue = 0

			End

			if(@debug = 1)
			Begin
				Select @IsCenturyULS			as  IsCenturyULS,
					@ConsigneeToConsigneeExists	as	ConsigneeToConsigneeExists,
					@ConsToConsLegNo				as	ConsToConsLegNo,
					@PortToLegRouteKey				as	PortToLegRouteKey,
					@Address1						as	Address1,
					@PrevFromLocation				as	PrevFromLocation,
					@IsDraybaseItemExists			as  IsDraybaseItemExists,
					@IsPrePullItemExists			as  IsPrePullItemExists
			End
			IF((isnull(@ConsToConsLegNo ,0) <> 0 and @PrevFromLocation = 'PORT') OR (@IsPrePullItemExists = 1))
			Begin
				Update A set InternalCost = 97.55
				from #ItemInfo A
				where A.DriverNonDriverCostDesc = 'Pre Pull'

				SEt @isPrePull = 1

				if((select count(1) from #Prepull where Container = @_ContainerNo) > 0)
				Begin
					update P set P.PrepullCost = 97.55,
							 PrePulllocation = @Address1
					from #prepull P
					where Container = @_ContainerNo
				End
				else
				Begin
					insert into #Prepull ( Container, PrepullCost, PrePulllocation)
					select @_ContainerNo, 97.55, @Address1
				End
			End

			Update A set InternalCost = case when isnull(InternalCost,0) = 0 then 97.55 else InternalCost end
			from #ItemInfo A
			where A.DriverNonDriverCostDesc = 'Pre Pull'

			update P set P.PrepullCost = Case when isnull(P.PrepullCost,0) = 0 then 97.55 else P.PrepullCost end,
						PrePulllocation = @Address1
			from #prepull P
			where Container = @_ContainerNo

			declare @PrePullCount int = 0
			Select  @PrePullCount=count(1) from #Prepull 
			print '-------------------'
			print @isPrePull
			print  @PrePullCount
			print '----------------------'
			--if(isnull(@PrePullCount,0) = 0)
			--Begin
			--	insert into #Prepull (Container, PrepullCost, PrePulllocation)
			--	Select @_ContainerNo, 97.55, ''
			--	SEt @isPrePull = 1
			--End

			Declare @ItemYardStopOffExists	bit = 0

			select @ItemYardStopOffExists = 1 from #ItemInfo A
			where A.DriverNonDriverCostDesc = 'Stop Off'

			if(@ItemYardStopOffExists = 1 and (Select count(1) from #StopOff where Container = @_ContainerNo) > 0)
			Begin
				update P set P.StopOffCost = 75
					from #StopOff P
					where Container = @_ContainerNo
				set @isStopOff = 1
			End
			else if (@ItemYardStopOffExists = 1 and (Select count(1) from #StopOff where Container = @_ContainerNo) = 0)
			Begin
				insert into #StopOff ( Container, StopOffCost, StopOfflocation)
					select @_ContainerNo, 75, ''
				set @isStopOff = 1
			End

			Declare @DryrunExportitemKey		int,
					@DryRunImportItemKey		int,
					@DryRunCustomerItemKey		int

			select @DryRunImportItemKey =itemkey from #ItemInfo where Description like '%Dry%Import%PORT%'
			select @DryrunExportitemKey =itemkey from #ItemInfo where Description like '%Dry%Export%PORT%'
			select @DryRunCustomerItemKey =itemkey from #ItemInfo where Description like '%Dry%CUSTOMER%'

			if(@debug = 1)
			Begin
				Select	@DryrunExportitemKey as DryrunExportitemKey,
						@DryRunImportItemKey as DryRunImportItemKey,
						@DryRunCustomerItemKey as DryRunCustomerItemKey
			End

			if(isnull(@DryrunExportitemKey,0) > 0)
			Begin
				update #ItemInfo set ItemUnitCost = 195.10
				where itemkey = @DryrunExportitemKey

				update #AccRercs set unitcost = 195.10 , TotalCost = 195.10
				where LineItem like '%Dry%Export%PORT%'
			End

			if(isnull(@DryRunImportItemKey,0) > 0)
			Begin
				update #ItemInfo set ItemUnitCost = 97.55
				where itemkey = @DryRunImportItemKey

				update #AccRercs set unitcost = 97.55, TotalCost = 97.55
				where LineItem like '%Dry%Import%PORT%'
			End

			if(isnull(@DryRunCustomerItemKey,0) > 0)
			Begin
				update #ItemInfo set ItemUnitCost = @DrayBaseValue
				where itemkey = @DryRunCustomerItemKey

				update #AccRercs set unitcost = @DrayBaseValue, TotalCost= @DrayBaseValue
				where LineItem like '%Dry%CUSTOMER%'
			End
			select @AddedAccessorialsTotalCost = sum(totalCost)  from #AccRercs where ContainerNo = @_ContainerNo

			if(@debug = 1)
			Begin
				select '#ItemInfo', * from #ItemInfo
				select '#AccRercs', * from #AccRercs
				Select 'Century', 
						@ConsigneeToConsigneeExists as ConsigneeToConsigneeExists,  
						@ConsToConsLegNo as ConsToConsLegNo,
						@PrevFromLocation as PrevFromLocation,
						@PortToLegRouteKey as PortToLegRouteKey,
				* from #BaseInfo1_Auto_ReturnBaseInfo
			END


		END
		/* END OF CHANGES FOR CENTURY AND ULS  */

		if(@isPrePull = 1 and (select count(1) from #Prepull ) = 0)
		Begin
			insert into #Prepull (Container, PrepullCost)
			Select @_ContainerNo, 99.70
		End

		if(@isStopOff = 1 and (select count(1) from #StopOff ) = 0)
		Begin
			insert into #StopOff (Container, StopOffCost)
			Select @_ContainerNo, 97.55
		End

		if(@isYardShuttle = 1 and isnull(@YardShuttleCost,0) = 0)
		Begin
			set @YardShuttleCost = 172.50
		End
		

		insert into #ContainerSummary (ContainerNo, LineItem1, LineItem1_Value, LineItem2, LineItem2_Value, LineItem3, LineItem3_Value,
				LineItem4, LineItem4_Value, LineItem5, LineItem5_Value, Total_text, Total_value, HeaderText, 
				LineItem6, LineItem6_Value, LineItem7, LineItem7_Value , LineItem8, LineItem8_Value)
		select		@_ContainerNo,'Pre-Pull', 0 , 
					'Yard Shuttle', 0, 
					'Stop Off', 0, 
					'Dray base',0,
					'Accessorial Costs',0, 
					'$$ TOTAL COST', 0, 
					'SELECTED FROM QUESTIONS',
					'DryRun',0,
					'BobTail',0,
					'FSF', 0
					
				
		declare @FsfCount int = 0
		select @FsfCount = count(1) from #ItemInfo where Container = @_ContainerNo and DriverNonDriverCostDesc = 'FSF'
		if(isnull(@FsfCount,0) > 0)
		Begin
			update #ContainerSummary set IsFSFExists = 1 where ContainerNo = @_ContainerNo
		End

		update #ContainerSummary set LineItem1_Value = isnull(Case when isnull(@isPrePull,0)=1 then (select top 1 PrePullCost from #Prepull) else 0 end,0)
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem2_Value = isnull(Case when isnull(@isYardShuttle,0)=1 then @YardShuttleCost else 0 end ,0)
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem3_Value = isnull( Case when isnull(@isStopOff,0)=1 then (select top 1 StopOffCost from #StopOff) else 0 end ,0)
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem4_Value = Case when @IsDraybase = 1 then  case when IsFSFExists = 1 then  
			isnull(@DrayageValue ,0) else isnull(@DrayBaseValue ,0) end else 0 end
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem5_Value = isnull(@AddedAccessorialsTotalCost,0)
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem6_Value =
			case when @DryRunType in( 'PrePull','Dry Run (PORT)','Dry Run-Port') then 
				(select top 1 PrePullCost from #Prepull) 
				else  isnull(@DrayBaseValueDryRun,@DrayBaseValue) end 
			where ContainerNo = @_ContainerNo and (@DryRunItemCount > 0 OR @IsDryRun = 1  )
		update #ContainerSummary set LineItem7_Value = isnull(@DrayBaseValue,0)/2
			where ContainerNo = @_ContainerNo and @IsBobtail = 1
		update #ContainerSummary set LineItem8_Value = isnull(@FSFValue,0)
			where ContainerNo = @_ContainerNo and @IsFSFExists = 1

		update #ContainerSummary set Total_value = isnull(LineItem1_Value,0) + isnull(LineItem2_Value,0) 
					+ isnull(LineItem3_Value,0) + isnull(LineItem4_Value,0) + isnull(LineItem5_Value,0) 
					+ Case when @DryRunItemCount > 0 then LineItem6_Value else 0 end 
					+ Case when @IsBobtail > 0 then LineItem7_Value else 0 end 
					+ Case when IsFSFExists  = 1 then LineItem8_Value else 0 end 
			where ContainerNo = @_ContainerNo

		

		drop table #YardShuttleKeys
		drop table #AccesorialItemKeys
		Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	END
	CLOSE _ContainerList
	DEALLOCATE _ContainerList

	

	if(@debug = 1)
	Begin
		select '#ContainerSummary', * from #ContainerSummary
	end
	
	
	
	if(@debug = 1)
	Begin
		select 'PrePull', * from #Prepull
		select 'StopOff', * from #StopOff
		Select 'Yard Shuttle From', * from #YardShuttleFrom
		Select 'Yard Shuttle To', * from #YardShuttleTo
	end 
	

	Create Table #Summary
	(
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
		LineItem6			varchar(100), -- Dry run
		LineItem6_Value		decimal(18,3), -- Dry run Value
		LineItem7			varchar(100),  -- Bobtail
		LineItem7_Value		decimal(18,3), -- Bobtail Value
		LineItem8			varchar(100),  -- FSF
		LineItem8_Value		decimal(18,3), -- FSF Value
		Total_text			varchar(100),
		Total_value			decimal(18,3)
	)

	insert into #Summary (LineItem1, LineItem1_Value, LineItem2, LineItem2_Value, LineItem3, LineItem3_Value,
				LineItem4, LineItem4_Value, LineItem5, LineItem5_Value, Total_text, Total_value, HeaderText ,
				LineItem6, LineItem6_Value,LineItem7, LineItem7_Value, LineItem8, LineItem8_Value)
	select		LineItem1, sum(isnull(LineItem1_Value,0)),
				LineItem2, sum(isnull(LineItem2_Value,0)),
				LineItem3, sum(isnull(LineItem3_Value,0)),
				LineItem4, sum(isnull(LineItem4_Value,0)),
				LineItem5, sum(isnull(LineItem5_Value,0)),
				'TOTAL $$', 0,'SUMMARY',
				LineItem6, sum(isnull(LineItem6_Value,0)),
				LineItem7, sum(isnull(LineItem7_Value,0)),
				LineItem8, sum(isnull(LineItem8_Value,0))
	From #ContainerSummary
	group by LineItem1, LineItem2, LineItem3, LineItem4, LineItem5, LineItem6, LineItem7, LineItem7, LineItem8

	update #Summary set Total_value = isnull(LineItem1_Value,0) + isnull(LineItem2_Value,0) 
				+ isnull(LineItem3_Value,0) + isnull(LineItem4_Value,0) + isnull(LineItem5_Value,0) 
				+ isnull(LineItem6_Value,0) + isnull(LineItem7_Value,0) +  isnull(LineItem8_Value,0)

	if(@debug = 1)
	Begin
		select * from #Summary
	end 

	SElect PriceGroupingKey, PriceGrouping, MarketLocationKey , Case when PriceGroupingKey = @TerminalKey then 0 else 1 end as SortOrder
	into #Terminal from PriceGrouping 
	where MarketLocationKey = @MarketKey and PriceGroupingKey = @TerminalKey

	update #ItemInfo set InternalCost = 0

	Update A set InternalCost = S.LineItem1_Value
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'Pre Pull'

	Update A set InternalCost = S.LineItem2_Value
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'Shuttle'

	Update A set InternalCost = S.LineItem3_Value
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'Stop Off'

	Update A set InternalCost = Case when @IsDraybase = 1 then 
		case when S.IsFSFExists = 1 then @DrayageValue else @DrayBaseValue  end
		else 0 end
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'Drayage'

	Update A set InternalCost = @FSFValue 
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'FSF'

	Update A set InternalCost = S.LineItem6_Value
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'Dry Run'

	Update A set InternalCost = S.LineItem7_Value
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'BobTail'

	if(@debug = 1)
	Begin
		select '#Summary',* from #Summary
	end

	/* SHOW ADDITIONS COSTS (NOT MAPPING IN ITEMS) TO ITEM LIST */
	Declare @ContainerNo			varchar(20),
		@LineItem1_Value		decimal(18,3),
		@LineItem2_Value		decimal(18,3),
		@LineItem3_Value		decimal(18,3),
		@LineItem4_Value		decimal(18,3),
		@LineItem5_Value		decimal(18,3),
		@LineItem6_Value		decimal(18,3),
		@LineItem7_Value		decimal(18,3)

	Declare _Contcursor cursor LOCAL for
	Select ContainerNo, LineItem1_Value, LineItem2_Value, LineItem3_Value, LineItem4_Value, LineItem5_Value , LineItem6_Value, LineItem7_Value
	from #ContainerSummary

	Open _Contcursor
	Fetch next from _Contcursor into @ContainerNo, @LineItem1_Value, @LineItem2_Value, @LineItem3_Value, @LineItem4_Value, @LineItem5_Value, @LineItem6_Value, @LineItem7_Value

	While @@FETCH_STATUS = 0
	BEGIN
		
		if(@isStopOff = 1)
		Begin
			if((Select count(1) from #ItemInfo where Container = @ContainerNo AND  DriverNonDriverCostDesc = 'Stop Off') = 0)
			Begin
				print  '@isStopOff'
				print @isStopOff
				INSERT INTO #ItemInfo (
					InvoiceKey, InvoiceNo, InvoicelineKey, Container, ItemKey, ItemID, Description, 
					InvoiceItemDesc, CostGrp, ItemCostGroup, 
					ItemUnitCost,  InternalCost, qty, DriverNonDriverCostDesc
				)
				SELECT @InvoiceKey, @InvoiceNo, 999, @ContainerNo, -999, 'Stop-Off', 'Stop-Off',
					'Stop-Off', '', 'Stop-Off',
					@LineItem3_Value, @LineItem3_Value, 1, 'Stop Off'
			End
		End

		if(@isPrePull = 1)
		Begin
			if((Select count(1) from #ItemInfo where Container = @ContainerNo AND  DriverNonDriverCostDesc = 'Pre Pull') = 0)
			Begin
				print  '@isPrePull'
				print @isPrePull
				INSERT INTO #ItemInfo (
					InvoiceKey, InvoiceNo, InvoicelineKey, Container, ItemKey, ItemID, Description, 
					InvoiceItemDesc, CostGrp, ItemCostGroup, 
					ItemUnitCost,  InternalCost, qty, DriverNonDriverCostDesc
				)
				SELECT @InvoiceKey, @InvoiceNo, 999, @ContainerNo, -998, 'Pre-Pull', 'Pre-Pull',
					'Pre-Pull', '', 'Pre-Pull',
					@LineItem1_Value, @LineItem1_Value, 1, 'Pre Pull'
			End
		End

		if(@isYardShuttle = 1)
		Begin
			if((Select count(1) from #ItemInfo where Container = @ContainerNo AND  DriverNonDriverCostDesc = 'Shuttle') = 0)
			Begin
				print  '@isYardShuttle'
				print @isYardShuttle
				INSERT INTO #ItemInfo (
					InvoiceKey, InvoiceNo, InvoicelineKey, Container, ItemKey, ItemID, Description, 
					InvoiceItemDesc, CostGrp, ItemCostGroup, 
					ItemUnitCost,  InternalCost, qty, DriverNonDriverCostDesc
				)
				SELECT @InvoiceKey, @InvoiceNo, 999, @ContainerNo, -997, 'Shuttle', 'Shuttle',
					'Shuttle', '', 'Shuttle',
					@LineItem2_Value, @LineItem2_Value, 1, 'Shuttle'
			End
		End

		if(@IsDryRun = 1 OR @DryRunItemCount > 0)
		Begin
			if((Select count(1) from #ItemInfo where Container = @ContainerNo AND description like '%Dry Run%') = 0)
			Begin
				print  '@IsDryRun'
				print @IsDryRun
				INSERT INTO #ItemInfo (
					InvoiceKey, InvoiceNo, InvoicelineKey, Container, ItemKey, ItemID, Description, 
					InvoiceItemDesc, CostGrp, ItemCostGroup, 
					ItemUnitCost,  InternalCost, qty, DriverNonDriverCostDesc
				)
				SELECT @InvoiceKey, @InvoiceNo, 999, @ContainerNo, -997, 'Dry Run', 'Dry Run',
					'Dry Run', '', 'Dry Run',
					@LineItem6_Value, @LineItem6_Value, 1, 'Dry Run'
			End
		End
		

		if(@IsBobTail = 1)
		Begin
			if((Select count(1) from #ItemInfo where Container = @ContainerNo AND  DriverNonDriverCostDesc = 'BobTail') = 0)
			Begin
				print  '@IsBobTail'
				print @IsBobTail
				INSERT INTO #ItemInfo (
					InvoiceKey, InvoiceNo, InvoicelineKey, Container, ItemKey, ItemID, Description, 
					InvoiceItemDesc, CostGrp, ItemCostGroup, 
					ItemUnitCost,  InternalCost, qty, DriverNonDriverCostDesc
				)
				SELECT @InvoiceKey, @InvoiceNo, 999, @ContainerNo, -996, 'BobTail', 'BobTail',
					'BobTail', '', 'BobTail',
					@LineItem7_Value, @LineItem7_Value, 1, 'BobTail'
			End
		End
		Fetch next from _Contcursor into @ContainerNo, @LineItem1_Value, @LineItem2_Value, @LineItem3_Value, @LineItem4_Value, @LineItem5_Value, @LineItem6_Value, @LineItem7_Value
	END
	CLOSE _Contcursor
	DEALLOCATE _Contcursor

	
	/* END OF SHOW ADDITIONS COSTS (NOT MAPPING IN ITEMS) TO ITEM LIST */

	Create table #LegTypeValues
	(
		LegType		varchar(50),
		LegCost		decimal(18,3)
	)

	insert into #LegTypeValues values
	('PrePull', (select top 1 PrePullCost from #Prepull)),
	('Shuttle', @YardShuttleCost),
	('Dray Base', @DrayBaseValue / 2 ),
	('Stop-Off', (select top 1 StopOffCost from #StopOff))

		select LegGroupKey, LegTypeHeaderText ,LegGroupID
		into #LegGroups
		from Cost_LegGroups Order by LegGroupKey



	Select B.ContainerNo, B.OrderDetailKey, LegName, LegOrderBy, LT.LegTypeName
	into #LegTypeList
	from  Cost_LegTypes LT 
	inner join #BaseInfo1_Auto_ReturnBaseInfo B on LT.LegTypeID = B.LegCostType
	order by  LegOrderBy

	if(@debug = 1)
	Begin
		select '#Terminal',* from #Terminal
		SELECT '#Summary',* FROM #Summary
		select '#LegTypeList',* from #LegTypeList
		select '#LegGroups',* from #LegGroups
		Select '#ItemInfo',* from #ItemInfo
	end

	

	Select @JsonOutput = (
		select PriceGroupingKey, PriceGrouping, MarketLocationKey,
 					LegList = (Select Orderdetailkey,ContainerNo, LegName, LegOrderBy, isnull(LV.LegCost,-1) as LegCost
								from #LegTypeList LL
								Left join #LegTypeValues LV on LL.LegTypeName = LV.LegType
								Order by ContainerNo, LegOrderBy
								For JSON Path
								),
					LegGroupTotalCost = (Select sum( isnull(LV.LegCost,-1))
								from #LegTypeList LL
								Left join #LegTypeValues LV on LL.LegTypeName = LV.LegType
								),
					AddedAccessorials = (select A.ItemKey, A.itemID, LineItem, Per, B.UnitCost , B.TotalCost
										from #ItemInfo A
										LEft join #AccRercs B on A.Description = B.LineItem and A.Container = b.ContainerNo
										For JSON Path),
					AddedAccessorialsTotalCost = @AddedAccessorialsTotalCost,
					Summary = (Select LineItem1, isnull(LineItem1_Value,0) as LineItem1_Value, 
								LineItem2, isnull(LineItem2_Value,0) as LineItem2_Value, 
								LineItem3, isnull(LineItem3_Value,0) as LineItem3_Value,
								LineItem4, isnull(LineItem4_Value,0) as LineItem4_Value, 
								LineItem5, isnull(LineItem5_Value,0) as LineItem5_Value, 
								LineItem6, isnull(LineItem6_Value,0) as LineItem6_Value, 
								LineItem7, isnull(LineItem7_Value,0) as LineItem7_Value, 
								LineItem8, isnull(LineItem8_Value,0) as LineItem8_Value, 
								Total_text, Total_value, HeaderText 
								from #Summary
								For JSON PATH),
					ContainerSummary = (
						select ContainerNo, LineItem1, isnull(LineItem1_Value,0) as LineItem1_Value, 
								LineItem2, isnull(LineItem2_Value,0) as LineItem2_Value, 
								LineItem3, isnull(LineItem3_Value,0) as LineItem3_Value,
								LineItem4, isnull(LineItem4_Value,0) as LineItem4_Value, 
								LineItem5, isnull(LineItem5_Value,0) as LineItem5_Value, 
								LineItem6, isnull(LineItem6_Value,0) as LineItem6_Value, 
								LineItem7, isnull(LineItem7_Value,0) as LineItem7_Value, 
								LineItem8, isnull(LineItem8_Value,0) as LineItem8_Value, 
								Total_text, Total_value, HeaderText , IsFSFExists
						from #ContainerSummary
						For JSON PATH
					),
					LineItemDetails =  (
						Select ItemContainer = (Select distinct Container,
							ContainerItemList = (select 'Item Cost Breakup' as Heading,  A.ItemKey,
								isnull(LineItem, A.Description)  as LineItem, B.Per, isnull(b.UnitCost,A.InternalCost) UnitCost , 
								convert(int, isnull(A.qty,0)) as qty,
								convert(decimal(18,3), isnull(b.UnitCost,A.InternalCost)) * 
									Case when A.DriverNonDriverCostDesc = 'FSF' then CEILING(isnull(A.qty,0)) else isnull(A.qty,0) end as TotalCost
								from #ItemInfo A
								Left join #AccRercs B on A.Description = B.LineItem and A.Container = b.ContainerNo
								where A.Container = II.Container
								for JSON PATH
								) 
						from #ItemInfo II
						For JSON PATH)
						
					),
					ContainerDetails = (
						select distinct ContainerNo , 
						LegDetails = (select LegId, 
									FromLoc =case when FromLocation = 'Yard' then ShortName 
												when FromLocation = 'Port' then ShippingPortID
												When FromLocation in ('Consignee','Customer','Shipper') then  City End,
									ToLoc =case when ToLocation = 'Yard' then ShortName 
												when ToLocation = 'Port' then ShippingPortID
												When ToLocation in ('Consignee','Customer','Shipper') then  City End,
									TruckType, 
									LegCostType,
									LegTypeName,
									convert(bit, isnull(IsDryRun,0)) IsDryRun,
									IsBobtail
									from #BaseInfo1_Auto_ReturnBaseInfo BI where ContainerNo = B.ContainerNo
									for JSON PATH)
						From #BaseInfo1_Auto_ReturnBaseInfo B
						for JSON PATH
					),
					Params = (
						Select @Market as Market,
								@DriverType as TruckType,
								@Terminal as Terminal,
								@PrePullLocation as PrePullLocation,
								@StopOffLocation as StopOffLocation,
								@YardPortType as YardPortType,
								YardShuttleFrom = isnull( (Select top 1 YardFrom from #YardShuttleFrom),''),
								YardShuttleTo = isnull((Select top 1 YardTo from #YardShuttleTo),''),
								@OrderType as OrderType,
								@City as City,
								@State as State
						for JSON PATH
					),
					Reasons = (
						Select DrayBaseReason = @Reason,
							DryRunReason = @DryRunReason
						for JSON PATH
					)
		from #Terminal
		--where PriceGroupingKey = @TerminalKey
		order by SortOrder, PriceGrouping
		For JSON PATH
		)

	If @Status = 1
	Begin
		Set @Reason = 'SUCCESS'
	End

	DROP TABLE #AccRercs
	DROP TABLE #LegTypeValues
	DROP TABLE #YardKeys
--	DROP TABLE #AccesorialItemKeys
	DROP TABLE #Summary
	DROP TABLE #BaseInfo1_Auto_ReturnBaseInfo
	DROP TABLE #ItemInfo
	DROP TABLE #Terminal
	DROP TABLE #LegTypeList
	DROP TABLE #Prepull
	DROP TABLE #StopOff
	DROP TABLE #YardShuttleFrom
	DROP TABLE #YardShuttleTo
	DROP TABLE #ContainerSummary
	DROP TABLE #ContainerBase
	DROP TABLE #LegGroups

END
