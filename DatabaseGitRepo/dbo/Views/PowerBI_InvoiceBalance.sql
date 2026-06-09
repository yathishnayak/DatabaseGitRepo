
CREATE VIEW [PowerBI_InvoiceBalance]
AS

WITH P AS 
(SELECT DISTINCT CONCAT(I.InvoiceType, '-', I.InvoiceKey) AS 'InvoiceType+Key', SUM(I.PaidAmount) AS [Paid Amt]
FROM InvoicePayment AS I WITH (NOLOCK)
GROUP BY CONCAT(I.InvoiceType, '-', I.InvoiceKey))


SELECT I.[InvoiceType+Key], I.InvoiceType, I.[Invoice Type Desc], I.InvoiceNo, I.InvoiceDate, I.DueDate, I.InvoiceApprovedDate, I.CustKey, I.CustID, I.CustName, I.CustomerGroup, I.SalesPersonName, I.CSR, I.PaymentTermsID, I.[Pmt Terms Dec], I.[Pmt Terms Days]
		, I.InvoiceStatus, SUM(I.InvoiceVolume) AS InvoiceVolume, SUM(I.InvoiceAmount) AS [Invoice Amt], P.[Paid Amt], (SUM(I.InvoiceAmount) - COALESCE(P.[Paid Amt],0)) AS [Invoice Balance], I.OrderKey
FROM PowerBI_InvoiceHeader_Combined AS I WITH (NOLOCK)
LEFT JOIN P ON I.[InvoiceType+Key] = P.[InvoiceType+Key]
GROUP BY I.[InvoiceType+Key], I.InvoiceType, I.[Invoice Type Desc], I.InvoiceNo, I.InvoiceDate, I.DueDate, I.InvoiceApprovedDate, I.CustKey, I.CustID, I.CustName, I.CustomerGroup, I.SalesPersonName, I.CSR, I.PaymentTermsID, I.[Pmt Terms Dec], I.[Pmt Terms Days]
, I.InvoiceStatus, P.[Paid Amt], I.OrderKey