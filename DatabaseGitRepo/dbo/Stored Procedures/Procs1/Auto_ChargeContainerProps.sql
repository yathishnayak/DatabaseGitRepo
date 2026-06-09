CREATE proc [dbo].[Auto_ChargeContainerProps] -- Auto_ChargeContainerProps 117582, 1
(
	@OrderDetailKey		int = 47695 ,--
	@IsDebug				bit = 0			
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	Declare @ContainerNo	varchar(20)
			
	Declare 
		@Hazard				bit = 0,
		@Overweight			bit = 0,
		@Triaxle			bit = 0,
		@Needstobescaled	bit = 0,
		@Weekenddelivery	bit = 0,
		@Transload			bit = 0,
		@Genset				bit = 0,
		@Permits			bit = 0,
		@OTR				bit = 0,
		@Class9				bit = 0,
		@TL					bit = 0,
		@BNDD               bit = 0,
		@PWT                bit = 0,
		@CWT                bit = 0

	Declare 
		@HazardExists				bit = 0,
		@OverweightExists			bit = 0,
		@TriaxleExists				bit = 0,
		@NeedstobescaledExists		bit = 0,
		@WeekenddeliveryExists		bit = 0,
		@TransloadExists			bit = 0,
		@GensetExists				bit = 0,
		@PermitsExists				bit = 0,
		@OTRExists					bit = 0,
		@Class9Exists				bit = 0,
		@TLExists					bit = 0,
		@BNDDExists                 bit = 0,
		@PWTExists                  bit = 0,
		@CWTExists                  bit = 0

	Declare 
		@HazardItemKey				int = 161,
		@OverweightItemKey			int = 232,
		@TriaxleItemKey				int = 22,
		@NeedstobescaledItemKey		int = 113,
		@WeekenddeliveryItemKey		int = 132,
		@TransloadItemKey			int = 0,
		@GensetItemKey				int = 80,
		@PermitsItemKey				int = 137,
		@OTRItemKey					int = 291,
		@LineHaulItemKey			int = 357,
		@BNDDItemKey                int = 371,
		@PWTItemKey                 int = 5,
		@CWTItemKey                 int = 162,
		@Class9ItemKey                 int = 15

	Select CTL.OrderDetailKey,CTL.ContainerTypeKey,CT.TypeDescription
	INTO #TEMP
	from ContainerTypesLink CTL WITH (NOLOCK)
	inner JOIN ContainerTypes CT WITH (NOLOCK) on CTL.ContainerTypeKey = CT.ContainerTypeKey
	where orderdetailkey = @OrderDetailKey

	SELECT @Hazard		= COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 1
	SELECT @Overweight	= COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 2
	SELECT @Triaxle		= COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 3
	SELECT @Needstobescaled = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 4
	SELECT @Weekenddelivery = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 5
	SELECT @Transload = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 6
	SELECT @Genset = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 7
	SELECT @Permits = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 8
	SELECT @OTR = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 9
	SELECT @BNDD = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 16
	SELECT @PWT = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 12
	SELECT @CWT = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 13
	SELECT @Class9 = COUNT(1) FROM #TEMP WHERE ContainerTypeKey = 10

	if(@IsDebug =1)
	Begin
		SELECT '#TEMP',* FROM #TEMP
		SELECT 'Variables' as Col, 
			   @Hazard			AS 	Hazard,				 
			   @Overweight		AS 	Overweight,			
			   @Triaxle			AS 	Triaxle,		
			   @Needstobescaled	AS 	Needstobescaled,
			   @Weekenddelivery	AS 	Weekenddelivery,
			   @Transload		AS 	Transload,		
			   @Genset			AS 	Genset,			
			   @Permits			AS 	Permits,		
			   @OTR				AS 	OTR,
			   @BNDD			AS  BNDD,
			   @CWT			AS  CWT,
			   @PWT			AS  PWT
	End 

	DROP TABLE #TEMP   --

	UPDATE OE SET OrderDetailKey = RT.OrderDetailKey
	FROM OrderExpense OE
	INNER JOIN ROUTES RT WITH (NOLOCK) ON OE.ROUTEKEY = RT.RouteKey
	WHERE OE.OrderDetailKey IS NULL

	SELECT @HazardExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @HazardItemKey -- Hazard = Hazmat Surcharge 

	SELECT @OverweightExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @OverweightItemKey -- Overweight = Overweight Surcharge 

	SELECT @TriaxleExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @TriaxleItemKey -- Tri-axle

	SELECT @NeedstobescaledExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @NeedstobescaledItemKey -- Needs to be scaled = Scaling Fee 

	SELECT @WeekenddeliveryExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @WeekenddeliveryItemKey -- Weekend Delivery = WEEKEND DELIVERY 

	SELECT @GensetExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	WHERE OrderDetailKey = @OrderDetailKey AND  ITEMKEY = @GensetItemKey -- Genset = Genset 

	SELECT @PermitsExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @PermitsItemKey -- Permits = Permits 

	SELECT @OTRExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @OTRItemKey -- OTR = Dry Van  

	Select @TransloadExists = case when count(1) > 0 then 1 else 0 end FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY in (333, 334, 335, 336, 338, 339, 341, 343, 344) -- Transload  

	--SELECT @Class9Exists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	--inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	--inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	--WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @HazardItemKey -- Class9 = Hazmat

	SELECT @Class9Exists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @Class9ItemKey -- Class9 = Hazmat
	
	SELECT @TLExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (nolock) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @LineHaulItemKey -- TL = LineHaul

	SELECT @BNDDExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (NOLOCK) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @BNDDItemKey -- BNDD

	SELECT @PWTExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (NOLOCK) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @PWTItemKey -- PWT

	SELECT @CWTExists = count(1) FROM OrderExpense OE WITH (NOLOCK) 
	inner join Item I  WITH (NOLOCK) on OE.Itemkey = I.ItemKey
	inner join item M with (NOLOCK) on I.MasterItemKey = M.ItemKey
	WHERE OrderDetailKey = @OrderDetailKey AND  M.ITEMKEY = @CWTItemKey -- CWT

	if(@IsDebug =1)
	Begin
		SELECT @HazardExists			AS 	HazardExists,				 
			   @OverweightExists		AS 	OverweightExists,			
			   @TriaxleExists			AS 	TriaxleExists,		
			   @NeedstobescaledExists	AS 	NeedstobescaledExists,
			   @WeekenddeliveryExists	AS 	WeekenddeliveryExists,
			   @TransloadExists			AS 	TransloadExists,		
			   @GensetExists			AS 	GensetExists,			
			   @PermitsExists			AS 	PermitsExists,		
			   @OTRExists				AS 	OTRExists,
			   @Class9Exists			AS  Class9Exists,
			   @TLExists                AS  TLExists,
			   @BNDDExists              AS  BNDDExists,
			   @CWTExists              AS  CWTExists,
			   @PWTExists              AS  PWTExists
	End 

	Declare		@ContainerModeKey		int,
				@ContainerMode			varchar(50),
				@PalletCount			int = 0,
				@ContainerSize			int =0,
				@ContainerSizeToCalc	int = 0

	if(@Transload = 1)
	Begin
		Select	@ContainerModeKey = WCD.ContainerMode, 
				@ContainerMode = Case when WCD.ContainerMode = 1 then 'Floor' 
										when WCD.ContainerMode = 2 then 'Palletized'
										else 'NA' end,
				@PalletCount = WCD.PalletCount,
				@ContainerSize = isnull(CS.WarehouseSizeMap,0)
		from Warehouse_ContainerDetails WCD WITH (NOLOCK)
		inner join OrderDetail OD WITH (NOLOCK) on WCD.OrderDetailKey = OD.OrderDetailKey
		inner join ContainerSize CS WITH (NOLOCK) on OD.ContainerSizeKey = CS.ContainerSizeKey
		where WCD.OrderDetailKey = @OrderDetailKey
		
		if(@ContainerSize in (20,22))
		Begin
			set @ContainerSizeToCalc = 20
		End
		Else IF (@ContainerSize in (40, 45, 42, 55, 53, 52))
		Begin
			SEt @ContainerSizeToCalc = 40
		End

		if(@IsDebug = 1)
		Begin
			SElect  @ContainerModeKey as ContainerModeKey,
					@ContainerMode as ContainerMode,
					@PalletCount  as PalletCount,
					@ContainerSize as ContainerSize,
					@ContainerSizeToCalc as ContainerSizeToCalc
		End

		if( @ContainerModeKey = 2 and @ContainerSizeToCalc = 20)
		Begin
			set @TransloadItemKey = 335
		End
		else if (@ContainerModeKey = 2 and @ContainerSizeToCalc = 40  )
		Begin
			Set @TransloadItemKey = 336
		End
		else if (@ContainerModeKey = 1 and @PalletCount between 1 and 500)
		Begin
			SEt @TransloadItemKey = 338
		End
		else if (@ContainerModeKey = 1 and @PalletCount between 501 and 1000)
		Begin
			SEt @TransloadItemKey = 339
		End
		else if (@ContainerModeKey = 1 and @PalletCount between 1001 and 1500)
		Begin
			SEt @TransloadItemKey = 341
		End
		else if (@ContainerModeKey = 1 and @PalletCount between 1501 and 2000)
		Begin
			SEt @TransloadItemKey = 343
		End
		else if (@ContainerModeKey = 1 and @PalletCount > 2000)
		Begin
			SEt @TransloadItemKey = 344
		End
	End

	Declare @RouteKey	int, 
			@DateFrom	datetime
	Select top 1 @RouteKey = RouteKey, @DateFrom = ActualDeparture 
		from Routes RT WITH (NOLOCK) 
		Where orderDetailkey = @OrderDetailKey and isnull(IsDryRun,0) = 0 and isnull(IsBobtail,0) = 0
	order by RT.LegNo

	Select @RouteKey = Isnull(@RouteKey,0) 
	IF(@RouteKey=0)
	BEGIN
		RETURN;
	END

	select @ContainerNo = ContainerNo from orderdetail OD with (NOLOCK) where OrderDetailkey = @OrderDetailKey

	/* **************************  GET COST FROM SELL DB ************************* */
	Create Table #ParamsDFPSYS
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

	insert into #ParamsDFPSYS
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
	from #ParamsDFPSYS

	if(@IsDebug = 1)
	Begin
		Select '#Params',* from #ParamsDFPSYS
	End

	CREATE Table #ItemsAccDFPSYS
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
	
	SEt @ItemKeys =  '161:232:22:113:132:80:137:291:333:334:335:336:337:338:339:340:341:342:343:344'

	insert into #ItemsAccDFPSYS
	Exec AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys, @MarketKey,@OrderDetailKey, @ContainerNo	,
			@Terminal, @Location, @city	, @State, @TruckType, @CustKey,@IsGeneralNAC, 0

	if(@IsDebug = 1)
	Begin
		SElect @ItemKeys as ItemKeys
		Select '#ItemsAcc',* from #ItemsAccDFPSYS
	End

	Declare @ChangeCount		int = 0

	--Begin Transaction
	Begin Try
		/* *************************  ADD HAZARD ITEM *********************/
		print '@Hazard'
		print @Hazard
		print'@HazardExists'
		print @HazardExists
		if(@Hazard = 1 and @HazardExists = 0)
		Begin
		print 'entered haz insert'
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @HazardItemKey
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@Hazard = 0 and @HazardExists = 1)
		Begin
		print 'entered haz delete'
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @HazardItemKey and ChargeSource = 'Auto'
			set @ChangeCount = @ChangeCount +1
		End

		/* *************************  ADD OVERWEIGHT ITEM *********************/
		if(@Overweight = 1 and @OverweightExists = 0)
		Begin
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @OverweightItemKey

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Hazard Item Added for Container Prop Selected'
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@Overweight = 0 and @OverweightExists = 1)
		Begin
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @OverweightItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Hazard Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		End

		/* *************************  ADD SCALING FEE (NEEDS TO BE SCALED) ITEM *********************/
		if(@Needstobescaled = 1 and @NeedstobescaledExists = 0)
		Begin
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
			1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @NeedstobescaledItemKey

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Scaling Fee Item Added for Container Prop Selected'
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@Needstobescaled = 0 and @NeedstobescaledExists = 1)
		Begin
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @NeedstobescaledItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Scaling Fee Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		End

		/* *************************  ADD WEEKEND DELIVERY ITEM *********************/
		if(@Weekenddelivery = 1 and @WeekenddeliveryExists = 0)
		Begin
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @WeekenddeliveryItemKey

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Weekend Delivery Item Added for Container Prop Selected'
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@Weekenddelivery = 0 and @WeekenddeliveryExists = 1)
		Begin
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @WeekenddeliveryItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Weekend Delivery Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		End

		/* *************************  ADD GENSET ITEM *********************/
		if(@Genset = 1 and @GensetExists = 0)
		Begin
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @GensetItemKey

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Geneset Item Added for Container Prop Selected'
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@Genset = 0 and @GensetExists = 1)
		Begin
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @GensetItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Genset Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		End

		/* *************************  ADD PERMITS ITEM *********************/
		if(@Permits = 1 and @PermitsExists = 0)
		Begin
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @PermitsItemKey

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Permits Item Added for Container Prop Selected'
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@Permits = 0 and @PermitsExists = 1)
		Begin
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @PermitsItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Permits Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		End

		/* *************************  ADD OTR ITEM *********************/
		-- COMMENTED AS SUGGESTED BY KATHRYN ON 2024-10-14
		/*
		if(@OTR = 1 and @OTRExists = 0)
		Begin
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @OTRItemKey

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Dry Van Item Added for Container Prop Selected'
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@OTR = 0 and @OTRExists = 1)
		Begin
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @OTRItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Dry Van Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		End
		*/

		/* Removed the Process as per Incident #3178  
			/* *************************  ADD TRANSLOAD ITEM *********************/
			if(@Transload = 1 and @TransloadExists = 0)
			Begin
				insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
					BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
				Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
					1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
				from Item I With (NOLOCK)
				LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
				where I.itemkey = @TransloadItemKey

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Transload Item Added for Container Prop Selected'
				set @ChangeCount = @ChangeCount +1
			End
			else IF (@Transload = 0 and @TransloadExists = 1)
			Begin
				Delete from OrderExpense
				Where OrderDetailKey = @OrderDetailKey and Itemkey in (333, 334, 335, 336, 338, 339, 341, 343, 344)
					and ChargeSource = 'Auto'

				INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
				Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Transload Item Deleted for Container Prop De-Selected'
				set @ChangeCount = @ChangeCount +1
			End
		*/

		/* *************************  ADD Class9 ITEM *********************/
	    /* Added the Process as per Incident #3330 */
		print '@Class9 '
		print @Class9 
		print' @Class9Exists'
		print @Class9Exists
		if(@Class9 = 1 and @Class9Exists = 0)
		Begin
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @HazardItemKey

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Class 9 Item Added for Container Prop Selected'
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@Class9 = 0 and @Class9Exists = 1)
		Begin
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @HazardItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'Class 9 Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		End

				/* *************************  ADD TL ITEM *********************/
	    /* Added the Process as per Incident #3330 */

		if(@TL = 1 and @TLExists = 0)
		Begin
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(A.rate,I.UnitCost), 1, ISNULL(A.rate,I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAccDFPSYS A ON i.ItemKey = A.ItemKey
			where I.itemkey = @LineHaulItemKey

			Declare @DrayOrderExpenseKey int, @DrayBaseItemKey int = 18
			SELECT @DrayOrderExpenseKey = OrderExpenseKey from OrderExpense where OrderDetailKey = @OrderDetailKey and Itemkey = 18
			if((select count(1) from OrderExpense where OrderDetailKey = @OrderDetailKey and Itemkey = @DrayBaseItemKey) >0)
			BEGIN
				DELETE from OrderExpense where OrderExpenseKey = @DrayOrderExpenseKey
			END

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'TL Item Added for Container Prop Selected'
			set @ChangeCount = @ChangeCount +1
		End
		else IF (@TL = 0 and @TLExists = 1)
		Begin
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @LineHaulItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'TL Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		End

		IF(@BNDD = 1 AND @BNDDExists = 0)
		BEGIN
			INSERT INTO OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom)
			Select I.ItemKey, @RouteKey, ISNULL(I.UnitCost,0) , 1, 0, Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom
			FROM Item I With (NOLOCK)			
			WHERE I.itemkey = @BNDDItemKey		
		END
		ELSE IF (@Bndd = 0 AND @BNDDExists = 1)
		BEGIN
			Delete from OrderExpense
			Where OrderDetailKey = @OrderDetailKey and Itemkey = @BNDDItemKey and ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			Select GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'BNDD Item Deleted for Container Prop De-Selected'
			set @ChangeCount = @ChangeCount +1
		END

		DECLARE @TimeDuration VARCHAR(5) = '';

		IF(@PWT = 1 AND @PWTExists = 0)
		BEGIN	
			SELECT @TimeDuration = DATEDIFF(MINUTE, CAST(PWTFromTime AS TIME), CAST(PWTToTime AS TIME))
			FROM [Routes] WHERE RouteKey = @RouteKey;
    
			DECLARE @RoundedPWT INT = CEILING(@TimeDuration / 15.0) * 15;
    
			SELECT @TimeDuration = CAST(@RoundedPWT / 60 AS VARCHAR(10)) + ':' + RIGHT('0' + CAST(@RoundedPWT % 60 AS VARCHAR(2)), 2)

			INSERT INTO OrderExpense(Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, TimeDuration)
			SELECT I.ItemKey, @RouteKey, ISNULL(I.UnitCost,0) , 1, 0, GETDATE(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom, @TimeDuration
			FROM Item I WITH(NOLOCK)			
			WHERE I.Itemkey = @PWTItemKey		
		END
		ELSE IF(@PWT = 0 AND @PWTExists = 1)
		BEGIN
			DELETE FROM OrderExpense
			WHERE OrderDetailKey = @OrderDetailKey AND Itemkey = @PWTItemKey AND ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			SELECT GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'PWT Item Deleted for Container Prop De-Selected'
			SET @ChangeCount = @ChangeCount +1
		END
		SET @TimeDuration=''
		IF(@CWT = 1 AND @CWTExists = 0)
		BEGIN
			SELECT @TimeDuration = DATEDIFF(MINUTE, CAST(CWTFromTime AS TIME), CAST(CWTToTime AS TIME))
			FROM [Routes] WHERE RouteKey = @RouteKey;
	
			DECLARE @RoundedCWT INT = CEILING(@TimeDuration / 15.0) *15;

			SELECT @TimeDuration = CAST(@RoundedCWT / 60 AS varchar(10)) + ':' + RIGHT('0' + CAST(@RoundedCWT % 60 AS varchar(2)),2)

			INSERT INTO OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, TimeDuration)
			SELECT I.ItemKey, @RouteKey, ISNULL(I.UnitCost,0) , 1, 0, GETDATE(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, @DateFrom, @TimeDuration
			FROM Item I WITH(NOLOCK)			
			WHERE I.Itemkey = @CWTItemKey		
		END
		ELSE IF (@CWT = 0 AND @CWTExists = 1)
		BEGIN
			DELETE FROM OrderExpense
			WHERE OrderDetailKey = @OrderDetailKey AND Itemkey = @CWTItemKey AND ChargeSource = 'Auto'

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			SELECT GETDATE(), 1, 'Container', @ContainerNo, @OrderDetailKey, 'Auto', 'Text' , 'CWT Item Deleted for Container Prop De-Selected'
			SET @ChangeCount = @ChangeCount +1
		END

		--IF( @ChangeCount > 0)
		--Begin
		--	Commit Transaction
		--End
		--else
		--Begin
		--	RollBack Transaction
		--End
	End Try
	Begin Catch
		IF( @ChangeCount > 0)
		--Begin
		--	RollBack Transaction
		--End
		print @@Error
		print Error_line()
		print Error_Message()
	End Catch
	
End
