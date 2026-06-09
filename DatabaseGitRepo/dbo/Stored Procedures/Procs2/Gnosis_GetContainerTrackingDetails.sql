
-- [{"container_number":"TEMU8614398"}]

-- EXEC Gnosis_GetContainerTrackingDetails_Delete

CREATE Proc [dbo].[Gnosis_GetContainerTrackingDetails]
AS

--DROP TABLE			#BOLNotTracked
SELECT				BillOfLading , OD.ContainerNo,  MAX(OD.OrderDetailKey)OrderDetailKey
INTO				#BOLNotTracked
FROM				OrderDetail OD  WITH (NOLOCK)
INNER JOIN			OrderHeader OH  WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey 
LEFT JOIN			Gnosis_TrackingContainerRequestResponseDetail TD WITH (NOLOCK) ON LTRIM(RTRIM(oh.BillOfLading)) = TD.MBL AND LTRIM(RTRIM(OD.ContainerNo)) = TD.ContainerNo AND IsTrackingEnabled = 1
--LEFT JOIN			Gnosis_Integration_Container_Final CF  WITH (NOLOCK) ON OD.ContainerNo = CF.Container_number and OH.BillOfLading = CF.mbl
--LEFT JOIN			Gnosis_Integration_Container_Final CF WITH (NOLOCK) ON TD.UUID
WHERE				OD.Status NOT IN (10,13,12,14,15) AND TD.ContainerNo IS NULL AND 
					ISNULL(LTRIM(RTRIM(BillOfLading)),'') <> '' AND LTRIM(RTRIM(OH.BillOfLading)) <> 'JCT' -- AND BillOfLading = 'VIC-FULLETON-VIC'
GROUP BY			BillOfLading , OD.ContainerNo

--INSERT INTO #BOLNotTracked
--SELECT				BillOfLading , OD.ContainerNo,  MAX(OD.OrderDetailKey)OrderDetailKey
--FROM				OrderDetail OD
--INNER JOIN			OrderHeader OH ON OD.OrderKey = OH.OrderKey 
--LEFT JOIN			Gnosis_Integration_Container_Final CF ON OD.ContainerNo = CF.Container_number
--WHERE				OD.ContainerNo IN ('FANU1075187','KKFU8125091','MEDU1910728')
--GROUP BY			BillOfLading , OD.ContainerNo

-- SELECT * FROM #BOLNotTracked WHERE ContainerNo = 'FANU1075187'

--DROP TABLE			#AnalyseData
SELECT				BL.*, RR1.TrackingStatus, NP.MBL MBLNotProcessed
INTO				#AnalyseData
FROM				#BOLNotTracked BL
LEFT JOIN			(SELECT ContainerNo, MBL, MAX(createdDate) CreatedDate FROM Gnosis_TrackingContainerRequestResponseDetail  WITH (NOLOCK) GROUP BY ContainerNo, MBL) RR 
					ON BL.BillOfLading = RR.MBL AND BL.ContainerNo = RR.ContainerNo
LEFT JOIN			Gnosis_TrackingContainerRequestResponseDetail RR1  WITH (NOLOCK) ON RR.ContainerNo = RR1.ContainerNo AND RR.MBL = RR1.MBL AND RR.CreatedDate = RR1.CreatedDate		
LEFT JOIN			Gnosis_MBLContainer_NotProcessed NP  WITH (NOLOCK) ON BL.BillOfLading = NP.MBL AND BL.ContainerNo = NP.ContainerNo
--WHERE				RR1.TrackingStatus IS NULL AND NP.MBL IS NULL

-- SELECT * FROM #AnalyseData WHERE ContainerNo = 'FANU1075187'
/*
SELECT				TrackingStatus, CASE WHEN ISNULL(MBLNotProcessed,'') <> '' THEN 'Not Proccessed' ELSE '' END MBLNotProcessed , count(*)  tt
FROM				#AnalyseData
GROUP BY			TrackingStatus, CASE WHEN ISNULL(MBLNotProcessed,'') <> '' THEN 'Not Proccessed' ELSE '' END 
*/

SELECT				DISTINCT   CAST(0 AS BIT) as track_all_containers_under_mbl,LTRIM(RTRIM(BillOfLading))  AS submitted_mbl
					, containers = (SELECT ContainerNo AS container_number, OrderDetailKey FROM #AnalyseData T1 WHERE T1.BillOfLading = T2.BillOfLading  FOR JSON PATH)
FROM				#AnalyseData T2
--WHERE				T2.TrackingStatus = 'failed'
WHERE				T2.TrackingStatus IS NULL  AND T2.MBLNotProcessed IS NULL  -- OR T2.ContainerNo IN ('FANU1075187','KKFU8125091','MEDU1910728')
ORDER BY			LTRIM(RTRIM(BillOfLading)) DESC
FOR JSON PATH
