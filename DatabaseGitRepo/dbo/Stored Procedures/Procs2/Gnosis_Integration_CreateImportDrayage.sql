
CREATE PROCEDURE [dbo].[Gnosis_Integration_CreateImportDrayage]

AS

SELECT			DISTINCT  BillOfLading , OD.ContainerNo, MIN(OD.OrderDetailkey) OrderDetailkey 
INTO			#TOBeProcessed
FROM			(SELECT * FROM OrderDetail WITH (NOLOCK) ) OD 
INNER JOIN		OrderHeader OH  WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey 
INNER JOIN		Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
INNER JOIN		Leg L On  RT.LegKey = L.LegKey
WHERE			LegCostType IN ('2','2a','2b','3') AND OH.CreateDate > '2025-07-25'
				AND ISNULL(LTRIM(RTRIM(BillOfLading)),'') <> '' AND LTRIM(RTRIM(OH.BillOfLading)) <> 'JCT'
GROUP BY		BillOfLading , OD.ContainerNo

SELECT			DISTINCT C.UUID, Container_number, M.MBL_number 
INTO			#COntainerSentToGnosis
FROM			Gnosis_Integration_Container_Final C
LEFT JOIn		Gnosis_Integration_MBL_FINAL M ON C.UUID = M.UUID


SELECT			DISTINCT LD.OrderDetailKey, LD.EmptySetDate 
INTO			#EmptyContainers
FROM			EmptyLegData LD WITH (NOLOCK) 
INNER JOIN		OrderDetail OD WITH (NOLOCK)  ON LD.OrderDetailKey = OD.OrderDetailKey
WHERE			LD.IsEmpty = 1 AND EmptySetDate IS NOT NULL 

DECLARE @JsonResult NVARCHAR(MAX) = ''
SET @JsonResult = (SELECT			TOP 3 A.* 
					FROM			(SELECt			SG.*, EmptySetDate EmptyDate,P.OrderDetailKey, CASE WHEN ISNULL(EC.OrderDetailKey,0) > 0 THEN 'empty' ELSE 'full' END AS DrayageType
									FROM			#COntainerSentToGnosis SG
									INNER JOIN		#TOBeProcessed P ON SG.Container_number = P.ContainerNo AND SG.MBL_number = P.BillOfLading
									LEFT JOIN		#EmptyContainers EC ON P.OrderDetailkey = EC.OrderDetailKey ) A 
					LEFT JOIN		Gnosis_Integration_ImportDrayageDetails ID ON A.UUID = ID.UUID AND A.DrayageType = ID.DrayageType
					WHERE			ID.DrayageType IS NULL  AND A.DrayageType = 'Empty'				
					ORDER BY		A.OrderDetailKey DESC
FOR JSON PATH	)


SELECT @JsonResult AS JsonResult