
CREATE Proc [dbo].[GET_ItemDriverCostsAssetCogs]  -- GET_InvoiceDriverNoDriverCosts 27
(
	@ItemKey	int = 0
)
as
select ItemKey, InternalCost FROM Item Where ItemKey=@ItemKey
FOR JSON PATH
