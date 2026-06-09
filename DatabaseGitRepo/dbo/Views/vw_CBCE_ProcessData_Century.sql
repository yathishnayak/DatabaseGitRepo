

CREATE VIEW vw_CBCE_ProcessData_Century -- SELECT * FROM vw_CBCE_ProcessData_Century
AS
WITH CBCEToBeSent AS
(
    SELECT		DISTINCT OD.ContainerNo,ISNULL(OD.BillOfLadding, OH.BillOfLading) AS BillOfLading,
				CASE WHEN D.DocumentType = 21 THEN 'CE' ELSE 'CB' END AS DocumentType
    FROM		Document D WITH (NOLOCK)
    INNER JOIN	ContainerLegDocuments LD WITH (NOLOCK) ON D.DocumentKey = LD.DocumentKey
    INNER JOIN	Routes RT WITH (NOLOCK) ON LD.RouteKey = RT.RouteKey
    INNER JOIN	OrderDetail OD WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
    INNER JOIN	OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
    INNER JOIN	(SELECT	* 
				FROM	TMS_Integration_Customers WITH (NOLOCK) 
				WHERE	SiteID = 'Century'
				) TIC ON OH.CustKey = TIC.CustKey
    WHERE		DocumentType IN (20,21)
),
CBCESent AS
(
    SELECT		DISTINCT S.ContainerNo, S.BillOfLading, S.DocumentType, DD.DocUploaded
    FROM		CBCEToBeSent S WITH (NOLOCK)
    LEFT JOIN	Integration_JCB.dbo.Century_ContainerList CL WITH (NOLOCK) ON	S.ContainerNo = CL.equipmentNumber
    LEFT JOIN	Integration_JCB.dbo.Century_214DocData DD WITH (NOLOCK) ON	CL.DataKey = DD.DataKey 
				AND S.DocumentType = DD.StopType
				AND DD.ScheduleActual = 'A'
    WHERE		DD.DocUploaded IS NOT NULL
),
StopList AS
(
    SELECT		DISTINCT CL.equipmentNumber AS ContainerNo, SL.facilityCode, CL.TMSOrderDetailKey, CL.DataKey, 
				H.TMS_OrderKey AS OrderKey
    FROM		Integration_JCB.dbo.Century_Header H WITH (NOLOCK)
    INNER JOIN	Integration_JCB.dbo.Century_ContainerList CL WITH (NOLOCK) ON H.DataKey = CL.DataKey
    INNER JOIN	Integration_JCB.dbo.Century_StopList SL WITH (NOLOCK) ON CL.ContainerKey = SL.ContainerKey
    WHERE		SL.facilityCode IN ('CB','CE')
)

SELECT			DISTINCT SL.OrderKey,SL.TMSOrderDetailKey,SL.DataKey
FROM			CBCEToBeSent TS WITH (NOLOCK)
LEFT JOIN		CBCESent S WITH (NOLOCK) ON TS.ContainerNo = S.ContainerNo 
				AND TS.DocumentType = S.DocumentType
LEFT JOIN		StopList SL WITH (NOLOCK) ON TS.ContainerNo = SL.ContainerNo 
				AND TS.DocumentType = SL.facilityCode
WHERE			S.ContainerNo IS NULL  AND facilityCode IS NOT NULL
