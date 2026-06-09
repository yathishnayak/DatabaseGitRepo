

CREATE PROCEDURE Admin_GnosisMilestoneComparison -- Admin_GnosisMilestoneComparison 'GCXU5332206'
(
	@ContainerNo VARCHAR(20)
)

AS

BEGIN
	 SET NOCOUNT ON;

	SELECT		RT.RouteKey, GETDATE() AS SchedulePickup, GETDATE() AS ScheduleDelivery, GETDATE() AS ActualPickup, GETDATE() AS ActualDelivery
	INTO		#TMSData
	FROM		OrderDetail OD
	INNER JOIN	Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
	WHERE		OD.ContainerNo = @ContainerNo

	 DECLARE @Result NVARCHAR(MAX)
	 
	 SELECT @Result =
    (SELECT
		(
		-- Gnosis Data------------

		SELECT		D.CreatedDate,  C.Out_gate_dt  
		FROM		Gnosis_Integration_Container C
		INNER JOIN	Gnosis_Integration_ContainerDataJson D ON C.RecordKey = D.RecordKey
		WHERE		Container_number = @ContainerNo AND Out_gate_dt iS NOT NULL
		ORDER By	D.CreatedDate
		FOR JSON PATH
		) AS GnosisData,
		(
		-- TMS Data ---------------------

		SELECT		*
		FROM		#TMSData
		FOR JSON PATH
		) AS TMSData ,
		(
		------Route Log -----------------------------

		SELECT		RL.RouteKey, GETDATE() AS SchedulePickup, GETDATE() AS ScheduleDelivery, GETDATE() AS ActualPickup, GETDATE() AS ActualDelivery 
		FROM		Routes_Log RL
		INNER JOIN	#TMSData TD ON RL.RouteKey = TD.RouteKey
		FOR JSON PATH
		) AS RouteLog,
		(
		---Melrose Data------------------------------------------

		SELECt		FacilityCode, ScheduleActual, EventDate, CreatedDate, IsSuccess 
		FROm		MelroseIntegrate.dbo.Integration_Data ID
		WHERE		ContainerNo = @ContainerNo
		FOR JSON PATH
		) AS MelroseData

		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )

    SELECT @Result AS JsonOutput

END