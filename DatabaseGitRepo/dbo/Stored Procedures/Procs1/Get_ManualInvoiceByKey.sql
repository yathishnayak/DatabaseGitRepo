/*
declare @JSONText			varchar(max) = '' 
exec Get_ManualInvoiceByKey 1, @JSONText OUTPUT
select @JSONText
*/
CREATE Procedure [dbo].[Get_ManualInvoiceByKey] --
(
	@ManualInvoiceKey	int = 1,
	@JSONText			varchar(max) = '' OUTPUT
)
as
Begin
	if(@ManualInvoiceKey > 0)
	BEGIN
		DECLARE @DetailText varchar(max) 

		select @JSONText = (
			SELECT MInvoiceKey,MInvoiceNo, MInvoiceDate, MInvoiceAmount,H.OrderKey, H.OrderNo, CustomerKey,
				BillToAddressKey, MInvoiceSentDate, MInvoiceConfirmDate, 
				InternalNotes, H.CustomerNotes, H.StatusKey, H.BrokerRef,
				CreatedDate, CreatedUserKey, H.UpdateDate, UpdatedUserKey, IsFactored ,
				H.SteamShipLineKey, SteamShipLineRef,SSL.LineName AS SteamShipLineName,H.OriginalInvoiceNo,
				ManualInvoiceDetail =	(
					SELECT MInvoiceKey, MInvoiceLineKey, ContainerNo, MID.ItemKey, UnitPrice, Quantity, ExtCost,
						I.Description as itemdesc,
						CreatedDate, CreatedUserKey, UpdateDate, UpdatedUserKey, I.InvoiceItemDesc
					FROM ManualInvoiceDetail MID WITH (NOLOCK)
					Inner join Item I WITH (NOLOCK) ON MID.ItemKey = I.ItemKey
					WHERE MInvoiceKey = @ManualInvoiceKey
					for json path
				),InvoiceCompanyKey,ISNULL(OrderHeader.MarketLocationKey,Customer.MarketLocationKey) MarketLocationKey
			FROM ManualInvoiceHeader H WITH (NOLOCK)
			LEft join OrderHeader OrderHeader With (NoLock) on H.OrderKey = OrderHeader.OrderKey
			LEft join Customer Customer WITH (NOLOCK) on H.CustomerKey = Customer.CustKey
			Left join SteamShipLine SSL WITH (NOLOCK) ON H.SteamShipLineKey = SSL.LineKey
			WHERE MInvoiceKey = @ManualInvoiceKey
			for json path
		)
	END
End
