CREATE PROCEDURE [dbo].[Get_InvoiceKeybyNo]
@InvoiceNo	VARCHAR(100)=''
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	SELECT InvoiceKey, InvoiceNo, OrderKey From InvoiceHeader WHERE InvoiceNo=@InvoiceNo
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
