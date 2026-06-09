CREATE PROCEDURE [dbo].[Get_RouteServiceItem]
@RouteKey INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT OE.Itemkey,RouteKey,I.ItemID,I.[Description] AS ItemDescription,OE.Qty,DateFrom,DateTo
	FROM dbo.OrderExpense OE 
		INNER JOIN dbo.Item I ON I.ItemKey=OE.Itemkey
		INNER JOIN dbo.ItemType IT  ON IT.ItemTypeKey=I.ItemTypeKey
	WHERE RouteKey= @RouteKey AND IT.ItemType in ('Service','Expense + Service')
END
