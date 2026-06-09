
CREATE proc [dbo].[Auto_ChargeTMFCTF] -- Auto_ChargeTMFCTF 127335, 1
(
	@OrderDetailKey		INT = 47695 ,--
	@IsDebug			BIT = 0			
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @TMFCheckOff		BIT = 0,
			@CTFCheckOff		BIT = 0,
			@TMFJctPaid			BIT = 0,
			@TMFCustomerPaid	BIT = 0,
			@CTFJCTPaid			BIT = 0,
			@CTFCustomerPaid	BIT = 0,
			@ContainerSize		INT = 0,
			@TMFchargeExists	BIT = 0,
			@CTFChargeExists	BIT = 0,
			@CTF_CS20ITemKey	INT = 281,
			@CTF_CS40ItemKey	INT = 282,
			@TMF_CS20ITemKey	INT = 297,
			@TMF_CS40ITemKey	INT = 298,
			@CTF_20Exists		BIT = 0,
			@CTF_40Exists		BIT = 0,
			@TMF_20Exists		BIT = 0,
			@TMF_40Exists		BIT = 0,
			@CTFDate			DateTime,
			@TMFDate			Datetime
	
	
	UPDATE		CS 
	SET			WarehouseSizeMap = LEFT(Description,2)
	FROM		ContainerSize CS WITH (NOLOCK)
	WHERE		ISNULL(WarehouseSizeMap,'') = '' and ISNUMERIC(LEFT(Description,2)) = 1

	SELECT		@TMFCheckOff = OD.TMFCheckOff, @CTFCheckOff = CTFCheckOff,
				@TMFJctPaid = OD.IsTMFJCTPaid, @TMFCustomerPaid = OD.IsTMFCustomerPaid,
				@CTFJCTPaid = OD.IsCTFJCTPaid, @CTFCustomerPaid = OD.IsCTFCustomerPaid,
				@ContainerSize = Cs.WarehouseSizeMap,
				@CTFDate = OD.CTFMarkDate, @TMFDate = OD.TMFMarkDate
	FROM		OrderDetail OD WITH (NOLOCK)
	INNER JOIN	ContainerSize CS WITH (NOLOCK) on OD.ContainerSizeKey = CS.ContainerSizeKey
	WHERE		OrderDetailKey = @OrderDetailKey

	SELECT		@CTF_20Exists = case when count(1) > 0 then 1 ELSE 0 END
	FROM		OrderExpense OE WITH (NOLOCK) 
	INNER JOIN  Item I WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	INNER JOIN  Item M WITH (NOLOCK) on I.MasterItemKey = M.ItemKey
	WHERE		OrderDetailKey = @OrderDetailKey and M.itemkey = @CTF_CS20ITemKey --and ChargeSource = 'Auto'

	SELECT		@CTF_40Exists = case when count(1) > 0 then 1 ELSE 0 END
	FROM		OrderExpense OE WITH (NOLOCK) 
	INNER JOIN  Item I WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	INNER JOIN  Item M WITH (NOLOCK) on I.MasterItemKey = M.ItemKey
	WHERE		OrderDetailKey = @OrderDetailKey and M.itemkey = @CTF_CS40ITemKey --and ChargeSource = 'Auto'

	SELECT		@TMF_20Exists = case when count(1) > 0 then 1 ELSE 0 END
	FROM		OrderExpense OE WITH (NOLOCK) 
	INNER JOIN  Item I WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	INNER JOIN  Item M WITH (NOLOCK) on I.MasterItemKey = M.ItemKey
	WHERE		OrderDetailKey = @OrderDetailKey and M.itemkey = @TMF_CS20ITemKey --and ChargeSource = 'Auto'

	SELECT		@TMF_40Exists = case when count(1) > 0 then 1 ELSE 0 END
	FROM		OrderExpense OE WITH (NOLOCK) 
	INNER JOIN  Item I WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	INNER JOIN  Item M WITH (NOLOCK) on I.MasterItemKey = M.ItemKey
	WHERE		OrderDetailKey = @OrderDetailKey and M.itemkey = @TMF_CS40ITemKey --and ChargeSource = 'Auto'

	DECLARE  @RouteKey		INT,
			 @ContainerNo	VARCHAR(20)

	SELECT TOP 1	@RouteKey = RouteKey
	FROM			Routes RT WITH (NOLOCK) 
	WHERE			OrderDetailKey = @OrderDetailKey
	order by		RT.LegNo

	SELECT  @RouteKey = ISNULL(@RouteKey,0) 

	SELECT  @ContainerNo = ContainerNo 
	FROM	OrderDetail OD with (NOLOCK) 
	WHERE	OrderDetailKey = @OrderDetailKey

		/* **************************  GET COST FROM SELL DB ************************* */
	CREATE TABLE #ParamsCTC
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

	INSERT INTO #ParamsCTC
	EXEC Auto_ReturnsParameters @OrderDetailKey = @OrderDetailKey, @isDebug = 0

	DECLARE 
		@ItemKeys				VARCHAR(500), -- Colon separated itemkeys
		@MarketKey				INT = 0,
		@Terminal				VARCHAR(50) = '',
		@Location				VARCHAR(100) = '',
		@city					VARCHAR(100) = '',
		@State					VARCHAR(20) = '',
		@zoneKey				INT = 0,
		@ZoneName				VARCHAR(100) ='',
		@TruckType				VARCHAR(50) = '',
		@CustKey				INT = 0,
		@IsGeneralNAC			BIT = 1 -- When 1, then Ignore custKey and use General Data in NAC

	SELECT @MarketKey = MarketLocationKey, @Terminal = Terminal, @Location = Location, @zonekey = ZoneKey, @ZoneName = ZoneName,
			@City = city, @State = State, @TruckType = TruckType, @CustKey = CustKey, @IsGeneralNAC = 1
	FROM #ParamsCTC

	IF(@IsDebug = 1)
	BEGIN
		SELECT '#Params',* FROM #ParamsCTC
	END

	CREATE TABLE #ItemsAccCTC
	(
		RecordSL			INT,
		LineItem			VARCHAR(200),
		Market				VARCHAR(100),
		Terminal			VARCHAR(100),
		ItemKey				INT,
		Rate				numeric(18,4),
		BvsNB				VARCHAR(2),
		Freetime			INT,
		MinCnt				INT,
		MaxCnt				INT,
		EffectiveDate		DateTime,
		EffectiveDateFROM	VARCHAR(50),
		CostGroup			VARCHAR(50),
		FileName			VARCHAR(200),
		DateUploaded		Datetime,
		UploadedBy			VARCHAR(200)
	)
	
	SET @ItemKeys = CONVERT(VARCHAR,@TMF_CS20ITemKey)	+ ':' 
					+ CONVERT(VARCHAR,@TMF_CS40ITemKey) + ':' 
					+ CONVERT(VARCHAR,@CTF_CS20ITemKey) + ':' 
					+ CONVERT(VARCHAR,@CTF_CS40ITemKey)

	INSERT INTO #ItemsAccCTC
	EXEC AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys, @MarketKey,@OrderDetailKey, @ContainerNo	,
			@Terminal, @Location, @city	, @State, @TruckType, @CustKey,@IsGeneralNAC, 0

	IF(@IsDebug = 1)
	BEGIN
		SELECT @ItemKeys as ItemKeys
		SELECT '#ItemsAcc',* FROM #ItemsAccCTC
	END

	IF ISNULL(@RouteKey,0) <> 0
	BEGIN
		--BEGIN Transaction
		BEGIN Try

			--********************* TMF  ******************************
			--********************* TMF CONTAINER SIZE 20  ******************************
			IF(@TMFCheckOff = 1 and @TMFJctPaid = 1 and ISNULL(@TMF_20Exists,0) = 0 and @ContainerSize = 20)
			BEGIN
				INSERT INTO		OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
								BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				SELECT			I.ItemKey, @RouteKey, ISNULL(A.Rate, I.UnitCost), 1, ISNULL(A.Rate, I.UnitCost), Getdate(),  1, 0, 
								1, 0, 0, 'Auto', @OrderDetailKey, @TMFDate
				FROM			Item I With (NOLOCK)
				INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
				LEFT JOIN		#ItemsAccCTC A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
				WHERE			I.ItemKey = @TMF_CS20ITemKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Pier Pass (20) Item Added for Container '
			END
			ELSE IF (@TMFCheckOff = 1 and @TMFJctPaid = 0 and ISNULL(@TMF_20Exists,0) = 1 and @ContainerSize = 20)
			BEGIN
				Delete FROM OrderExpense
				WHERE		OrderDetailKey = @OrderDetailKey and Itemkey = @TMF_CS20ITemKey and ChargeSource = 'Auto'

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT		GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Pier Pass (20)  Item Deleted for Container'
			END

			--********************* TMF CONTAINER SIZE 40  ******************************
			IF(@TMFCheckOff = 1 and @TMFJctPaid = 1 and ISNULL(@TMF_40Exists,0) = 0 and @ContainerSize = 40)
			BEGIN
				INSERT INTO		OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
								BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				SELECT			I.ItemKey, @RouteKey, ISNULL(A.Rate, I.UnitCost), 1, ISNULL(A.Rate, I.UnitCost), Getdate(),  1, 0, 
								1, 0, 0, 'Auto', @OrderDetailKey, @TMFDate
				FROM			Item I With (NOLOCK)
				INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
				LEFT JOIN		#ItemsAccCTC A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
				WHERE			I.ItemKey = @TMF_CS40ITemKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Pier Pass (40) Item Added for Container '
			END
			ELSE IF (@TMFCheckOff = 1 and @TMFJctPaid = 0 and ISNULL(@TMF_40Exists,0) = 1 and @ContainerSize = 40)
			BEGIN
				Delete FROM OrderExpense
				WHERE		OrderDetailKey = @OrderDetailKey and Itemkey = @TMF_CS20ITemKey and ChargeSource = 'Auto'

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT		GETDATE(),'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Pier Pass (40)  Item Deleted for Container'
			END


			--********************* CTF  ******************************
			--********************* CTF CONTAINER SIZE 20  ******************************
			IF(@CTFCheckOff = 1 and @CTFJctPaid = 1 and ISNULL(@CTF_20Exists,0) = 0 and @ContainerSize = 20)
			BEGIN
				INSERT INTO		OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
								BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				SELECT			I.ItemKey, @RouteKey, ISNULL(A.Rate, I.UnitCost), 1, ISNULL(A.Rate, I.UnitCost), Getdate(),  1, 0, 
								1, 0, 0, 'Auto', @OrderDetailKey, @CTFDate
				FROM			Item I With (NOLOCK)
				INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
				LEFT JOIN		#ItemsAccCTC A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
				WHERE			I.ItemKey = @CTF_CS20ITemKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' ,'Clean Truck Fee (20) Item Added for Container '
			END
			ELSE IF (@CTFCheckOff = 1 and @CTFJctPaid = 0 and ISNULL(@CTF_20Exists,0) = 1 and @ContainerSize = 20)
			BEGIN
				Delete FROM OrderExpense
				WHERE		OrderDetailKey = @OrderDetailKey and Itemkey = @CTF_CS20ITemKey and ChargeSource = 'Auto'

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT		GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Clean Truck Fee (20)  Item Deleted for Container'
			END

			--********************* CTF CONTAINER SIZE 40  ******************************
			IF(@CTFCheckOff = 1 and @CTFJctPaid = 1 and ISNULL(@CTF_40Exists,0) = 0 and @ContainerSize = 40)
			BEGIN
				INSERT INTO		OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
								BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				SELECT			I.ItemKey, @RouteKey, ISNULL(A.Rate, I.UnitCost), 1, ISNULL(A.Rate, I.UnitCost), Getdate(),  1, 0, 
								1, 0, 0, 'Auto', @OrderDetailKey, @CTFDate
				FROM			Item I With (NOLOCK)
				INNER JOIN		Item M WITH (NOLOCK) ON I.MasterItemKey = M.ItemKey
				LEFT JOIN		#ItemsAccCTC A WITH (NOLOCK) ON M.ItemKey = A.ItemKey
				WHERE			I.ItemKey = @CTF_CS40ITemKey

				INSERT INTO		AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT			GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Clean Truck Fee (40) Item Added for Container '
			END
			ELSE IF (@CTFCheckOff = 1 and @CTFJctPaid = 0 and ISNULL(@CTF_40Exists,0) = 1 and @ContainerSize = 40)
			BEGIN
				Delete FROM OrderExpense
				WHERE		OrderDetailKey = @OrderDetailKey and Itemkey = @CTF_CS20ITemKey and ChargeSource = 'Auto'

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				SELECT		GETDATE(), 'Admin', 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Clean Truck Fee (40)  Item Deleted for Container'
			END
			--Commit Transaction
		END Try
		BEGIN Catch
			--Rollback Transaction
		END Catch
	END
END
