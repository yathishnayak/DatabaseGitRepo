
CREATE proc [dbo].[Verify_ContainerReadyToInvoice] -- Verify_ContainerReadyToInvoice 183
(
	@OrderDetailKey		INT = 0
)
as
BEGIN
	SET NOCOUNT ON
    SET FMTONLY OFF

	DECLARE @IsReadyToInvoice BIT = 0, @cnt INT = 0,  @InvoiceKey INT, @invoiceNo VARCHAR(50), @InvoiceDate DATETIME, @InvoiceAmount DECIMAL(18,5)
	SELECT @cnt = COUNT(1) FROM OrderDetail OD
		INNER JOIN Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
		WHERE OD.OrderDetailKey = @OrderDetailKey AND ISNULL(IsRateVerified,0) = 0

	SELECT @InvoiceKey = RI.InvoiceKey, @invoiceNo = IH.InvoiceNo, 
		@InvoiceDate = IH.InvoiceDate, @InvoiceAmount = IH.InvoiceAmount
	FROM RouteInvoice RI
	INNER JOIN InvoiceHeader IH on RI.InvoiceKey = IH.InvoiceKey
	WHERE OrderDetailKey = @OrderDetailKey

	IF(@cnt = 0)
	BEGIN
		SELECT @IsReadyToInvoice = 1
		FROM OrderDetail 
		WHERE  Status = 6 AND OrderDetailKey = @OrderDetailKey 
	END
	SELECT @IsReadyToInvoice AS IsReadyToInvoice,  @InvoiceKey AS InvoiceKey, @invoiceNo AS InvoiceNo,
			@InvoiceDate AS InvoiceDate, @InvoiceAmount AS InvoiceAmount
END
