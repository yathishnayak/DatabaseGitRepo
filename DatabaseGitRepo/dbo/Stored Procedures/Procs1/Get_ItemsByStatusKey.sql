CREATE PROCEDURE [dbo].[Get_ItemsByStatusKey] -- [Get_ItemsByStatusKey] 1
@StatusKey INT = 1
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF


	SELECT 	I.ItemKey,IT.ItemTypeKey,I.ItemID,I.Description AS ItemDescription,I.UnitCost , 
	IT.Description AS ItemType,I.CreateDate	,IPB.Description 'PriceBasisDescription',
	ST.StatusName, 
	I.InvoiceItemDesc
	FROM dbo.Item I 
		INNER JOIN dbo.ItemType IT ON I.ItemTypeKey = IT.ItemTypeKey
		INNER JOIN dbo.[Status] ST ON ST.StatusKey = I.StatusKey
		INNER JOIN [dbo].[ItemPriceBasis] IPB ON IPB.PriceBasisKey = I.PriceBasisKey 
	WHERE (@StatusKey = 0 OR ST.StatusKey=@StatusKey)
	
END
