
CREATE proc [dbo].[TMS_Integration_GetInvoiceReadyToPush_Century] -- TMS_Integration_GetInvoiceReadyToPush_Century 'Century', 3165
(
	@SiteID		varchar(20),
	@CustKey	int
)
as
set nocount on
set fmtonly off

select @CustKey = CustKey from Customer where CustID = 'Century'
select IH.InvoiceKey, COUNT(1) as NoEDICount
into #NoEDICount
		from Invoicedetail ID --on OD.OrderDetailKey = ID.OrderDetailKey
		inner join Item I on ID.ItemKey = I.ItemKey
		inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
		where CustKey = @CustKey  and isnull(I.EDICode,'') = ''
group by IH.InvoiceKey

select distinct OrderNo, OH.OrderNo as WorkOrdernumber , InvoiceNo, InvoiceDate, InvoiceAmount, Ih.InvoiceKey, 
	OH.OrderKey,TH.DataKey DataKey, OD.OrderDetailKey, OD.ContainerNo, @SiteID SiteID, TC.ContainerKey ,
	ItemDetails = (
		select  I.ItemKey, I.ItemID, I.Description, I.EDICode,
		sum(ID.Qty) as Qty, max(ID.UnitPrice) as UnitPrice, sum(ID.ExtAmt) as ExtAmt
		from Invoicedetail ID --on OD.OrderDetailKey = ID.OrderDetailKey
		inner join Item I on ID.ItemKey = I.ItemKey
		where OD.OrderDetailKey = ID.OrderDetailKey  
		group by  I.ItemKey, I.ItemID, I.Description, I.EDICode
		FOR JSON PATH
	),
	ItemWOEDICodeCount = nec.NoEDICount
from  OrderHeader OH 
inner join OrderDetail OD on OH.OrderKey = OD.OrderKey
inner join Invoicedetail ID on OD.OrderDetailKey = ID.OrderDetailKey
inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
inner join TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey AND TH.SiteID = 'Century'
inner join TMS_Integration_Container TC on TH.DataKey = TC.DataKey and OD.ContainerNo = TC.ContainerNo    AND TC.SiteID = TH.SiteID 
--Left join TMS_Integration_Invoice TI on TI.SiteID = @SiteID and IH.InvoiceKey = TI.InvoiceKey
left join #NoEDICount NEC on IH.InvoiceKey = NEC.InvoiceKey
where OH.CustKey = @CustKey and IH.StatusKey >= 2 and isnull(NEC.NoEDICount,0) = 0
FOR JSON PATH
