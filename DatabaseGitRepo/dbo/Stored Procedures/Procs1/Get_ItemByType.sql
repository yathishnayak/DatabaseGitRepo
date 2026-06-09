CREATE PROCEDURE [dbo].[Get_ItemByType]
/*
dbo.fn_get_itemsbytype
*/
@ItemType VARCHAR(50)='Expense'
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT i.ItemKey, i.ItemID, i.[Description] AS ItemDescription, F.[Description] AS Itemtype 
	FROM dbo.Item i 
		INNER JOIN Dbo.ItemType F ON F.ItemTypeKey=I.ItemTypeKey
	where F.ItemType in ( @ItemType, 'Expense + Service')
END
