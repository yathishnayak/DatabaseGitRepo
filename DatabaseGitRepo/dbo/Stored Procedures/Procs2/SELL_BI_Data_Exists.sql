/*

	declare @InvoiceNo varchar(50) = '44333', @is_BI_DataExists  bit=0
	EXEC SELL_BI_Data_Exists @InvoiceNo, @is_BI_DataExists OUTPUT
 
*/

CREATE Procedure [dbo].[SELL_BI_Data_Exists]
(
@InvoiceNo varchar(50) = '',
@is_BI_DataExists bit OUTPUT
)
AS
BEGIN

	Declare @count1 int, @count2 int, @count3 int, @count4 int, @count5 int, @finalcount int

	SELECT @count1 = count(1)
	FROM SELL_InvoiceProcessStatus
	WHERE InvoiceKey IN (
	SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK) 
	WHERE IH.InvoiceNo = @InvoiceNo) 
 
	SELECT @count2 = count(1)
	FROM Sell_InvoiceBobtailSummary
	WHERE InvoiceSummaryKey IN 
	(SELECT InvoiceSummaryKey 
	FROM invoiceheader IH WITH (NOLOCK)
	INNER JOIN SELL_InvoiceSummary SIS WITH (NOLOCK) ON IH.InvoiceKey = SIS.InvoiceKey
	WHERE IH.InvoiceNo = @InvoiceNo)
 
	SELECT @count3 = count(1)
	FROM SELL_InvoiceDraybaseSummary
	WHERE InvoiceSummaryKey IN 
	(SELECT InvoiceSummaryKey 
	FROM invoiceheader IH WITH (NOLOCK)
	INNER JOIN SELL_InvoiceSummary SIS WITH (NOLOCK) ON IH.InvoiceKey = SIS.InvoiceKey
	WHERE IH.InvoiceNo = @InvoiceNo)
 
	SELECT @count4 = count(1) 
	FROM SELL_InvoiceItemSummary
	WHERE InvoiceSummaryKey IN 
	(SELECT InvoiceSummaryKey 
	FROM InvoiceHeader IH WITH (NOLOCK)
	INNER JOIN SELL_InvoiceSummary SIS WITH (NOLOCK) ON IH.InvoiceKey = SIS.InvoiceKey
	WHERE IH.InvoiceNo = @InvoiceNo)

	SELECT @count5 = count(1)
	FROM SELL_InvoiceSummary ICS
	WHERE InvoiceKey IN (
	SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK) 
	WHERE IH.InvoiceNo = @InvoiceNo)

	SET @finalcount = @count1 + @count2 + @count3 + @count4 + @count5
	SET @is_BI_DataExists = case when @finalcount = 0 then 0 else 1 end

	--SELECT @is_BI_DataExists
END