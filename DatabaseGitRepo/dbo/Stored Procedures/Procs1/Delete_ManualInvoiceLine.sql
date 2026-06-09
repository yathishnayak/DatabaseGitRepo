
create PROCEDURE [dbo].[Delete_ManualInvoiceLine]
@MInvoicelinekey	INT,
@MInvoicekey			INT,
@OutPut				BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DELETE 
	FROM dbo.ManualInvoiceDetail
	WHERE MInvoicelinekey = @MInvoicelinekey and MInvoicekey =@MInvoicekey;  

	UPDATE dbo.ManualInvoiceHeader
	SET MInvoiceAmount= ( SELECT SUM(ExtCost) FROM dbo.ManualInvoiceDetail WHERE MInvoiceKey=@MInvoicekey )
	WHERE MInvoiceKey=@MInvoicekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @OutPut=1
	END	;

END
