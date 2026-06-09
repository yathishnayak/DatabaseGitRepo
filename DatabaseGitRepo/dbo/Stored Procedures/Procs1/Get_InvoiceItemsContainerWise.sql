

Create Proc [dbo].[Get_InvoiceItemsContainerWise]
(
	@InvoiceKey int = 19
)
as
select IH.InvoiceKey, IH.InvoiceNo, IH.InvoiceDate, IH.InvoiceAmount,ID.ItemKey, ID.Description, ID.Qty, ID.ExtAmt,
	OE.Itemkey, I.ItemID, OE.Qty, OE.UnitCost , OD.OrderDetailKey, Od.ContainerNo
from InvoiceHeader IH
inner join InvoiceDetail ID on IH.InvoiceKey = ID.InvoiceKey
inner join RouteInvoice RI on ID.OrderDetailKey = RI.OrderDetailKey
inner join Routes R on RI.OrderDetailKey = R.OrderDetailKey
inner join OrderExpense OE on OE.RouteKey = R.RouteKey and ID.ItemKey = OE.Itemkey
inner join Item I on ID.ItemKey = I.ItemKey
inner join OrderDetail OD on R.OrderDetailKey = OD.OrderDetailKey
where IH.InvoiceKey = @InvoiceKey
order by ContainerNo, ItemID
