

CREATE proc [dbo].[TMS_Integration_ItemsWOEDICode]
(@Siteid		varchar(10))
as
select distinct  I.ItemID, I.Description, I.EDICode,TH.SiteID
from TMS_Integration_Header TH
inner join OrderHeader OH on TH.TMS_OrderKey = OH.OrderKey
inner join OrderDetail OD on OH.OrderKey = OD.OrderKey
inner join TMS_Integration_Container TC on TC.DataKey = TH.DataKey and TC.TMS_OrderDetailKey = OD.OrderDetailKey
inner join Invoicedetail ID on OD.OrderDetailKey = ID.OrderDetailKey
inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
inner join Item I on ID.ItemKey = I.ItemKey
where EDICode is null and TH.SiteID = @Siteid
order by Description 
