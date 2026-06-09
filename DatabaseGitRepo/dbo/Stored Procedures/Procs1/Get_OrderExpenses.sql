CREATE proc [dbo].[Get_OrderExpenses] 
(
	@OrderDetailKey		int,
	@RouteKeyStr		varchar(200) 
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SELECT * INTO #Routes FROM dbo.Fn_SplitParamCol(@RouteKeyStr)

	select OE.OrderExpenseKey, OE.RouteKey, L.LegID, OE.Itemkey, I.ItemID, I.Description, OE.Qty, OE.UnitCost, RT.IsRateVerified,  
		OD.OrderDetailKey,  isnull(OE.Qty,0) *  ISNULL( OE.UnitCost,0) as ExtAmt, CAST(ISNULL(RT.IsChargesApproved,0) AS BIT) AS IsChargesApproved
	from OrderExpense OE
	inner join Routes RT on OE.RouteKey = RT.RouteKey
	inner join OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
	inner join #Routes TR on RT.RouteKey = TR.Value
	inner join Item I on OE.Itemkey = I.ItemKey
	inner join ItemType T on I.ItemTypeKey = T.ItemTypeKey
	inner join Leg L on RT.LegKey = L.LegKey
	where OD.OrderDetailKey = @OrderDetailKey and T.ItemType in ('Service','Expense + Service') --and ContainerStatusKey = 5 -- and OD.Status = 6
END
