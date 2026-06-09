create proc ValidateContainerNo
(
	@CustomerKey	int,
	@ContainerNo	varchar(50),
	@Output			Bit = 0 OUTPUT
)
as
BEGIN
	set nocount on
	set fmtonly off

	declare @cnt int = 0
	select @cnt = count(1)
	from OrderDetail OD WITH (NOLOCK)
	inner join OrderHeader OH WITH (NOLOCK) on OD.orderkey = OH.OrderKey
	where OH.CustKey = @CustomerKey and OD.ContainerNo = @ContainerNo

	if( ISNULL(@cnt,0) = 0)
	begin
		set @Output = 0
		return;
	end
	else
	begin
		set @Output = 1
		return;
	end
END
