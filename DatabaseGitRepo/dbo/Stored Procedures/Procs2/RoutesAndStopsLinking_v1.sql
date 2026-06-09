
CREATE PROCEDURE [dbo].[RoutesAndStopsLinking_v1]  -- [RoutesAndStopsLinking_v1] 178034, 1
(
	@OrderDetailKey		    INT = 0,
	@IsDebug				BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	--ALTER TABLE Routes Add  FromODStopKey	bigint, ToODStopKey		bigint, LegID  varchar(50)
	DECLARE  
	    --@OrderDetailKey		    INT = 178010,
	    @OrderKey			    INT = 0,
	    @OrderTypeKey		    INT = 0,
	    @OrderNo			    VARCHAR(50) = '',
	    @Containerno		    VARCHAR(50) = '',
	    @TotalStopsCount	    INT = 0,
	    @ReadyStopsCount	    INT = 0,
	    @RoutesCount		    INT = 0,
	    @DryRunPortStopKey	    INT = 0,
	    @DryRunCustomerStopKey	INT = 0


	SELECT @OrderKey = OH.orderKey,
		   @OrderNo	 = OH.OrderNo,
		   @OrderTypeKey  = OD.OrderTypeKey,
		   @Containerno	  = OD.ContainerNo
	FROM OrderDetail OD WITH (NOLOCK) 
	INNER JOIN ORderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	WHERE ORderDetailKey = @OrderDetailKey
	
	SELECT @TotalStopsCount = COUNT(1)
	FROM ORderDetailStops ODS WITH (NOLOCK)
	WHERE OrderDetailKey = @OrderDetailKey
	
	SELECT @ReadyStopsCount = COUNT(1)
	FROM ORderDetailStops ODS WITH (NOLOCK)
	WHERE OrderDetailKey = @OrderDetailKey AND isnull(StopAddrKey,0) > 0 AND isnull(LocationType,'') <> ''
	
	SELECT @DryRunPortStopKey = OrderDetailStopKey
	FROM ORderDetailStops ODS WITH (NOLOCK)
	WHERE OrderDetailKey = @OrderDetailKey AND isnull(IsDryRunPort,0) = 1
	
	SELECT @DryRunCustomerStopKey = OrderDetailStopKey
	FROM ORderDetailStops ODS WITH (NOLOCK)
	WHERE OrderDetailKey = @OrderDetailKey AND isnull(IsDryRunCustomer,0) = 1
	
	SELECT @RoutesCount = COUNT(1)
	FROM Routes RT WITH (NOLOCK)
	WHERE OrderDetailKey = @OrderDetailKey
	
	IF(@IsDebug = 1)
    BEGIN
		SELECT 
	     @OrderDetailKey        AS  OrderDetailKey,
		 @OrderKey              AS  OrderKey,
		 @OrderTypeKey          AS  OrderTypeKey,
		 @OrderNo               AS  OrderNo,
		 @Containerno           AS  Containerno,
		 @TotalStopsCount       AS  TotalStopsCount,
		 @ReadyStopsCount       AS  ReadyStopsCount,
		 @RoutesCount           AS  RoutesCount,
		 @DryRunPortStopKey     AS  DryRunPortStopKey,
		 @DryRunCustomerStopKey AS  DryRunCustomerStopKey
    END
	
	CREATE TABLE #StopMap
	(
		FromStopNo			INT,
		FromODSStopKey		INT,
		FromRouteKey		INT,
		ToStopNo			INT,
		ToODSStopKey		INT,
		ToRouteKey			INT,
		IsRouteMatching		BIT DEFAULT  0
	)

	-- ********************************************* Initial setups
	-- ***************************Update the Stop Numbers
	update A set StopNumber = B.NewStopNumber
	from OrderDetailStops A
	inner join (
		select ROW_NUMBER() Over (Order by OrderDetailKey, SM.StoptypeKey) as NewStopNumber, SM.StopTypeShortcode, OrderDetailStopKey
		from OrderDetailStops ODS
		inner join StopsMaster SM on ODS.StopTypeKey = SM.StopTypeKey
		where ODs.orderdetailkey = @OrderDetailKey
	) B on A.OrderDetailStopKey = B.OrderDetailStopKey

	-- ***************************Update the Dry Run Mismatch
	Update RT SET IsDryRun = 1,
		DryRunSetDate = isnull(ODs.DryRunPortSetDateTime, ODS.DryRunCustomerSetDateTime),
		DryRunSetUser = ISNULL(ODS.DryRunPortSetUserKey, ODS.DryRunCustomerSetUserKey),
		DryRunType = Case when ISNULL(ODs.IsDryRunPort,0) = 1 then 1
						when ISNULL(ODs.IsDryRunCustomer,0) = 1 then 2 else null end
	--Select *
	from OrderDetailStops ODS WITH (NOLOCK)
	inner join Routes RT WITH (NOLOCK) on ODs.FromRouteKey = RT.RouteKey
	where (ISNULL(ODs.IsDryRunPort,0) = 1 OR ISNULL(ODS.IsDryRunCustomer,0) = 1 ) and isnull(RT.IsDryRun ,0) = 0
		and ODS.orderdetailkey = @OrderDetailKey
	
	
	-- ********************************************* GET THE @ReadyStopsCount > 0
	SELECT ODS.*, SM.StopTypeShortcode
	INTO #ReadyStops
	FROM OrderDetailStops ODS  WITH (NOLOCK)
	inner join StopsMaster SM WITH (NOLOCK) on ODS.StopTypeKey = SM.StopTypeKey
	WHERE OrderDetailKey = @OrderDetailKey AND isnull(StopAddrKey,0) > 0 AND isnull(LocationType,'') <> ''
			AND  isnull(IsDryRunPort,0) = 0 AND isnull(IsDryRunCustomer,0) = 0
	ORDER BY ODS.StopNumber
	
	INSERT INTO #stopMap (FromStopNo, FromODSStopKey, FromRouteKey)
	SELECT StopNumber, OrderDetailStopKey, FromRouteKey
	FROM #ReadyStops
	
	UPDATE A SET 
		ToStopNo = B.StopNumber,
		ToODSStopKey = B.OrderDetailStopKey,
		ToRouteKey = B.ToRouteKey
	FROM #StopMap A
	INNER JOIN #ReadyStops B ON A.FromStopNo = B.StopNumber - 1
	
	DELETE FROM #StopMap WHERE ToStopNo IS NULL
	IF(@IsDebug = 1)
    BEGIN
		SELECT '#StopMap' AS StopMap,* from #StopMap ORDER BY FromStopNo
	End
	-- ********************************************* GET THE @IsDryRunPort = 1
	Declare @DryRnPortCount int = 0, @DryRunCustomerCount int = 0
	SELECT ODS.*, SM.StopTypeShortcode
	INTO #DryRunPortStops
	FROM OrderDetailStops ODS  WITH (NOLOCK)
	inner join StopsMaster SM WITH (NOLOCK) on ODS.StopTypeKey = SM.StopTypeKey
	WHERE OrderDetailKey = @OrderDetailKey AND ISNULL(StopAddrKey,0) > 0 AND ISNULL(LocationType,'') <> ''
			AND  ISNULL(IsDryRunPort,0) = 1  and FromRouteKey  is null
	ORDER BY ODS.StopNumber
	
	Select @DryRnPortCount = count(1) from #DryRunPortStops
	-- ********************************************* GET THE @IsDryRunCustomer = 1
	SELECT ODS.*, SM.StopTypeShortcode
	INTO #DryRunCustomerStops
	FROM OrderDetailStops ODS  WITH (NOLOCK)
	inner join StopsMaster SM WITH (NOLOCK) on ODS.StopTypeKey = SM.StopTypeKey
	WHERE OrderDetailKey = @OrderDetailKey AND ISNULL(StopAddrKey,0) > 0 AND ISNULL(LocationType,'') <> ''
			AND  ISNULL(IsDryRunCustomer,0) = 1 and FromRouteKey is null
	ORDER BY ODS.StopNumber
	
	SElect @DryRunCustomerCount = count(1) from #DryRunCustomerStops
	
	
	if(@DryRnPortCount > 0)
	Begin
		declare @DryRunPortStop varchar(5) =''
		select @DryRunPortStop = StopTypeShortcode 
		from #DryRunPortStops A

		if(@DryRunPortStop = 'SF')
		Begin
			declare @DR_SF_Routekey int = 0
			INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo, 
						DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status, 
						ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,  
						LegType, FromODStopKey, ToODStopKey, IsDryRun, DryRunSetDate, DryRunSetUser, DryRunType)
			SELECT @OrderDetailKey, @OrderKey, LegKey, F.StopNumber, F.StopAddrKey AS SourceAddrKey, 
				F.SchedulePickupDate AS PickupDateFrom, F.SchedulePickupDateTo AS PickupDateTo, 
				T.ScheduleDeliveryDate AS  DeliveryDateFrom, T.ScheduleDeliveryDateTo AS  DeliveryDateTo, 
				F.locationType AS FromLocation,T.LocationType AS  ToLocation, 
				T.StopAddrKey AS DestinationAddrKey, 1 AS Status, 
				F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate AS ScheduledDeparture, 
				T.CreateUserKey,  T.CreateDate, CASE WHEN isnull(T.DropOrLive,0) =0 THEN 'Live' ELSE 'Drop' END AS LegType,
				F.OrderDetailStopKey, T.OrderDetailStopKey, 1, Getdate(), F.CreateUserKey, 1
			FROM #DryRunPortStops F 
			INNER JOIN #ReadyStops T ON T.StopTypeShortcode = 'ST'
			INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation
				AND L.Statuskey = 1
			INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey
			where F.StopTypeShortcode ='SF' and T.StopTypeShortcode = 'ST'

			select @DR_SF_Routekey = SCOPE_IDENTITY()
			
			update ODS set FromRouteKey = @DR_SF_Routekey, ToRouteKey = @DR_SF_Routekey
			from OrderDetailStops ODS
			inner join #DryRunPortStops DS on ODs.OrderDetailStopKey = DS.OrderDetailStopKey
			where DS.StopTypeShortcode = 'SF'
		end

		if(@DryRunPortStop = 'RT')
		Begin
			declare @DR_RT_Routekey int = 0
			INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo, 
						DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status, 
						ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,  
						LegType, FromODStopKey, ToODStopKey, IsDryRun, DryRunSetDate, DryRunSetUser, DryRunType)
			SELECT @OrderDetailKey, @OrderKey, LegKey, F.StopNumber, F.StopAddrKey AS SourceAddrKey, 
				F.SchedulePickupDate AS PickupDateFrom, F.SchedulePickupDateTo AS PickupDateTo, 
				T.ScheduleDeliveryDate AS  DeliveryDateFrom, T.ScheduleDeliveryDateTo AS  DeliveryDateTo, 
				F.locationType AS FromLocation,T.LocationType AS  ToLocation, 
				T.StopAddrKey AS DestinationAddrKey, 1 AS Status, 
				F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate AS ScheduledDeparture, 
				T.CreateUserKey,  T.CreateDate, CASE WHEN isnull(T.DropOrLive,0) =0 THEN 'Live' ELSE 'Drop' END AS LegType,
				F.OrderDetailStopKey, T.OrderDetailStopKey, 1, Getdate(), F.CreateUserKey, 1
			FROM #ReadyStops  F 
			INNER JOIN #DryRunPortStops T ON 1=1
			INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation
				AND L.Statuskey = 1
			INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey
			where F.StopTypeShortcode = 'ST' and T.StopTypeShortcode ='RT'

			select @DR_RT_Routekey = SCOPE_IDENTITY()

			update ODS set FromRouteKey = @DR_RT_Routekey, ToRouteKey = @DR_RT_Routekey
			from OrderDetailStops ODS
			inner join #DryRunPortStops DS on ODs.OrderDetailStopKey = DS.OrderDetailStopKey
			where DS.StopTypeShortcode = 'RT'
		end
	End
	if(@DryRunCustomerCount > 0)
	Begin
		declare @DryRunCustomerStop varchar(5) =''
		select @DryRunCustomerStop = StopTypeShortcode 
		from #DryRunCustomerStops A

		if(@DryRunCustomerStop = 'ST')
		Begin
			declare @DR_ST_Routekey int = 0
			INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo, 
						DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status, 
						ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,  
						LegType, FromODStopKey, ToODStopKey, IsDryRun, DryRunSetDate, DryRunSetUser, DryRunType)
			SELECT @OrderDetailKey, @OrderKey, LegKey, F.StopNumber, F.StopAddrKey AS SourceAddrKey, 
				F.SchedulePickupDate AS PickupDateFrom, F.SchedulePickupDateTo AS PickupDateTo, 
				T.ScheduleDeliveryDate AS  DeliveryDateFrom, T.ScheduleDeliveryDateTo AS  DeliveryDateTo, 
				F.locationType AS FromLocation,T.LocationType AS  ToLocation, 
				T.StopAddrKey AS DestinationAddrKey, 1 AS Status, 
				F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate AS ScheduledDeparture, 
				T.CreateUserKey,  T.CreateDate, CASE WHEN isnull(T.DropOrLive,0) =0 THEN 'Live' ELSE 'Drop' END AS LegType,
				F.OrderDetailStopKey, T.OrderDetailStopKey, 1, Getdate(), F.CreateUserKey, 2
			FROM #DryRunCustomerStops F 
			INNER JOIN #ReadyStops T ON T.StopTypeShortcode = 'ST'
			INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation
				AND L.Statuskey = 1
			INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey
			where F.StopTypeShortcode ='SF' and T.StopTypeShortcode = 'ST'

			select @DR_ST_Routekey = SCOPE_IDENTITY()

			update ODS set FromRouteKey = @DR_ST_Routekey, ToRouteKey = @DR_ST_Routekey
			from OrderDetailStops ODS
			inner join #DryRunCustomerStops DS on ODs.OrderDetailStopKey = DS.OrderDetailStopKey
			where DS.StopTypeShortcode = 'ST'
		end

		
	End

	If(@IsDebug = 1)
	Begin
		SELECT '#ReadyStops' AS ReadyStops, * FROM #ReadyStops ORDER BY StopNumber
		SELECT '#DryRunPortStops' AS DryRunPortStops, * FROM #DryRunPortStops  ORDER BY StopNumber
		SELECT '#DryRunCustomerStops' AS DryRunCustomerStops, * FROM #DryRunCustomerStops  ORDER BY StopNumber
		Select @DR_SF_Routekey as DR_SF_Routekey, @DR_ST_Routekey as DR_ST_Routekey, @DR_RT_Routekey as DR_RT_Routekey
	End

	-- ********************************************* GET THE ROUTES DATA
	SELECT RouteKey, RT.LegNo, RT.LegKey,  L.FromLocation as LegFromLocation, L.ToLocation LegToLocation, 
		RT.FromLocation RTFromLocation, RT.ToLocation  RTToLocation, RT.LegID, Rt.FromODStopKey, Rt.ToODStopKey
	INTO #Routes
	FROM Routes RT WITH (NOLOCK)
	INNER JOIN Leg L WITH (NOLOCK) ON RT.legkey = L.LegKey
	where ORderDetailKey = @OrderDetailKey and isnull(RT.IsDryRun,0) = 0
	
	If(@IsDebug = 1)
	Begin
		SELECT '#Routes' AS Routes,* FROM #Routes
	End
	
	-- ############################################# VERIFY THE DATA
	
	UPDATE #ReadyStops SET LocationType = REPLACE( REPLACE(LocationType,'Customer','Consignee'), 'Shipper','Consignee')
	UPDATE #ReadyStops SET LocationType = REPLACE( REPLACE(LocationType,'Customer','Consignee'), 'Shipper','Consignee')
	
	DECLARE @IsRoutesExists	BIT = 0,
			@RouteToBeCount	INT = 0,
			@RouteCount		INT = 0,
			@IsRoutesCountMatching	BIT = 0,
			@IsDryRunPortMatching	BIT = 0,
			@IsDryRunCustomerMAtching	BIT = 0
	
	SELECT @IsRoutesExists = CASE WHEN  COUNT(1) > 0 THEN 1 ELSE 0 END FROM #Routes
	SELECT @RouteToBeCount = COUNT(1) FROM #StopMap
	SELECT @RouteCount = COUNT(1)  FROM #Routes
	SELECT @IsRoutesCountMatching = CASE WHEN @RouteToBeCount = @RouteCount THEN 1 ELSE 0 END
	
	IF(@IsDebug = 1)
    BEGIN
		SELECT @IsRoutesExists AS IsRoutesExists,@RouteCount AS RouteCount, @RouteToBeCount AS RouteToBeCount,
			@IsRoutesCountMatching AS IsRoutesCountMatching
	End

	IF(@RouteCount = 0 AND @RouteToBeCount > 0)
	BEGIN
		DECLARE @RowsInserted INT = 0
		INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo, 
					DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status, 
					ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,  
					LegType, FromODStopKey, ToODStopKey)
		SELECT @OrderDetailKey, @OrderKey, LegKey, A.FromStopNo, F.StopAddrKey AS SourceAddrKey, 
			F.SchedulePickupDate AS PickupDateFrom, F.SchedulePickupDateTo AS PickupDateTo, 
			T.ScheduleDeliveryDate AS  DeliveryDateFrom, T.ScheduleDeliveryDateTo AS  DeliveryDateTo, 
			F.locationType AS FromLocation,T.LocationType AS  ToLocation, 
			T.StopAddrKey AS DestinationAddrKey, 1 AS Status, 
			F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate AS ScheduledDeparture, 
			T.CreateUserKey,  T.CreateDate, CASE WHEN isnull(T.DropOrLive,0) =0 THEN 'Live' ELSE 'Drop' END AS LegType,
			A.FromODSStopKey, A.ToODSStopKey
		FROM #StopMap a
		INNER JOIN #ReadyStops F ON a.FromStopNo = F.StopNumber AND A.FromODSStopKey = F.OrderDetailStopKey
		INNER JOIN #ReadyStops T ON a.ToStopNo = T.StopNumber AND A.ToODSStopKey = T.OrderDetailStopKey
		INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation
			--replace(replace(L.FromLocation,'Customer','Consignee'),'Shipper','Consignee') = replace(replace(T.LocationType,'Customer','Consignee'),'Shipper','Consignee')  and
			--replace(replace(L.ToLocation,'Customer','Consignee'),'Shipper','Consignee') = replace(replace(T.LocationType,'Customer','Consignee'),'Shipper','Consignee') 
			AND L.Statuskey = 1
		INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey
		ORDER BY A.FromStopNo
		
		SET @RowsInserted = @@ROWCOUNT 
		If(@IsDebug = 1)
		Begin
			SELECT  @RowsInserted AS RowsInserted
		End
		IF(@RowsInserted > 0)
		BEGIN
			UPDATE ODS SET FromRouteKey = null, ToRouteKey = null 
			from OrderDetailStops ODS
			inner join #ReadyStops RS on ODs.OrderDetailStopKey = RS.OrderDetailStopKey
			WHERE ODS.OrderDetailkey = @OrderDetailKey 
	
			UPDATE A SET FromRouteKey = Rt.RouteKey, ToRouteKey = Rt.Routekey
			FROM #StopMap A
			INNER JOIN Routes RT ON A.FromODSStopKey = Rt.FromODStopKey AND A.ToODSStopKey = Rt.ToODStopKey
	
			UPDATE ODS SET FromRouteKey = SM.FromRouteKey
			FROM OrderDetailStops ODS
			INNER JOIN #StopMap SM ON ODs.OrderDetailStopKey = SM.FromODSStopKey
	
			UPDATE ODS SET ToRouteKey = SM.ToRouteKey
			FROM OrderDetailStops ODS
			INNER JOIN #StopMap SM ON ODs.OrderDetailStopKey = SM.ToODSStopKey
	
			UPDATE RT SET FromODStopKey = SM.FromODSStopKey, ToODStopKey = SM.ToODSStopKey
			FROM Routes RT
			INNER JOIN #StopMap SM ON Rt.routekey = SM.Fromroutekey AND Rt.RouteKey = SM.ToRouteKey
			IF(@IsDebug = 1)
			BEGIN
				SELECT * FROM #StopMap
				SELECT * FROM orderDetailStops WHERE OrderDetailKey =@OrderDetailKey ORDER BY StopNumber
				SELECT * FROM Routes WHERE OrderDetailKey = @OrderDetailKey ORDER BY LegNo
			end
		End
		
	End
	
	IF( @RouteCount > 0 AND @RouteToBeCount > 0)
	BEGIN
		UPDATE A SET IsRouteMatching = 
			CASE WHEN rt.LegNo = A.FromStopNo AND Rt.FromODStopKey = A.FromODSStopKey AND rt.ToODStopKey = A.ToODSStopKey THEN 1 ELSE 0 END
		FROM #StopMap A
		LEFT JOIN Routes RT ON a.FromRouteKey = RT.RouteKey
	
		IF(@IsDebug = 1)
		BEGIN
			SELECT 'RoutesCount and RoutesToBeCount Not MAtching',  * FROM #StopMap
		end

		DECLARE @RouteNotMatchingCount INT = 0
		SELECT @RouteNotMatchingCount = count(1) FROM #StopMap WHERE IsRouteMatching = 0
		IF(@RouteNotMatchingCount > 0)
		BEGIN
				SELECT * INTO #PrevRoutes FROM Routes WHERE orderDetailKey = @OrderDetailKey
				IF(@IsDebug = 1)
				BEGIN
					SELECT '#PrevRoutes' as PrevRoutes,* FROM #PrevRoutes
				END

				DELETE FROM Routes WHERE orderdetailkey = @OrderDetailKey AND  
					routekey IN (SELECT FromRouteKey FROM #StopMap WHERE IsRouteMatching = 0)
	
				DECLARE @RowsInserted2 INT = 0
	
				INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo, 
					DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status, 
					ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,  
					LegType, FromODStopKey, ToODStopKey)
				SELECT @OrderDetailKey, @OrderKey, LegKey, A.FromStopNo, F.StopAddrKey as SourceAddrKey, 
					F.SchedulePickupDate as PickupDateFrom, F.SchedulePickupDateTo as PickupDateTo, 
					T.ScheduleDeliveryDate as  DeliveryDateFrom, T.ScheduleDeliveryDateTo as  DeliveryDateTo, 
					F.locationType as FromLocation,T.LocationType as  ToLocation, 
					T.StopAddrKey as DestinationAddrKey, 1 as Status, 
					F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate as ScheduledDeparture, 
					T.CreateUserKey,  T.CreateDate, case when isnull(T.DropOrLive,0) =0 then 'Live' else 'Drop' end as LegType,
					A.FromODSStopKey, A.ToODSStopKey
				FROM #StopMap a
				INNER JOIN #ReadyStops F ON a.FromStopNo = F.StopNumber AND A.FromODSStopKey = F.OrderDetailStopKey
				INNER JOIN #ReadyStops T ON a.ToStopNo = T.StopNumber AND A.ToODSStopKey = T.OrderDetailStopKey
				INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation
					--replace(replace(L.FromLocation,'Customer','Consignee'),'Shipper','Consignee') = replace(replace(T.LocationType,'Customer','Consignee'),'Shipper','Consignee')  and
					--replace(replace(L.ToLocation,'Customer','Consignee'),'Shipper','Consignee') = replace(replace(T.LocationType,'Customer','Consignee'),'Shipper','Consignee') 
					AND L.Statuskey = 1
				INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey
				WHERE a.IsRouteMatching = 0
				ORDER BY A.FromStopNo
	
				SET @RowsInserted2 = @@ROWCOUNT 
				
				IF(@RowsInserted2 > 0)
				Begin
					UPDATE ODS SET FromRouteKey = null, ToRouteKey = null 
					from OrderDetailStops ODS
					inner join #ReadyStops RS on ODs.OrderDetailStopKey = RS.OrderDetailStopKey
					WHERE ODS.OrderDetailkey = @OrderDetailKey 
	
	
					UPDATE A SET FromRouteKey = Rt.RouteKey, ToRouteKey = Rt.Routekey
					FROM #StopMap A
					INNER JOIN Routes RT ON A.FromODSStopKey = Rt.FromODStopKey AND A.ToODSStopKey = Rt.ToODStopKey
	
					UPDATE ODS SET FromRouteKey = SM.FromRouteKey
					FROM OrderDetailStops ODS
					INNER JOIN #StopMap SM ON ODs.OrderDetailStopKey = SM.FromODSStopKey
	
					UPDATE ODS SET ToRouteKey = SM.ToRouteKey
					FROM OrderDetailStops ODS
					INNER JOIN #StopMap SM ON ODS.OrderDetailStopKey = SM.ToODSStopKey
	
					UPDATE RT SET FromODStopKey = SM.FromODSStopKey, ToODStopKey = SM.ToODSStopKey
					FROM Routes RT
					INNER JOIN #StopMap SM ON Rt.routekey = SM.Fromroutekey AND Rt.RouteKey = SM.ToRouteKey
	
					IF(@IsDebug = 1)
					BEGIN
						SELECT * FROM #StopMap
						SELECT * FROM orderDetailStops WHERE OrderDetailKey =@OrderDetailKey ORDER BY StopNumber
						SELECT * FROM Routes WHERE OrderDetailKey = @OrderDetailKey ORDER BY LegNo
					END
				END
	
				DROP TABLE #PrevRoutes
		END
		
	END

	-- ******************************************** SET SCHEDULER TO CONFIRM STATUS
	Declare @FinalRouteCount	int = 0,
			@OrderDetailStatus	smallint = 0,
			@CurrentRouteKey	int = 0,
			@CurrentLegNo		int = 0,
			@FirstRouteKey		int = 0

	select @OrderDetailStatus = Status, @CurrentLegNo = CurrentLegNo, @CurrentRouteKey = CurrentRouteKey  
	from OrderDetail OD WITH(NOLOCK) where ORderdetailkey = @OrderDetailKey
	select @FinalRouteCount = count(1) from Routes where orderdetailkey = @OrderDetailKey
	select top 1 @FirstRouteKey = routekey from Routes where OrderDetailkey = @OrderDetailKey and LegNo = 1
	if(@OrderDetailStatus in (0,1,2,3) and @FinalRouteCount > 0)
	Begin
		update OrderDetail set Status = 2
		where OrderDetailKey = @OrderDetailKey
		
		update ORderDetail set CurrentRouteKey = @FirstRouteKey, CurrentLegNo = 1 , TotalLegs = @FinalRouteCount
		where ORderDetailKey = @OrderDetailKey
	End
	-- ********************************************* CLOSING STEPS
	--DROP TABLE #ReadyStops
	--DROP TABLE #DryRunPortStops
	--DROP TABLE #DryRunCustomerStops
	--DROP TABLE #StopMap
	--DROP TABLE #Routes
END
