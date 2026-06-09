CREATE PROCEDURE Gnosis_JOB_DataForScheduler
AS
BEGIN
	SELECT 
		OD.OrderDetailKey,MBL_number,0 AS SSLKey,Mother_vessel,
		CAST(isnull(GICF.Vessel_eta_dt,Gnosis_vessel_eta_dt)  AS DATETIME) AS ETAATADT ,
		CAST(GICF.Last_free_demurrage_day_dt AS DATETIME) AS LFD,
		CS.ContainerSizeKey,
		SGS.StatusKey,
		IIF(isnull(GICF.Available_for_pickup,'false')='false',0,1)AS Available ,
		CASE WHEN (CTF = 'true' OR TMF = 'true' 
			OR Line = 'true' OR Other = 'true' OR Customs = 'true') THEN 1
			WHEN (CTF = 'false' and TMF = 'false' 
			and Line = 'false' and Other = 'false' and Customs = 'false') THEN 0 END AS Hold,
		CASE WHEN CTF = 'true' THEN 1 WHEN TMF = 'true' THEN  5
			WHEN Line = 'true' THEN 3 WHEN Other = 'true' THEN 4 
			WHEN Customs = 'true'THEN 2 END AS HoldType,
			'' AS HoldNote,ISNULL(GICF.Available_dt,CAST( case when Is_railing = 'true' then GICF.Rail_discharged_dt else  GICF.Discharged_dt end  AS DATETIME)) AS AvailableDate
	INTO #TempGnosisData
	FROM Gnosis_Integration_Container_Final GICF
	INNER JOIN OrderDetail OD ON OD.OrderDetailKey=GICF.OrderDetailKey
	LEFT JOIN Gnosis_Integration_MBL_FINAL GIMF ON GICF.UUID=GIMF.UUID
	LEFT JOIN Gnosis_Integration_Holds_Final GIHF  ON GICF.UUID=GIHF.UUID
	Left JOIN Scheduler_GnosisContainerStatus SGS ON SGS.StatusName=GICF.ContainerStatus
	LEFT JOIN ContainerSize CS ON REPLACE(CS.Description,' ' ,'')= CASE WHEN GICF.Container_type LIKE '%[^a-zA-Z0-9]%' THEN REPLACE(GICF.Container_type,' ','')
															   ELSE isnull(GICF.Length,'')+REPLACE(isnull(GICF.Container_type,''),' ','') END

	INSERT INTO Container_GnosisData
	(OrderDetailKey,MBL,SSLKey,Vessel,ETA_ATA,LFD,Size_Type,ContainerStatus,Available,Hold,HoldType,HoldNote,AvailableDate)
	SELECt * FROM #TempGnosisData WHERE OrderDetailKey NOT IN (SELECT OrderDetailKey FROM Container_GnosisData)

	UPDATE CG
	SET 
		MBL=CASE WHEN ISNULL(CG.MBLChangedByUser,0)=0 THEN TG.MBL_number ELSE CG.MBL END,
		Vessel=CASE WHEN ISNULL(CG.VesselChangedByUser,0)=0 THEN TG.Mother_vessel ELSE CG.Vessel END,
		ETA_ATA=CASE WHEN ISNULL(CG.ETA_ATAChangedByUser,0)=0 THEN TG.ETAATADT ELSE CG.ETA_ATA END,
		LFD=CASE WHEN ISNULL(CG.LFDChangedByUser,0)=0 THEN TG.LFD ELSE CG.LFD END,
		Size_Type=CASE WHEN ISNULL(CG.Size_TypeChangedByUser,0)=0 THEN TG.ContainerSizeKey ELSE CG.Size_Type END,
		ContainerStatus=CASE WHEN ISNULL(CG.ContainerStatusChangedByUser,0)=0 THEN TG.StatusKey ELSE CG.ContainerStatus END,
		Available=CASE WHEN ISNULL(CG.AvailableChangedByUser,0)=0 THEN TG.Available ELSE CG.Available END,
		Hold=CASE WHEN ISNULL(CG.HoldChangedByUser,0)=0 THEN TG.Hold ELSE CG.Hold END,
		HoldType=CASE WHEN ISNULL(CG.HoldTypeChangedByUser,0)=0 THEN TG.HoldType ELSE CG.HoldType END,
		AvailableDate=CASE WHEN ISNULL(CG.AvailableDateChangedByUser,0)=0 THEN TG.AvailableDate ELSE CG.AvailableDate END
	FROM Container_GnosisData CG 
	INNER JOIN #TempGnosisData TG ON TG.OrderDetailKey=CG.OrderDetailKey

	DROP TABLE #TempGnosisData
END