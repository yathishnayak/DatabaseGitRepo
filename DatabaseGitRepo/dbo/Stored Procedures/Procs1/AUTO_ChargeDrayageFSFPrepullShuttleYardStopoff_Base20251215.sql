
-- AUTO_ChargeDrayageFSFPrepullShuttleYardStopoff_Base06122024 188090, 1

-- select orderdetailkey from orderdetail where containerno = 'DFSU7100983'

-- 48771, 129159, 129105, 129098, 128852, 121695, 127232, 127231
CREATE PROC [dbo].[AUTO_ChargeDrayageFSFPrepullShuttleYardStopoff_Base20251215]  -- AUTO_ChargeDrayageFSFPrepullShuttleYardStopoff 186924, 1
(
	@OrderDetailKey		int = 121425,
	@IsDebug			bit = 0
)
as 
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	Declare @ContainerNo					varchar(20),
			@OrderType						varchar(20),
			@RouteKey						int,
			@IncludeFSF						bit = 0,

			@IsDraybase						bit = 0,
			@IsPrePull						bit = 0,
			@IsYardStopOff					bit = 0,
			@IsYardShuttle					bit = 0,
			@IsFSFIncluded					bit = 0,

			@DraybaseItemKey				int = 18,
			@PrePullItemKey					int = 103,
			@YardStopOffItemKey				int = 24,
			@YardShuttleItemKey				int = 116,
			@FSFItemKey						int = 76,

			@IsDraybaseItemExists			bit = 0,
			@IsPrepullItemExists			bit = 0,
			@IsYardStopOffItemExists		bit = 0,
			@IsFSFItemExists				bit = 0,
			@IsYardShuttleItemExists		bit = 0,

			@DraybaseBvsNB					bit = 0,
			@PrePullBvsNB					bit = 0,
			@YardStopOffBvsNB				bit = 0,
			@YardShuttleBvsNB				bit = 0,
			@FSFIncludedBvsNB				bit = 0,

			@DraybaseFreeTime				int= 0,
			@PrePullFreeTime				int= 0,
			@YardStopOffFreeTime			int= 0,
			@YardShuttleFreeTime			int= 0,
			@FSFIncludedFreeTime			int= 0,

			@DraybaseMax					int = 0,
			@PrePullMax						int = 0,
			@YardStopOffMax					int = 0,
			@YardShuttleMax					int = 0,
			@FSFIncludedMax					int = 0,

			@DraybaseMin					int = 0,
			@PrePullMin						int = 0,
			@YardStopOffMin					int = 0,
			@YardShuttleMin					int = 0,
			@FSFIncludedMin					int = 0,

			@SteamCustKey					INT = 2692,
			@SteamAMZCustKey				INT = 3516,
			@CustKey						INT = 0,
			@CenturyCustKey1				INT = 3049,
			@CenturyCustKey2				INT = 3402,
			@IsLinked						Bit = 0,

			@MarketLocationKey				INT=0,
			@IsStopOffChecked				BIT=0


	Select @ContainerNo = ContainerNo, @OrderType = Ot.OrderType, @IncludeFSF = isnull(C.IncludeFSF,0), @CustKey = C.CustKey,
	@MarketLocationKey=OH.MarketLocationKey,
	@IsStopOffChecked=CASE WHEN ISNULL(CTL.OrderDetailKey,0)=0 THEN 0 ELSE 1 END
	from OrderDetail OD WITH (NOLOCK)
	inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	inner join Customer C WITH (NOLOCK) on OH.CustKey = C.CustKey 
	LEFT JOIN Containertypeslink CTL WITH (NOLOCK) ON CTL.OrderDetailKey=OD.OrderDetailKey AND ContainerTypeKey=14
	where OD.OrderdetailKey = @OrderDetailKey


	select *
	into #BaseInfo1
	from (select top 1000  
		OD.OrderDetailKey,
		OD.ContainerNo, RT.Routekey, L.LegID, L.FromLocation, L.ToLocation , 
		RT.SourceAddrKey, Rt.DestinationAddrKey, Y.ShortName, Y.YardType, Y.yardid,
		P.ShippingPortKey, P.ShippingPortID,
		A.City, A.State, A.ZipCode, D.DriverKey, D.driverID, TT.TruckType, 
		L.LegCostType, LT.LegTypeName, RT.IsDryRun, RT.DryRunType as DryRunTypeKey, 
		DRT.DryRunType, isnull(RT.IsBobtail,0) as IsBobtail,
		RT.LegNo, Rt.ActualArrival, RT.ActualDeparture
	from OrderDetail OD WITH (NOLOCK)
	inner join routes RT WITH (NOLOCK) on OD.OrderDetailKey = RT.OrderDetailKey --and OD.ContainerNo = ID.Container
	inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey 
	LEft join Yard Y WITH (NOLOCK) on case when L.FromLocation  = 'Yard' then Rt.SourceAddrKey
		When L.ToLocation = 'Yard' then Rt.DestinationAddrKey else 0 end = Y.AddrKey
	LEft join ShippingPort P WITH (NOLOCK) on case when L.FromLocation  = 'Port' then Rt.SourceAddrKey
		When L.ToLocation = 'Port' then Rt.DestinationAddrKey else 0 end = P.AddrKey
	LEft join Address A WITH (NOLOCK) on case when L.FromLocation  in ('Shipper','Customer', 'Consignee') then Rt.SourceAddrKey
		When L.ToLocation in ('Shipper','Customer', 'Consignee') then Rt.DestinationAddrKey else 0 end = A.AddrKey
	LEFT join Driver D WITH (NOLOCK) on RT.DriverKey = D.DriverKey
	LEft join TruckType TT WITH (NOLOCK) on D.TruckTypeKey = TT.TruckTypeKey
	LEFT Join Cost_LegTypes LT WITH (NOLOCK) on L.LegCostType = LT.LegTypeID
	LEFT Join DryRunType DRT WITH (NOLOCK) on RT.DryRunType = DRT.DryRunTypeKey
	WHERE OD.OrderDetailKey =  @OrderDetailKey -- 129159 
	order by Rt.LegNo ASC ) A

	if(@IsDebug = 1)
	Begin
		Select * from #BaseInfo1
	End

	Select @IsDraybase    = case when  count(1) > 0 then 1 else 0 end from #BaseInfo1 where LegTypeName = 'Dray Base'
	Select @IsPrePull     = case when  count(1) > 0 then 1 else 0 end from #BaseInfo1 where LegTypeName = 'PrePull'
	Select @IsYardShuttle = case when  count(1) > 0 then 1 else 0 end from #BaseInfo1 where LegTypeName = 'Shuttle'
	Select @IsYardStopOff = case when  count(1) > 0 then 1 else 0 end from #BaseInfo1 where LegTypeName = 'Stop-Off'



	select @IsDraybaseItemExists = Case when count(1) > 0 then 1 else 0 end 
			from orderExpense OE WITH (NOLOCK)
			LEft join Item I WITH (NOLOCK) on OE.itemkey = I.ItemKey 
			where OE.OrderDetailKey = @OrderDetailKey and ( OE.itemkey = @DraybaseItemKey OR I.MasterItemKey = @DraybaseItemKey)
	select @IsPrepullItemExists = Case when count(1) > 0 then 1 else 0 end 
			from orderExpense OE WITH (NOLOCK)
			LEft join Item I WITH (NOLOCK) on OE.itemkey = I.ItemKey 
			where OE.OrderDetailKey = @OrderDetailKey and (OE.itemkey = @PrePullItemKey OR I.MasterItemKey = @PrePullItemKey)
	select @IsYardShuttleItemExists = Case when count(1) > 0 then 1 else 0 end 
			from orderExpense OE WITH (NOLOCK)
			LEft join Item I WITH (NOLOCK) on OE.itemkey = I.ItemKey 
			where OE.OrderDetailKey = @OrderDetailKey and (OE.itemkey = @YardShuttleItemKey OR I.MasterItemKey = @YardShuttleItemKey)
	select @IsYardStopOffItemExists = Case when count(1) > 0 then 1 else 0 end 
			from orderExpense OE WITH (NOLOCK)
			LEft join Item I WITH (NOLOCK) on OE.itemkey = I.ItemKey 
			where OE.OrderDetailKey = @OrderDetailKey and (OE.itemkey = @YardStopOffItemKey OR I.MasterItemKey = @YardStopOffItemKey)
	select @IsFSFItemExists = Case when count(1) > 0 then 1 else 0 end 
			from orderExpense OE WITH (NOLOCK)
			LEft join Item I WITH (NOLOCK) on OE.itemkey = I.ItemKey 
			where OE.OrderDetailKey = @OrderDetailKey and (OE.itemkey = @FSFItemKey OR I.MasterItemKey = @FSFItemKey)

	if(@IsDebug = 1)
	Begin
		Select  @ContainerNo as ContainerNo, @OrderType as OrderType 
		Select  @IsDraybase as Draybase, @IsPrePull as PrePull, 
				@IsYardShuttle as YardShuttle, @IsYardStopOff as YardStopOff,
				@IncludeFSF as IncludeFSF
		Select  @IsDraybaseItemExists as IsDraybaseItemExists,
				@IsPrepullItemExists as IsPrepullItemExists,
				@IsYardShuttleItemExists as IsYardShuttleItemExists,
				@IsYardStopOffItemExists as IsYardStopOffItemExists,
				@IsFSFItemExists as IsFSFItemExists
		SElect * from #BaseInfo1
	End

	/* ****************************** CALCULATION FOR DRAYBASE & FSF  ********************************************** */
	Create Table #JsonData
	(
		JsonResult nvarchar(max)
	)
	
	insert into #JsonData (JsonResult)
	Exec AUTO_Sell_OutputByOrderDetailKey @OrderDetailKey,0

	if(@IsDebug = 1)
	begin
	select * from #JsonData
	end

	declare @jsonresult nvarchar(max) = (select JsonResult from #JsonData)
	
	create table #sumresults (
			Market					varchar(50),
			MarketKey				int,
			Terminal				varchar(50),
			TerminalKey				int,
			ZoneKey					int,
			ZoneName				varchar(50),
			city					varchar(50),
			State					varchar(50),
			CustKey					int,
			CustName				varchar(50),
			IsDryRun				bit,
			IsBobTail				bit,
			Customersegment			varchar(50),
			DrayBase				nvarchar(max),
			Error					nvarchar(max)
			)
	insert into #sumresults
	select
			Market			,
			MarketKey		,
			Terminal		,
			TerminalKey		,
			ZoneKey			,
			ZoneName		,
			city			,
			State			,
			CustKey			,
			CustName		,
			IsDryRun		,
			IsBobTail		,
			Customersegment	,
			DrayBase		,
			Error			
	from openjson(@jsonresult, '$')
	with (
			Market					varchar(50)			 '$.Market',		   
			MarketKey				int					 '$.MarketKey',	   
			Terminal				varchar(50)			 '$.Terminal',		   
			TerminalKey				int					 '$.TerminalKey',	   
			ZoneKey					int					 '$.ZoneKey',		   
			ZoneName				varchar(50)			 '$.ZoneName',		   
			city					varchar(50)			 '$.city',			   
			State					varchar(50)			 '$.State',		   
			CustKey					int					 '$.CustKey',		   
			CustName				varchar(50)			 '$.CustName',		   
			IsDryRun				bit					 '$.IsDryRun',		   
			IsBobTail				bit					 '$.IsBobTail',	   
			Customersegment			varchar(50)			 '$.Customersegment', 
			DrayBase				nvarchar(max)		 '$.DrayBase' as json,		   
			Error					nvarchar(max)		 '$.Error' as json
		)

	if(@IsDebug = 1)
	begin
	select * from #sumresults
	end

	declare @draybasedata nvarchar(max) = '',
			@errordata nvarchar(max) = ''

	select top 1 @draybasedata = DrayBase from #sumresults
	select top 1 @errordata = Error from #sumresults

	create table #draybase (
		ContainerNo			   varchar(50),
		DrayBase_Value		   float,
		Margin_Percent		   float,
		Margin_Value		   float,
		DrayBase_Rate		   float,
		FSF_Percent			   float,
		FSF_Value			   float,
		Draybase_Total		   float,
		NetRevenue			   float,
		EffectiveDate		   datetime,
		EffectiveDateFrom	   varchar(50),
		FileName			   varchar(50),
		DateUploaded		   datetime,
		UploadedBy			   varchar(50),
		OutputDataKey		   int
	)

	insert into #draybase
	select
			ContainerNo			,
			DrayBase_Value		,
			Margin_Percent		,
			Margin_Value		,
			DrayBase_Rate		,
			FSF_Percent			,
			FSF_Value			,
			Draybase_Total		,
			NetRevenue			,
			EffectiveDate		,
			EffectiveDateFrom	,
			FileName			,
			DateUploaded		,
			UploadedBy			,
			OutputDataKey		
	from openjson(@draybasedata, '$')
	with (
				ContainerNo			   varchar(50)				 '$.ContainerNo',
				DrayBase_Value		   nvarchar(50)				 '$.DrayBase_Value',
				Margin_Percent		   nvarchar(50)				 '$.Margin_Percent',
				Margin_Value		   nvarchar(50)				 '$.Margin_Value',
				DrayBase_Rate		   nvarchar(50)				 '$.DrayBase_Rate',
				FSF_Percent			   nvarchar(50)				 '$.FSF_Percent',
				FSF_Value			   nvarchar(50)				 '$.FSF_Value',
				Draybase_Total		   nvarchar(50)				 '$.Draybase_Total',
				NetRevenue			   nvarchar(50)				 '$.NetRevenue',
				EffectiveDate		   datetime					 '$.EffectiveDate',
				EffectiveDateFrom	   varchar(50)				 '$.EffectiveDateFrom',
				FileName			   varchar(50)				 '$.FileName',
				DateUploaded		   datetime					 '$.DateUploaded',
				UploadedBy			   varchar(50)				 '$.UploadedBy',
				OutputDataKey		   nvarchar(50)				 '$.OutputDataKey'
		)
		
		--if (@IncludeFSF = 0)
		--begin
		--update #draybase
		--set FSF_Value = null, Draybase_Total = DrayBase_Rate
		--end

	if(@IsDebug = 1)
	begin
	select * from #draybase
	end


	/* ****************************** CALCULATION FOR ITEMS  ********************************************** */

	declare
		@ItemKeys				varchar(500)='', -- Colon separated itemkeys
		@MarketKey				int = 0,
		@Terminal				varchar(50) = '',
		@Location				varchar(100) = '',
		@city					varchar(100) = '',
		@State					varchar(20) = '',
		@TruckType				varchar(50) = '',
		--@CustKey				int = 0,
		@IsGeneralNAC			Bit = 0 -- When 1, then Ignore custKey and use General Data in NAC

	if(@IsPrePull = 1)
	Begin
		set @Itemkeys = @ItemKeys + convert(varchar, @PrePullItemKey)  + ':' ;
	End

	if(@IsYardShuttle = 1)
	Begin
		set @Itemkeys = @ItemKeys + convert(varchar, @YardShuttleItemKey)  + ':' ;
	End

	if(@IsYardStopOff = 1)
	Begin
		set @Itemkeys = @ItemKeys +convert(varchar,  @YardStopOffItemKey)  + ':' ;
	End

	select @MarketKey = MarketKey, @Terminal = Terminal, @city = city, @State = State, @CustKey = CustKey
	from #sumresults

	Create Table #JsonDatafromproc2
	(
		JsonResult2 nvarchar(max)
	)

	create table #sjsonresuls (
		RecordSL				int,
		LineItem				nvarchar(50),
		MArket					nvarchar(50),
		Terminal				varchar(100),
		ItemKey					int,
		Rate					float,
		BvsNB					varchar(50),
		FreeTime				int,
		MinCnt					int,
		MaxCnt					int,
		EffectiveDate			datetime,
		EffectiveDateFrom		varchar(50),
		CostGroup				varchar(50),
		FileName				varchar(200),
		DateUploaded			Datetime,
		UploadedBy				varchar(100)
	)

	insert into #sjsonresuls
	Exec AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys, @MarketKey, @OrderDetailKey, @ContainerNo, @Terminal, 
		@Location, @city, @State, @TruckType, @CustKey, @IsGeneralNAC, 0

		if(@IsDebug = 1)
		begin
		select '#sjsonresuls', * from #sjsonresuls
		end

		/* ****************************** FINAL CALCULATIONS ********************************************** */
		Declare @DrayBaseValue			numeric(18,4) = 0,
				@FSFValue				numeric(18,4) = 0,
				@PrepullValue			numeric(18,4) = 0,
				@ShuttleValue			numeric(18,4) = 0,
				@StopOffValue			numeric(18,4) = 0,
				@EmptyStopOffValue		numeric(18,4) = 0,
				@LoadedStopOffValue		numeric(18,4) = 0,

				@DraybaseQty			int	= 0,
				@FSFQty					int = 0,
				@PRePullQty				int = 0,
				@ShuttleQty				int = 0,
				@StopOffQty				int = 0,
				@EmptyStopOffQty		int = 0,
				@LoadedStopOffQty		int = 0,

				@DraybaseRouteKey	int = 0,
				@FSFRouteKey		int = 0,
				@PrePullRouteKey	int = 0,
				@ShuttleRouteKey	int = 0,
				@StopOffRouteKey	int = 0,

				@DraybaseDate		DateTime,
				@FSFDate			DateTime,
				@PrePullDate		DateTime,
				@ShuttleDate		DateTime,
				@StopOffDate		DateTime

		Select @DraybaseQty = 1 from #BaseInfo1 where  LegTypeName = 'Dray Base'
		Select @FSFQty		= case when @IncludeFSF = 0 then @DraybaseQty else 0 end
		Select @PRePullQty	= 1 from #BaseInfo1 where  LegTypeName = 'PrePull'
		Select @ShuttleQty	= 1 from #BaseInfo1 where  LegTypeName = 'Shuttle'
		Select @StopOffQty	= 1 from #BaseInfo1 where  LegTypeName = 'Stop-Off'

		Select top 1 @DraybaseRouteKey	= RouteKey, @DraybaseDate = ActualArrival from #BaseInfo1 where  LegTypeName = 'Dray Base'
		Select top 1 @FSFRouteKey		= RouteKey, @FSFDate	  = ActualArrival from #BaseInfo1 where  LegTypeName = 'Dray Base'
		Select top 1 @PrePullRouteKey	= RouteKey, @PrePullDate  = ActualArrival from #BaseInfo1 where  LegTypeName = 'PrePull'
		Select top 1 @ShuttleRouteKey	= RouteKey, @ShuttleDate  = ActualArrival from #BaseInfo1 where  LegTypeName = 'Shuttle'
		Select top 1 @StopOffRouteKey	= RouteKey, @StopOffDate  = ActualArrival from #BaseInfo1 where  LegTypeName = 'Stop-Off'

		Select	@DrayBaseValue = case when @IncludeFSF = 0 then DrayBase_Rate else DrayBase_Value end,
				@FSFValue = Case When @IncludeFSF = 0 then FSF_Value else 0 end
		from #draybase
		
		--Select @PrepullValue = Rate, @PrePullBvsNB =  Case when BvsNB = 'NB' then 0 else 1 end, @PrePullFreeTime = FreeTime, @PrePullMax = MaxCnt, @PrePullMin = MinCnt
		--	FROM #sjsonresuls WHERE ITEMKEY = @PrePullItemKey
		--Select @StopOffValue  = Rate , @YardStopOffBvsNB = Case when BvsNB = 'NB' then 0 else 1 end, @YardStopOffFreeTime = FreeTime, @YardStopOffMax = MaxCnt, @YardStopOffMin = MinCnt
		--	FROM #sjsonresuls WHERE ITEMKEY = @YardStopOffItemKey
		--Select @ShuttleValue  = Rate, @YardShuttleBvsNB =  Case when BvsNB = 'NB' then 0 else 1 end, @YardShuttleFreeTime = FreeTime, @YardShuttleMax = MaxCnt, @YardShuttleMin = MinCnt 
		--	FROM #sjsonresuls WHERE ITEMKEY = @YardShuttleItemKey

		Select @PrepullValue = Rate, @PrePullBvsNB =  Case when BvsNB = 'NB' then 0 else 1 end, 
			@PrePullFreeTime = FreeTime, @PrePullMax = MaxCnt, @PrePullMin = MinCnt
			FROM #sjsonresuls WHERE ITEMKEY = @PrePullItemKey
		Select @StopOffValue  = Rate , @YardStopOffBvsNB = Case when BvsNB = 'NB' then 0 else 1 end, 
			@YardStopOffFreeTime = FreeTime, @YardStopOffMax = MaxCnt, @YardStopOffMin = MinCnt
			FROM #sjsonresuls WHERE ITEMKEY = @YardStopOffItemKey
		Select @ShuttleValue  = Rate, @YardShuttleBvsNB =  Case when BvsNB = 'NB' then 0 else 1 end, 
			@YardShuttleFreeTime = FreeTime, @YardShuttleMax = MaxCnt, @YardShuttleMin = MinCnt 
			FROM #sjsonresuls WHERE ITEMKEY = @YardShuttleItemKey

		Declare @ItemCount	int = 0
		--Begin Transaction
		Begin try
			/* ****************************** INSERT DRAYBASE ITEM ********************************************** */
			if(@IsDraybase = 1 and @DraybaseQty > 0 and isnull(@IsDraybaseItemExists,0) = 0)
			Begin
				insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
					BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				Select @DraybaseItemKey, @DraybaseRouteKey, @DrayBaseValue, @DraybaseQty, @DrayBaseValue, Getdate(),  
					1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DraybaseDate

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Draybase Item Added for Container '
				
				Set @ItemCount = @ItemCount + 1
			end
	
			/* ****************************** INSERT FSF ITEM ********************************************** */
			if(@IncludeFSF = 0 and  @IsDraybase = 1 and @DraybaseQty > 0 and isnull(@IsFSFItemExists,0) = 0)
			Begin
				insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
					BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				Select @FSFItemKey, @FSFRouteKey, @FSFValue, @FSFQty, @FSFValue, Getdate(),  
					1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @FSFDate

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'FSF Item Added for Container '
				
				Set @ItemCount = @ItemCount + 1
			end

			/* ****************************** INSERT PREPULL ITEM ********************************************** */
			if( @IsPrePull = 1 and @PRePullQty > 0 and isnull(@IsPrepullItemExists,0) = 0)
			Begin
				insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
					BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				Select @PrePullItemKey, @PrePullRouteKey, @PrepullValue, @PRePullQty, @PrepullValue, Getdate(),  
					1, @PrePullFreeTime, @PrePullBvsNB, @PrePullMin, @PrePullMax, 'Auto', @OrderDetailKey, @PrePullDate

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Pre-Pull Item Added for Container '
				
				Set @ItemCount = @ItemCount + 1
			end

			/* ****************************** INSERT SHUTTLE ITEM ********************************************** */
			if( @IsYardShuttle = 1 and @ShuttleQty > 0 and isnull(@IsYardShuttleItemExists,0) = 0)
			Begin
				insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
					BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				Select @YardShuttleItemKey, @ShuttleRouteKey, @ShuttleValue, @ShuttleQty, @ShuttleValue, Getdate(),  
					1, @YardShuttleFreeTime, @YardShuttleBvsNB, @YardShuttleMin, @YardShuttleMax, 'Auto', @OrderDetailKey, @ShuttleDate

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Shuttle Item Added for Container '

				Set @ItemCount = @ItemCount + 1
			end
			/* ****************************** INSERT YARD STOP-OFF ITEM ********************************************** */
			print '@MarketLocationKey'
			print @MarketLocationKey
			print '@OrderType'
			print @OrderType
			print '@IsStopOffChecked'
			print @IsStopOffChecked
			print 'isnull(@IsYardStopOffItemExists,0)'
			print isnull(@IsYardStopOffItemExists,0)

			IF(@MarketLocationKey=2 AND @OrderType='Import' AND @IsStopOffChecked=1 AND isnull(@IsYardStopOffItemExists,0) = 0)
			BEGIN
				if(isnull(@StopOffRouteKey,0) = 0)
				Begin
					select top 1 @StopOffRouteKey = routekey from routes WITH (NOLOCK) where OrderDetailKey = @OrderDetailKey
				End

					insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
						BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
					Select @YardStopOffItemKey, @StopOffRouteKey, @StopOffValue, @StopOffQty, @StopOffValue, Getdate(),  
						1, @YardStopOffFreeTime, @YardStopOffBvsNB, @YardStopOffMin, @YardStopOffMax, 'Auto', @OrderDetailKey, @StopOffDate

					INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
					Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Stop-Off Item Added for Container '

					Set @ItemCount = @ItemCount + 1
				--end
			END
			ELSE
			BEGIN
			/* ****************************** INSERT YARD STOP-OFF ITEM ********************************************** */
			Declare 
				@YardEmptyStopOffItemKey		int = 24,
				@YardLoadedStopOffItemKey		int = 373,
				@IsEmptyYardStopOff				bit = 0,
				@IsLoadedYardStopOff			bit = 0,
				@IsEmptyYardStopOffItemExists	bit = 0,
				@IsLoadedYardStopOffItemExists	bit = 0,
				@YardEmptyStopOffBvsNB			bit = 0,
				@YardLoadedStopOffBvsNB			bit = 0,
				@YardEmptyStopOffFreeTime		int= 0,
				@YardLoadedStopOffFreeTime		int= 0,
				@YardEmptyStopOffMax			int = 0,
				@YardLoadedStopOffMax			int = 0,
				@YardEmptyStopOffMin			int = 0,
				@YardLoadedStopOffMin			int = 0

			-- Loaded Stop Off : 373
			-- Empty Stop Off : 24

			/*
			When the order is an import: after consignee delivery, if the stop goes to LOCAL yard at any point, 
				generate line item "Empty Stop Off"
				a) Consignee > IE > Local > Port 
				Generate item "Yard Shuttle" as NON Billable, do not allow user to edit from NB to B 
				Generate item "Empty Stop Off" as Billable - this is dependent on the client not billable every time
				b) Consignee > IE > Port 
				Generate item "Empty Stop Off" as NON Billable, do not allow user to edit from NB to B
				c) Consignee > Local > Port 
				Generate "Empty Stop Off" as Billable
			When the order is an export: after consignee/shipper foundational stop, if the added stop goes to LOCAL yard, 
				generate line item "Loaded Stop Off"
				a) Consignee > IE > Local > Port
				Generate item "Yard Shuttle" as NON Billable, do not allow user to edit from NB to B 
				Generate item "Loaded Stop Off" as Billable - this is dependent on the client not billable every time  
				b) Consignee > IE > Port 
				Generate item "Loaded Stop Off" as NON Billable, do not allow user to edit from NB to B
				c) Consignee > Local > Port 
				Generate "Loaded Stop Off" as Billable
			*/
				if( @IsYardStopOff = 1 and @StopOffQty > 0 and isnull(@IsYardStopOffItemExists,0) = 0)
				Begin
					insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
						BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
					Select @YardStopOffItemKey, @StopOffRouteKey, @StopOffValue, @StopOffQty, @StopOffValue, Getdate(),  
						1, @YardStopOffFreeTime, @YardStopOffBvsNB, @YardStopOffMin, @YardStopOffMax, 'Auto', @OrderDetailKey, @StopOffDate

					INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
					Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Stop-Off Item Added for Container '

					Set @ItemCount = @ItemCount + 1
				end
			END
			/* ************ FOR CUSTOMER STEAM AUTOMATICALLY CREATES YARD STOP-OFF WHEN ORDER TYPE IS EMPTY ******************* */
			IF(@CustKey in (@SteamCustKey, @SteamAMZCustKey) AND @OrderType = 'Empty' AND isnull(@IsYardStopOffItemExists,0) = 0)
			Begin
				print '@YardStopOffItemKey '
				print @YardStopOffItemKey

				insert into OrderExpense (Itemkey, Routekey, 
				UnitCost, Qty, NewUnitCost, CreateDate, 
				CreateUserKey, FreeTime, BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				Select @YardStopOffItemKey, COALESCE(@DraybaseRouteKey, @FSFRouteKey, @PrePullRouteKey, 
				@ShuttleRouteKey, @StopOffRouteKey), @StopOffValue, @StopOffQty, @StopOffValue, Getdate(),  
					1, @YardStopOffFreeTime, @YardStopOffBvsNB, @YardStopOffMin, @YardStopOffMax, 'Auto', @OrderDetailKey, @StopOffDate

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Stop-Off Item Added for Container '
				
				if(@IsDebug = 1)
				BEGIN
				Select 'OrderExpense', * From OrderExpense where OrderdetailKey = @OrderDetailKey
				END

				Set @ItemCount = @ItemCount + 1
			end

			/* ************ FOR Century customer and Container is paired to the container ******************* */

			Select @IsLinked = (Select isnull(IsLinked, 0) from OrderDetail WHERE OrderDetailKey = @OrderDetailKey)

			IF(@CustKey IN (@CenturyCustKey1, @CenturyCustKey2)  AND @IsLinked = 1 AND isnull(@IsYardStopOffItemExists,0) = 0)
			Begin
				print '@CenturyCustKey'
				print @CenturyCustKey1
				print @CenturyCustKey2

				SET @YardStopOffBvsNB = 1

				insert into OrderExpense (Itemkey, Routekey, 
				UnitCost, Qty, NewUnitCost, CreateDate, 
				CreateUserKey, FreeTime, BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				Select @YardStopOffItemKey, COALESCE(@DraybaseRouteKey, @FSFRouteKey, @PrePullRouteKey, @ShuttleRouteKey, @StopOffRouteKey), 
				@StopOffValue, @StopOffQty, @StopOffValue, Getdate(),  
					1, @YardStopOffFreeTime, 1, @YardStopOffMin, @YardStopOffMax, 'Auto', @OrderDetailKey, @StopOffDate

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Stop-Off Item Added for Container '
				
				if(@IsDebug = 1)
				BEGIN
				Select 'OrderExpense', * From OrderExpense where OrderdetailKey = @OrderDetailKey
				END

				Set @ItemCount = @ItemCount + 1
			end

			--if(@ItemCount > 0)
			--Begin
			--	Commit Transaction
			--end
			--else 
			--Begin
			--	Rollback Transaction
			--end
		End Try
		Begin Catch
			print @@ERROR
			--Rollback transaction
		End Catch
	drop table #BaseInfo1
	drop table #draybase
	drop table #JsonData
	drop table #JsonDatafromproc2
	drop table #sjsonresuls
	drop table #sumresults

END
