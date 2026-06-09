


CREATE Proc TMS_Integration_UpdateAddrKey -- TMS_Integration_UpdateAddrKey 40591
(
 @InvoiceKey int = 38408
)
as
Declare
		@OrderAddrKey	int,
		@ConsAddrKey	int

select @OrderAddrKey =  OH.DestinationAddrKey
from InvoiceHeader IH
inner join OrderHeader OH on IH.OrderKey = OH.OrderKey
inner join Address A on OH.DestinationAddrKey = A.AddrKey
where InvoiceKey = @InvoiceKey --21428
PRINT' @OrderAddrKey'
PRINT @OrderAddrKey
PRINT '-------------'

select @ConsAddrKey = RT.DestinationAddrKey
from Routes Rt
inner join OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
inner join Invoicedetail ID on OD.OrderDetailKey = ID.OrderDetailKey 
inner join Address A on Rt.DestinationAddrKey = A.AddrKey
inner join Leg L on RT.legkey = L.LegKey
where ID.InvoiceKey = @InvoiceKey and L.ToLocation in ( 'Consignee', 'Customer','Shipper')

PRINT' @ConsAddrKey'
PRINT @ConsAddrKey
PRINT '-------------'
if(@OrderAddrKey <> @ConsAddrKey and isnull(@OrderAddrKey,0) > 0)
Begin
	update RT set DestinationAddrKey = @OrderAddrKey
	from Routes Rt
	inner join OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
	inner join Invoicedetail ID on OD.OrderDetailKey = ID.OrderDetailKey 
	inner join Address A on Rt.DestinationAddrKey = A.AddrKey
	inner join Leg L on RT.legkey = L.LegKey
	where ID.InvoiceKey = @InvoiceKey and L.ToLocation in ( 'Consignee', 'Customer','Shipper')
End
