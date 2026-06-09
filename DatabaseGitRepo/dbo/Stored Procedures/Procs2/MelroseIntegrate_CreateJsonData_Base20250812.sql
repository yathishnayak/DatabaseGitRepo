CREATE PROC [dbo].[MelroseIntegrate_CreateJsonData_Base20250812]  -- MelroseIntegrate_CreateJsonData_Base20250812 '[{"StopKey":1298231,"ScheduleActual":"A"}]'
(
	@JsonString NVARCHAR(MAX) = ''
)

AS

BEGIN
	
	DECLARE @JSONResult NVARCHAR(MAX);
	DECLARE @event_classifier VARCHAR(10) = ''


	CREATE TABLE #FinalData
	(
		OrderDetailkey		INT,
		RouteKey			INT,
		LocationCode		VARCHAR(10),
		OrderKey			INT,
		OrderTypeKey		INT,
		LocationType		VARCHAR(20),
		LegNo				INT,
		IsEmpty				BIT,
		IsDryRun			BIT,
		LegKey				INT,
		EventDate			DATETIME,
		ScheduleActual		VARCHAR(5),
		AddrKey				INT,
		RefDataKey			INT
	)

	CREATE TABLE #StopKeys
	(
		StopKey			INT,
		ScheduleActual	VARCHAR(10)

	)

	--UPDATE		RU SET IsDataSenttoMelrose = 1, SentToMelroseDate = ID.CreatedDate
	--FROM			MelroseIntegrate_RouteDateUpdates  RU WITH (NOLOCK)
	--INNER JOIN	MelroseIntegrate.dbo.Integration_Data  ID WITH (NOLOCK) ON RU.Datakey <= ID.DataKey AND RU.OrderKey = ID.OrderKey
	--WHERE			ISNULL(RU.IsDataSenttoMelrose,0) = 0

	--INSERT INTO #FinalData
	--EXEC MelroseIntegrate_GetRouteDateUpdates

	IF(@JsonString <> '')
		BEGIN
			INSERT INTO		#StopKeys
			SELECT			Stopkey,ScheduleActual
			FROM			OPENJSON(@JSONString, '$')
									WITH (
											Stopkey			INT				'$.StopKey',
											ScheduleActual	VARCHAR(10)		'$.ScheduleActual'
										)
			
			SELECT * INTO #MelroseIntegrate_RouteDateUpdates FROM MelroseIntegrate_RouteDateUpdates
			WHERE 1 = 2

			-- SELECT * FROM #StopKeys
			IF(SELECT COUNT(*) FROM #StopKeys) > 0
				BEGIN
					INSERT INTO	#MelroseIntegrate_RouteDateUpdates
								(OrderKey,RouteKey,UpdateColumnName,IsRouteRecordUpdate,IsInitiated,InitiatedDate,IsDataSenttoMelrose
								,SentToMelroseDate,CreatedDate)
					SELECT		DISTINCT TMS_OrderKey ,0,'',NULL,NULL,NULL,0,NULL,GETDATE() 
					FROM		Integration_JCB.dbo.Flexpro_StopList  SL WITH (NOLOCK)
					INNER JOIN	Integration_JCB.dbo.Flexpro_ContainerList CL WITH (NOLOCK) ON SL.ContainerKey = CL.ContainerKey
					INNER JOIN	Integration_JCB.dbo.Flexpro_Header H WITH (NOLOCK) ON Cl.DataKey = H.DataKey
					INNER JOIN	#StopKeys SK ON SL.StopKey = Sk.StopKey
					WHERE		ISNULL(TMS_OrderKey,0) > 0
				END
		END
	
	SELECT		DISTINCT H.TMS_OrderKey OrderKey, SL.StopKey, facilityCode , SK.ScheduleActual
	INTO		#StopDetails
	FROM		Integration_JCB.dbo.Flexpro_Header H WITH (NOLOCK)
	INNER JOIN	Integration_JCB.dbo.Flexpro_ContainerList CL WITH (NOLOCK) On H.DataKey = Cl.DataKey
	INNER JOIN	Integration_JCB.dbo.Flexpro_StopList SL WITH (NOLOCK) ON CL.ContainerKey = SL.ContainerKey
	INNER JOIN	#StopKeys SK ON SL.StopKey = SK.StopKey
	
	--SELECT * FROM #StopDetails

	SELECT		ROW_NUMBER() OVER (ORDER BY OrderKey) AS SL, MAX(Datakey) Datakey, OrderKey
	INTO		#RouteUpdateData
	FROM		#MelroseIntegrate_RouteDateUpdates WITH (NOLOCK)
	WHERE		ISNULL(IsDataSenttoMelrose,0) = 0 --  AND OrderKey = 190947
	GROUP BY	OrderKey

	---SELECT * FROM #RouteUpdateData WHERE  OrderKey IN (SELECT DISTINCT OrderKey FROM #StopDetails)

	DECLARE		@OrderKey INT = 0, @i INT = 1, @OutputID VARCHAR(50), @RefDataKey	INT  =0

	WHILE(@i <= (SELECT COUNT(*) FROM #RouteUpdateData))
		BEGIN
			SELECT		@OrderKey =  OrderKey, @RefDataKey = Datakey 
			FROM		#RouteUpdateData 
			WHERE		SL = @i 
			-- SELECT @OrderKey
			 EXEC		MelroseIntegrate_GetScheduleAndActuals @OrderKey , @OutputID OUTPUT

			INSERT INTO #FinalData
			SELECT		OrderDetailKey,RouteKey,Locationtype,OrderKey,OrderTypeKey,Loco,LegNo,IsEmpty,IsDryRun
						,LegKey,EventDate,ScheduleActual,AddrKey , @RefDataKey
			FROm		MelroseIntegrate_SchedulesActuals_WRK WITH (NOLOCK)
			WHERE		ID = @OutputID

			-- SELECT * FROM #FinalData
			--SELECT DISTINCT OrderKey FROM #StopDetails

			--SELECT * FROM MelroseIntegrate_SchedulesActuals_WRK WHERE  OrderKey IN (SELECT DISTINCT OrderKey FROM #StopDetails)

			DELETE FROM MelroseIntegrate_SchedulesActuals_WRK WHERE ID = @OutputID

			SET @i = @i +1
		END

	-- SELECT * FROM #FinalData

	-- SELECT 'Data',* FROM #FinalData WHERE OrderKey IN (SELECT DISTINCT OrderKey FROM #StopDetails)

	--SELECT * FROM #StopDetails

	DELETE		FD
	--SELECT		'Test',FD.OrderKey,FD.LocationType, SD.OrderKey,SD.facilityCode
	FROM		(SELECT * FROM #FinalData WHERE OrderKey IN (SELECT DISTINCT OrderKey FROM #StopDetails)) FD
	LEFT JOIN	#StopDetails SD ON FD.OrderKey = SD.OrderKey AND FD.LocationCode = SD.facilityCode AND FD.ScheduleActual = SD.ScheduleActual
				
	WHERE		SD.OrderKey IS NULL

	CREATE TABLE #TMPData
	(
		event_classifier	VARCHAR(10),
		EventDate			DATETIME,
		RefDatakey			INT,
		ContainerNo			VARCHAR(50),
		Routekey			INT,
		FacilityCode		VARCHAR(10),
		IsRouteRecordUpdate	BIT,
		OrderNo				VARCHAR(50),
		EventType			VARCHAR(10),
		TransportMode		VARCHAR(10),
		FacilityType		VARCHAR(10),
		EmptyIndicator		VARCHAR(10),
		OrderKey			INT,
		OrderDetailKey		INT,
		AddrKey				INT,
		ScheduleActual		VARCHAR(20)
	)
		

	INSERT INTO	#TMPData
	SELECT		CASE WHEN ScheduleActual = 'S' THEN 'PLN' ELSE 'ACT' END AS event_classifier
				, CAST(EventDate AT TIME ZONE 'Pacific Standard Time' AT TIME ZONE 'UTC' AS DATETIME) AS EventDate
				,RefDataKey,ContainerNo,A.RouteKey,LocationCode,0, OH.OrderNo,
				CASE  
					WHEN LocationCode = 'SF' THEN 'GTOT'
					WHEN LocationCode = 'ST' THEN 'DROP'
					WHEN LocationCode = 'ER' THEN 'PICK'
					WHEN LocationCode = 'RP' THEN 'PICK'
					WHEN LocationCode = 'EP' THEN 'PICK'
					WHEN LocationCode = 'RT' THEN 'GTIN' END AS EventType
					,'TRUCK' AS TransportMode
					, CASE WHEN  LocationCode IN ('SF','RT') THEN 'POTE' ELSE 'CLOC' END AS FacilityType
					, CASE WHEN (LocationCode IN ('RT','EP')) THEN 'EMPTY' ELSE 'LADEN' END AS EmptyIndicator
					, A.OrderKey , A.OrderDetailkey,AddrKey
					, CASE WHEN ScheduleActual = 'S' THEN 'Schedule' ELSE 'Actual' END 
	FROM		#FinalData  A
	INNER JOIn	OrderDetail OD WITH (NOLOCK) On A.OrderDetailkey = OD.OrderDetailKey
	INNER JOIN	OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
	--WHERE		LocationCode <> 'ER'	


	-- SELECT * FROM #TMPData
	 
	SET @JSONResult = (
		SELECT 
			event_classifier event_classifier, 
			EventDate AS event_date_time,RT.OrderNo,
			RefDatakey As RefDataKey,RT.ContainerNo,Routekey,IsRouteRecordUpdate,OrderKey, OrderDetailkey, FacilityCode,  ScheduleActual,
			--Equipment Event
			equipment_event = JSON_QUERY((
				SELECT ContainerNo AS equipment_reference, 
					   EventType AS event_type, 
					   TransportMode AS transport_mode, 
					   FacilityType AS facility_type, 
					  EmptyIndicator AS empty_indicator
				FROM #TMPData T  
				WHERE T.Routekey = RT.Routekey AND T.EventType = RT.EventType
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			)),

			/*
			-- Transport Event
			transport_event = JSON_QUERY((
				SELECT 'ARRI' AS event_type, 
					   EventDate AS event_date_time, 
					   TransportMode AS transport_mode, 
					   FacilityType AS facility_type
				FROM #TMPData T
				WHERE T.Routekey = RT.Routekey AND T.EventType = RT.EventType
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			)),
			*/

			-- Location 
			location = JSON_QUERY((
				SELECT 
					JSON_QUERY((
						SELECT AD.AddrName AS name, 
							   AD.Address1 AS address_line_1, 
							   AD.City AS city, 
							   AD.State AS state, 
							   AD.Country AS country_code, 
							   AD.ZipCode AS postal_code
						FROM #TMPData T
						INNER JOIN Address AD WITH (NOLOCK) ON T.AddrKey = AD.AddrKey
						WHERE T.Routekey = RT.Routekey AND T.EventType = RT.EventType
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
					)) AS address_location
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			))

		FROM #TMPData RT WITH (NOLOCK) 
		-- WHERE RouteKey = @RouteKey
		FOR JSON PATH 
	);

	SELECT @JSONResult AS JSONResult

	DROP TABLE #TMPData
	
END