CREATE PROCEDURE [dbo].[Get_RatebyCustomer]
/*
dbo.fn_get_ratebycustomer
*/
@CustomerKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT rs.Ratekey, rs.CustomerKey, cus.CustName,i.ItemKey,i.Description,rs.UnitPrice, rs.UnitCost, rs.CreateDate
	FROM dbo.RateSheet rs 
		LEFT JOIN dbo.Item i ON i.ItemKey = rs.ItemKey
		LEFT JOIN dbo.Customer cus ON cus.CustKey = rs.CustomerKey
	WHERE rs.CustomerKey = @CustomerKey;	
END
