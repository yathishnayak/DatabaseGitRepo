

/*
	DECLARE @InvoiceNo		varchar(50) = '', @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(100) = '' 
	SET @InvoiceNo		 = '22820'
	EXEC Cost_OutputEstimateByInvoice @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT
	SELECT @JsonOutput, @Status, @Reason
*/

CREATE proc [dbo].[Cost_OutputEstimateByInvoice]
(
	@InvoiceNo		varchar(50) = '',
	@JsonOutput		nvarchar(max) ='' OUTPUT,
	@Status			bit = 0 output,
	@Reason			varchar(500) = '' output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	if( ISNULL(@InvoiceNo,'') = '')
	BEGIN
		set @Status = 0
		set @Reason = 'Invoice Parameters not received'
		return
	END
	SEt @Status = 1
	Declare
		@InvoiceKey						int,
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
		@OrderType						varchar(50)
	
	Select @InvoiceKey = InvoiceKey
	from InvoiceHeader IH WITH (NOLOCK)
	WHERE InvoiceNo = @InvoiceNo

	--// MARKET
	select @MarketKey = isnull(OH.MarketLocationKey, C.MarketLocationKey), @Market = ml.MarketLocation,
		@OrderType = OT.OrderType
	from InvoiceHeader IH WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
	inner join Customer C WITH (NOLOCK) on ih.CustKey = c.CustKey
	inner join MarketLocation ML WITH (NOLOCK) ON isnull(OH.MarketLocationKey, C.MarketLocationKey) = ml.MarketLocationKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where IH.InvoiceKey = @InvoiceKey

	print @OrderType
	print @MarketKey
	print @Market
	
	--/// TERMINAL
	Select @TerminalKey = case when @MarketKey = 2 then 6 else 4 end
	select @Terminal = PriceGrouping from PriceGrouping where PriceGroupingKey = @TerminalKey

	--// YARD, PORT AND CITY, STATE, ZIPCODE
	select IH.Invoicekey, IH.InvoiceNo, IH.InvoiceDate,
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
	LEft join Address A on case when L.FromLocation  = 'Consignee' then Rt.SourceAddrKey
		When L.ToLocation = 'Consignee' then Rt.DestinationAddrKey else 0 end = A.AddrKey
	LEFT join Driver D on RT.DriverKey = D.DriverKey
	LEft join TruckType TT on D.TruckTypeKey = TT.TruckTypeKey
	LEFT Join Cost_LegTypes LT on L.LegCostType = LT.LegTypeID
	order by ContainerNo, RouteKey, Rt.LegNo 

	Select * from #BaseInfo

	Select top 1 	@City = City, 
			@State = State,
			@ZipCode = ZipCode
	From #BaseInfo where City is not null
	print '@City'
	print @city
	print '@State'
	print @state

	select top 1 @DriverType = TruckType
	from #BaseInfo where TruckType is not null and 
	Case when @OrderType = 'Import' then ToLocation else FromLocation end in ('Consignee','Customer','Shipper')

	print '@TruckType'
	print @DriverType

	Select top 1	@YardPortType = Yardtype
	From #BaseInfo Where Yardtype is not null

	set @YardPortType = isnull(@YardPortType,'Local')

	print '@TErminal'
	print @Terminal

	print '@YardPortType'
	print @YardPortType

	--// Accessorial Items Details
	select ih.InvoiceKey, IH.InvoiceNo, ID.InvoicelineKey,ID.Container, ID.ItemKey,I.ItemID, I.Description, 
		I.InvoiceItemDesc, I.CostGrp, I.ItemCostGroup, I.UnitCost as ItemUnitCost, I.InternalCost, ID.qty
	into #ItemInfo
	from InvoiceDetail  ID 
	inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
	INNER JOIN ITEM i ON id.ItemKey = I.ItemKey
	where ID.InvoiceKey = @InvoiceKey and ID.Container is not null

	select * from #ItemInfo

	select distinct Description as value into #AccesorialItemKeys from #ItemInfo
	select 0 as value into #YardShuttleKeys where 1 = 0

	Select @DriverType = TruckType from TruckType where TruckTypeKey = @DriverTypeKey

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

	if((Select count(1) from #BaseInfo where LegCostType = '1')>0)
	Begin
		SEt @isPrePull = 1
		SElect @PrePullYardPortType = YardType, @PrePullLocationKey = YardId, @PrePullLocation = YardType from #BaseInfo where LegCostType = '1'
		print '@PrePullYardPortType'
		print @PrePullYardPortType
	End

	if((Select count(1) from #BaseInfo where LegCostType = '1b')>0)
	Begin
		SEt @isYardShuttle = 1
		--SElect @PrePullYardPortType = YardType, @PrePullLocationKey = YardId, @PrePullLocation = YardType from #BaseInfo where LegCostType = '1'
		--print '@PrePullYardPortType'
		--print @PrePullYardPortType
		insert into #YardShuttleKeys
		select distinct Yardid as value  from #BaseInfo where FromLocation = 'Yard' and ToLocation = 'Yard'
	End

	if((Select count(1) from #BaseInfo where LegCostType = '4a')>0)
	Begin
		SEt @isStopOff  = 1
		SElect @StopOffYardPortType = YardType, @StopOffLocationKey = YardId, @StopOffLocation = YardType from #BaseInfo where LegCostType = '4a'
		print '@StopOffYardPortType'
		print @StopOffYardPortType
	End

	select top 1 @DrayBaseValue = Cost + fsf  
		from COST_CostDataOutput 
		where city = @city and State = @State and DriverType =@DriverType 
			and Terminal = @Terminal and Market = @Market and YardPortType = @YardPortType
		order by convert(datetime, (CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) END)) desc
	print '@DrayBaseValue'
	print @DrayBaseValue
	--select @DrayBaseValue
	
	
	select '#YardShuttleKeys', * from #YardShuttleKeys
	create table #YardKeys
	(
		YardID		int, 
		YardType	varchar(10)
	)

	if((Select count(1) from #YardShuttleKeys) > 0)
	Begin
		Insert into #YardKeys
		select Distinct Yardid , YardType
		from #YardShuttleKeys A
		inner join Yard Y on A.Value = Y.YardId
		
	End
	--select * from #YardKeys
	--select * from #AccesorialItemKeys
	-- Setup Defaults where not selected
	--SEt Pre-Pull Location
	if(isnull(@isPrePull,0) = 0)
	Begin
		if(@MarketKey = 2)
		begin
			--select @PrePullLocationKey = YardId, @PrePullLocation = ShortName from Yard where ShortName = 'Reyes'
			select @PrePullLocationKey = YardId, @PrePullLocation = YardType from Yard where ShortName = 'Reyes'
		End
		else IF(@MarketKey = 3)
		Begin
			select @PrePullLocationKey = YardId, @PrePullLocation = ShortName from Yard where ShortName = 'Reyes'
			select @PrePullLocationKey = YardId, @PrePullLocation = YardType from Yard where ShortName = 'JCT-Fontana'
		End
		else
		Begin
			select @PrePullLocationKey = YardId, @PrePullLocation = ShortName from Yard where ShortName = 'Reyes'
			select @PrePullLocationKey = YardId, @PrePullLocation = YardType from Yard where ShortName = 'Reyes'
		End
	End
	print '-----------------------'
	print '@PrePullLocationKey'
	print @PrePullLocationKey

	--SEt the StopOff Location
	if(isnull(@isStopOff,0) = 0)
	Begin
		if(@MarketKey = 2)
		begin
			--select @StopOffLocationKey = YardId, @StopOffLocation = ShortName from Yard where ShortName = 'Reyes'
			select @StopOffLocationKey = YardId, @StopOffLocation = YardType from Yard where ShortName = 'Reyes'
		End
		else IF(@MarketKey = 3)
		Begin
			--select @StopOffLocationKey = YardId, @StopOffLocation = ShortName from Yard where ShortName = 'Reyes'
			select @StopOffLocationKey = YardId, @StopOffLocation = Yardtype from Yard where ShortName = 'Reyes'
		End
		else
		Begin
			--select @StopOffLocationKey = YardId, @StopOffLocation = ShortName from Yard where ShortName = 'Reyes'
			select @StopOffLocationKey = YardId, @StopOffLocation = YardType from Yard where ShortName = 'Reyes'
		End
	End

	print '------------------'
	print '@StopOffLocationKey'
	print @StopOffLocationKey

	--SEt the Yard Shuttle Location
	if(isnull(@isYardShuttle,0) = 0 OR (select count(1) from #YardShuttleKeys) = 0)
	Begin
		insert into #YardKeys
		select  YardId , YardType from Yard where ShortName = 'Reyes'
	End

	SELECT A.*
		into #Prepull
		FROM COST_CostDataOutput_PrePull A
		inner join Yard Y on  A.Prepulllocation = Y.YardType
		where Y.YardId = @PrePullLocationKey and A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal

	SELECT A.*
		into #StopOff
		FROM COST_CostDataOutput_StopOff A
		inner join Yard Y on A.StopOfflocation =  Y.YardType
		where Y.YardId = @StopOffLocationKey and A.City = @city and A.State = @State and Market = @Market and Terminal = @Terminal


	SELECT Top 1 A.*
		into #YardShuttleFrom
		FROM COST_CostDataOutput_YardShuttle A
		inner join Yard Y on   Y.YardType = A.YardFrom
		inner join #YardKeys K on Y.YardId = K.YardID -- and Market = @Market and Terminal = @Terminal
		where A.City = @city and A.State = @State

	SELECT top 1 A.*
		into #YardShuttleTo
		FROM COST_CostDataOutput_YardShuttle A
		inner join Yard Y on Y.Yardtype  = A.YardTo
		inner join #YardKeys K on Y.YardId = K.YardID -- and Market = @Market and Terminal = @Terminal
		where A.City = @city and A.State = @State

	select 'PrePull', * from #Prepull
	select 'StopOff', * from #StopOff
	Select 'Yard Shuttle From', * from #YardShuttleFrom
	Select 'Yard Shuttle To', * from #YardShuttleTo

	select @YardShuttleCost =  convert(decimal(18,3),isnull((select YardCost from #YardShuttleFrom),0)) --+ isnull((select YardCost from #YardShuttleTo),0) )
	--Select '@YardShuttleCost', @YardShuttleCost

	--///*********** ACCESSORIAL COST CALCULATION **************************
	--select B.LineItem, B.Per, b.UnitCost , convert(decimal(18,3),b.UnitCost) as TotalCost
	--into #Accessorials
	--from #AccesorialItemKeys A
	--inner join COSTACC_FinalDataOutput B on A.Value = B.LineItem
	--inner join MarketLocation M on B.Market = M.MarketLocation and M.MarketLocationKey = @MarketKey
	--select  '@AccessorialsLineItems', @AccessorialsLineItems
	declare @combinedString varchar(max)
	select @combinedString = COALESCE(@combinedString + ', ', '') + value from #AccesorialItemKeys
	--select '@combinedString', @combinedString

	select RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent 
	into #AccRercs
	from COSTACC_FinalDataOutput where 1=0

	insert into #AccRercs 
	( RecordSL, LineItem, Market, Terminal, TruckType, YardPort, [Zone], [Group], 
		FixVsNonFix, Per, UnitCost, EffectiveDate, EffectiveDateFrom, FreePer,
		SplitPercent)
	exec CostACC_CalcAccessorialCost @MarketKey = @marketKey,
			@AccessorialsLineItems = @combinedString,
			@Terminal = @Terminal,
			@YardPort = @YardPortType,
			@TruckType = @DriverType

	alter table #AccRercs add TotalCost Decimal(18,3) 
	update #AccRercs set TotalCost = convert(decimal(18,3),UnitCost)  * isnull(B.qty,0)
	from #AccRercs A
	LEft join #ItemInfo B on A.LineItem = B.Description 
	--select * from #AccRercs
	select @AddedAccessorialsTotalCost = sum(totalCost)  from #AccRercs
	--///*********** ACCESSORIAL COST CALCULATION **************************

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
	select		'Pre-Pull', 0 , 
				'Yard Shuttle', 0, 
				'Stop Off', 0, 
				'Dray base',0,
				'Accessorial Item Cost',0, 
				'$$ TOTAL COST', 0, 
				'SELECTED FROM QUESTIONS'

	update #Summary set LineItem1_Value = Case when isnull(@isPrePull,0)=1 then (select top 1 PrePullCost from #Prepull) else 0 end
	update #Summary set LineItem2_Value = Case when isnull(@isYardShuttle,0)=1 then @YardShuttleCost else 0 end 
	update #Summary set LineItem3_Value = Case when isnull(@isStopOff,0)=1 then (select top 1 StopOffCost from #StopOff) else 0 end 
	update #Summary set LineItem4_Value = @DrayBaseValue 
	update #Summary set LineItem5_Value = @AddedAccessorialsTotalCost

	update #Summary set Total_value = LineItem1_Value + LineItem2_Value + LineItem3_Value + LineItem4_Value + LineItem5_Value

	SElect PriceGroupingKey, PriceGrouping, MarketLocationKey , Case when PriceGroupingKey = @TerminalKey then 0 else 1 end as SortOrder
	into #Terminal from PriceGrouping 
	where MarketLocationKey = @MarketKey


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
	
	Select LegGroupKey, LegName, LegOrderBy, LegTypeName
	into #LegTypeList
	from Cost_LegGroups LG
	inner join Cost_LegTypes LT on LG.LegTypesCombined like '%' + LT.LegTypeID + ',' + '%'
	order by LegGroupKey, LegOrderBy

	--select * from #Terminal
	--SELECT * FROM #Summary
	--select * from #LegTypeList
	--select * from #LegGroups

	Select @JsonOutput = (
		select PriceGroupingKey, PriceGrouping, MarketLocationKey,
			TruckTypes=(select TruckTypeKey, TruckType,
					LegHeadings = (Select LegGroupKey, LegTypeHeaderText ,LegGroupID,
									LegList = (Select LegGroupKey, LegName, LegOrderBy, isnull(LV.LegCost,-1) as LegCost
												from #LegTypeList LL
												Left join #LegTypeValues LV on LL.LegTypeName = LV.LegType
												Where LL.LegGroupKey = LG.LegGroupKey
												For JSON Path
												),
									LegGroupTotalCost = (Select sum( isnull(LV.LegCost,-1))
												from #LegTypeList LL
												Left join #LegTypeValues LV on LL.LegTypeName = LV.LegType
												Where LL.LegGroupKey = LG.LegGroupKey)
								from #LegGroups LG
								Order by LegGroupKey
								For JSON PAth),
					AddedAccessorials = (select isnull(LineItem, A.Description) as LineItem, Per, UnitCost , TotalCost
										from #ItemInfo A
										left join #AccRercs B on A.Description = B.LineItem
										For JSON Path),
					AddedAccessorialsTotalCost = @AddedAccessorialsTotalCost
					from TruckType
					for JSON Path),
			Summary = (Select LineItem1, LineItem1_Value, LineItem2, LineItem2_Value, LineItem3, LineItem3_Value,
						LineItem4, LineItem4_Value, LineItem5, LineItem5_Value, Total_text, Total_value, HeaderText 
						from #Summary
						For JSON PATH),
			LineItemDetails =  (
				select 'Accessorial Item Details' as Heading, 
						isnull(LineItem, A.Description + ' (Not in Accessorial Item)') as LineItem, B.Per, b.UnitCost , 
						convert(int, isnull(A.qty,0)) as qty,
						convert(decimal(18,3),b.UnitCost) * isnull(A.qty,0) as TotalCost
				from #ItemInfo A
				Left join #AccRercs B on A.Description = B.LineItem
				for JSON PATH
			),
			LegDetails = (
				select ContainerNo, LegId, 
					FromLoc =case when FromLocation = 'Yard' then ShortName 
								when FromLocation = 'Port' then ShippingPortID
								When FromLocation in ('Consignee','Customer','Shipper') then  City End,
					ToLoc =case when ToLocation = 'Yard' then ShortName 
								when ToLocation = 'Port' then ShippingPortID
								When ToLocation in ('Consignee','Customer','Shipper') then  City End,
					TruckType, 
					LegCostType,
					LegTypeName
				from #BaseInfo
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
	Drop table #AccesorialItemKeys
	DROP TABLE #Summary
	drop table #LegGroups
	drop table #Terminal
	drop table #LegTypeList
END
