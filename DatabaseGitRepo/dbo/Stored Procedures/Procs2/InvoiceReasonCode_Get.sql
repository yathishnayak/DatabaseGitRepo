

CREATE PROCEDURE [dbo].[InvoiceReasonCode_Get]
AS
BEGIN
      SELECT ReasoncodeKey,ReasonCode,Status 
	  FROM InvoiceReasonCode
	  WHERE Status = 1
	  FOR JSON PATH
END

--SELECT * FROM InvoiceReasonCode


