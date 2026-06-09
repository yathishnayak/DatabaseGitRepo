CREATE PROCEDURE [dbo].[Get_IncomeReport]
(
	@FromDate	DATETIME,
	@ToDate		DATETIME
)
AS

BEGIN
	  select 'JCB' as Company, E.CustID, E.CustName, InvoiceNo, 'Order' as Type, D.InvoiceAmount, D.InvoiceDate, F.OrderNo,   ContainerNo,
      ItemId   as Item,  Sum(ExtAmt) as ExtAmt from  Invoicedetail  A
      inner join OrderDetail B on (A.OrderDetailKey = B.OrderDetailKey)
      inner join Item C on (A.ItemKey = C.ItemKey)
      inner join InvoiceHeader D on (A.InvoiceKey = D.InvoiceKey)
      inner join Customer E on (D.CustKey = E.CustKey)
      inner join OrderHeader F on (B.OrderKey = F.OrderKey)
	  WHERE D.CreateDate BETWEEN @FromDate AND @ToDate
      Group by E.CustID, E.CustName, InvoiceNo,D.InvoiceAmount,   F.OrderNo,  ContainerNo, ItemId , D.InvoiceDate
      
	  union all
      
	  select 'JCB' as Company, E.CustID, E.CustName, D.MInvoiceNo , 'Manual' as Type,  D.MInvoiceAmount, D.MInvoiceDate, '' as OrderNo,  
      isnull(ContainerNo,''),
      ItemId   as Item,  Sum(A.ExtCost) as ExtAmt from  ManualInvoiceDetail A       
      inner join Item C on (A.ItemKey = C.ItemKey)
      inner join ManualInvoiceHeader D on (A.MInvoiceKey = D.MInvoiceKey)
      inner join Customer E on (D.CustomerKey = E.CustKey)
	  WHERE D.CreatedDate BETWEEN @FromDate AND @ToDate
      Group by E.CustID, E.CustName, MInvoiceNo,D.MInvoiceAmount,   isnull(ContainerNo,''), ItemId , D.MInvoiceDate
END
