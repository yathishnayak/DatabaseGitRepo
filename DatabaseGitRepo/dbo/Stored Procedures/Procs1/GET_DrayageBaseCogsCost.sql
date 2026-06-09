CREATE PROCEDURE [dbo].[GET_DrayageBaseCogsCost]
@InvoiceKey	INT
AS
BEGIN
	SELECT @InvoiceKey AS InvoiceKey, CAST(0 AS DECIMAL(18,2)) AS DrayageBaseCogsCost
	--WHERE InvoiceKey = @InvoiceKey 
	--GROUP BY InvoiceKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
