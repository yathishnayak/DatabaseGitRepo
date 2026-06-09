

CREATE proc [dbo].[Update_InvoiceBrokerRefNo]
(
	@InvoiceKey		int,
	@BrokerRefNo	varchar(20),
	@UserKey	int,
	@Output			bit OUTPUT
)
as
BEGIN
	SET @Output = 0
	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM InvoiceHeader WHERE InvoiceKey = @InvoiceKey
	IF(@CNT > 0)
	BEGIN
		UPDATE InvoiceHeader
		SET BrokerRefNo = @BrokerRefNo,  UpdateUserKey = @UserKey
		where InvoiceKey = @InvoiceKey

		UPDATE data_invoiceReport
		SET BrokerRefNo = @BrokerRefNo
		where InvoiceKey = @InvoiceKey
		
		SET @Output = 1
	END
END
