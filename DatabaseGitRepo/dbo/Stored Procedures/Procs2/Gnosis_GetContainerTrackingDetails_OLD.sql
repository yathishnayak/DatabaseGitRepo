
-- [{"container_number":"TEMU8614398"}]

CREATE Proc [dbo].[Gnosis_GetContainerTrackingDetails_OLD]
AS


SELECT				ContainerNo , COUNT(*) CNT
INTO				#ContainerNos
FROM				OrderHeader OH
INNER JOIN			OrderDetail OD ON OH.OrderKey = OD.OrderKey 
WHERE				ISNULL(BillOfLading,'') <> '' -- AND ISNUMERIC(BillOfLading) = 0 
					-- AND LEN(BillOfLading)  >= 10  
					AND OD.Status NOT IN (10,13,12,14,15) 
GROUP BY			ContainerNo
HAVING				COUNT(*) = 1


SELECT				REPLACE(BillOfLading, ' ','')BillOfLading, OD.ContainerNo , OD.OrderDetailKey 
INTO				#ContainerDetails
FROM				OrderHeader OH
INNER JOIN			OrderDetail OD ON OH.OrderKey = OD.OrderKey 
INNER JOIN			#ContainerNos C On OD.ContainerNo = C.ContainerNo AND OD.Status NOT IN (10,13,12,14,15) 
					AND ISNULL(BillOfLading,'') <> '' -- AND ISNUMERIC(BillOfLading) = 0 
					--AND LEN(BillOfLading) > = 10   


SELECT				REPLACE(BillOfLading, ' ','')BillOfLading, CD.ContainerNo , CD.OrderDetailKey-- , C.Container_number,D.ContainerNo 
INTO				#TMP
FROM				#ContainerDetails CD
LEFT JOIN			(SELECT DISTINCT Container_number FROM Gnosis_Integration_Container) C ON CD.ContainerNo = C.Container_number 
LEFT JOIN			(SELECT DISTINCT ContainerNo FROM  Gnosis_TrackingContainerRequestResponseDetail WHERE ISNULL(ContainerTrackingReqUUID,'') <> '' ) D ON CD.ContainerNo = D.ContainerNo 
WHERE				ISNULL(C.Container_number,'') = '' AND ISNULL(D.ContainerNo,'') = ''

SELECT				DISTINCT   CAST(0 AS BIT) as track_all_containers_under_mbl,LTRIM(RTRIM(BillOfLading))  AS submitted_mbl
					, containers = (SELECT ContainerNo AS container_number, OrderDetailKey FROM #TMP T1 WHERE T1.BillOfLading = T2.BillOfLading  FOR JSON PATH)
FROM				#TMP T2
LEFT OUTER JOIN		Gnosis_MBLContainer_NotProcessed M ON LTRIM(RTRIM(BillOfLading)) = M.MBL
-- WHERE				M.MBL IS NULL
ORDER BY			LTRIM(RTRIM(BillOfLading)) DESC
-- FOR JSON PATH
