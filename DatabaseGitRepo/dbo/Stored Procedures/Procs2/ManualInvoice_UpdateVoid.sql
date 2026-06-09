CREATE proc [dbo].[ManualInvoice_UpdateVoid]
(
	@InvoiceKey	int = 0,
	@CreateUserKey	int = 0,
	@Output	bit = 0 output
)
as
begin
	set nocount on
	set fmtonly off

	declare @cnt int = 0, @PreVoidStatusKey int = 0, @PaidInvoice	smallint = 0
	set @Output = 0
	select @cnt = count(1)	from ManualInvoiceHeader where MInvoiceKey = @InvoiceKey
	select @PreVoidStatusKey = StatusKey from ManualInvoiceHeader where MInvoiceKey = @InvoiceKey
	select @PaidInvoice = count(1) from InvoicePayment where InvoiceKey = @InvoiceKey and InvoiceType = 'M' HAVING SUM(ISNULL(PaidAmount,0))<>0

	if(@cnt > 0 and isnull(@PaidInvoice,0) = 0)
	begin
		update ManualInvoiceHeader 
			set VoidedDate = GetDate(),
			IsVoid = 1,
			VoidedUserKey = @CreateUserKey,
			StatusKey = 4,
			PreVoidStatusKey = Case when  @PreVoidStatusKey <> 4 then @PreVoidStatusKey else PreVoidStatusKey end
		where MInvoiceKey = @InvoiceKey

		insert into ManualInvoiceComments (MInvoiceKey, CommentDate, CreateUserKey, Comment)
		values (@InvoiceKey, GETDATE(), @CreateUserKey, 'Invoice marked as Void on ' + convert(varchar, getDate()))
		set @Output = 1
	end
end
