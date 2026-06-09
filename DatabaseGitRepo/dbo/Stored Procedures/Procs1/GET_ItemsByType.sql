CREATE PROCEDURE [dbo].[GET_ItemsByType] -- [GET_ItemsByType] 'Service'
(
	@ItemType VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT i.ItemKey, i.ItemID, i.[Description] AS ItemDescription, F.[Description] as Itemtype, i.UnitCost, i.UnitCost , I.InvoiceItemDesc
	FROM dbo.Item i INNER JOIN Dbo.ItemType F ON F.ItemTypeKey=I.ItemTypeKey
	WHERE F.ItemType in (@ItemType, 'Expense + Service') ;
END
