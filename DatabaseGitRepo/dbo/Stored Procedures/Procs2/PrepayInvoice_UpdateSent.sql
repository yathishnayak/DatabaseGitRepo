
create proc [dbo].[PrepayInvoice_UpdateSent]
(
	@InvoiceKey	int = 0,
	@CreateUserKey	int = 0,
	@Output	bit = 0 output
)
as
begin
	set nocount on
	set fmtonly off

	declare @cnt int = 0
	set @Output = 0
	select @cnt = count(1)	from PrepayInvoiceHeader where PPInvoiceKey = @InvoiceKey

	if(@cnt > 0)
	begin
		update PrepayInvoiceHeader 
			set PPInvoiceSentDate = GetDate(),
			StatusKey = 2
		where PPInvoiceKey = @InvoiceKey

		insert into [PrePayInvoiceComments] (PPInvoiceKey, CommentDate, CreateUserKey, Comment)
		values (@InvoiceKey, GETDATE(), @CreateUserKey, 'PrePay Invoice marked as Sent on ' + convert(varchar, getDate()))
		set @Output = 1
	end
end
