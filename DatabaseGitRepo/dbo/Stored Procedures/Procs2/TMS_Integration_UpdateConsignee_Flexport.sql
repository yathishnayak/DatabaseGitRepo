
CREATE PROCEDURE [dbo].[TMS_Integration_UpdateConsignee_Flexport]
AS

BEGIN
	INSERT INTO	Customer_Consignee (ConsigneeName,CustKey)
	SELECT		H.Consignee, 1966
	FROM		(SELECT		DISTINCT Consignee
				FROM		Integration_JCB.dbo.Flexpro_Header WITH (NOLOCK)
				WHERE		ISNULL(Consignee,'') <> '' AND CreateDate > GETDATE() - 10) H
	LEFT JOIn	Customer_Consignee CC ON LTRIM(RTRIM(H.Consignee)) = LTRIM(RTRIM(CC.ConsigneeName)) AND CC.CustKey = 1966
	WHERE		ISNULL(CC.ConsigneeName,'') = ''


	-- SELECT		H.Consignee, OH.Consignee , OH.OrderKey , TMS_OrderKey , OH.ConsigneeKey  
	UPDATE		OH SET Consignee = H.Consignee 
	FROM		Integration_JCB.dbo.Flexpro_Header H
	INNER JOIN	OrderHeader OH ON H.TMS_OrderKey = OH.OrderKey
	WHERE		ISNULL(H.Consignee,'') <> ISNULL(OH.Consignee,'')  AND ISNULL(H.Consignee,'') <> '' 
				AND  H.CreateDate > GETDATE() - 10 AND ISNULL(OH.ConsigneeKey,0) = 0

	-- SELECT		DISTINCT  OH.Consignee, CC.ConsigneeName, OH.ConsigneeKey 
	UPDATE	OH SET ConsigneeKey = CC.ConsigneeKey
	FROM		OrderHeader OH
	INNER JOIN	Customer_Consignee CC ON ISNULL(OH.Consignee,'') = ISNULL(CC.ConsigneeName,'')  AND OH.CustKey = CC.CustKey 
	WHERE		ISNULL(OH.Consignee,'') <> '' AND ISNULL(OH.ConsigneeKey,0) = 0
				AND  OH.CreateDate > GETDATE() - 10 AND OH.CustKey = 1966
END
