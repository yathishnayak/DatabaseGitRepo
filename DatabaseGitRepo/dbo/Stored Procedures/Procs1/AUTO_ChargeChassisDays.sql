

-- 129159, 129105, 129098, 128852, 121695, 127232, 127231
CREATE PROC [dbo].[AUTO_ChargeChassisDays] -- AUTO_ChargeChassisDays 267797, 1
(
	@OrderDetailKey		int = 121425,
	@IsDebug			bit = 0
)
as 
	SET NOCOUNT ON
	SET FMTONLY OFF
	Declare @ContainerNo			varchar(20),
			@FromRouteKey			int,
			@FromChassisKey			int,
			@FromChassisCategory	varchar(20),
			@ToRouteKey				int,
			@TochassisKey			int,
			@ToChassisCategory		varchar(20),
			@BillDays				int,
			@StartDate				DateTime,
			@StopDate				DateTime,
			@IsTriaxle				bit = 0,
			@TriaxleItemKey			int = 22,
			@ChassisPortItemKey		int = 100,
			@ChassisJCTItemKey		int = 84,
			@IsPortItemExists		bit = 0,
			@IsJCTItemExists		bit = 0,
			@IsTriaxleItemExists	bit = 0
		
	select @IsTriaxle = convert(bit,1)
	from ContainerTypesLink CTL
	where CTL.OrderDetailKey = @OrderDetailKey and CTL.ContainerTypeKey = 3

	Select @IsPortItemExists = 1 from OrderExpense
	where OrderDetailKey = @OrderDetailKey and itemkey = @ChassisPortItemKey

	Select @IsJCTItemExists = 1 from OrderExpense
	where OrderDetailKey = @OrderDetailKey and itemkey = @ChassisJCTItemKey

	Select @IsTriaxleItemExists = 1 from OrderExpense
	where OrderDetailKey = @OrderDetailKey and itemkey = @TriaxleItemKey

	SElect * into #Temp
	from (
		SELECT DATEDIFF(D, A.ActualDeparture, isnull(B.ActualArrival,StreetTurnSetDate)) + 1 AS BillDays, 
		A.OrderDetailKey, A.ContainerNo, 
			A.RouteKey as FromRouteKey, A.ChassisKey as FromChassisKey, A.ChassisCategory FromChassisCategory,
			B.RouteKey as ToRouteKey, B.ChassisKey as TochassisKey, B.ChassisCategory as ToChassisCategory,
			Status, CompleteDate, A.ActualDeparture as PickupDate, B.ActualArrival as DeliveryDate
		FROM (
			select Rt.OrderDetailKey, OD.ContainerNo, RT.Routekey, LF.LegID, 
				RT.ActualDeparture, rT.ChassisKey, rT.ChassisNo, RT.ChassisType, CC.ChassisCategory,
				OD.Status, OD.CompleteDate
			from Routes RT
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = Od.OrderDetailKey
			INNER join LEG LF WITH (NOLOCK) on RT.LegKey = LF.LegKey and Lf.FromLocation = 'PORT'
			LEFT JOIN ChassisCategory CC WITH (NOLOCK) ON RT.ChassisCategoryKey = CC.ChassisCategoryKey
			where ActualArrival is not null and ActualDeparture is not null AND ISNULL(RT.IsDryRun,0) = 0
				and rt.OrderDetailKey = @OrderDetailKey
		) A 
		LEFT JOIN (
			select Rt.OrderDetailKey, OD.ContainerNo, RT.Routekey, LT.LegID,
				RT.ActualArrival, rT.ChassisKey, rT.ChassisNo, RT.ChassisType, CC.ChassisCategory
			from Routes RT
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = Od.OrderDetailKey
			INNER join LEG LT WITH (NOLOCK) On Rt.LegKey = LT.LegKey and LT.ToLocation = 'Port'
			LEFT JOIN ChassisCategory CC WITH (NOLOCK) ON RT.ChassisCategoryKey = CC.ChassisCategoryKey
			where ActualArrival is not null and ActualDeparture is not null  AND ISNULL(RT.IsDryRun,0) = 0
				and rt.OrderDetailKey = @OrderDetailKey
		) B ON A.OrderDetailKey = B.OrderDetailKey
		LEFT JOIN (
			select Rt.OrderDetailKey, OD.ContainerNo, RT.Routekey, '' LegID,
				OD.StreetTurnSetDate, rT.ChassisKey, rT.ChassisNo, RT.ChassisType, CC.ChassisCategory
			from Routes RT
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = Od.OrderDetailKey
			LEFT JOIN ChassisCategory CC WITH (NOLOCK) ON RT.ChassisCategoryKey = CC.ChassisCategoryKey
			where ActualArrival is not null and ActualDeparture is not null  AND ISNULL(RT.IsDryRun,0) = 0
				and rt.OrderDetailKey = @OrderDetailKey and RT.isStreetTurn = 1
		) C ON A.OrderDetailKey = B.OrderDetailKey
	) A
	WHERE BillDays >0 AND FromChassisCategory IN ('JCT','PORT')

	SELECT	@ContainerNo			=	ContainerNo,
			@FromRouteKey			=	FromRouteKey,
			@FromChassisKey			=	FromChassisKey,
			@FromChassisCategory	=	FromChassisCategory,
			@ToRouteKey				=	ToRouteKey,
			@TochassisKey			=	TochassisKey,
			@ToChassisCategory		=	ToChassisCategory,
			@BillDays				=	BillDays,
			@StartDate				=	PickupDate,
			@StopDate				=	DeliveryDate
	FROM #Temp
	
	if(@IsDebug = 1)
	Begin
		Select * from #Temp

		SELECT	@ContainerNo			as	ContainerNo,
				@FromRouteKey			as	FromRouteKey,
				@FromChassisKey			as	FromChassisKey,
				@FromChassisCategory	as	FromChassisCategory,
				@ToRouteKey				as	ToRouteKey,
				@TochassisKey			as	TochassisKey,
				@ToChassisCategory		as	ToChassisCategory,
				@BillDays				as	BillDays,
				@StartDate				as	PickupDate,
				@StopDate				as	DeliveryDate,
				@IsTriaxle				as  IsTriaxle
		FROM #Temp

		Select @IsPortItemExists		as IsPortItemExists,
				@IsJCTItemExists		as IsJCTItemExists,
				@IsTriaxleItemExists	as IsTriaxleItemExists
	end


	/* **************************  GET COST FROM SELL DB ************************* */
	Create Table #Params
	(
		OrderDetailKey			int,
		MarketLocationKey		int,
		Market					varchar(100),
		Terminal				varchar(100),
		City					varchar(100),
		State					varchar(100),
		Location				varchar(100),
		ZoneKey					int,
		ZoneName				varchar(100),
		ContainerNo				varchar(20),
		TruckType				varchar(50),
		CustKey					int,
		CustName				varchar(200)
	)

	insert into #Params
	exec Auto_ReturnsParameters @OrderDetailKey = @OrderDetailKey, @isDebug = 0

	Declare 
		@ItemKeys				varchar(500), -- Colon separated itemkeys
		@MarketKey				int = 0,
		@Terminal				varchar(50) = '',
		@Location				varchar(100) = '',
		@city					varchar(100) = '',
		@State					varchar(20) = '',
		@TruckType				varchar(50) = '',
		@CustKey				int = 0,
		@IsGeneralNAC			Bit = 1 -- When 1, then Ignore custKey and use General Data in NAC

	select @MarketKey = MarketLocationKey, @Terminal = Terminal, @Location = Location,
			@City = city, @State = State, @TruckType = TruckType, @CustKey = CustKey, @IsGeneralNAC = 1
	from #Params

	if(@IsDebug = 1)
	Begin
		Select '#Params',* from #Params
	End

	CREATE Table #ItemsAcc
	(
		RecordSL		int,
		LineItem		varchar(200),
		Market			varchar(100),
		Terminal		varchar(100),
		ItemKey			int,
		Rate			numeric(18,4),
		BvsNB			varchar(2),
		Freetime		int,
		MinCnt			int,
		MaxCnt			int,
		EffectiveDate	DateTime,
		EffectiveDateFrom	varchar(50),
		CostGroup			varchar(50),
		FileName			varchar(200),
		DateUploaded		Datetime,
		UploadedBy			varchar(200)
	)
	
	SEt @ItemKeys = convert(varchar,@TriaxleItemKey) + ':' + convert(varchar,@ChassisPortItemKey) + ':' + convert(varchar,@ChassisJCTItemKey)

	insert into #ItemsAcc
	Exec AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys, @MarketKey,@OrderDetailKey, @ContainerNo	,
			@Terminal, @Location, @city	, @State, @TruckType, @CustKey,@IsGeneralNAC, 0

	if(@IsDebug = 1)
	Begin
		SElect @ItemKeys as ItemKeys
		Select '#ItemsAcc',* from #ItemsAcc
	End

	/* **************************  FINAL INSERT ITEM AND WRITE LOG  ************************* */
	if(@IsTriaxle = 1 and @BillDays > 0 and isnull(@IsTriaxleItemExists,0) = 0)
	Begin
		insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
			BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, DateTo)
		Select I.ItemKey, @FromRouteKey, ISNULL(a.RATE, I.UnitCost), @BillDays, ISNULL(a.RATE, I.UnitCost), Getdate(),  
			1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @StartDate, @StopDate
		from Item I With (NOLOCK)
		LEFT JOIN #ItemsAcc A ON i.ItemKey = A.ItemKey
		where I.itemkey = @TriaxleItemKey

		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Tri-Axle Item Added for Container '
	end
	Else if(@FromChassisCategory = 'JCT' and @BillDays > 0 and isnull(@IsJCTItemExists,0) = 0)
	Begin
		insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
			BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, DateTo)
		Select I.ItemKey, @FromRouteKey, ISNULL(a.RATE, I.UnitCost), @BillDays, ISNULL(a.RATE, I.UnitCost), Getdate(),  
			1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @StartDate, @StopDate
		from Item I With (NOLOCK)
		LEFT JOIN #ItemsAcc A ON i.ItemKey = A.ItemKey
		where i.itemkey = @ChassisJCTItemKey

		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(),  'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Chassis (JCT) Item Added for Container '
	End
	Else if(@FromChassisCategory = 'PORT' and @BillDays > 0 and isnull(@IsPortItemExists,0) = 0)
	Begin
		insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
			BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, DateTo)
		Select I.ItemKey, @FromRouteKey, ISNULL(a.RATE, I.UnitCost), @BillDays, ISNULL(a.RATE, I.UnitCost), Getdate(),  
			1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @StartDate, @StopDate
		from Item I With (NOLOCK)
		LEFT JOIN #ItemsAcc A ON i.ItemKey = A.ItemKey
		where i.itemkey = @ChassisPortItemKey

		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(),  'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Chassis (PORT) Item Added for Container '
	End
