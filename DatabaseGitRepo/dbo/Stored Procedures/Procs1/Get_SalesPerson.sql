
CREATE Proc [dbo].[Get_SalesPerson]
as
Begin
	Select SalesPersonKey, SalesPersonID, SalesPersonName, FirstName, LastName,
		A.AddrName, A.Address1, A.Address2, A.City, A.State, A.ZipCode, a.Country, SP.IsActive,
		LinkedUserKey, U.UserName as LinkedUserName
	from SalesPerson SP with (nolock)
	Inner join Address  A  with (nolock) on SP.AddrKey = A.AddrKey
	LEft Join [User] U  with (nolock) on SP.LinkedUserKey = U.UserKey
	Order by SalesPersonID
End
