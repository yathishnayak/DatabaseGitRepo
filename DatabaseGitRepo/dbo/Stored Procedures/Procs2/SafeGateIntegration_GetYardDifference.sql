

-- [SafeGateIntegration_GetYardDifference] 'CCLU5162428',3, 1
-- [SafeGateIntegration_GetYardDifference] null,3, 1
--select Datediff(hh, '2024-10-16 19:49:27.967','2024-10-16 12:44:30.850')

CREATE PROCEDURE [dbo].[SafeGateIntegration_GetYardDifference] -- [SafeGateIntegration_GetYardDifference_Shiva] 'APHU7229593',1, 1
(
	@ContainerNo	varchar(20) =null,
	@TimeDiff		int = 1,
	@DaysToVerify	int = 1,
	@IsDebug		BIT = 0
)
AS
BEGIN
	----------------------Safegate Data ------------------------------------------------------------------------
	SELECT		ActivityId, YardName,LTRIM(RTRIM(CD.ContainerNo)) as ContainerNo,CreatedDate, ContainerDesc -- ,Y.ShortName TMSYardName
				,  Effect,ContainerType, YM.TMSYardID, Y.AddrKey
				,CASE WHEN ContainerType = 'Empty Container' THEN 1 ELSE 0 END IsEmpty
				, ROW_NUMBER() OVER (Partition BY CD.ContainerNo, CreatedDate,Effect,ISNULL(COntainerType,'') ORDER BY CreatedDate) AS SL
				, ROW_NUMBER() OVER (Partition BY CD.ContainerNo ORDER BY CD.ContainerNo, CreatedDate, Effect) AS Leg_No
	INTO		#SFGData
	FROM		SafeGateIntegration_ContainerDetails CD 
	INNER JOIN	(SELECT		DISTINCT ContainerNo
				FROM		SafeGateIntegration_ContainerDetails CD
				WHERE		CreatedDate > CAST(CONVERT(VARCHAR,GETDATE()-30,102) AS DATETIME) ) CD1 ON CD.ContainerNo = CD1.ContainerNo
	INNER JOIN	SafegateIntegration_SafegateTMSYardNameMapping YM ON CD.YardName = YM.SafeGateYardName
	INNER JOIN	Yard Y ON YM.TMSYardID = Y.YardId
	WHERE		@ContainerNo is null OR LTRIM(RTRIM(CD.ContainerNo)) = @ContainerNo

	-------------------------TMS Data----------------------------------------------------------------------------
	SELECT		OrderType,ContainerNo,ActualDeparture,ActualArrival, 
				ISNULL(PickupYard,'') PUYardLocation,
				ISNULL(DeliveryYard,'') DELYardLocation
				, ISNULL(PickupYardID,'') PUYardLocationID
				, ISNULL(DeliveryYardID,'') DELYardLocationID
				,ISNULL(IsDeliveryYard,IsPickupYard) Effect,FromLocation,ToLocation,IsEmpty , LegID, LegNo, RouteKey
				, DestinationAddrKey,SourceAddrKey,RTIsEmpty,
				ROW_NUMBER() OVER (ORDER BY CONTAINERNO, ROUTEKEY, LEGNO) AS ROW_ID,
				OrderDetailKey
	INTO		#TMSData
	FROM		(SELECT		 OT.OrderType, LTRIM(RTRIM(ContainerNo)) ContainerNo,ActualDeparture, ActualArrival
							,YS.ShortName PickupYard, YD.ShortName DeliveryYard, RT.RouteKey, RT.DestinationAddrKey,RT.SourceAddrKey
							,YS.YardId PickupYardID, YD.YardId DeliveryYardID, L.LegID,RT.LegNo
							, CASE WHEN YS.ShortName IS NULL THEN NULL ELSE -1 END IsPickupYard
							, CASE WHEN YD.ShortName IS NULL THEN NULL ELSE 1 END IsDeliveryYard
							,  L.FromLocation,L.ToLocation
							, RT.IsEmpty as RTIsEmpty
							, CASE WHEN OT.OrderType = 'Import' AND (L.FromLocation in ('Consignee','Customer','Shipper') OR L.ToLocation = 'Port') THEN  1 ELSE  
							CASE WHEN OT.OrderType = 'Export' AND (L.FromLocation = 'Port' OR L.ToLocation in ('Consignee','Customer','Shipper')) THEN  1 ELSE  0 END
							END AS  IsEmpty 
							,CASE WHEN L.FromLocation = 'Yard' AND L.ToLocation = 'Yard' THEN 1 ELSE 0 END ISExclude,
							OD.OrderDetailKey
				FROM		OrderDetail OD
				INNER JOIN	Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
				INNER JOIN	OrderHeader OH ON OD.OrderKey = OH.OrderKey
				INNER JOIN	OrderType OT ON OH.OrderTypeKey = OT.OrderTypeKey
				INNER JOIN	Leg L ON RT.LegKey = L.LegKey
				LEFT JOIN	Yard YD ON RT.DestinationAddrKey = YD.AddrKey
				LEFT JOIN	Yard YS ON RT.SourceAddrKey = YS.AddrKey
				WHERE		
							(@ContainerNo is null OR LTRIM(RTRIM(OD.ContainerNo)) = @ContainerNo)
							AND (L.FromLocation = 'Yard' OR L.ToLocation = 'Yard')	
							AND RT.OrderDetailKey in (
								Select distinct OrderDetailkey 
								from Routes RTT
								inner join LEG LL on RTT.legkey = LL.LegKey
								where (RTT.ActualArrival > CAST(CONVERT(VARCHAR,GETDATE()-(@DaysToVerify),102) AS DATETIME)  OR
								RTT.ActualDeparture > CAST(CONVERT(VARCHAR,GETDATE()-(@DaysToVerify),102) AS DATETIME) ) AND
								(LL.FromLocation = 'YARD' OR LL.ToLocation = 'YARD')
							)
				)A 
	--WHERE		ISExclude = 0

	------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	
	SELECT ROW_ID, RouteKey, PUYardLocation YardLocation,PUYardLocationID as YardLocationID, ContainerNo,'Pickup' Type,
		 ActualDeparture, SourceAddrKey, -1 as Effect, IsEmpty, RTIsEmpty, LegNo, OrderDetailKey
	INTO #TMS_FROMYARD
	FROM	#TMSData
	WHERE FromLocation = 'YARD'

	SELECT ROW_ID, RouteKey,DELYardLocation  YardLocation,DELYardLocationID as YardLocationID, ContainerNo, 'Delivery' Type,
		ActualArrival, DestinationAddrKey, 1 as Effect, IsEmpty, RTIsEmpty,  LegNo, OrderDetailKey
	INTO #TMS_TOYARD
	FROM	#TMSData
	WHERE ToLocation = 'YARD'

	CREATE TABLE #TMS_ALL
	(
		ROW_ID			int, 
		RouteKey		int, 
		YardLocation	varchar(50), 
		YardLocationID	int, 
		ContainerNo		varchar(20),
		ActionDate		datetime, 
		AddrKey			int,
		Effect			int,
		IsEmpty			bit,
		RTIsEmpty		bit,
		TMS_LEg_no			int,
		LegNO			int,
		TranType		varchar(20),
		ORderDetailKey		int
	)

	insert into #TMS_ALL (ROW_ID, RouteKey, YardLocation, YardLocationID, ContainerNo, ActionDate,  AddrKey, Effect, IsEmpty, RTIsEmpty, TMS_LEG_NO, TranType, OrderDetailKey)
	select  ROW_ID, RouteKey, YardLocation, YardLocationID, ContainerNo,ActualDeparture, SourceAddrKey, Effect, IsEmpty, RTIsEmpty, LegNo, [type], OrderDetailKey
	from #TMS_FROMYARD
	union all 
	select  ROW_ID, RouteKey, YardLocation, YardLocationID, ContainerNo,ActualArrival, DestinationAddrKey, Effect, IsEmpty, RTIsEmpty, LegNo,  [type], OrderDetailKey
	from #TMS_TOYARD


	Select '#TMS_ALL', A.*,
		ROW_NUMBER() OVER (Partition BY A.ContainerNo ORDER BY A.ContainerNo, A.ActionDate)  as LegNo
		From #TMS_ALL A
		inner join #TMS_ALL B on A.ROW_ID = B.ROW_ID and A.AddrKey = B.AddrKey

	update X Set LegNo = Y.LegNo_New
	from #TMS_ALL X
	inner join (
		Select A.*,
		ROW_NUMBER() OVER (Partition BY A.ContainerNo ORDER BY A.ContainerNo, A.ActionDate)  as LegNo_New
		From #TMS_ALL A
		inner join #TMS_ALL B on A.ROW_ID = B.ROW_ID  and A.AddrKey = B.AddrKey
	) Y on X.ROW_ID = Y.ROW_ID  and X.AddrKey = Y.AddrKey

	Select ContainerNo, Count(1) SFGContCount 
	Into #SFG_ContCount
	from #SFGData
	group by ContainerNo

	Select ContainerNo, Count(1) TMSContCount
	into #TMS_ContCount
	From #TMS_ALL
	Group by ContainerNo

	/* RECORDS MATCHING WITH NO. OF LEGS */
	select 'Matching' as Type, T.ContainerNo, T.TMSContCount, S.SFGContCount
	into #ContMatch
	from #TMS_ContCount T
	LEft JOIN #SFG_ContCount S on T.ContainerNo = S.ContainerNo
	where T.TMSContCount = S.SFGContCount

	/*RECORDS NOT MATCHING WITH NO OF LEGS */
	/*
	select 'Difference' as Type, T.ContainerNo, T.TMSContCount, S.SFGContCount
	into #ContDiff
	from #TMS_ContCount T
	LEft JOIN #SFG_ContCount S on T.ContainerNo = S.ContainerNo
	where T.TMSContCount <> S.SFGContCount
	*/

	IF(@IsDebug = 1)
	BEGIN
		SELECT '#SFGData', * FROM #SFGData ORDER BY ContainerNo, CreatedDate, Effect, ISNULL(COntainerType,'')
		SELECT '#TMSData', * FROM #TMSData ORDER BY ltrim(rtrim(ContainerNo))
		--SELECT * FROM #TMS_FROMYARD ORDER BY ContainerNo, ROW_ID
		--SELECT * FROM #TMS_TOYARD ORDER BY ContainerNo, ROW_ID
		SELECT '#TMS_ALL',* from #TMS_ALL ORDER BY ContainerNo, ROW_ID
		Select '#ContMatch',* from #ContMatch
		--select '#ContDiff',* from #ContDiff
		SELECT '#SFGData', * FROM #SFGData ORDER BY ContainerNo, CreatedDate, Effect, ISNULL(COntainerType,'')
	END
	

	select T.ContainerNo, T.LegNo, T.YardLocation, T.YardLocationID, S.YardName, S.TMSYardID, TMS_LEg_no, T.TranType
	From #TMS_ALL T
	inner join #SFGData S on s.ContainerNo = T.ContainerNo and S.Leg_No = T.LegNO
	inner join #ContMatch M on M.ContainerNo = T.ContainerNo
	where T.YardLocationID <> S.TMSYardID

	/* RECORDS MATCHING WITH TIME MATCH BETWEEN +/-@TimeDiff  */
	select 'Between' as type, T.ContainerNo, T.TMS_LEg_no, T.YardLocation, T.YardLocationID, S.YardName, S.TMSYardID,LegNo,
		T.ActionDate, S.CreatedDate,
		DateDiff(hh, T.ActionDate, S.CreatedDate) as HourDiff, T.RouteKey, T.TranType, T.ORderDetailKey
	INTO #FinalDataToUpdate
	From #TMS_ALL T
	inner join #SFGData S on s.ContainerNo = T.ContainerNo and S.Leg_No = T.LegNO
	inner join #ContMatch M on M.ContainerNo = T.ContainerNo
	where T.YardLocationID <> S.TMSYardID and T.Effect = S.Effect and
	T.ActionDate between DateAdd(hh,-(@TimeDiff), S.CreatedDate) and  DateAdd(hh,(@TimeDiff), S.CreatedDate)
	
	if(@IsDebug =1)
	Begin
		Select '#FinalDataToUpdate', * from #FinalDataToUpdate
	End
	/* RECORDS MATCHING WITH TIME MATCH BETWEEN +/-@TimeDiff  */
	/*
	select 'NOT Between', T.ContainerNo, T.TMS_LEg_no, T.YardLocation, T.YardLocationID, S.YardName, S.TMSYardID,LEgNo,
		T.ActionDate, S.CreatedDate,
		DateDiff(hh, T.ActionDate, S.CreatedDate) as HourDiff
	From #TMS_ALL T
	inner join #SFGData S on s.ContainerNo = T.ContainerNo and S.Leg_No = T.LEgno
	inner join #ContMatch M on M.ContainerNo = T.ContainerNo
	where T.YardLocationID <> S.TMSYardID and T.Effect = S.Effect and
			T.ActionDate NOT between DateAdd(hh,-(@TimeDiff), S.CreatedDate) and  DateAdd(hh,(@TimeDiff), S.CreatedDate)
	*/
	DECLARE @RouteKey				int, 
			@SFGYardLocation		varchar(50), 
			@SFGYardID				int, 
			@TMSYardLocation		varchar(50),
			@TMSYardID				int,
			@CurContainerNo			varchar(20),
			@ActionDate				datetime, 
			@CreatedDAte			datetime,
			@TMS_LEg_no				int,
			@LegNO					int,
			@HourDiff				int,
			@TranType				varchar(20),
			@YardAddrKey			int,
			@ORderDetailKey			int,
			@Comments				varchar(500),
			@AuditKey				int

	Declare DB_Cursor CURSOR FOR 
	SElect ContainerNo, TMS_LEg_no,YardLocation, YardLocationID, YardName as SFGYardName, TMSYardID as SFGYardID, LEgNo, ActionDate,
			CreatedDate, HourDiff, RouteKey, TranType , OrderDetailKey
	from #FinalDataToUpdate

	Open DB_Cursor
	FETCH NEXT From DB_Cursor into @CurContainerNo,@TMS_LEg_no, @TMSYArdLocation, @TMSYardID,
		@SFGYardLocation, @SFGYardID, @LegNO,@ActionDate,@CreatedDAte, @HourDiff,@RouteKey, @TranType, @ORderDetailKey
	WHILE @@FETCH_STATUS = 0
	Begin
		SEt @YardAddrKey = 0
		SET @AuditKey = 0

		Print @CurContainerNo
		SET @Comments = 'AUTO UPDATE: Yard Changed from ' + @TMSYArdLocation + ' to ' + 
					@SFGYardLocation + ' [' +  convert(varchar(50), @SFGYardID) + ']'

		Select @YardAddrKey = AddrKey from Yard WITH (NOLOCK) where YardId = @SFGYardID
		
		INSERT INTO AuditLogDetail (DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT GETDATE(),'Auto','Container',@ContainerNo,@OrderDetailKey,'','Text',@Comments
		SET @AuditKey = @@IDENTITY

		Update Routes Set 
				SFGYardChangePickup			= @TranType,
				SFGYardChangePickupMessage	= 'Yard Changed from ' + @TMSYArdLocation + ' to ' + 
					@SFGYardLocation + ' [' +  convert(varchar(50), @SFGYardID) + ']',
				YardIDPickupBeforeUpdate	= @TMSYardID,
				SourceAddrKey = @YardAddrKey,
				SFGYardDiffLogKeyPickup = @AuditKey
		WHERE RouteKey = @RouteKey and @TranType = 'Pickup'

		Update Routes Set 
				SFGYardChangeDelivery			= @TranType,
				SFGYardChangeDeliveryMessage	= 'Yard Changed from ' + @TMSYArdLocation + ' to ' + 
					@SFGYardLocation + ' [' +  convert(varchar(50), @SFGYardID) + ']',
				YardIDDeliveryBeforeUpdate	= @TMSYardID,
				DestinationAddrKey = @YardAddrKey,
				SFGYardDiffLogKeyDelivery = @AuditKey
		WHERE RouteKey = @RouteKey and @TranType = 'DELIVERY'



		FETCH NEXT From DB_Cursor into @CurContainerNo,@TMS_LEg_no, @TMSYArdLocation, @TMSYardID,
			@SFGYardLocation, @SFGYardID, @LegNO,@ActionDate,@CreatedDAte, @HourDiff,@RouteKey, @TranType, @ORderDetailKey
	End
	Close DB_Cursor
	DEALLOCATE DB_Cursor

/*
	SELECT		A.ActivityId, A.ContainerNo,A.YardName, A.ContainerDesc, A.AddrKey, A.ContainerType ,A.Effect,
				A.CreatedDate,B.YardLocation TMSYardName, B.LegID, B.RouteKey
				,   CAST(ISNULL(B.LegNo,'') AS VARCHAR)LegNo
				, CASE WHEN B.Effect = 1 THEN B.ActualArrival ELSE B.ActualDeparture END AS ArrivalDepartureDate 
				, DestinationAddrKey,SourceAddrKey
				,CASE WHEN C.YardName <> A.YardName 
				THEN 'One more Record found with ActivityID ' +  CAST(C.ActivityId AS VARCHAR) +  
					' for the same Leg on same day (' + CAST(C.CreatedDate AS VARCHAR)  
				+') where Location is ' +  C.YardName  ELSE NULL END AS Remarks
				-- ,A.ContainerNo , B.ContainerNo , A.Effect , B.Effect , A.IsEmpty , B.IsEmpty, C.ContainerNo,C.Effect,C.IsEmpty
	FROM		#SFGData A
	INNER JOIN	#TMSData B ON A.ContainerNo = B.ContainerNo AND A.Effect = B.Effect AND A.IsEmpty = B.IsEmpty
				AND CONVERT(VARCHAR,CreatedDate,101) = CONVERT(VARCHAR, CASE WHEN B.Effect = 1 THEN B.ActualArrival ELSE B.ActualDeparture END,101) 
				AND SL = 1
	LEFT JOIN	(SELECT * FROM #SFGData WHERE SL = 2) C ON A.ContainerNo = C.ContainerNo AND A.Effect = C.Effect AND A.IsEmpty = C.IsEmpty
				AND CONVERT(VARCHAR,A.CreatedDate,101) = CONVERT(VARCHAR,A.CreatedDate,101) 
	WHERE		1 = 1  AND A.TMSYardID <> B.YardLocationID
	ORDER BY	A.ContainerNo,A.CreatedDate
	*/
	DROP TABLE #SFGData
	DROP TABLE #TMSData
	DROP TABLE #TMS_FROMYARD
	DROP TABLE #TMS_TOYARD
	DROP TABLE #ContMatch
	DROP TABLE #SFG_ContCount
	DROP TABLE #TMS_ALL
	DROP TABLE #TMS_ContCount
	drop table #FinalDataToUpdate
END

