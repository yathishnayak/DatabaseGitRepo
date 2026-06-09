
/*
declare @JSONText			varchar(max) = '' 
exec Get_PrepayInvoiceByKey 1, @JSONText OUTPUT
select @JSONText
*/
CREATE Proc [dbo].[Get_PrepayInvoiceByKey] --
(
	@PrepayInvoiceKey	int = 1,
	@JSONText			varchar(max) = '' OUTPUT
)
as
Begin
	if(@PrepayInvoiceKey > 0)
	BEGIN
		DECLARE @DetailText varchar(max) 

		select @JSONText = (
			SELECT PPInvoiceKey,PPInvoiceNo, PPInvoiceDate, PPInvoiceAmount,H.OrderKey, 
			isnull(H.OrderNo,'') as OrderNo, CustomerKey,
				OrderHeader.OrderDate as OrderDate,
				BillToAddressKey, PPInvoiceSentDate, PPInvoiceConfirmDate, 
				InternalNotes, H.CustomerNotes,
				CreatedDate, CreatedUserKey, UpdateDate, UpdatedUserKey,  IsFactored,
					PrepayInvoiceDetail = (
					SELECT PPInvoiceKey, PPInvoiceLineKey, ContainerNo, PID.ItemKey, UnitPrice, Quantity, 
					ExtCost, CreatedDate, CreatedUserKey, UpdateDate, UpdatedUserKey, I.InvoiceItemDesc, I.Description as itemdesc
					FROM PrepayInvoiceDetail PID WITH (NOLOCK)
					inner join Item I WITH (NOLOCK) on PID.ItemKey = I.ItemKey
					WHERE PPInvoiceKey = @PrepayInvoiceKey
					for json PATH
				)
			FROM PrepayInvoiceHeader H WITH (NOLOCK)
			LEft join OrderHeader OrderHeader With (NoLock) on H.OrderKey = OrderHeader.OrderKey
			LEFT Join Customer C with (nolock) on H.CustomerKey = C.CustKey
			WHERE PPInvoiceKey = @PrepayInvoiceKey
			for json PATH
		)
	END
End
