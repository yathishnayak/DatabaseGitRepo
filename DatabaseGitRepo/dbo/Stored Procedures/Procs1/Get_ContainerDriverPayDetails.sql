

CREATE Proc [dbo].[Get_ContainerDriverPayDetails] -- [Get_ContainerDriverPayDetails] 
(
	@OrderDetailKey		INT
)
AS
BEGIN
	SELECT  OD.OrderDetailKey, OD.ContainerNo, R.RouteKey,L.LegID, 
	ISNULL(VH.VoucherKey,0) AS VoucherKey,
	ISNULL(VH.VoucherNo,'NA') AS VoucherNo, CONVERT(varchar,VH.VoucherDate,101) VoucherDate,
	ISNULL(VD.ExtCost,0) AS DPayTotal, ISNULL(RE.OExp,0) AS OtherExp, 
	ISNULL(VS.Description,'Not Created') AS StatusDescr
	FROM  OrderDetail OD 
	LEFT JOIN Routes R ON OD.OrderDetailKey = R.OrderDetailKey
	LEFT JOIN Leg L ON R.LegKey = L.LegKey
	LEFT JOIN 
	(
		SELECT voucherkey,  routekey, SUM(extcost) extCost
		FROM VoucherDetail 
		GROUP BY voucherkey , routekey
	) VD ON VD.RouteKey = R.RouteKey
	LEFT JOIN VoucherHeader VH ON VD.Voucherkey = VH.VoucherKey
	LEFT JOIN 
	(
		SELECT Routekey, SUM(OE.Qty * ISNULL(OE.UnitCost, I.UnitCost)) AS OExp
		FROM OrderExpense OE
		INNER JOIN Item I ON OE.Itemkey = I.ItemKey
		GROUP BY Routekey 
	) RE ON R.RouteKey =RE.RouteKey AND R.RouteKey is null
	LEFT JOIN VoucherStatus VS ON VH.StatusKey = VS.StatusKey
	WHERE OD.OrderDetailKey = @OrderDetailKey
END

