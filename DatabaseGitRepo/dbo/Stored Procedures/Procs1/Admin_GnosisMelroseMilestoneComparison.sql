

/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"ContainerNo":"CMAU8349689"}'
SET	@IsDebug  = 0

EXEC [Admin_GnosisMelroseMilestoneComparison] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/

CREATE PROCEDURE [dbo].[Admin_GnosisMelroseMilestoneComparison] -- Admin_GnosisMelroseMilestoneComparison 'TLLU4206655'
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	@Result1		VARCHAR(1000)	= ''	OUTPUT,
	@Result2		VARCHAR(1000)	= ''	OUTPUT,
	@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@IsDebug		BIT				= 0
)

AS

BEGIN
	 SET NOCOUNT ON;

	 DECLARE @ContainerNo VARCHAR(20) = ''

	SELECT	@ContainerNo = ContainerNo
	FROM	OPENJSON(@JSONString, '$')
			WITH (
					ContainerNo			VARCHAR(20)	 '$.ContainerNo'
				)

	 -- Gnosis Data------------
	SELECT		A.ReceivedDateUTC,A.ReceivedDatePST, A.Out_gate_dt, A.ContainerNo
	INTO		#GnosisData
	FROM		(SELECT		D.CreatedDate AS ReceivedDateUTC
							,CAST(D.CreatedDate AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME2(3) )   AS ReceivedDatePST
							,C.Out_gate_dt 
							, ROW_NUMBER() OVER (PARTITION BY C.Out_gate_dt ORDER BY D.CreatedDate)Sl
							, C.Container_number AS ContainerNo
				FROM		Gnosis_Integration_Container C
				INNER JOIN	Gnosis_Integration_ContainerDataJson D ON C.RecordKey = D.RecordKey
				WHERE		Container_number = @ContainerNo AND Out_gate_dt iS NOT NULL ) A 
	WHERE		Sl = 1


	-- TMS Data ---------------------
	SELECT		RT.RouteKey, L.LegID
				,ISNULL(isnull(Isnull(RT.PickupDateTo,RT.PickupDateFrom), RT.ActualDeparture),'1900-01-01') AS SchedulePickup
				,ISNULL(isnull(isnull(RT.DeliveryDateTo, Rt.DeliveryDateFrom),RT.ActualArrival),'1900-01-01') AS ScheduleDelivery
				, ISNULL(RT.ActualDeparture,'1900-01-01') AS ActualPickup, ISNULL(RT.ActualArrival,'1900-01-01') AS ActualDelivery
				
				,OD.OrderDetailKey
				,OD.OrderKey
				,OD.ContainerNo
				,OD.CreateDate
				,OD.BillOfLadding

	INTO		#TMSData
	FROM		OrderDetail OD
	INNER JOIN	Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
	LEFT JOIN	Leg L ON RT.LegKey = L.LegKey
	WHERE		OD.ContainerNo = @ContainerNo

	------Route Log -----------------------------

	CREATE TABLE #RouteLog
	(
		RouteKey		INT,
		LastUpdateDate	DATETIME,
		SchedulePickup	DATETIME,
		ScheduleDelivery	DATETIME,
		ActualPickup	DATETIME,
		ActualDelivery	DATETIME
	)



	INSERT INTO #RouteLog
	SELECT		RT.RouteKey, LastUpdateDate
				,ISNULL(isnull(Isnull(RT.PickupDateTo,RT.PickupDateFrom), RT.ActualDeparture),'1900-01-01') AS SchedulePickup
				,ISNULL(isnull(isnull(RT.DeliveryDateTo, Rt.DeliveryDateFrom),RT.ActualArrival),'1900-01-01') AS ScheduleDelivery
				, ISNULL(RT.ActualDeparture,'1900-01-01') AS ActualPickup, ISNULL(RT.ActualArrival,'1900-01-01') AS ActualDelivery
	FROM		Routes_Log RT
	INNER JOIN	#TMSData TD ON RT.RouteKey = TD.RouteKey
	ORDER BY	LastUpdateDate

	---Melrose Data------------------------------------------
	SELECt		FacilityCode, ScheduleActual, EventDate AS EventDateUTC
				,CAST(EventDate AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time' AS DATETIME) AS EventDatePST
				, CreatedDate, IsSuccess 

				, ID.RequestSent, ID.ResponseReceived
				,ID.ContainerNo, ID.DataKey
	INTO		#MelroseData
	FROm		MelroseIntegrate.dbo.Integration_Data ID
	WHERE		ContainerNo = @ContainerNo

	DECLARE		@Result NVARCHAR(MAX)
	 
	SET	@Result = (
		SELECT 
		TOP 1
			@ContainerNo AS ContainerNo,
			TD.OrderDetailKey,
			TD.OrderKey,
			MD.DataKey,
			TD.CreateDate,
			OH.CustKey,
			ISNULL(OH.BillOfLading, TD.BillOfLadding) AS MBLNo,

			(
				SELECT 
					GD2.ReceivedDateUTC, GD2.ReceivedDatePST, GD2.Out_gate_dt
				FROM  #GnosisData GD2 WITH (NOLOCK)
				WHERE GD2.ContainerNo = MD.ContainerNo
				FOR JSON PATH
			) AS GnosisData,
			(
				SELECT 
					TD2.RouteKey, TD2.LegID, TD2.SchedulePickup, TD2.ScheduleDelivery, TD2.ActualDelivery, TD2.ActualPickup
				FROM #TMSData TD2 WITH (NOLOCK)
				WHERE TD2.ContainerNo = MD.ContainerNo
				FOR JSON PATH
			) AS TMSData,
			(
				SELECT 
					RL.RouteKey,
					(
						SELECT 
							LastUpdateDate,
							SchedulePickup,
							ScheduleDelivery,
							ActualPickup,
							ActualDelivery
						FROM #RouteLog RL2 WITH (NOLOCK)
						WHERE RL2.RouteKey = RL.RouteKey
						FOR JSON PATH
					) AS RouteInfo
				FROM 
					#RouteLog RL WITH (NOLOCK)
				GROUP BY RL.RouteKey
				ORDER BY RL.RouteKey
				FOR JSON PATH 
			) AS RouteLog,
			(
				SELECT	
					MD2.FacilityCode, MD2.ScheduleActual, MD2.EventDatePST, MD2.EventDateUTC, MD2.CreatedDate, MD2.IsSuccess, MD2.RequestSent, MD2.ResponseReceived
				FROM #MelroseData MD2 WITH (NOLOCK)
				WHERE MD2.ContainerNo = MD.ContainerNo
				FOR JSON PATH, INCLUDE_NULL_VALUES
			) AS MelroseData
		FROM 
			#MelroseData AS MD WITH (NOLOCK)
			LEFT JOIN #TMSData AS TD WITH (NOLOCK)
				ON TD.ContainerNo = MD.ContainerNo
			LEFT JOIN #GnosisData AS GD WITH (NOLOCK)
				ON GD.ContainerNo = MD.ContainerNo
			LEFT JOIN  OrderHeader OH
				ON OH.OrderKey = TD.OrderKey
		FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER 

		/*
		SELECT		@ContainerNo AS ContainerNo,
				(SELECT * FROM #GnosisData FOR JSON PATH ) AS GnosisData,
				(SELECT	* FROM #TMSData FOR JSON PATH ) AS TMSData ,
				(SELECT 
					RL.RouteKey,
					(
						SELECT 
							LastUpdateDate,
							SchedulePickup,
							ScheduleDelivery,
							ActualPickup,
							ActualDelivery
						FROM #RouteLog RL2
						WHERE RL2.RouteKey = RL.RouteKey
						ORDER BY	LastUpdateDate
						FOR JSON PATH
					) AS RouteInfo
				FROM #RouteLog RL
				GROUP BY RL.RouteKey
				
				FOR JSON PATH ) AS RouteLog ,
				(SELECT	* FROM #MelroseData FOR JSON PATH ) AS MelroseData
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER 
		*/
	);

    SELECT @Result AS JsonOutput

END
