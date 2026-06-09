CREATE PROCEDURE [dbo].[GET_InvoiceNonDriverIC]  -- GET_InvoiceNonDriverIC 27
(
	@InvoiceKey	INT = 0
)
AS
SELECT InvoiceKey, sum(isnull(Charges,0)) NonDriverIC
	FROM Invoicedetail ID
	INNER JOIN ITEM I WITH (NOLOCK) ON I.ItemKey=ID.ItemKey
	INNER JOIN DriverNonDriverCostItems CI ON CI.DriverNonDriverCostKey=I.CostGrp AND CI.DriverNonDriverCostId='CG001'
		WHERE InvoiceKey = @InvoiceKey
GROUP BY InvoiceKey
FOR JSON PATH
