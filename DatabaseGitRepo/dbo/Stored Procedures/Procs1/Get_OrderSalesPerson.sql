




create Proc [dbo].[Get_OrderSalesPerson]
(
	@OrderKey			int,
	@CustKey			int,
	@SalesPersonKey		int = 0 Output,
	@SalesPersonName	varchar(100) = '' Output
)
as
Begin
	Set NoCount on
	Set FmtOnly Off

	Select 
			@SalesPersonKey = isnull(OH.SalesPersonKey,0),
			@SalesPersonName = SalesPersonName
	From OrderHeader OH
	inner join SalesPerson SP on ISNULL(OH.SalesPersonKey,0) = SP.SalesPersonKey

	return;
End
