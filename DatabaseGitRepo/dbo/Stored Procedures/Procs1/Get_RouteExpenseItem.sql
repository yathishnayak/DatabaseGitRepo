CREATE PROCEDURE [dbo].[Get_RouteExpenseItem]  -- [Get_RouteExpenseItem] 366331
@RouteKey INT=382
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT OE.Itemkey,RouteKey,I.ItemID,I.[Description] AS ItemDescription,
	case when OE.Qty > 0 then OE.qty else 0 end as Qty,DateFrom,DateTo, IT.ItemType
	FROM dbo.OrderExpense OE 
		INNER JOIN dbo.Item I ON I.ItemKey=OE.Itemkey
		INNER JOIN dbo.ItemType IT  ON IT.ItemTypeKey=I.ItemTypeKey
	WHERE RouteKey= @RouteKey AND IT.ItemType in('Expense','Expense + Service')
END
