CREATE Proc [dbo].[GET_InvoiceDriverPay]  -- GET_InvoiceDriverPay 27
(
	@InvoiceKey	int = 0
)
as
select A.InvoiceKey, sum(isnull(A.VoucherAmount,0)) DriverPay from (
	select distinct ID.InvoiceKey, VH.voucherkey, VoucherAmount
	from Invoicedetail ID
	inner join Routes R on ID.OrderDetailKey = R.OrderDetailKey
	inner join VoucherDetail VD on R.RouteKey = VD.RouteKey
	inner join VoucherHeader VH on VD.Voucherkey = VH.VoucherKey
	where InvoiceKey = @InvoiceKey
) A
group by A.InvoiceKey