CREATE Proc [dbo].[Get_InvoiceDriverPayDetails] -- Get_InvoiceDriverPayDetails 24
(
	@InvoiceKey int = 24,
	@ContainerNo varchar(20) = 'BMOU2392710'
)
as
Begin
	select  distinct IH.InvoiceKey, IH.InvoiceNo, ID.Container,R.RouteKey,L.LegID, 
	IH.InvoiceAmount, isnull(VH.VoucherKey,0) as VoucherKey,
	isnull(VH.VoucherNo,'NA') as VoucherNo, convert(varchar,VH.VoucherDate,101) VoucherDate,
	isnull(VD.ExtCost,0) as DPayTotal, isnull(RE.OExp,0) as OtherExp, 
	isnull(VS.Description,'Not Created') as StatusDescr, D.DriverID, ISNULL(D.FirstName,'')+' '+ISNULL(D.LastName,'') AS DriverName
	from InvoiceHeader IH
	inner join Invoicedetail ID on IH.InvoiceKey = Id.InvoiceKey
	inner join OrderDetail OD on ID.OrderDetailKey = OD.OrderDetailKey
	left join Routes R on OD.OrderDetailKey = R.OrderDetailKey
	left join Leg L on R.LegKey = L.LegKey
	left join 
	(
		select voucherkey,  routekey, sum(extcost) extCost from VoucherDetail group by voucherkey , routekey
	) VD on VD.RouteKey = R.RouteKey
	left join VoucherHeader VH on VD.Voucherkey = VH.VoucherKey
	left join 
	(
		select Routekey, sum(OE.Qty * isnull(OE.UnitCost, I.UnitCost)) as OExp
		from OrderExpense OE
		inner join Item I on OE.Itemkey = I.ItemKey
		group by Routekey 
	) RE on R.RouteKey =RE.RouteKey and R.RouteKey is null
	left join VoucherStatus VS on VH.StatusKey = VS.StatusKey
	INNER JOIN Driver D WITH (NOLOCK) ON D.DriverKey=R.DriverKey
	where IH.InvoiceKey =@InvoiceKey and OD.ContainerNo = TRIM(@ContainerNo)
end

