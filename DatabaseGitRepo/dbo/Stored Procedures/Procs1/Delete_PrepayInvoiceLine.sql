create PROCEDURE [dbo].[Delete_PrepayInvoiceLine]
@PPInvoicelinekey	INT,
@PPInvoicekey			INT,
@OutPut				BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DELETE 
	FROM dbo.PrepayInvoiceDetail
	WHERE PPInvoicelinekey = @PPInvoicelinekey and PPInvoicekey =@PPInvoicekey;  

	UPDATE dbo.PrepayInvoiceHeader
	SET PPInvoiceAmount= ( SELECT SUM(ExtCost) FROM dbo.PrepayInvoiceDetail WHERE PPInvoiceKey=@PPInvoicekey )
	WHERE PPInvoiceKey=@PPInvoicekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @OutPut=1
	END	;

END
