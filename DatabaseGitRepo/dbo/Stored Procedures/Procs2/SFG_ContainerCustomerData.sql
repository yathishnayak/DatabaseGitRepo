create proc SFG_ContainerCustomerData
as
select  OD.OrderDetailKey, OD.ContainerNo, C.CustID, C.CustName, C.CustKey, isnull(C.IsFactored,0) as IsFactored, 
A.AddrName, A.Address1, A.Address2, A.City, A.State, a.ZipCode, A.Country,
A.Phone, a.Phone2, A.Email, A.Email2, a.Website
from OrderDetail OD
inner join OrderHeader OH on OD.OrderKey = OH.OrderKey
inner join Customer C on OH.CustKey = C.CustKey
inner join Address A on C.AddrKey = A.AddrKey
