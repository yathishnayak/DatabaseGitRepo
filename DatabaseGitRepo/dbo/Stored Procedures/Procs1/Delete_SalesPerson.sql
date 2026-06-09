


CREATE Proc [dbo].[Delete_SalesPerson]
(
	@SalesPersonKey	int,
	@output			Bit = 0 OUTPUT,
	@Reason			varchar(100) = '' OUTPUT
)
as
Begin
	set nocount on
	set fmtonly off

	declare @cntSP int = 0,
			@cntSPLinks int = 0,
			@isError bit = 0

	select @cntSP = count(1) from SalesPerson where SalesPersonKey = @SalesPersonKey
	if(ISNULL(@cntSP,0) = 0)
	begin
		set @output = convert(bit, 0)
		set @Reason = 'No Salesperson found matching this';
		set @isError = 1
		return;
	end
	ELSE
	Begin
		select @cntSPLinks = count(1) from Customer 
		where SalesPersonKey = @SalesPersonKey
		if(ISNULL(@cntSPLinks,0) > 0)
		begin
			set @output = CONVERT(bit, 0)
			set @Reason = 'Salesperson linked to Customer. Can not be deleted'
			set @isError = 1
			return;
		end

		select @cntSPLinks = count(1) from OrderHeader
		where SalesPersonKey = @salespersonKey
		if(ISNULL(@cntSPLinks,0) > 0)
		begin
			set @output = CONVERT(bit, 0)
			set @Reason = 'Salesperson linked to Customer. Can not be deleted'
			set @isError = 1
			return;
		end
	end

	if(@isError = 0)
	begin
		delete from SalesPerson where SalesPersonKey = @SalesPersonKey
		set @output = 1
		set @Reason = 'Salesperson Deleted'
		return;
	end
End
