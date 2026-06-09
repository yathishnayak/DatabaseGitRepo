--Sell_Delete_FiveTables
CREATE Proc [dbo].[Delete_Sell_InvoiceTable_Data]
AS
BEGIN

Delete
--SELECT *
FROM SELL_InvoiceProcessStatus
WHERE INVOICEKEY IN (
SELECT INVOICEKEY FROM  InvoiceHeader IH WITH (NOLOCK) 
INNER JOIN SELL_BI_Rerun RR WITH (NOLOCK) ON IH.InvoiceNo = RR.InvoiceNo)

Delete
--SELECT *
FROM Sell_InvoiceBobtailSummary
WHERE InvoiceSummaryKey IN 
(SELECT InvoiceSummaryKey 
FROM SELL_BI_Rerun CBR WITH (NOLOCK) 
INNER JOIN invoiceheader IH WITH (NOLOCK)  ON CBR.InvoiceNo = IH.InvoiceNo
INNER JOIN SELL_InvoiceSummary SIS WITH (NOLOCK)  ON IH.InvoiceKey = SIS.InvoiceKey)

Delete
--SELECT *
FROM SELL_InvoiceDraybaseSummary
WHERE InvoiceSummaryKey IN 
(SELECT InvoiceSummaryKey 
FROM SELL_BI_Rerun CBR WITH (NOLOCK) 
INNER JOIN invoiceheader IH WITH (NOLOCK)  ON CBR.InvoiceNo = IH.InvoiceNo
INNER JOIN SELL_InvoiceSummary SIS WITH (NOLOCK)  ON IH.InvoiceKey = SIS.InvoiceKey)

Delete
--SELECT *
FROM SELL_InvoiceItemSummary
WHERE InvoiceSummaryKey IN 
(SELECT InvoiceSummaryKey 
FROM SELL_BI_Rerun CBR WITH (NOLOCK) 
INNER JOIN InvoiceHeader IH WITH (NOLOCK)  ON CBR.InvoiceNo = IH.InvoiceNo
INNER JOIN SELL_InvoiceSummary SIS WITH (NOLOCK)  ON IH.InvoiceKey = SIS.InvoiceKey)

Delete
--SELECT * 
FROM SELL_InvoiceSummary 
WHERE InvoiceKey IN (
SELECT InvoiceKey FROM  InvoiceHeader IH WITH (NOLOCK) 
INNER JOIN SELL_BI_Rerun RR WITH (NOLOCK) ON IH.InvoiceNo = RR.InvoiceNo)

END