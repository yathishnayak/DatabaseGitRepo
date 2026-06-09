/*
	declare @InvoiceNo varchar(50) = '44333', @is_BI_DataExists  bit=0
	EXEC Cost_BI_Data_Exists @InvoiceNo, @is_BI_DataExists OUTPUT

--select * from Cost_InvoiceProcessStatus order by invoicekey desc

select invoicekey, invoiceno from InvoiceHeader where invoiceKey IN (
137561,
137532,
137352,
137350,
137344)

*/

--Cost_BI_Data_Exists '96554'

CREATE Procedure [dbo].[Cost_BI_Data_Exists]
(
@InvoiceNo varchar(50) = '',
@is_BI_DataExists bit output
)
AS
BEGIN

	Declare @count1 int, @count2 int, @count3 int, @count4 int, @finalcount int

	SELECT @count1 = count(1)
	FROM Cost_InvoiceProcessStatus IPS
	WHERE INVOICEKEY IN (
	SELECT INVOICEKEY FROM InvoiceHeader IH WITH (NOLOCK)
	where ih.InvoiceNo = @InvoiceNo) 
 
	SELECT @count2 = count(1)
	FROM Cost_InvoiceItemSummary
	WHERE InvoiceSummaryKey IN (
	SELECT InvoiceSummaryKey 
	from invoiceheader IH WITH (NOLOCK)
	inner join Cost_InvoiceSummary CIS WITH (NOLOCK)  on IH.InvoiceKey = cis.InvoiceKey
	where ih.InvoiceNo = @InvoiceNo)
 
	SELECT @count3 = count(1)
	FROM Cost_InvoiceContainerSummary
	WHERE InvoiceSummaryKey IN (
	SELECT InvoiceSummaryKey 
	from invoiceheader IH WITH (NOLOCK) 
	inner join Cost_InvoiceSummary CIS on IH.InvoiceKey = cis.InvoiceKey
	where ih.InvoiceNo = @InvoiceNo)
 
	SELECT @count4 = count(1) 
	FROM Cost_InvoiceSummary ICS
	WHERE INVOICEKEY IN (
	SELECT INVOICEKEY FROM InvoiceHeader IH WITH (NOLOCK)
	where ih.InvoiceNo = @InvoiceNo)

	set @finalcount = @count1 + @count2 + @count3 + @count4
	set @is_BI_DataExists = case when @finalcount = 0 then 0 else 1 end

END