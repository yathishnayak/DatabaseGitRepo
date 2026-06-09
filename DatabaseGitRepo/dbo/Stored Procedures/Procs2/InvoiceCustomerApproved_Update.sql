

CREATE PROCEDURE [dbo].[InvoiceCustomerApproved_Update] --InvoiceCustomerApproved_Update @InvoiceKey = '83262:83182:'
(
    @InvoiceKeyStr varchar(max) = ''
	--@CustApproved Bit 
)
AS
BEGIN

    select * into #InvoiceKeys from dbo.Fn_SplitParamCol(@InvoiceKeyStr)

      UPDATE  InvoiceHeader 
	  SET CustApproved = 1  --@CustApproved
	  WHERE InvoiceKey in (select value from #InvoiceKeys ) 
END
