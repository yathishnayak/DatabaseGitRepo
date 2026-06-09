CREATE PROCEDURE [dbo].[Get_AccountingItems]
/*
fn_get_accountingoptionsbykey
*/
@OrderDetailkey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT I.Itemkey, I.Itemkey, I.OrderDetailKey, I.CustomerKey
	FROM dbo.ItemsForAccounting I 
	WHERE I.orderdetailkey = @OrderDetailkey;
END
