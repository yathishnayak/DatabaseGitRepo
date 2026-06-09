
create Proc ValidateOrderNo
(
	@CustKey	int = 0,
	@OrderNo	varchar(50) = '',
	@IsValid	bit = 0 OUTPUT
)
AS
Begin
	set nocount on
	set fmtonly off
	if(isnull(@CustKey,0) = 0 OR isnull(@OrderNo,'') = '')
	Begin
		set @IsValid = convert(bit, 0)
		return;
	end
	ELSE
	BEGIN
		declare @cnt int = 0
		select @cnt = count(1) from OrderHeader
		where CustKey = @CustKey and OrderNo = @OrderNo

		if(@cnt > 0)
		begin
			set @IsValid = convert(bit,1)
		end
		else
		Begin
			set @IsValid = convert(bit, 0)
		end
		return;
	END
END
