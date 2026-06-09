
CREATE Proc [dbo].[Get_SalesPersonByKey]
(
	@SalePersonKey	int = 0
)
as
Begin
	set nocount on
	set fmtonly off
	select SalesPersonKey, SalesPersonID, SalesPersonName,FirstName, LastName, SP.AddrKey, IsActive,
	LinkedUserKey, U.UserName as LinkedUserName
	from SalesPerson SP WITH (NOLOCK)
	Inner join Address  A  with (nolock) on SP.AddrKey = A.AddrKey
	LEft Join [User] U  with (nolock) on SP.LinkedUserKey = U.UserKey
	where SalesPersonKey = @SalePersonKey
End
