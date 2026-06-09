CREATE PROCEDURE [dbo].[GET_InvoiceAssetDriverCogs]  -- GET_InvoiceAssetDriverCogs 27
(
	@InvoiceKey	INT = 0
)
AS
SELECT InvoiceKey, SUM(ISNULL(Charges,0)) AssetDriverCogs 
FROM Invoicedetail ID
INNER JOIN ITEM I WITH (NOLOCK) ON I.ItemKey=ID.ItemKey 
INNER JOIN DriverNonDriverCostItems CI ON CI.DriverNonDriverCostKey=I.CostGrp AND CI.DriverNonDriverCostId='CG002'
		WHERE InvoiceKey = @InvoiceKey 
GROUP BY InvoiceKey
FOR JSON PATH
