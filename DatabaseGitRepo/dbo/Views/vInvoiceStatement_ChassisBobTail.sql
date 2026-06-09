

CREATE View [dbo].[vInvoiceStatement_ChassisBobTail]
AS


Select CustomerID, CustomerName, InvoiceNo, [Invoice Date], [Order Number], Container, city, BrokerRefNo,
InvoiceAmount, Status,
sum(Case when ItemID ='BOBTAIL' then ExtAmt else 0 end ) as BOBTAIL,
sum(Case when ItemID ='JCT OWN CHASSIS' then ExtAmt else 0 end) as [CHASSIS],
sum(Case when ItemID ='JCT OWN CHASSIS' then NoOfDays else 0 end) as [CHASSIS_DAYS]
from
(select c.CustID as CustomerID,c.CustName as CustomerName, a.InvoiceNo, convert(Varchar(10), A.InvoiceDate,101) as [Invoice Date],
E.OrderNo [Order Number],b.Container, h.city,
e.BrokerRefNo,a.InvoiceAmount,i.Description as Status, g.ItemID,b.UnitPrice, b.Qty as NoOfDays,b.ExtAmt
from InvoiceHeader A
inner join Invoicedetail B on (A.InvoiceKey = B.InvoiceKey)
inner join Customer C on (A.CustKey = C.CustKey)
inner join OrderDetail D on (B.OrderDetailKey = D.OrderDetailKey)
inner join OrderHeader E on (D.OrderKey = E.OrderKey)
inner join Address F on (A.BillToAddrKey = F.AddrKey)
inner join Item G on (B.ItemKey = G.ItemKey)
Left outer join Address H ON ( e.DestinationAddrKey=h.AddrKey)
left outer Join InvoiceStatus i ON a.StatusKey=i.StatusKey
where c.CustID='C&B' and g.ItemID like '%Chassis%' and a.InvoiceDate <= '05-26-2022'
--group by c.CustID,c.custname,a.InvoiceNo,a.InvoiceDate,e.OrderNo,f.City,a.DueDate,e.BrokerRefNo,a.InvoiceAmount,h.city
--order by a.InvoiceDate



union all



select c.CustID as CustomerID,c.CustName as CustomerName, a.InvoiceNo, convert(Varchar(10), A.InvoiceDate,101) as [Invoice Date],
E.OrderNo [Order Number],b.Container, h.city,
e.BrokerRefNo,a.InvoiceAmount,i.Description as Status, g.ItemID,b.UnitPrice, b.Qty as NoOfDays,b.ExtAmt
from InvoiceHeader A
inner join Invoicedetail B on (A.InvoiceKey = B.InvoiceKey)
inner join Customer C on (A.CustKey = C.CustKey)
inner join OrderDetail D on (B.OrderDetailKey = D.OrderDetailKey)
inner join OrderHeader E on (D.OrderKey = E.OrderKey)
inner join Address F on (A.BillToAddrKey = F.AddrKey)
inner join Item G on (B.ItemKey = G.ItemKey)
Left outer join Address H ON ( e.DestinationAddrKey=h.AddrKey)
left outer Join InvoiceStatus i ON a.StatusKey=i.StatusKey
where c.CustID='C&B' and g.ItemID = 'BOBTAIL' and a.InvoiceDate <= '05-26-2022'
) A
--where Container ='BMOU4876061'
group by CustomerID, CustomerName, InvoiceNo, [Invoice Date], [Order Number], Container, city, BrokerRefNo,
InvoiceAmount, Status
--order by [Invoice Date]

