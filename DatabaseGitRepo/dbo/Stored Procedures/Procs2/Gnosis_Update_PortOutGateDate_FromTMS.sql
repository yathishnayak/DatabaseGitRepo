
CREATE PROCEDURE [dbo].[Gnosis_Update_PortOutGateDate_FromTMS]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	DECLARE @Comment NVARCHAR(MAX)='Gnosis Out_gate_dt is updated from null to ActualDeparture of TMS By Admin';
	--SELECT GF.Container_number, Od.OrderDetailKey, RT.ActualDeparture, L.LegID, L.FromLocation, RT.IsDryRun 
	SELECT GF.Container_number, Od.OrderDetailKey, RT.ActualDeparture, L.LegID, L.FromLocation, RT.IsDryRun, OD.ContainerNo INTO #TempData
		FROM [Routes] Rt WITH (NOLOCK)
		INNER JOIN Leg L WITH (NOLOCK) ON Rt.LegKey = L.LegKey
		INNER JOIN OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN Gnosis_Integration_Container_Final GF WITH (NOLOCK) ON OD.OrderDetailKey = GF.OrderDetailKey
		WHERE GF.ContainerStatus NOT IN ('Empty Returned','Out for Delivery') AND ISNULL(Out_gate_dt,'')=''
		AND L.FromLocation = 'PORT' AND ISNULL(IsDryRun,0) = 0
		AND Rt.ActualDeparture IS NOT NULL 

	BEGIN TRANSACTION
	BEGIN TRY
		--AND Container_number='ONEU9079738'
		UPDATE GF SET GF.Out_gate_dt=CONVERT(DATE,TD.ActualDeparture)
		FROM #TempData TD
		INNER JOIN Gnosis_Integration_Container_Final GF WITH (NOLOCK) ON TD.OrderDetailKey = GF.OrderDetailKey

		INSERT INTO  AuditLogDetail(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
		SELECT GETDATE(),'Admin','Container',ContainerNo,null,'Text',@Comment,OrderDetailKey FROM #TempData
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH
END
