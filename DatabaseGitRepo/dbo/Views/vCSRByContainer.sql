

Create View [dbo].[vCSRByContainer]
AS
select c.CsrName,b.ContainerNo,D.CustName,A.OrderDate from Orderheader(nolock) A
Inner Join OrderDetail(nolock) B
On  A. OrderKey=B.OrderKey
Inner Join CSR C
On a.CsrKey=c.CsrKey
Inner Join Customer D
ON A.CustKey=D.CustKey
--Order by 1

