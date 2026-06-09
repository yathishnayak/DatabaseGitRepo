CREATE procedure [dbo].[ProfitReport_Get] -- [ProfitReport_Get] 1135, '2023-01-01', '2023-07-01'
(
  @CustKey int = 0,
  @InvDateFrom datetime = '2020-01-01',
  @InvDateTo	Datetime = '2050-12-31',
  @UserKey		INT=0
)
as
begin
	set nocount on
	set fmtonly off

	select distinct ih.InvoiceKey, id.OrderDetailKey, R.RouteKey , SUM(isnull(ID.ExtAmt,0)) AS ODInvAmt
	into #Invoices
	from InvoiceHeader ih WITH(NOLOCK) 
	inner join Invoicedetail  id WITH(NOLOCK) on ih.InvoiceKey = id.InvoiceKey 
	inner join Routes R WITH(NOLOCK) on ID.OrderDetailKey = R.OrderDetailKey
	where ih.CustKey = @CustKey and 
		(ISNULL(@InvDateFrom,'2020-01-01') = '2020-01-01' OR convert(Date, ih.InvoiceDate) >= convert(Date,@InvDateFrom)) and
		(ISNULL(@InvDateTo,'2050-12-31') = '2050-12-31' OR convert(Date, ih.InvoiceDate) <= convert(Date,@InvDateTo))
	Group by ih.InvoiceKey, id.OrderDetailKey, R.RouteKey

	--select * from #Invoices

	SELECT  OD.OrderDetailKey,VH.VoucherKey, VH.VoucherNo, VH.VoucherDate,VoucherAmount, R.RouteKey, SUM(isnull(VD.ExtCost,0)) as ContVouchAmt
	INTO #DRIVERPAY
		FROM OrderDetail OD WITH(NOLOCK) 
		INNER JOIN Routes R WITH(NOLOCK) ON R.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN VoucherDetail VD WITH(NOLOCK) ON  VD.RouteKey = R.RouteKey
		INNER JOIN VoucherHeader VH WITH(NOLOCK) ON VH.VoucherKey = VD.Voucherkey
		INNER JOIN #Invoices ih WITH (NOLOCK) ON OD.OrderDetailKey = ih.OrderDetailKey and R.RouteKey = ih.RouteKey
	group by OD.OrderDetailKey,VH.VoucherKey, VH.VoucherNo, VH.VoucherDate,VoucherAmount, R.RouteKey

	--select * from #DRIVERPAY

	SELECT IH.InvoiceKey, IH.InvoiceNo, IH.InvoiceDate, IH.InvoiceAmount, ODInvAmt as ContInvoiceAmt, 
			DP.VoucherKey, DP.VoucherNo, DP.VoucherDate, DP.VoucherAmount, 
			OD.OrderDetailKey, OD.ContainerNo, C.CustID, C.CustName, C.CustKey,
			ISNULL(I.ODInvAmt,0) - ISNULL(DP.VoucherAmount,0) as GrossProfit
	FROM InvoiceHeader IH WITH(NOLOCK) 
	INNER JOIN #Invoices I ON IH.InvoiceKey = I.InvoiceKey
	LEFT JOIN #DRIVERPAY DP ON I.OrderDetailKey = DP.OrderDetailKey
	leFT JOIN OrderDetail OD WITH (NOLOCK) ON I.OrderDetailKey = OD.OrderDetailKey and I.RouteKey = DP.RouteKey
	LEFT JOIN Customer C WITH(NOLOCK)  ON IH.CustKey = C.CustKey

	drop table #Invoices
	drop table #DRIVERPAY
END
