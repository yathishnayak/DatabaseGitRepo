
/*
SELECT Rt.OrderDetailKey, OD.ContainerNo, count(1)
FROM Routes RT
INNER JOIN OrderDetail OD ON Rt.OrderDetailKey = Od.OrderDetailKey
WHERE ActualArrival is not null AND ActualDeparture is not null
group by Rt.OrderDetailKey, OD.ContainerNo 
having count(1) > 4
order by OrderDetailKey desc

121238, 131208, 129596, 131505
*/
CREATE PROC [dbo].[Auto_ChargeYardStorage_Shiva_20260316] -- [Auto_ChargeYardStorage] 265605, 1
(
	@OrderDetailKey		INT = 47695 ,--
	@IsDebug			BIT = 0			
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE		@ContainerNo	VARCHAR(20),
				@OrderType		VARCHAR(20)

	SELECT		L.FromLocation, L.ToLocation, OrderType, OD.ContainerNo, L.LegID, 
				ActualDeparture, ActualArrival, RT.LegNo, RT.RouteKey 
	INTO		#TMPDATA
	FROM		OrderHeader OH WITH (NOLOCK)
	INNER JOIN	OrderDetail OD WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
	INNER JOIN	Routes RT WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey
	INNER JOIN	OrderType OT WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
	INNER JOIN	LEG L WITH (NOLOCK) ON RT.LegKey = L.LegKey
	WHERE		OD.OrderDetailKey = @OrderDetailKey 
	
	SELECT TOP 1 @OrderType = OrderType, @ContainerNo = ContainerNo FROM  #TMPDATA

	IF(@IsDebug = 1)
	BEGIN
		SELECT '#TMPDATA', ContainerNo, OrderType,LegNo, LegId, FromLocation, ToLocation, 
			ActualDeparture as Pickup, ActualArrival as Delivery FROM #TMPDATA
		SELECT @OrderType as OrderType, @ContainerNo as ContainerNo
	END

	DECLARE @LoadedPickup		DATETIME,
			@LoadedDelivery		DATETIME,
			@EmptyPickup		DATETIME,
			@EmptyDelivery		DATETIME,
			@LoadedRouteKey		INT = 0,
			@EmptyRouteKey		INT = 0,
			@LoadedDateDiff		INT,
			@EmptyDateDiff		INT,
			@LoadedItemKey		INT = 121,
			@EmptyItemKey		INT = 68,
			@LoadedItemExists	BIT = 0,
			@EmptyItemExists	BIT = 0,
			@LoadedQtyExists	INT = 0,
			@EmptyQtyExists		INT = 0


	/* **************************  GET COST FROM SELL DB ************************* */
	Create Table #ParamsCYS
	(
		OrderDetailKey			INT,
		MarketLocationKey		INT,
		Market					VARCHAR(100),
		Terminal				VARCHAR(100),
		City					VARCHAR(100),
		State					VARCHAR(100),
		Location				VARCHAR(100),
		ZoneKey					INT,
		ZoneName				VARCHAR(100),
		ContainerNo				VARCHAR(20),
		TruckType				VARCHAR(50),
		CustKey					INT,
		CustName				VARCHAR(200)
	)

	INSERT INTO #ParamsCYS
	exec Auto_ReturnsParameters @OrderDetailKey = @OrderDetailKey, @IsDebug = 0

	IF(@IsDebug = 1)
	BEGIN
		SELECT '#Params',* FROM #ParamsCYS
	END

	DECLARE 
		@ItemKeys				VARCHAR(500), -- Colon separated ItemKeys
		@MarketKey				INT = 0,
		@Terminal				VARCHAR(50) = '',
		@Location				VARCHAR(100) = '',
		@City					VARCHAR(100) = '',
		@State					VARCHAR(20) = '',
		@TruckType				VARCHAR(50) = '',
		@CustKey				INT = 0,
		@IsGeneralNAC			BIT = 1 -- When 1, then Ignore custKey AND use General Data in NAC

	SELECT @MarketKey = MarketLocationKey, @Terminal = Terminal, @Location = Location,
			@City = city, @State = State, @TruckType = TruckType, @CustKey = CustKey, @IsGeneralNAC = 1
	FROM #ParamsCYS

	CREATE Table #ItemsAccCYS
	(
		RecordSL			INT,
		LineItem			VARCHAR(200),
		Market				VARCHAR(100),
		Terminal			VARCHAR(100),
		ItemKey				INT,
		Rate				NUMERIC(18,4),
		BvsNB				VARCHAR(2),
		Freetime			INT,
		MinCnt				INT,
		MaxCnt				INT,
		EffectiveDate		DATETIME,
		EffectiveDateFrom	VARCHAR(50),
		CostGroup			VARCHAR(50),
		FileName			VARCHAR(200),
		DateUploaded		DATETIME,
		UploadedBy			VARCHAR(200)
	)
	
	SET @ItemKeys = convert(VARCHAR,@LoadedItemKey) + ':' + convert(VARCHAR,@EmptyItemKey)
	print '@ItemKeys'
	print @ItemKeys
	IF(@IsDebug = 1)
	BEGIN
	select @ItemKeys, @MarketKey,@OrderDetailKey, @ContainerNo	,
			@Terminal, @Location, @City	, @State, @TruckType, @CustKey,@IsGeneralNAC
			END

	INSERT INTO #ItemsAccCYS
	Exec AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys, @MarketKey,@OrderDetailKey, @ContainerNo	,
			@Terminal, @Location, @City	, @State, @TruckType, @CustKey,@IsGeneralNAC, 0
print 'after'
	IF(@IsDebug = 1)
	BEGIN
		SELECT @ItemKeys as ItemKeys
		SELECT '#ItemsAcc',* FROM #ItemsAccCYS
	END


	IF(@OrderType = 'Import')
	BEGIN
		SELECT @LoadedDelivery = ActualArrival, @LoadedRouteKey = RouteKey
		FROM #TMPDATA
		WHERE FromLocation = 'Port' AND ToLocation = 'Yard'

		SELECT @LoadedPickup = ActualDeparture
		FROM #TMPDATA
		WHERE FromLocation = 'Yard' AND ToLocation = 'Consignee'

		SELECT @EmptyDelivery = ActualArrival, @EmptyRouteKey = RouteKey 
		FROM #TMPDATA
		WHERE FromLocation = 'Consignee' AND ToLocation = 'Yard'

		SELECT @EmptyPickup = ActualDeparture
		FROM #TMPDATA
		WHERE FromLocation = 'Yard' AND ToLocation = 'Port'

		IF(@LoadedDelivery is not null AND @LoadedPickup is not null)
		BEGIN
			SET				@LoadedDateDiff = DATEDIFF(D, @LoadedDelivery, @LoadedPickup)

			SELECT top 1	@LoadedQtyExists = Qty, @LoadedItemExists = 1 
			FROM			OrderExpense OE WITH (NOLOCK)
			INNER JOIN		Item I WITH (NOLOCK) ON OE.ItemKey = I.ItemKey
			INNER JOIN		Item M  WITH (NOLOCK) ON M.ItemKey = I.MasterItemKey
			WHERE			OrderDetailKey = @OrderDetailKey AND M.ItemKey = @LoadedItemKey

			IF(@LoadedDateDiff > 1 AND isnull(@LoadedItemExists,0) = 0)
			BEGIN

				INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
								BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, DateTo)
				SELECT			I.ItemKey, @LoadedRouteKey, ISNULL(A.Rate, I.UnitCost), (@LoadedDateDiff-1), ISNULL(A.Rate, I.UnitCost), Getdate(),  
								1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @LoadedDelivery, @LoadedPickup
				FROM			Item I WITH (NOLOCK)
				INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
				LEFT JOIN		#ItemsAccCYS A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
				WHERE			I.ItemKey = @LoadedItemKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Storage (Loaded) Item Added for Container '
			END
		END
		IF(@EmptyDelivery is not null AND @EmptyPickup is not null)
		BEGIN
			SET				@EmptyDateDiff = DATEDIFF(D, @EmptyDelivery, @EmptyPickup)

			SELECT top 1	@EmptyQtyExists = Qty, @EmptyItemExists = 1 
			FROM			OrderExpense  OE WITH (NOLOCK)
			INNER JOIN		Item I WITH (NOLOCK) ON OE.ItemKey = I.ItemKey
			INNER JOIN		Item M WITH (NOLOCK) ON M.ItemKey = I.MasterItemKey
			WHERE			OrderDetailKey = @OrderDetailKey AND M.ItemKey = @EmptyItemKey

			IF(@EmptyDateDiff > 1 AND isnull(@EmptyItemExists,0) = 0)
			BEGIN

				INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
								BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, DateTo)
				SELECT			I.ItemKey, @EmptyRouteKey, ISNULL(A.Rate, I.UnitCost), (@EmptyDateDiff-1), ISNULL(A.Rate, I.UnitCost), Getdate(),  
								1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @EmptyDelivery, @EmptyPickup
				FROM			Item I WITH (NOLOCK)
				INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
				LEFT JOIN		#ItemsAccCYS A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
				WHERE			I.ItemKey = @EmptyItemKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Storage (Empty) Item Added for Container '
			END
		END
	END

	IF(@OrderType = 'Export')
	BEGIN
		SELECT @LoadedDelivery = ActualArrival, @LoadedRouteKey = RouteKey
		FROM #TMPDATA
		WHERE FromLocation = 'Consignee' AND ToLocation = 'Yard'

		SELECT @LoadedPickup = ActualDeparture
		FROM #TMPDATA
		WHERE FromLocation = 'Yard' AND ToLocation = 'Port'

		SELECT @EmptyDelivery = ActualArrival, @EmptyRouteKey = RouteKey 
		FROM #TMPDATA
		WHERE FromLocation = 'Port' AND ToLocation = 'Yard'

		SELECT @EmptyPickup = ActualDeparture
		FROM #TMPDATA
		WHERE FromLocation = 'Yard' AND ToLocation = 'Consignee'

		IF(@LoadedDelivery is not null AND @LoadedPickup is not null)
		BEGIN
			SET				@LoadedDateDiff = DATEDIFF(D, @LoadedDelivery, @LoadedPickup)

			SELECT top 1	@LoadedQtyExists = Qty, @LoadedItemExists = 1 
			FROM			OrderExpense OE WITH (NOLOCK)
			INNER JOIN		Item I WITH (NOLOCK) ON OE.ItemKey = I.ItemKey
			INNER JOIN		Item M WITH (NOLOCK) ON M.ItemKey = I.MasterItemKey
			WHERE			OrderDetailKey = @OrderDetailKey AND M.ItemKey = @LoadedItemKey

			IF(@LoadedDateDiff > 1 AND isnull(@LoadedItemExists,0) = 0)
			BEGIN
				INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
								BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, DateTo)
				SELECT			I.ItemKey, @LoadedRouteKey, ISNULL(A.Rate, I.UnitCost), (@LoadedDateDiff-1), ISNULL(A.Rate, I.UnitCost), Getdate(),  
								1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @LoadedDelivery, @LoadedPickup
				FROM			Item I WITH (NOLOCK)
				INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
				LEFT JOIN		#ItemsAccCYS A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
				WHERE			I.ItemKey = @LoadedItemKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Storage (Loaded) Item Added for Container '
			END
		END
		IF(@EmptyDelivery is not null AND @EmptyPickup is not null)
		BEGIN
			SET				@EmptyDateDiff = DATEDIFF(D, @EmptyDelivery, @EmptyPickup)
			SELECT top 1	@EmptyQtyExists = Qty, @EmptyItemExists = 1 
			FROM			OrderExpense OE WITH (NOLOCK)
			INNER JOIN		Item I WITH (NOLOCK) ON OE.ItemKey = I.ItemKey
			INNER JOIN		Item M WITH (NOLOCK) ON M.ItemKey = I.MasterItemKey
			WHERE			OrderDetailKey = @OrderDetailKey AND M.ItemKey = @EmptyItemKey

			IF(@EmptyDateDiff > 1 AND isnull(@EmptyItemExists,0) = 0)
			BEGIN
				INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
								BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, DateTo)
				SELECT			I.ItemKey, @EmptyRouteKey, ISNULL(A.Rate, I.UnitCost), (@EmptyDateDiff-1), ISNULL(A.Rate, I.UnitCost), Getdate(),  
								1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @EmptyDelivery, @EmptyPickup
				FROM			Item I WITH (NOLOCK)
				INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
				LEFT JOIN		#ItemsAccCYS A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
				WHERE			I.ItemKey = @EmptyItemKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Yard Storage (Empty) Item Added for Container '
			END
		END
	END
		
		IF(@IsDebug = 1)
		BEGIN
			SELECT  @LoadedDateDiff-1 as LoadedDateDiff, 
					@LoadedItemKey as LoadedItemKey, 
					@LoadedItemExists as LoadedItemExists,
					@LoadedQtyExists as LoadedQtyExists,
					@LoadedRouteKey as LoadedRouteKey,
					@EmptyDateDiff-1 as EmptyDateDiff ,
					@EmptyItemKey as EmptyItemKey, 
					@EmptyItemExists as EmptyItemExists,
					@EmptyQtyExists as EmptyQtyExists,
					@EmptyRouteKey as EmptyRouteKey
		END

	DROP TABLE #TMPDATA
	drop table #ItemsAccCYS
	drop table #ParamsCYS
END
