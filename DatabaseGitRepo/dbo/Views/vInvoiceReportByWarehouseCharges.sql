


CREATE View [dbo].[vInvoiceReportByWarehouseCharges]
AS
select c.CustID as CustomerID,c.CustName as CustomerName, a.InvoiceNo, convert(Varchar(10), A.InvoiceDate,101) as [InvoiceDate],	
E.OrderNo [OrderNumber],b.Container, h.city,
e.BrokerRefNo,a.InvoiceAmount,i.Description as Status, g.ItemID,b.UnitPrice, b.Qty as NoOfDays,b.ExtAmt,
A.CustKey
from InvoiceHeader A WITH (NOLOCK) 
inner join Invoicedetail B WITH (NOLOCK)  on (A.InvoiceKey = B.InvoiceKey)
inner join Customer  C WITH (NOLOCK)  on (A.CustKey = C.CustKey)
inner join OrderDetail D WITH (NOLOCK)  on (B.OrderDetailKey = D.OrderDetailKey) 
inner join OrderHeader E WITH (NOLOCK)  on (D.OrderKey = E.OrderKey)
inner join Address F WITH (NOLOCK)  on (A.BillToAddrKey = F.AddrKey)
inner join Item G WITH (NOLOCK)  on (B.ItemKey = G.ItemKey)
Left outer join Address H WITH (NOLOCK)  ON ( e.DestinationAddrKey=h.AddrKey)
left outer Join InvoiceStatus i WITH (NOLOCK)  ON a.StatusKey=i.StatusKey
Left Outer Join ItemCategory j WITH (NOLOCK)  ON g.CategoryKey=j.CategoryKey
where IsNUll(g.CategoryKey,0)=4
--Order by c.CustID

