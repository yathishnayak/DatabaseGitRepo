

CREATE procedure [dbo].[InvoicerKey_GetList]
AS
BEGIN

SELECT DISTINCT CreateUserKey from InvoiceHeader WHERE StatusKey in (1,2,3)
FOR JSON PATH
END
