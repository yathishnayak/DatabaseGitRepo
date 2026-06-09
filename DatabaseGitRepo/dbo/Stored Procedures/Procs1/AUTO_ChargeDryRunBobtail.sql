-- 129159, 129105, 129098, 128852, 121695, 127232, 127231
CREATE PROC [dbo].[AUTO_ChargeDryRunBobtail] -- AUTO_ChargeDryRunBobtail 107405, 1
(
	@OrderDetailKey		INT = 121425,
	@IsDebug			BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE @ContainerNo					VARCHAR(20),
			@OrderType						VARCHAR(20),
			@RouteKey						INT,
			@IsDryRun						BIT = 0,
			@IsBobtail						BIT = 0,
			@BobTailItemKey					INT = 234,
			@DryRunImportItemKey			INT = 11,
			@DryRunExportItemKey			INT = 10,
			@DryRunHazardItemKey			INT = 237,
			@IsDryRunItemExists				BIT = 0,
			@IsBobtailItemExists			BIT = 0,
			@IsDryRunHazardItemExists		BIT = 0,
			@IsHazard						BIT = 0,
			@IsImport						BIT = 0,
			@IsExport						BIT = 0,
			@DryRunDate						Datetime,
			@BobTailDate					Datetime

	SELECT @ContainerNo = ContainerNo FROM OrderDetail WITH (NOLOCK)
							WHERE OrderDetailKey = @OrderDetailKey

	SELECT @IsDryRun  = CASE WHEN ISNULL(IsDryRun, 0)  = 1 THEN 1 ELSE 0 END,
		   @IsBobtail = CASE WHEN ISNULL(IsBobtail, 0) = 1 THEN 1 ELSE 0 END,
		   @DryRunDate = CASE WHEN ISNULL(IsDryRun, 0)  = 1 THEN ActualDeparture ELSE null END ,
		   @BobTailDate = CASE WHEN ISNULL(IsBobtail, 0) = 1 THEN ActualDeparture ELSE null END
						FROM Routes RT WITH (NOLOCK)
						WHERE OrderDetailKey = @OrderDetailKey

	SELECT @IsHazard = CASE WHEN (SELECT COUNT(*) FROM OrderDetail od WITH (NOLOCK)
						INNER JOIN ContainerTypesLink CTL WITH (NOLOCK) on OD.OrderDetailKey = CTL.OrderDetailKey
						WHERE ContainerTypeKey = 1
						AND OD.OrderDetailKey = @OrderDetailKey) > 0 THEN 1 ELSE 0 END
	
	SELECT @IsImport = CASE WHEN OT.OrderType = 'Import' THEN 1 ELSE 0 END,
		   @IsExport = CASE WHEN OT.OrderType = 'Export' THEN 1 ELSE 0 END
						FROM OrderDetail OD WITH (NOLOCK)
						INNER JOIN OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
						INNER JOIN OrderType OT WITH (NOLOCK) on OH.OrderTypekey = OT.OrderTypekey
						AND OrderDetailKey = @OrderDetailKey
	
	DECLARE		@BobRouteKey			INT,
				@BobLegCnt				INT,
				@DryRouteKey			INT,
				@DryLegCnt				INT
	
	SELECT		@DryRouteKey = CASE WHEN ISNULL(IsDryRun, 0)  = 1 THEN RouteKey ELSE NULL END,
				@BobRouteKey = CASE WHEN ISNULL(IsBobtail, 0) = 1 THEN RouteKey ELSE NULL END
	FROM		Routes WITH (NOLOCK)
	WHERE		OrderDetailKey = @OrderDetailKey

	SELECT		@DryLegCnt = CASE WHEN ISNULL(IsDryRun, 0)  = 1 THEN (SELECT COUNT(legkey) as DryLegCnt) ELSE 0 END,
				@BobLegCnt = CASE WHEN ISNULL(IsBobtail, 0) = 1 THEN (SELECT COUNT(legkey) as BobLegCnt) ELSE 0 END
	FROM		Routes RT WITH (NOLOCK)
	WHERE		RT.OrderDetailKey = @OrderDetailKey
	GROUP BY	RT.OrderDetailKey, IsBobtail, IsDryRun

		/* **************************  GET COST FROM SELL DB ************************* */
	CREATE TABLE #ParamsDRBT
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

	INSERT INTO #ParamsDRBT
	EXEC Auto_ReturnsParameters @OrderDetailKey = @OrderDetailKey, @IsDebug = 0

	DECLARE 
		@ItemKeys				VARCHAR(500), -- Colon separated ItemKeys
		@MarketKey				INT = 0,
		@Terminal				VARCHAR(50) = '',
		@Location				VARCHAR(100) = '',
		@City					VARCHAR(100) = '',
		@State					VARCHAR(20) = '',
		@TruckType				VARCHAR(50) = '',
		@CustKey				INT = 0,
		@IsGeneralNAC			BIT = 1 -- WHEN 1, THEN Ignore custKey AND use General Data in NAC

	SELECT	@MarketKey = MarketLocationKey, @Terminal = Terminal, @Location = Location,
				@City = city, @State = State, @TruckType = TruckType, @CustKey = CustKey, @IsGeneralNAC = 1
	FROM	#ParamsDRBT

	IF(@IsDebug = 1)
	BEGIN
		SELECT '#Params',* FROM #ParamsDRBT
	END

	CREATE TABLE #ItemsAccDRBT
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
		EffectiveDateFROM	VARCHAR(50),
		CostGroup			VARCHAR(50),
		FileName			VARCHAR(200),
		DateUploaded		DATETIME,
		UploadedBy			VARCHAR(200)
	)
	
	SET @ItemKeys = convert(VARCHAR,@DryRunImportItemKey)   + ':' 
					+ convert(VARCHAR,@DryRunExportItemKey) + ':' 
					+ convert(VARCHAR,@DryRunHazardItemKey) + ':' 
					+ convert(VARCHAR,@BobTailItemKey)

	INSERT INTO #ItemsAccDRBT
	EXEC AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys, @MarketKey,@OrderDetailKey, @ContainerNo	,
			@Terminal, @Location, @City, @State, @TruckType, @CustKey,@IsGeneralNAC, 0

	IF(@IsDebug = 1)
	BEGIN
		SELECT @ItemKeys as ItemKeys
		SELECT '#ItemsAcc',* FROM #ItemsAccDRBT
	END

	IF (@IsDryRun = 1 and @IsImport = 1)
	BEGIN
		SELECT		@IsDryRunItemExists = 1 
		FROM		OrderExpense OE WITH (NOLOCK)
		INNER JOIN  Item I WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
		INNER JOIN  Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
		WHERE		RouteKey = @DryRouteKey AND M.ItemKey = @DryRunImportItemKey
		
		IF (@IsDryRunItemExists = 0)
		BEGIN
			INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
							BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			SELECT			I.ItemKey, @DryRouteKey, ISNULL(A.Rate, I.UnitCost), @DryLegCnt, ISNULL(A.Rate, I.UnitCost), Getdate(),  
							1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DryRunDate
			FROM			Item I WITH (NOLOCK)
			INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
			LEFT JOIN		#ItemsAccDRBT A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
			WHERE			I.ItemKey = @DryRunImportItemKey

			INSERT			INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'DryRun Import Item Added for Container'
		END
	END

	IF (@IsDryRun = 1 and @IsExport = 1)
	BEGIN
		SELECT		@IsDryRunItemExists = 1 
		FROM		OrderExpense OE WITH (NOLOCK)
		INNER JOIN  Item I WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
		INNER JOIN  Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey 
		WHERE		RouteKey = @DryRouteKey AND M.ItemKey = @DryRunExportItemKey
		
		IF (@IsDryRunItemExists = 0)
		BEGIN
			INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
							BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			SELECT			I.ItemKey, @DryRouteKey, ISNULL(A.Rate, I.UnitCost), @DryLegCnt, ISNULL(A.Rate, I.UnitCost), Getdate(),  
							1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DryRunDate
			FROM			Item I WITH (NOLOCK)
			INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
			LEFT JOIN		#ItemsAccDRBT A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
			WHERE			I.ItemKey = @DryRunExportItemKey

			INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'DryRun Export Item Added for Container'
		END
	END

	IF (@IsDryRun = 1 AND @IsHazard = 1)
	BEGIN
		SELECT		@IsDryRunItemExists = 1 
		FROM		OrderExpense OE WITH (NOLOCK)
		INNER JOIN  Item I WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
		INNER JOIN  Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
		WHERE		RouteKey = @DryRouteKey AND M.ItemKey = @DryRunHazardItemKey
		
		IF (@IsDryRunItemExists = 0)
		BEGIN
			INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
							BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			SELECT			I.ItemKey, @DryRouteKey, ISNULL(A.Rate, I.UnitCost), @DryLegCnt, ISNULL(A.Rate, I.UnitCost), Getdate(),  
							1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DryRunDate
			FROM			Item I WITH (NOLOCK)
			INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
			LEFT JOIN		#ItemsAccDRBT A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
			WHERE			I.ItemKey = @DryRunHazardItemKey

			INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'DryRun Hazard Item Added for Container'
		END
	END

	IF (@IsBobtail = 1)
	BEGIN
		SELECT		@IsBobtailItemExists = 1 
		FROM		OrderExpense OE WITH (NOLOCK)
		INNER JOIN  Item I WITH (NOLOCK) ON OE.Itemkey = I.ItemKey
		INNER JOIN  Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
		WHERE		RouteKey = @BobRouteKey AND M.ItemKey = @BobTailItemKey
		
		IF (@IsBobtailItemExists = 0)
		BEGIN
			INSERT INTO		OrderExpense (ItemKey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
							BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			SELECT			I.ItemKey, @BobRouteKey, ISNULL(A.Rate, I.UnitCost), @BobLegCnt, ISNULL(A.Rate, I.UnitCost), Getdate(),  
							1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @BobTailDate
			FROM			Item I WITH (NOLOCK)
			INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
			LEFT JOIN		#ItemsAccDRBT A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
			WHERE			I.ItemKey = @BobTailItemKey

			INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'BobTail Item Added for Container'
		END
	END
END
