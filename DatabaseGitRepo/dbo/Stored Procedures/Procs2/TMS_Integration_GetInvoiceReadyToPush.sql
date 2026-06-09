
CREATE proc [dbo].[TMS_Integration_GetInvoiceReadyToPush] -- TMS_Integration_GetInvoiceReadyToPush 'ACER'
(
	@SiteID		varchar(20)
)
as
set nocount on
set fmtonly off

select distinct OrderNo, WorkOrdernumber , InvoiceNo, InvoiceDate, InvoiceAmount, Ih.InvoiceKey, 
	TMS_OrderKey, TH.DataKey, TC.ContainerKey, TC.ContainerNo, TH.SiteID,
	ItemDetails = (
		select  I.ItemKey, I.ItemID, I.Description, I.EDICode,
		sum(ID.Qty) as Qty, max(ID.UnitPrice) as UnitPrice, sum(ID.ExtAmt) as ExtAmt
		from Invoicedetail ID --on OD.OrderDetailKey = ID.OrderDetailKey
		inner join Item I on ID.ItemKey = I.ItemKey
		where OD.OrderDetailKey = ID.OrderDetailKey
		group by  I.ItemKey, I.ItemID, I.Description, I.EDICode
		FOR JSON PATH
	),
	ItemWOEDICodeCount = (
	select  COUNT(1)
		from Invoicedetail ID --on OD.OrderDetailKey = ID.OrderDetailKey
		inner join Item I on ID.ItemKey = I.ItemKey
		where OD.OrderDetailKey = ID.OrderDetailKey and I.EDICode is NULL
		
	)
from TMS_Integration_Header TH
inner join OrderHeader OH on TH.TMS_OrderKey = OH.OrderKey
inner join OrderDetail OD on OH.OrderKey = OD.OrderKey
inner join TMS_Integration_Container TC on TC.DataKey = TH.DataKey and TC.TMS_OrderDetailKey = OD.OrderDetailKey
inner join Invoicedetail ID on OD.OrderDetailKey = ID.OrderDetailKey
inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
Left join TMS_Integration_Invoice TI on TH.SiteID = TI.SiteID and TH.DataKey = TI.DataKey and IH.InvoiceKey = TI.InvoiceKey
where TI.InvoiceKey is null and TH.SiteID = @SiteID And IH.StatusKey >= 2
FOR JSON PATH

