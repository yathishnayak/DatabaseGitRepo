

CREATE PROCEDURE [dbo].[TMS_Integration_GetPendingDOToMoveToTMS_Melrose]
AS

BEGIN
	
	SELECT		 D.DODockey,D.Datakey AS Datakey , OH.OrderKey, OH.OrderNo,  STRING_AGG(CAST(OrderDetailKey AS VARCHAR), ':') AS OrderDetailKey,D.FileURL,13 AS DeliveryTypeKey
				, CAST(1 AS BIT) AS IsFromOrderScreen, D.DocName
	INTO		#DocDetails
	FROM		Integration_JCB.dbo.Melrose_Documents D
	INNER JOIn	Integration_JCB.dbo.Melrose_Header H ON D.DataKey = H.DataKey 
	INNER JOIN	OrderHeader OH ON OH.OrderKey = H.TMS_OrderKey 
	INNER JOIN	OrderDetail OD ON OH.OrderKey = OD.OrderKey
	--INNER JOIN	Integration_JCB.dbo.Melrose_Documents  DO ON H.DataKey = DO.DataKey 
	WHERE		ISNULL(D.IsMovedtoTMS,0) = 0 AND D.CreatedDate > '2025-07-17'   AND D.DODockey NOT IN (610)
				AND DocName IS NOT NULL
	GROUP BY	OH.OrderKey,OH.OrderNo, D.FileURL, D.DataKey, D.DODockey, DocName

	DECLARE @JsonResult NVARCHAR(MAX)

	SET @JsonResult	 = (SELECT		*
						FROM		#DocDetails
						FOR JSON PATH )

	SELECT @JsonResult AS JSONResult

	DROP TABLE #DocDetails
END