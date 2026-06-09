

/*
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '23865',   @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(500) = '' 
	EXEC Cost_OutputByInvoice @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT
	SELECT @JsonOutput, @Status, @Reason
*/

/*
	DECLARE @InvoiceKey int =72098, @InvoiceNo Varchar(50) = '',   @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(500) = '' 
	EXEC Cost_OutputByInvoice @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT
	SELECT @JsonOutput, @Status, @Reason
*/
CREATE proc [dbo].[Cost_OutputByInvoice_Old]
(
	@InvoiceKey		int	= 0,
	@InvoiceNo		varchar(50) = '',
	@JsonOutput		nvarchar(max) ='' OUTPUT,
	@Status			bit = 0 output,
	@Reason			varchar(500) = '' output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

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
		Total_text			varchar(100),
		Total_value			decimal(18,3)
	)

	select convert(varchar(50),'') as ContainerNo, RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent 
	into #AccRercs
	from COSTACC_FinalDataOutput where 1=0
	alter table #AccRercs add TotalCost Decimal(18,3) 

	--select '#AccRercs',* from #AccRercs

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
		@combinedString varchar(max) = ''
	
	--select * from COSTACC_FinalDataOutput
	
	--// MARKET
	select @MarketKey = isnull(OH.MarketLocationKey, C.MarketLocationKey), @Market = ml.MarketLocation,
		@OrderType = OT.OrderType
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
		select @Market = MarketLocation from MarketLocation where MarketLocationKey = @MarketKey
	End
	
	--/// TERMINAL
	Select @TerminalKey = case when @MarketKey = 2 then 6 else 4 end
	select @Terminal = PriceGrouping from PriceGrouping where PriceGroupingKey = @TerminalKey

	--// YARD, PORT AND CITY, STATE, ZIPCODE
	select IH.Invoicekey, IH.InvoiceNo, IH.InvoiceDate,OD.OrderDetailKey,
		OD.ContainerNo, RT.Routekey, L.LegID, L.FromLocation, L.ToLocation , 
		RT.SourceAddrKey, Rt.DestinationAddrKey, Y.ShortName, Y.YardType, Y.yardid,
		P.ShippingPortKey, P.ShippingPortID,
		A.City, A.State, A.ZipCode, D.DriverKey, D.driverID, TT.TruckType, 
		L.LegCostType, LT.LegTypeName
	INTO #BaseInfo
	from (Select distinct InvoiceKey, orderdetailkey, Container from InvoiceDetail where InvoiceKey = @InvoiceKey) ID 
	inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
	inner join OrderDetail OD on ID.OrderDetailKey = OD.OrderDetailKey
	inner join routes RT on ID.OrderDetailKey = RT.OrderDetailKey and OD.ContainerNo = ID.Container
	inner join Leg L on RT.LegKey = L.LegKey 
	LEft join Yard Y on case when L.FromLocation  = 'Yard' then Rt.SourceAddrKey
		When L.ToLocation = 'Yard' then Rt.DestinationAddrKey else 0 end = Y.AddrKey
	LEft join ShippingPort P on case when L.FromLocation  = 'Port' then Rt.SourceAddrKey
		When L.ToLocation = 'Port' then Rt.DestinationAddrKey else 0 end = P.AddrKey
	LEft join Address A on case when L.FromLocation  in ('Shipper','Customer', 'Consignee') then Rt.SourceAddrKey
		When L.ToLocation in ('Shipper','Customer', 'Consignee') then Rt.DestinationAddrKey else 0 end = A.AddrKey
	LEFT join Driver D on RT.DriverKey = D.DriverKey
	LEft join TruckType TT on D.TruckTypeKey = TT.TruckTypeKey
	LEFT Join Cost_LegTypes LT on L.LegCostType = LT.LegTypeID
	order by ContainerNo, RouteKey, Rt.LegNo 

	--Select * from #BaseInfo

	

	--// Accessorial Items Details
	select ih.InvoiceKey, IH.InvoiceNo, ID.InvoicelineKey,ID.Container, ID.ItemKey,I.ItemID, I.Description, 
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, 
		sum(I.UnitCost) as ItemUnitCost, sum(I.InternalCost) InternalCost,sum( ID.qty) qty, C.DriverNonDriverCostDesc
	into #ItemInfo
	from InvoiceDetail  ID 
	inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
	INNER JOIN ITEM i ON id.ItemKey = I.ItemKey
	inner join  DriverNonDriverCostItems C on I.CostGrp = C.DriverNonDriverCostKey
	where ID.InvoiceKey = @InvoiceKey and ID.Container is not null
	group by ih.InvoiceKey, IH.InvoiceNo, ID.InvoicelineKey,ID.Container, ID.ItemKey,I.ItemID, I.Description, 
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, C.DriverNonDriverCostDesc
	
	--SELECT * FROM #ItemInfo

	select distinct OrderdetailKey, ContainerNo into #ContainerBase from  #BaseInfo

	Declare @_OrderdetailKey int,@_ContainerNo varchar(50)
	declare   _ContainerList Cursor Local
	For Select OrderdetailKey, ContainerNo from #ContainerBase

	Open _ContainerList
	Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	WHILE  @@FETCH_STATUS = 0
	BEGIN
		PRINT '------------------'
		PRINT @_ContainerNo

		Select top 1 	@City = City, 
			@State = State,
			@ZipCode = ZipCode
		From #BaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND  City is not null

		select top 1 @DriverType = TruckType
		from #BaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND TruckType is not null and 
		Case when @OrderType = 'Import' then ToLocation else FromLocation end in ('Consignee','Customer','Shipper')

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

		select distinct Yardid as value into #YardShuttleKeys from #BaseInfo 
		where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND FromLocation = 'Yard' and ToLocation = 'Yard'

		--select * from #ItemInfo WHERE Container = @_ContainerNo

		select distinct Description as value into #AccesorialItemKeys from #ItemInfo 
		WHERE Container = @_ContainerNo and DriverNonDriverCostDesc = 'Accessorial'
		--select '#AccesorialItemKeys', * from #AccesorialItemKeys

		Declare @RecCount int = 0
		select @RecCount = count(1) from COST_CostDataOutput where City = @city and State = @State and 
			Market = @Market and Terminal = @Terminal and DriverType = @DriverType

		if(@RecCount = 0)
		Begin
			Set @Status = 0
			set @Reason = 'Records not found in Cost Database for the combination of City:' + isnull(@City,'') + ', State:' + isnull(@State,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') + ', DriverType:' + isnull(@DriverType,'')
			print @Reason
		End

		if((Select count(1) from #BaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND LegCostType = '1')>0)
		Begin
			SEt @isPrePull = 1
			SElect @PrePullYardPortType = YardType, @PrePullLocationKey = YardId, @PrePullLocation = ShortName 
				from #BaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND LegCostType = '1'
			print '@PrePullYardPortType'
			print @PrePullYardPortType
		End

		if((Select count(1) from #BaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND LegCostType = '4a')>0)
		Begin
			SEt @isStopOff  = 1
			SElect @StopOffYardPortType = YardType, @StopOffLocationKey = YardId, @StopOffLocation = ShortName 
			from #BaseInfo where ORDERDETAILKEY = @_OrderdetailKey AND ContainerNo = @_ContainerNo AND LegCostType = '4a'
			print '@StopOffYardPortType'
			print @StopOffYardPortType
		End
		Declare @DrayageValue numeric(18,2), @FSFValue numeric(18,2)

		select top 1 @DrayBaseValue = Cost + fsf  
			from COST_CostDataOutput 
			where city = @city and State = @State and DriverType =@DriverType 
				and Terminal = @Terminal and Market = @Market and YardPortType = @YardPortType
			order by EffectiveDate desc
		select top 1 @DrayageValue = Cost  
			from COST_CostDataOutput 
			where city = @city and State = @State and DriverType =@DriverType 
				and Terminal = @Terminal and Market = @Market and YardPortType = @YardPortType
			order by EffectiveDate desc
		select top 1 @FSFValue = fsf  
			from COST_CostDataOutput 
			where city = @city and State = @State and DriverType =@DriverType 
				and Terminal = @Terminal and Market = @Market and YardPortType = @YardPortType
			order by EffectiveDate desc
		print '@DrayBaseValue'
		print @DrayBaseValue
		--select @DrayBaseValue

		TRUNCATE TABLE #YardKeys
		
		--select '#YardShuttleKeys', * from #YardShuttleKeys
		

		if((Select count(1) from #YardShuttleKeys) > 0)
		Begin
			Insert into #YardKeys
			select Distinct Yardid , YardType
			from #YardShuttleKeys A
			inner join Yard Y on A.Value = Y.YardId
		
			set @isYardShuttle = 1
		End
		
	
		print '-----------------------'
		print '@PrePullLocationKey'
		print @PrePullLocationKey

		print '------------------'
		print '@StopOffLocationKey'
		print @StopOffLocationKey

		--select '#YardKeys',* from #YardKeys

		insert into #Prepull (Container, Prepulllocation, PrepullCost)
		SELECT @_ContainerNo AS Container, A.Prepulllocation, A.PrepullCost
			FROM COST_CostDataOutput_PrePull A
			inner join Yard Y on  A.Prepulllocation = YardType --Y.ShortName
			where Y.YardId = @PrePullLocationKey and A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal

		insert into #StopOff (Container, StopOfflocation, StopOffCost)
		SELECT  @_ContainerNo AS Container, A.StopOfflocation, A.StopOffCost
			FROM COST_CostDataOutput_StopOff A
			inner join Yard Y on A.StopOfflocation =  YardType --Y.ShortName
			where Y.YardId = @StopOffLocationKey and A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal

		insert into #YardShuttleFrom (Container, YardFrom, YardCost)
		SELECT Top 1  @_ContainerNo AS Container, A.YardFrom, A.YardCost
			FROM COST_CostDataOutput_YardShuttle A
			inner join Yard Y on Y.YardType = A.YardFrom -- Y.ShortName like '%' + A.YardFrom + '%'
			inner join #YardKeys K on Y.YardId = K.YardID -- and Market = @Market and Terminal = @Terminal
			where A.City = @city and A.State = @State

		insert into #YardShuttleTo (Container, YardTo, YardCost)
		SELECT top 1  @_ContainerNo AS Container, A.YardTo, A.YardCost
			FROM COST_CostDataOutput_YardShuttle A
			inner join Yard Y on Y.YardType = A.YardTo --Y.ShortName like '%' + A.YardTo + '%'
			inner join #YardKeys K on Y.YardId = K.YardID -- and Market = @Market and Terminal = @Terminal
			where A.City = @city and A.State = @State

		select @YardShuttleCost =  convert(decimal(18,3),isnull((select YardCost from #YardShuttleFrom),0)) 
		--Select '@YardShuttleCost', @YardShuttleCost

		--///*********** ACCESSORIAL COST CALCULATION **************************
		set @AddedAccessorialsTotalCost = 0
		set @combinedString = ''
		select @combinedString = COALESCE(@combinedString + ',', ',') + value from #AccesorialItemKeys
		--select '@combinedString', @combinedString

		--Select @MarketKey as marketKey,
		--		@combinedString as AccessorialsLineItems,
		--		@Terminal as Terminal,
		--		@YardPortType as YardPortType,
		--		@DriverType as DriverType
		

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

		update A set TotalCost = convert(decimal(18,3),UnitCost) * B.qty
		from #AccRercs A
		LEft join #ItemInfo B on A.LineItem = B.Description
		where ContainerNo = @_ContainerNo

		--select '#AccRercs', * from #AccRercs
		select @AddedAccessorialsTotalCost = sum(totalCost)  from #AccRercs where ContainerNo = @_ContainerNo

		--///*********** ACCESSORIAL COST CALCULATION **************************

		insert into #ContainerSummary (ContainerNo, LineItem1, LineItem1_Value, LineItem2, LineItem2_Value, LineItem3, LineItem3_Value,
				LineItem4, LineItem4_Value, LineItem5, LineItem5_Value, Total_text, Total_value, HeaderText )
		select		@_ContainerNo,'Pre-Pull', 0 , 
					'Yard Shuttle', 0, 
					'Stop Off', 0, 
					'Dray base',0,
					'Accessorial Costs',0, 
					'$$ TOTAL COST', 0, 
					'SELECTED FROM QUESTIONS'

		update #ContainerSummary set LineItem1_Value = Case when isnull(@isPrePull,0)=1 then (select top 1 PrePullCost from #Prepull) else 0 end
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem2_Value = Case when isnull(@isYardShuttle,0)=1 then @YardShuttleCost else 0 end 
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem3_Value = Case when isnull(@isStopOff,0)=1 then (select top 1 StopOffCost from #StopOff) else 0 end 
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem4_Value = @DrayBaseValue 
			where ContainerNo = @_ContainerNo
		update #ContainerSummary set LineItem5_Value = @AddedAccessorialsTotalCost
			where ContainerNo = @_ContainerNo

		update #ContainerSummary set Total_value = isnull(LineItem1_Value,0) + isnull(LineItem2_Value,0) 
					+ isnull(LineItem3_Value,0) + isnull(LineItem4_Value,0) + isnull(LineItem5_Value,0)
			where ContainerNo = @_ContainerNo

		drop table #YardShuttleKeys
		drop table #AccesorialItemKeys
		Fetch next from _containerList into @_OrderdetailKey, @_ContainerNo
	END
	CLOSE _ContainerList
	DEALLOCATE _ContainerList

	--select '#ContainerSummary', * from #ContainerSummary

	
	
	

	--select 'PrePull', * from #Prepull
	--select 'StopOff', * from #StopOff
	--Select 'Yard Shuttle From', * from #YardShuttleFrom
	--Select 'Yard Shuttle To', * from #YardShuttleTo

	

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
		Total_text			varchar(100),
		Total_value			decimal(18,3)
	)

	insert into #Summary (LineItem1, LineItem1_Value, LineItem2, LineItem2_Value, LineItem3, LineItem3_Value,
				LineItem4, LineItem4_Value, LineItem5, LineItem5_Value, Total_text, Total_value, HeaderText )
	select		LineItem1, sum(isnull(LineItem1_Value,0)),
				LineItem2, sum(isnull(LineItem2_Value,0)),
				LineItem3, sum(isnull(LineItem3_Value,0)),
				LineItem4, sum(isnull(LineItem4_Value,0)),
				LineItem5, sum(isnull(LineItem5_Value,0)),
				'TOTAL $$', 0,'SUMMARY'
	From #ContainerSummary
	group by LineItem1, LineItem2, LineItem3, LineItem4, LineItem5

	update #Summary set Total_value = isnull(LineItem1_Value,0) + isnull(LineItem2_Value,0) 
				+ isnull(LineItem3_Value,0) + isnull(LineItem4_Value,0) + isnull(LineItem5_Value,0)

	
	--select * from #Summary

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

	Update A set InternalCost = @DrayageValue
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'Drayage'

	Update A set InternalCost = @FSFValue 
	from #ItemInfo A
	left join #ContainerSummary S on A.Container = S.ContainerNo
	where A.DriverNonDriverCostDesc = 'FSF'

	--select * from #Summary

	/* SHOW ADDITIONS COSTS (NOT MAPPING IN ITEMS) TO ITEM LIST */
	Declare @ContainerNo			varchar(20),
		@LineItem1_Value		decimal(18,3),
		@LineItem2_Value		decimal(18,3),
		@LineItem3_Value		decimal(18,3),
		@LineItem4_Value		decimal(18,3),
		@LineItem5_Value		decimal(18,3)

	Declare _Contcursor cursor LOCAL for
	Select ContainerNo, LineItem1_Value, LineItem2_Value, LineItem3_Value, LineItem4_Value, LineItem5_Value from #ContainerSummary

	Open _Contcursor
	Fetch next from _Contcursor into @ContainerNo, @LineItem1_Value, @LineItem2_Value, @LineItem3_Value, @LineItem4_Value, @LineItem5_Value

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

		
		Fetch next from _Contcursor into @ContainerNo, @LineItem1_Value, @LineItem2_Value, @LineItem3_Value, @LineItem4_Value, @LineItem5_Value
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

	--select LegGroupKey, LegTypeHeaderText ,LegGroupID
	--into #LegGroups
	--from Cost_LegGroups Order by LegGroupKey
	
	Select B.ContainerNo, B.OrderDetailKey, LegName, LegOrderBy, LT.LegTypeName
	into #LegTypeList
	from  Cost_LegTypes LT 
	inner join #BaseInfo B on LT.LegTypeID = B.LegCostType
	order by  LegOrderBy

	--select * from #Terminal
	--SELECT * FROM #Summary
	--select * from #LegTypeList
	--select * from #LegGroups
	--Select * from #ItemInfo

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
										LEft join #AccRercs B on A.Description = B.LineItem
										For JSON Path),
					AddedAccessorialsTotalCost = @AddedAccessorialsTotalCost,
					Summary = (Select LineItem1, isnull(LineItem1_Value,0) as LineItem1_Value, 
								LineItem2, isnull(LineItem2_Value,0) as LineItem2_Value, 
								LineItem3, isnull(LineItem3_Value,0) as LineItem3_Value,
								LineItem4, isnull(LineItem4_Value,0) as LineItem4_Value, 
								LineItem5, isnull(LineItem5_Value,0) as LineItem5_Value, 
								Total_text, Total_value, HeaderText 
								from #Summary
								For JSON PATH),
					ContainerSummary = (
						select ContainerNo, LineItem1, isnull(LineItem1_Value,0) as LineItem1_Value, 
								LineItem2, isnull(LineItem2_Value,0) as LineItem2_Value, 
								LineItem3, isnull(LineItem3_Value,0) as LineItem3_Value,
								LineItem4, isnull(LineItem4_Value,0) as LineItem4_Value, 
								LineItem5, isnull(LineItem5_Value,0) as LineItem5_Value, 
								Total_text, Total_value, HeaderText 
						from #ContainerSummary
						For JSON PATH
					),
					LineItemDetails =  (
						Select ItemContainer = (Select distinct Container,
							ContainerItemList = (select 'Item Cost Breakup' as Heading,  A.ItemKey,
								isnull(LineItem, A.ItemID)  as LineItem, B.Per, isnull(b.UnitCost,A.InternalCost) UnitCost , 
								convert(int, isnull(A.qty,0)) as qty,
								convert(decimal(18,3), isnull(b.UnitCost,A.InternalCost)) * isnull(A.qty,0) as TotalCost
								from #ItemInfo A
								Left join #AccRercs B on A.Description = B.LineItem
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
									LegTypeName
									from #BaseInfo BI where ContainerNo = B.ContainerNo
									for JSON PATH)
						From #BaseInfo B
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
								@OrderType as OrderType
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

	drop table #AccRercs
	drop table #LegTypeValues
	drop table #YardKeys
--	Drop table #AccesorialItemKeys
	DROP TABLE #Summary
	drop table #BaseInfo
	drop table #ItemInfo
	drop table #Terminal
	drop table #LegTypeList
	drop table #Prepull
	drop table #StopOff
	drop table #YardShuttleFrom
	drop table #YardShuttleTo
	drop table #ContainerSummary
END
