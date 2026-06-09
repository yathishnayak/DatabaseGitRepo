

CREATE PROCEDURE [dbo].[InvoiceReasonCode_Update]
(
    @InvoiceKey INT = 0,
	@ReasoncodeKey INT = 0
)
AS
BEGIN
      UPDATE  InvoiceHeader 
	  SET ReasoncodeKey =  @ReasoncodeKey
	  WHERE InvoiceKey =  @InvoiceKey
END

--SELECT * FROM InvoiceHeader where InvoiceKey =82952
