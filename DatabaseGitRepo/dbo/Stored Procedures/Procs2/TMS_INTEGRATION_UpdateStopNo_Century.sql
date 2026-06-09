

CREATE PROC [dbo].[TMS_INTEGRATION_UpdateStopNo_Century] -- TMS_INTEGRATION_UpdateStopNo_Century 1195
(
	@ContainerKey INT = 0
)
AS
/*
SELECT * FROM Integration_JCB.DBO.Century_StopList
WHERE ContainerKey = 1195
*/

BEGIN
	SELECT		SL.StopKey, SL.facilityCode, ROW_NUMBER() OVER (ORDER BY OrderBy) SL
	INTO		#TMPData
	FROM		Integration_JCB.DBO.Century_StopList SL
	INNER JOIN	TMS_Integration_SiteIDFacilityCodes SN ON SL.facilityCode = SN.facilityCode
	WHERE		SL.ContainerKey = @ContainerKey AND SiteID = 'Century'

	UPDATE		SL
	SET			stopNumber = SL, stopReferenceNumber = SL
	FROM		Integration_JCB.DBO.Century_StopList SL
	INNER JOIN	#TMPData T ON SL.StopKey = T.StopKey

	DROP TABLE	#TMPData
END
 