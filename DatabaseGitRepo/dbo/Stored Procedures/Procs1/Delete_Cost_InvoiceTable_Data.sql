CREATE PROC [Delete_Cost_InvoiceTable_Data]
AS
BEGIN

	--SELECT *
	DELETE 
	FROM Cost_InvoiceProcessStatus
	WHERE INVOICEKEY IN (
	SELECT INVOICEKEY FROM  InvoiceHeader IH WITH (NOLOCK) 
	INNER JOIN Cost_BI_Rerun RR WITH (NOLOCK) ON IH.INVOICENO = RR.INVOICENO
	)

	--SELECT *
	DELETE 
	FROM Cost_InvoiceItemSummary
	WHERE InvoiceSummaryKey IN 
	(Select InvoiceSummaryKey 
	from Cost_BI_Rerun CBR WITH (NOLOCK) 
	inner join invoiceheader IH WITH (NOLOCK)  on CBR.invoiceno = IH.invoiceno
	inner join Cost_InvoiceSummary CIS WITH (NOLOCK)  on IH.InvoiceKey = cis.InvoiceKey)

	--SELECT *
	DELETE 
	FROM Cost_InvoiceContainerSummary
	WHERE InvoiceSummaryKey IN 
	(Select InvoiceSummaryKey from Cost_BI_Rerun CBR
	inner join invoiceheader IH on CBR.invoiceno = IH.invoiceno
	inner join Cost_InvoiceSummary CIS on IH.InvoiceKey = cis.InvoiceKey);
 
	--SELECT * 
	DELETE
	FROM Cost_InvoiceSummary
	WHERE INVOICEKEY IN (
	SELECT INVOICEKEY FROM  InvoiceHeader IH WITH (NOLOCK) 
	INNER JOIN Cost_BI_Rerun RR WITH (NOLOCK) ON IH.INVOICENO = RR.INVOICENO
	)

END