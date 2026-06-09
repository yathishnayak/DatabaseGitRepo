CREATE PROCEDURE [dbo].[Get_ChargesItemsForMail]
(
	@OrderDetailKey	INT=0
)
AS
BEGIN
	SELECT I.ItemID,I.ItemKey,OE.UnitCost,OE.Qty,OE.NewUnitCost FROM OrderExpense  OE
	INNER JOIN Item I WITH (NOLOCK) ON OE.Itemkey=I.ItemKey
	WHERE RouteKey IN (SELECT RouteKey FROM Routes WHERE OrderDetailKey=@OrderDetailKey)
	FOR JSON PATH
END
