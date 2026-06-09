
CREATE PROCEDURE [dbo].[Update_InvoicePaymentReceived]
@InvoiceKeySTR varchar(2000),
@UserKey	INT,
@Output		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @STATUSKEY INT = 0

	SET @Output=0;

	select * into #InvoiceKeys from dbo.Fn_SplitParamCol(@InvoiceKeySTR)

	select @STATUSKEY = StatusKey from InvoiceStatus where Description = 'Payment Received'

	UPDATE dbo.InvoiceHeader
	SET IsPaymentReceived = 1, PaymentRecdDate = GETDATE(), PaymentRecdUserKey = @UserKey,
		StatusKey = @STATUSKEY
	WHERE StatusKey = 2 and InvoiceKey in (select Value from #InvoiceKeys);

	UPDATE InvoicePayment
	SET StatusKey =5 where InvoiceKey in (select Value from #InvoiceKeys)
	
	SET @Output=1;
END
