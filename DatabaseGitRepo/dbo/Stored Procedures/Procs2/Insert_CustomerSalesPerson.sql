
/*
declare @custKey int = 15, @SPKeys nvarchar(max) = '[{"SalesPersonKey":6,"SalesPersonName":"divya","SalesPersonID":"1006","IsSelected":true},{"SalesPersonKey":9,"SalesPersonName":"divya","SalesPersonID":"1009","IsSelected":false},{"SalesPersonKey":5,"SalesPersonName":"harish","SalesPersonID":"1005","IsSelected":false},{"SalesPersonKey":13,"SalesPersonName":"lloyd ","SalesPersonID":"1013","IsSelected":false},{"SalesPersonKey":14,"SalesPersonName":"poojitha","SalesPersonID":"1014","IsSelected":false},{"SalesPersonKey":12,"SalesPersonName":"reethika","SalesPersonID":"1012","IsSelected":false},{"SalesPersonKey":4,"SalesPersonName":"shiva ","SalesPersonID":"1004","IsSelected":false},{"SalesPersonKey":8,"SalesPersonName":"teju","SalesPersonID":"1008","IsSelected":false}]',
	@UserKey	int = 29, @output bit = 0
exec Insert_CustomerSalesPerson @custKey, @SPKeys, @UserKey, @output output
select @output
select * from CustomerSalesPerson
*/
CREATE proc [dbo].[Insert_CustomerSalesPerson]  --  Exec [Insert_CustomerSalesPerson] 183, 1164, 4, 29
(
	@CustomerKey		int,
	@SalesPersonsKeys  NVARCHAR(MAX) = '',
	@UserKey			int,
	@Output				Bit = 0 OUTPUT
)
as
Begin
	set nocount on
	set fmtonly off
	set @Output = CONVERT(Bit, 0)

	if(@SalesPersonsKeys = '')
	Begin
		return;
	End

	if(@SalesPersonsKeys != '')
	Begin
		create table #SalesPerson
		(
			SalesPersonKey		int,
			IsSelected			bit
		)

		insert into #SalesPerson (SalesPersonKey, IsSelected)
		SELECT SalesPersonKey, IsSelected FROM OPENJSON(@SalesPersonsKeys,'$')
		WITH
		(
			SalesPersonKey		int				'$.SalesPersonKey',
			IsSelected			bit				'$.IsSelected'
		)
		--select * from #SalesPerson

		declare @cnt int = 0
		select @cnt = count(1) from #SalesPerson

		if(isnull(@cnt ,0) = 0)
		begin
			set @Output = CONVERT(bit,0);
			return
		end
		else
		begin
			delete from CustomerSalesPerson where CustomerKey = @CustomerKey

			insert into CustomerSalesPerson(CustomerKey, SalesPersonKey)
			select @CustomerKey, SalesPersonKey from #SalesPerson where ISNULL(IsSelected,0) = 1

			set @Output = convert(bit,1)
			return
		end
	end
End
