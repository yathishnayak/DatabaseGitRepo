


CREATE VIEW [dbo].[PowerBI_InvoiceDetail_Combined] as

SELECT ID.*
		, I.ItemID, I.Description AS ItemDesc, I.InvoiceItemDesc AS InvItemDesc, M.Description AS MasterItemDesc, CI.ChargeCode, CI.ChargeDescription
		, IT.ItemType AS ItemType, IT.Description AS ItemTypeDesc, IC.Name AS ItemCategory 

FROM
(
SELECT	I.InvoicelineKey, NULL AS MInvoiceLineKey, NULL AS PPInvoiceLineKey, I.InvoiceKey, NULL AS MInvoiceKey, NULL AS PPInvoiceKey, I.OrderDetailKey, I.Container
		, I.ItemKey, I.UnitPrice, I.Qty, I.ExtAmt, I.Charges
		, 'I' AS InvoiceType, 'Invoice' AS 'Invoice Type Desc', CONCAT('I-', I.InvoiceKey) AS 'InvoiceType+Key'
		, CASE WHEN I.BvsNB = 1 THEN 'B' ELSE 'NB' END AS BvsNB
FROM Invoicedetail I WITH (NOLOCK) where   I.InvoiceKey not in (103389, 134684, 136005,136330,139782, 143588, 147042,148171)  --OrderDetailKey not in (127105)

UNION ALL

SELECT NULL AS InvoicelineKey, M.MInvoiceLineKey, NULL AS PPInvoiceLineKey, NULL AS InvoiceKey, M.MInvoiceKey, NULL AS PPInvoiceKey, NULL AS OrderDetailKey, M.ContainerNo AS Container
		, M.ItemKey, M.UnitPrice, M.Quantity AS Qty, M.ExtCost AS ExtAmt, NULL AS Charges
		, 'M' AS InvoiceType, 'Manual Invoice' AS 'Invoice Type Desc', CONCAT('M-', M.MInvoiceKey) AS 'InvoiceType+Key'
		, 'B' AS BvsNB
FROM ManualInvoiceDetail M WITH (NOLOCK)

UNION ALL

SELECT NULL AS InvoicelineKey, NULL AS MInvoiceLineKey, P.PPInvoiceLineKey, NULL AS InvoiceKey, NULL AS MInvoiceKey, P.PPInvoiceKey, NULL AS OrderDetailKey, P.ContainerNo AS Container
		, P.ItemKey, P.UnitPrice, P.Quantity AS Qty, P.ExtCost AS ExtAmt,  NULL AS Charges
		, 'P' AS InvoiceType, 'Prepay Invoice' AS 'Invoice Type Desc', CONCAT('P-', P.PPInvoiceKey) AS 'InvoiceType+Key'
		, 'B' AS BvsNB
FROM PrepayInvoiceDetail P WITH (NOLOCK)
) AS ID

LEFT JOIN Item AS I WITH (NOLOCK) ON ID.ItemKey = I.ItemKey 
LEFT JOIN Item M ON I.MasterItemKey = M.ItemKey
LEFT JOIN CustomerItem CI ON M.ItemKey = CI.MasterItemKey
LEFT JOIN ItemType AS IT WITH (NOLOCK) ON I.ItemTypeKey = IT.ItemTypeKey 
LEFT JOIN ItemCategory AS IC WITH (NOLOCK) ON I.CategoryKey = IC.CategoryKey
