
Create Proc [dbo].[Get_OrderHeaderByOrderDetailKey]
(
	@OrderDetailKey		int
)
as
Begin
	Select DISTINCT OH.OrderKey, OrderNo, OrderDate 
	from OrderDetail OD WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	where OD.OrderDetailKey = @OrderDetailKey
End
