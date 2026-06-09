




CREATE proc [dbo].[Get_CustomerSalesPersonList]
(
	@CustomerKey	int = 1
)
as
Begin
	set nocount on
	set fmtonly off

	select sp.SalesPersonKey, SP.SalesPersonName, SP.SalesPersonID, 
	CONVERT( BIT, CASE WHEN ISNULL(C.Custkey,0) > 0 THEN 1 ELSE 0 END) AS IsSelected, LinkedUserKey
	from SalesPerson SP WITH (NOLOCK)
	Left join Customer C with (nolock) on SP.SalesPersonKey = C.SalesPersonKey
	--left join CustomerSalesPerson CSP WITH (NOLOCK) on  SP.SalesPersonKey = CSP.SalesPersonKey AND CSP.CustomerKey = @CustomerKey
	order by CASE WHEN ISNULL(C.Custkey,0) = 1 THEN 1 ELSE 0 END Desc, SalesPersonName
	for JSON PATH
	
end
