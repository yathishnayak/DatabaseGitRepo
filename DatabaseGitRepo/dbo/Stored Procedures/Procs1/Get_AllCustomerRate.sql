CREATE PROCEDURE [dbo].[Get_AllCustomerRate]
/*
dbo.fn_get_rates
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT rs.Ratekey, rs.CustomerKey,cus.CustName, i.ItemKey,i.Description
		,rs.UnitPrice, rs.UnitCost, rs.CreateDate
	FROM dbo.RateSheet rs 
		LEFT JOIN dbo.Item i ON rs.ItemKey = i.ItemKey
		LEFT JOIN dbo.Customer cus ON rs.CustomerKey = cus.CustKey;;	
END
