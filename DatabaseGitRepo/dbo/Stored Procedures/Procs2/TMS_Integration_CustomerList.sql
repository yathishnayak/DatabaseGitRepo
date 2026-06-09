
CREATE Proc [dbo].[TMS_Integration_CustomerList]
as
select  c.CustKey, c.CustID, c.CustName, IsFactored , StatusName
from Customer c with (nolock)
inner join Status S with (nolock) on C.StatusKey = S.StatusKey
inner join Address A with (nolock) on c.AddrKey = A.AddrKey
--WHERE StatusName = 'Active'
order by CustName
For JSON PATH
