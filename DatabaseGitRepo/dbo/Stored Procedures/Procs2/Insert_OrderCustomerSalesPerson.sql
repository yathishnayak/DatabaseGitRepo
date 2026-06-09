
CREATE proc [dbo].[Insert_OrderCustomerSalesPerson]  --  Exec [Insert_CustomerSalesPerson] 183, 1164, 4, 29
(
	@OrderKey			int,
	@CustomerKey		int,
	@SalesPersonKey		int,
	@UserKey			int,
	@Output				Bit = 0 OUTPUT
)
as
Begin
	set nocount on
	set fmtonly off
	set @Output = CONVERT(Bit, 0)

	if( isnull(@CustomerKey,0) = 0 OR ISNULL(@SalesPersonKey,0) = 0)
	begin
		set @Output = CONVERT(Bit, 0)
		return;
	end
	ELSE
	Begin
		Declare @cnt int = 0
		select @cnt = Count(1) from Customer where CustKey = @CustomerKey and SalesPersonKey = @SalesPersonKey
		if(isnull(@cnt,0) =0)
		Begin
			Update Customer Set SalesPersonKey = @SalesPersonKey where CustKey = @CustomerKey

		End
		select @cnt = Count(1) from OrderHeader where OrderKey = @OrderKey and SalesPersonKey = @SalesPersonKey
		if(isnull(@cnt,0) = 0)
		Begin
			Update OrderHeader Set
				SalesPersonKey = @SalesPersonKey
			where OrderKey = @OrderKey

			
		End
		set @Output = CONVERT(Bit, 1)
		return;
	END
End
