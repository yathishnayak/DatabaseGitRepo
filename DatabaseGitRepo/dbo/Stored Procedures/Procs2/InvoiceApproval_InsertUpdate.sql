

CREATE proc [dbo].[InvoiceApproval_InsertUpdate]
(
	@InvoiceType	varchar(10),
	@InvoiceKey		int,
	@IsApproved		Bit = 0,
	@UserKey		int,
	@Output			bit output,
	@Reason			varchar(100) output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE @cnt int = 0
	select @cnt = COUNT(1)
	from vAllInvoiceStatement
	where InvoiceType = @InvoiceType and InvoiceKey = @InvoiceKey 
	if(ISNULL(@cnt,0) = 0)
	begin
		set @Output = 0
		set @Reason ='Invoice not exists'
	end
	select @cnt = COUNT(1)
	from vAllInvoiceStatement
	where InvoiceType = @InvoiceType and InvoiceKey = @InvoiceKey and Description = 'Approved'
	if(ISNULL(@cnt,0) = 0)
	begin
		set @Output = 0
		set @Reason ='Invoice not approved'
		return
	end
	set @cnt = 0
	select @cnt = COUNT(1) from invoiceApproval where Invoicetype = @InvoiceType and InvoiceKey = @InvoiceKey
	if(isnull(@cnt,0) = 0)
	begin
		insert into InvoiceApproval (InvoiceType, InvoiceKey, IsApproved, ApprovedUserKey, ApprovedDate)
		select @InvoiceType, @InvoiceKey, @IsApproved, @UserKey, GETDATE()
		set @Output = 1
		set @Reason ='Invoice Approved'
	end
	else
	begin
		if(@IsApproved = 1)
		begin
			update InvoiceApproval set 
				IsApproved = @IsApproved,
				ApprovedUserKey = @UserKey,
				ApprovedDate = GETDATE()
			where InvoiceType = @InvoiceType and InvoiceKey = @InvoiceKey and @IsApproved = 1
			set @Output = 1
			set @Reason ='Invoice Approved'
		end
		else
		begin
			update InvoiceApproval set 
				IsApproved = @IsApproved,
				ApprovedUserKey = @UserKey,
				ApprovedDate = GETDATE()
			where InvoiceType = @InvoiceType and InvoiceKey = @InvoiceKey and @IsApproved = 0
			set @Output = 1
			set @Reason ='Invoice Approval reverted'
		end
	end
END
