CREATE PROCEDURE [dbo].[Get_ItemsDetail]
/*
 dbo.fn_get_items
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT i.ItemKey, i.ItemID, i.[Description]AS ItemDescription, F.[Description] AS ItemType, i.UnitCost 
	FROM dbo.Item i
		INNER JOIN Dbo.ItemType F ON F.ItemTypeKey=I.ItemTypeKey
END
