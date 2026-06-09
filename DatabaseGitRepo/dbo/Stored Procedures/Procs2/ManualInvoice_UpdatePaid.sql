
CREATE proc [dbo].[ManualInvoice_UpdatePaid]
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
	select @cnt = count(1)	from ManualInvoiceHeader where MInvoiceKey = @InvoiceKey

	if(@cnt > 0)
	begin
		update ManualInvoiceHeader 
			set MInvoiceSentDate = GetDate(),
			StatusKey = 3
		where MInvoiceKey = @InvoiceKey

		insert into ManualInvoiceComments (MInvoiceKey, CommentDate, CreateUserKey, Comment)
		values (@InvoiceKey, GETDATE(), @CreateUserKey, 'Invoice marked as Paid on ' + convert(varchar, getDate()))
		set @Output = 1
	end
end
