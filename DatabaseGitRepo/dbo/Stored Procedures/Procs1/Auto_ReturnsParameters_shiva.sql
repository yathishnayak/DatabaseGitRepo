
-- exec [Auto_ReturnsParameters] 160777, 0

CREATE Procedure [dbo].[Auto_ReturnsParameters_shiva]  -- 1765 // 3281
(
	@OrderDetailKey			int = 0,
	@IsDebug				bit = 0
)
As
BEGIN
	print  CONVERT(varchar,Getdate(),114)
	declare @ContainerNo varchar(50) = ''
	
	select top 1 @ContainerNo = ContainerNo from OrderDetail WITH (NOLOCK)
								where OrderDetailKey = @OrderDetailKey
		
	declare
		@MarketKey				int = 0,
		@Market					varchar(50) = '',
		@OrderType				varchar(50) = '',
		@Terminal				varchar(50) = '',
		@TerminalKey			int,
		@Location				varchar(100) = '',
		@city					varchar(100) = '',
		@State					varchar(20) = '',
		@TruckType				varchar(50) = '',
		@CustKey				int = 0,
		@CustName				varchar(50) = '',
		@IncludeFSF				Bit = 0,
		@ZoneKey				int =0,
		@ZoneName				varchar(200) = '',
		@ZipCode				varchar(20),
		@DriverType				varchar(50),
		@CityDryRun				varchar(50),
		@StateDryRun			varchar(10),
		@DryRunType				varchar(20) = ''
		--@IsGeneralNAC			Bit = 0 -- When 1, then Ignore custKey and use General Data in NAC

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
		A.City, A.State, A.ZipCode, D.DriverKey, D.driverID, TT.TruckType, A.AddrName as LocationName,
		L.LegCostType, LT.LegTypeName, RT.IsDryRun, RT.DryRunType as DryRunTypeKey, DRT.DryRunType, isnull(RT.IsBobtail,0) as IsBobtail,
		RT.LegNo, A.AddrName, Address1
	INTO #BaseInfo
	from ORderDetail OD WITH (NOLOCK)
	inner join Orderheader OH WITH (NOLOCK) on OD.orderkey = OH.OrderKey
	inner join routes RT WITH (NOLOCK) on OD.OrderDetailKey = RT.OrderDetailKey 
	INNER JOIN OrderType OT  WITH (NOLOCK) ON OT.OrderTypeKey=OH.OrderTypeKey
	inner join Leg L on RT.LegKey = L.LegKey 
	LEft join Yard Y on case when L.FromLocation  = 'Yard' then Rt.SourceAddrKey
		When L.ToLocation = 'Yard' then Rt.DestinationAddrKey else 0 end = Y.AddrKey
	LEft join ShippingPort P on case when L.FromLocation  = 'Port' then Rt.SourceAddrKey
		When L.ToLocation = 'Port' then Rt.DestinationAddrKey else 0 end = P.AddrKey
	LEft join Address A WITH (NOLOCK) on 
		case 
			when OT.OrderType ='Import' and  L.ToLocation  in ('Shipper','Customer', 'Consignee') then Rt.DestinationAddrKey
			when OT.OrderType ='Export' and  L.FromLocation  in ('Shipper','Customer', 'Consignee') then Rt.SourceAddrKey
			When L.ToLocation in ('Shipper','Customer', 'Consignee') then Rt.DestinationAddrKey 
			else 0 end = A.AddrKey
	LEFT join Driver D on RT.DriverKey = D.DriverKey
	LEft join TruckType TT on D.TruckTypeKey = TT.TruckTypeKey
	LEFT Join Cost_LegTypes LT on L.LegCostType = LT.LegTypeID
	LEFT Join DryRunType DRT on RT.DryRunType = DRT.DryRunTypeKey
	
	order by ContainerNo, RouteKey, Rt.LegNo 

	select	@City = A.City, 
			@State = A.State,
			@Location = A.AddrName
	from ORderDetail OD WITH (NOLOCK)
	inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	inner join Address A WITH (NOLOCK) on OH.DestinationAddrKey = A.AddrKey
	where OD.OrderDetailKey = @OrderDetailKey

	if(@OrderType = 'Export')
		Begin
			select Top 1 @city = City , @State = State,  @ZipCode = ZipCode, @DriverType = TruckType
			from #BaseInfo
			where ORDERDETAILKEY = @OrderdetailKey AND ContainerNo = @ContainerNo AND  City is not null
				and FromLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 0
			order by LEgNo ASC

			select Top 1 @CityDryRun = City , @StateDryRun = State
			from #BaseInfo
			where ORDERDETAILKEY = @OrderdetailKey AND ContainerNo = @ContainerNo AND  City is not null
				and FromLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 1
			order by LEgNo ASC
		end
		else 
		Begin
			select Top 1 @city = City , @State = State,  @ZipCode = ZipCode, @DriverType = TruckType
			from #BaseInfo
			where ORDERDETAILKEY = @OrderdetailKey AND ContainerNo = @ContainerNo AND  City is not null
				and ToLocation in ('Shipper','Customer', 'Consignee') and isnull(IsDryRun,0) = 0
			order by LEgNo DESC

			select Top 1  @CityDryRun = City , @StateDryRun = State
			from #BaseInfo
			where ORDERDETAILKEY = @OrderdetailKey AND ContainerNo = @ContainerNo AND  City is not null
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
				from ORderDetail IH WITH (NOLOCK)
				inner join OrderHeader OH WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
				inner join Address A WITH (NOLOCK) on OH.DestinationAddrKey = A.AddrKey
				where IH.OrderDetailKey = @OrderDetailKey
			end
			Else
			Begin
				select @City = A.City, 
					@State = A.State,
					@ZipCode = A.ZipCode
				from ORderDetail IH WITH (NOLOCK)
				inner join OrderHeader OH WITH (NOLOCK) on IH.OrderKey = OH.OrderKey
				inner join Address A WITH (NOLOCK) on OH.DestinationAddrKey = A.AddrKey
				where IH.OrderDetailKey = @OrderDetailKey
			end
		End

		

		if(@IsDebug = 1)
		Begin
			select @city as City, @State as State, @ZipCode as Zip
			select @CityDryRun as City, @StateDryrun as State, @ZipCode as Zip
			select @DryRunType as DryRunType
		end

	select @TruckType = TT.TruckType
	from Routes RT WITH (NOLOCK)
	LEFT join Driver D WITH (NOLOCK) on RT.DriverKey = D.DriverKey
	LEft join TruckType TT WITH (NOLOCK) on D.TruckTypeKey = TT.TruckTypeKey
	where RT.OrderDetailKey = @OrderDetailKey

	select top 1 @ZoneKey = ZoneKey 
	from ZoneCityMap 
	where MarketKey = @MarketKey and TerminalKey = @TerminalKey and City = @City and State = @State

	if(@IsDebug = 1)
	Begin
		Select '#BaseInfo',* from #BaseInfo
	End

	select	@OrderDetailKey as OrderDetailKey,@MarketKey as MarketLocationKey, @Market as Market,  
			@Terminal as Terminal,@City as City, @State as State, 
			@Location as Location, @ZoneKey as ZoneKey, @ZoneName as ZoneName,
			@ContainerNo as ContainerNo, @TruckType as TruckType, 
			@custKey as CustKey, @CustName as Customer,
			@DryRunType as DryRunType, @CityDryRun as CityDryRun, @StateDryRun as StateDryRun
			
	print  CONVERT(varchar,Getdate(),114)
END
