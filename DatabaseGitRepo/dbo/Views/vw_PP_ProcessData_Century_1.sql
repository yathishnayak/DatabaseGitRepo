


CREATE VIEW [dbo].[vw_PP_ProcessData_Century] -- SELECT * FROM vw_PP_ProcessData_Century
AS
WITH PPToBeSent AS
(
    SELECT		DISTINCT OD.ContainerNo,ISNULL(OD.BillOfLadding, OH.BillOfLading) AS BillOfLading, 'PP' DocumentType
	FROM		OrderHeader  OH WITH (NOLOCK)
	INNER JOIN	(SELECT * FROM TMS_Integration_Customers WITH (NOLOCK) WHERE SiteID = 'Century' ) TIC ON OH.CustKey = TIC.CustKey 
	INNER JOIN	OrderDetail OD  WITH (NOLOCK)  on OH.orderKey = OD.OrderKey
	INNER JOIN	Routes RT  WITH (NOLOCK)  on OD.OrderDetailKey = RT.OrderDetailKey
	INNER JOIN	(SELECT * FROM Leg WITH (NOLOCK)  WHERE LegID LIKE '%Pre-Pull%') L   on RT.LegKey = L.LegKey
	WHERE		L.FromLocation = 'Port' AND L.ToLocation in ('Yard') and OH.OrderTypeKey = 1 AND OH.CreateDate > '2025-04-28'
				--AND OH.OrderKey IN (175441)
				and isnull(RT.IsDryRun ,0) = 0 
),
PPSent AS
(
    SELECT		DISTINCT S.ContainerNo, S.BillOfLading, S.DocumentType, DD.DocUploaded
    FROM		PPToBeSent S WITH (NOLOCK)
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
    WHERE		SL.facilityCode IN ('PP')
)

SELECT			DISTINCT SL.OrderKey,SL.TMSOrderDetailKey,SL.DataKey
FROM			PPToBeSent TS WITH (NOLOCK)
LEFT JOIN		PPSent S WITH (NOLOCK) ON TS.ContainerNo = S.ContainerNo 
				AND TS.DocumentType = S.DocumentType
LEFT JOIN		StopList SL WITH (NOLOCK) ON TS.ContainerNo = SL.ContainerNo 
				AND TS.DocumentType = SL.facilityCode
WHERE			S.ContainerNo IS NULL  AND facilityCode IS NOT NULL
