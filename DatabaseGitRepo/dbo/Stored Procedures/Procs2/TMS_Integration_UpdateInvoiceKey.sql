
CREATE proc [dbo].[TMS_Integration_UpdateInvoiceKey]
(
	@SiteID		Varchar(20),
	@DataKey	int,
	@InvoiceKey	int
)
as
Begin
	set nocount on
	set fmtonly off
	declare @cnt int = 0
	select @cnt = COUNT(1) from TMS_Integration_Invoice 
		where SiteID = @SiteID and DataKey = @DataKey and InvoiceKey = @InvoiceKey
	if(@cnt =0)
	begin
		insert into TMS_Integration_Invoice (SiteID, DataKey, InvoiceKey)
		values (@SiteID, @DataKey, @InvoiceKey)
	end
End
