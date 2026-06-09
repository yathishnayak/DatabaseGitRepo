
CREATE PROC [dbo].[MelroseIntegrate_CreateJsonData_All_Delete]  
-- MelroseIntegrate_CreateJsonData_All_Delete '[{"OrderDetailKey":280028,"Routekey":885294,"StopType":"SF","OrderKey":231210,"OrderTypeKey":1,"EventDate":"2025-12-09T21:47:00","ScheduleActual":"A","AddrKey":40400,"ContainerNo":"KKFU6673497","OrderNo":"DAC012512976"}]'
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
		EventDate			DATETIME,
		ScheduleActual		VARCHAR(10),
		AddrKey				INT,
		OrderNo				VARCHAR(50),
		ContainerNo			VARCHAR(50),
	)


	IF(@JsonString <> '')
		BEGIN
			INSERT INTO		#FinalData
			SELECT			OrderDetailkey,RouteKey,LocationCode,OrderKey,OrderTypeKey,EventDate,ScheduleActual,AddrKey,OrderNo,ContainerNo
			FROM			OPENJSON(@JSONString, '$')
									WITH (
											OrderDetailkey			INT			'$.OrderDetailKey',
											RouteKey				INT			'$.Routekey',
											LocationCode			VARCHAR(10)	'$.StopType',
											OrderKey				INT			'$.OrderKey',
											OrderTypeKey			INT			'$.OrderTypeKey',
											EventDate				DATETIME	'$.EventDate',
											ScheduleActual			VARCHAR(10)	'$.ScheduleActual',
											AddrKey					INT			'$.AddrKey',
											OrderNo					VARCHAR(50)	'$.OrderNo',
											ContainerNo				VARCHAR(50)	'$.ContainerNo'
										)
			
		END
	
	SELECT FD.*
	-- , ISNULL(OD.BookingNo,ISNULL(OH.BookingNo,ISNULL(OD.BillOfLadding,OH.BillOfLading)))BookingNo
	, CASE	WHEN ISNULL(OD.BookingNo,'') = ''
			THEN CASE WHEN ISNULL(OH.BookingNo,'') = '' 
					  THEN CASE WHEN ISNULL(OD.BillOfLadding,'') = '' 
								THEN OH.BillOfLading 
								ELSE OD.BillOfLadding END 
					  ELSE  OH.BookingNo END 
			ELSE OD.BookingNo  END  BookingNo
	, OD.BookingNo ODBook ,OH.BookingNo OHBook ,OD.BillOfLadding ODBOL , OH.BillOfLading OHBOL
	INTO #OrderData
	FROM #FinalData FD
	INNER JOIN Routes RT WITH (NOLOCK) ON FD.RouteKey = RT.RouteKey
	INNER JOIN OrderDetail OD  WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN OrderHeader OH  WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey 

	SELECT * FROM #OrderData

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
				,0 RefDataKey,ContainerNo,A.RouteKey,LocationCode,0, OrderNo,
				CASE  
					WHEN LocationCode = 'SF' THEN 'GTOT'
					WHEN LocationCode = 'ST' THEN 'DROP'
					WHEN LocationCode = 'ER' THEN 'AVPU'
					WHEN LocationCode = 'RP' THEN 'PICK'
					WHEN LocationCode = 'EP' THEN 'PICK'
					WHEN LocationCode = 'RT' THEN 'GTIN' END AS EventType
					,'TRUCK' AS TransportMode
					, CASE WHEN  LocationCode IN ('SF','RT') THEN 'POTE' ELSE 'CLOC' END AS FacilityType
					, CASE WHEN (LocationCode IN ('RT','EP','ER')) THEN 'EMPTY' ELSE 'LADEN' END AS EmptyIndicator
					, A.OrderKey , A.OrderDetailkey,AddrKey
					, CASE WHEN ScheduleActual = 'S' THEN 'Schedule' ELSE 'Actual' END 
	FROM		#FinalData  A

	--SELECT * FROM #FinalData 

	--SELECT * FROM #TMPData
	 
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
							   CASE WHEN ISNULL(LTRIM(RTRIM(Country)),'USA') = 'US' THEN 'USA' 
							WHEN ISNULL(LTRIM(RTRIM(Country)),'USA') = '' THEN 'USA' 
							ELSE ISNULL(LTRIM(RTRIM(Country)),'USA') END AS country_code, 
							   AD.ZipCode AS postal_code
						FROM #TMPData T
						INNER JOIN Address AD WITH (NOLOCK) ON T.AddrKey = AD.AddrKey
						WHERE T.Routekey = RT.Routekey AND T.EventType = RT.EventType
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
					)) AS address_location
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			)),

			-- references 
			[references] = (
						SELECT * FROM (SELECT DISTINCT 'PO' AS reference_type_code, 
							   OrderNo AS reference_value
						FROM #TMPData T
						WHERE T.Routekey = RT.Routekey AND T.EventType = RT.EventType
						UNION ALL
						SELECT DISTINCT 'PieceCount' AS reference_type_code, 
							   '0' AS reference_value
						FROM #TMPData T
						WHERE T.Routekey = RT.Routekey AND T.EventType = RT.EventType
						UNION ALL
						SELECT DISTINCT TOP 1 'CBR' AS reference_type_code, 
							   BookingNo AS reference_value
						FROM #OrderData
						) A
						FOR JSON PATH 
			)

		FROM #TMPData RT WITH (NOLOCK) 
		-- WHERE RouteKey = @RouteKey
		FOR JSON PATH 
	);

	SELECT @JSONResult AS JSONResult

	DROP TABLE #TMPData
	
END
