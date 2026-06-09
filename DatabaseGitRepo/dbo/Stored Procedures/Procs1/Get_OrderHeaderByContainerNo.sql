
Create Proc [dbo].[Get_OrderHeaderByContainerNo]
(
	@ContainerNo		varchar(20)
)
as
Begin
	Select DISTINCT OH.OrderKey, OrderNo, OrderDate , OrderDetailKey
	from OrderDetail OD WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	where OD.ContainerNo = @ContainerNo
	order by OrderDetailKey desc
End
