
CREATE PROCEDURE [dbo].[Get_InvoiceDetailByInvoiceKey] -- [Get_InvoiceDetailByInvoiceKey] 361 537
@InvoiceKey  INT=52
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT  
		INV.Container,ItemID, ind.[Description],
		SUM(ind.ExtAmt ) AS ExtAmt , AVG(inh.InvoiceAmount ) AS InvoiceAmount
	FROM 
		dbo.Invoicedetail ind 
		INNER JOIN
		(
		 SELECT STRING_AGG(Container,',') AS Container,InvoiceKey FROM Invoicedetail
		 GROUP BY InvoiceKey
		) INV ON INV.InvoiceKey=ind.InvoiceKey
		JOIN dbo.InvoiceHeader inh  ON inh.InvoiceKey = ind.InvoiceKey
		--JOIN  dbo.RouteInvoice tmi ON tmi.InvoiceKey = inh.InvoiceKey
		JOIN dbo.item I ON I.ItemKey=ind.ItemKey
	WHERE ind.InvoiceKey = @InvoiceKey and ind.OrderDetailKey is not null
	GROUP BY ItemID,ind.[Description],INV.Container
END
