CREATE PROCEDURE [dbo].[Get_ItemBykey]
@ItemKey int
/*
Scheduler Screen
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 	I.ItemKey,
	IT.ItemTypeKey,
	I.ItemID,
	I.Description AS ItemDescription,
	I.UnitCost , 
	IT.Description AS ItemType,
	I.CreateDate	,
	IPB.Description 'PriceBasisDescription',
	ST.StatusName,
	St.StatusKey ,
	IPB.PriceBasisKey 	,
	I.InvoiceItemDesc, ECC.Code EDICode,ECC.[Description] AS EDIChargeCodeDesc,
	CI.DriverNonDriverCostDesc AS CostGrpDescription, CI.DriverNonDriverCostKey AS CostGrp, I.InternalCost As InternalCost, CategoryKey

	FROM dbo.Item I 
		INNER JOIN dbo.ItemType IT ON I.ItemTypeKey = IT.ItemTypeKey
		INNER JOIN dbo.[Status] ST ON ST.StatusKey = I.StatusKey
		INNER JOIN [dbo].[ItemPriceBasis] IPB ON IPB.PriceBasisKey = I.PriceBasisKey 
		LEFT JOIN EDIChargeCode ECC WITH (NOLOCK) ON ECC.Code=I.EDICode
		LEFT JOIN DriverNonDriverCostItems CI WITH (NOLOCK) ON CI.DriverNonDriverCostKey=I.CostGrp
	   WHERE i.ItemKey = @ItemKey --.StatusName='Active';	
END