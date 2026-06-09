
CREATE PROCEDURE [dbo].[Gnosis_AutoReadyToSchedule]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SELECT GICF.OrderDetailKey INTO #OrderDetailKeys
	from OrderDetail OD WITH (NOLOCK)
	LEFT JOIN Gnosis_Integration_Container_Final GICF WITH (NOLOCK) ON GICF.OrderDetailKey=OD.OrderDetailKey
	WHERE OD.Status=1 AND ISNULL(GICF.Available_for_pickup,'false')='true'


	UPDATE OD SET OD.Status=3
	from OrderDetail OD  
	WHERE OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys)

	UPDATE GICF SET GICF.IsAutoMove=1,
	GICF.MovedBy=49,
	GICF.MovedOn=GETDATE()
	from Gnosis_Integration_Container_Final GICF
	WHERE GICF.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys)

	DROP TABLE #OrderDetailKeys
END
