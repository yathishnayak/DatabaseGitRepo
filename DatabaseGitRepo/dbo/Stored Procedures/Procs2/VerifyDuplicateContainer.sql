
/*
declare @isExists bit = 0,
		@OrderdetailKey int = 27,
		@ContainerNo varchar(20) = 'TGBU3301657'
Exec VerifyDuplicateContainer @OrderdetailKey, @ContainerNo, @isExists out
select @isExists
*/
create Proc VerifyDuplicateContainer
(
	@OrderDetailKey int,
	@ContainerNo varchar(20),
	@IsExists bit = 0 Output
)
as
BEGIN
	Declare @cnt int = 0
	select @cnt = Count(1)  
	from OrderDetail OD
	where ContainerNo = @ContainerNo
		and ( isnull(@OrderDetailKey,0) = 0 OR OD.OrderDetailKey <> @OrderDetailKey )
		
	Set @IsExists = Case when isnull(@cnt,0) = 0 then 0 else 1 end
END