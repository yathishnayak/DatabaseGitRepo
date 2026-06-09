/*
DECLARE @UserKey INT = 714 ,@JSONString NVARCHAR(MAX),@Status BIT,@Reason VARCHAR(10)
SET @JSONString = '{"ContainerNo":""}'
EXEC Integration_DataGet @UserKey,@JSONString,@Status OUTPUT, @Reason OUTPUT
SELECT @Status, @Reason
*/

CREATE PROC [dbo].[Integration_DataGet](
	 @UserKey INT,
     @JSONString NVARCHAR(MAX),
     @Status BIT OUTPUT,
     @Reason VARCHAR(10) OUTPUT
)
AS BEGIN
	SET @Status = 1
	SET @Reason = ''


	-- DROP TABLE #LoctionTypes
	CREATE TABLE #LoctionTypes
	(
		LocationName	VARCHAR(50),
		LocationType	VARCHAR(10),
		OrderBy			INT
	)

	INSERT INTO #LoctionTypes
	VALUES ('Pickup','SF',1), ('Drop','ST',2), ('Empty Ready','ER',3), ('Empty Pickup','EP',4), ('Return','RT',5) 

	DECLARE 
		@ContainerNo VARCHAR(20),
		@DateBy DATETIME


	IF(ISNULL(@JSONString,'') <> '')
		BEGIN
			SET @ContainerNo = JSON_VALUE(@JSONString,'$.ContainerNo')
		END

	-- SET @ContainerNo = 'HLBU3766817'

	IF(@ContainerNo IS NULL)
		SET @DateBy = GETDATE() - 1
	ELSE
		SET @DateBy = '2023-01-01 04:39:59.590'

	SET @ContainerNo = ISNULL(@ContainerNo,'')
	
	SELECT		DataKey,RouteKey,OrderNo,ContainerNo,OrderKey,ISNULL(ScheduleActual,'') AS ScheduleActual,
                OrderDetailKey,LT.LocationName + ' - (' +  FacilityCode + ')' AS FacilityCode,UserKey,EventDate,
                IsRouteRecordUpdate,Id,IsSuccess,RequestSent,ResponseReceived,
                ID.CreatedDate,OrderBy,
                ROW_NUMBER() OVER (PARTITION BY OrderKey, ScheduleActual,FacilityCode  ORDER BY  DataKey DESC ) AS SL
	INTO		#TMP_Integration_Data
	FROM		Integration_Data ID WITH (NOLOCK) 
	INNER JOIN	#LoctionTypes LT ON ID.FacilityCode = LT.LocationType
	WHERE		ID.CreatedDate > @DateBy 
				AND (CASE WHEN @ContainerNo = '' THEN '' ELSE ID.ContainerNo END) = @ContainerNo
	
	--WHERE		ID.CreatedDate > '2025-08-11 04:39:59.590' --  ID.ContainerNo = 'UACU5776329'

	--SELECT		*
	--INTO		#RouteEventChanges
	--FROM		JCBDB_Live.dbo.vw_RouteEventChanges EC
	--WHERE		RouteKey IN (SELECT DISTINCT RouteKey FROM #TMP_Integration_Data)


	DECLARE @JsonResult NVARCHAR(MAX) = ''

	SET @JsonResult =	
	(SELECT	*	
	FROM	(SELECT		DataKey,ID#1.RouteKey,OrderNo,ContainerNo,OrderKey,ISNULL(ScheduleActual,'') AS ScheduleActual,
						OrderDetailKey,FacilityCode,UserKey
						-- ,(ID#1.EventDate AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time')  AS EventDate
						, ID#1.EventDate  AS EventDate
						, ID#1.EventDate AS EventDateUTC,  IsRouteRecordUpdate,Id,
						IsSuccess,RequestSent,ResponseReceived,CreatedDate,OrderBy,
						ROW_NUMBER() OVER (PARTITION BY OrderKey, ScheduleActual,FacilityCode  ORDER BY  DataKey DESC ) AS SL,
						RouteSubData = (SELECT		DataKey,
													ID#2.RouteKey,
													OrderNo,
													ContainerNo,
													OrderKey,
													ISNULL(ScheduleActual,'') AS ScheduleActual,   
													OrderDetailKey,
													FacilityCode,
													UserKey,
													ID#2.EventDate,
													ID#2.EventDate AS EventDateIST,
													IsRouteRecordUpdate,
													Id,
													IsSuccess,
													RequestSent,
													ResponseReceived,
													CreatedDate
										FROM		#TMP_Integration_Data ID#2
										WHERE		ID#1.OrderDetailKey = ID#2.OrderDetailKey 
													AND ID#1.FacilityCode = ID#2.FacilityCode 
													AND ID#1.ScheduleActual = ID#2.ScheduleActual
													AND SL <> 1
													ORDER BY CreatedDate DESC
										FOR JSON PATH, INCLUDE_NULL_VALUES
										)
						--ActualArrival = (SELECT EventDate,LastUpdateDate FROM #RouteEventChanges EC 
						--				WHERE EventType = 'Actual Arrival' AND EC.RouteKey = ID#1.RouteKey
						--				FOR JSON PATH),
						--ActualDeparture = (SELECT EventDate,LastUpdateDate FROM #RouteEventChanges EC1 
						--				WHERE EventType = 'Actual Departure' AND EC1.RouteKey = ID#1.RouteKey
						--				FOR JSON PATH)
			FROM		#TMP_Integration_Data ID#1) A
	WHERE	SL = 1  -- AND OrderKey IN (144952, 144951)
	ORDER BY CASE WHEN @ContainerNo <> '' THEN GETDATE() ELSE CreatedDate END  DESC , OrderBy, ScheduleActual DESC  --,ContainerNo, ScheduleActual,OrderBy  DESC	
	FOR JSON PATH, INCLUDE_NULL_VALUES
	)

	SELECT @JsonResult AS JsonResult

END
