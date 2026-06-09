
CREATE VIEW [PowerBI_SellDB_Vs_Invoice_Rates]
AS

--SELL_InvoiceItemSummary
WITH ItemSellDB AS 
(SELECT DISTINCT InvoiceSummaryKey, ContainerNo, itemkey, Rate, EffectiveDate 
FROM SELL_InvoiceItemSummary WITH (NOLOCK)),

ItemSellDBSummary AS 
(SELECT DISTINCT I.InvoiceSummaryKey, I.ContainerNo, I.itemkey, MAX(I.EffectiveDate) AS EffectiveDate
FROM ItemSellDB AS I 
GROUP BY I.InvoiceSummaryKey, I.ContainerNo, I.itemkey),

InvItm AS 
(SELECT DISTINCT I.InvoiceSummaryKey, I.ContainerNo, I.itemkey, I.EffectiveDate, B.Rate 
FROM ItemSellDBSummary AS I 
LEFT JOIN ItemSellDB AS B ON I.InvoiceSummaryKey = B.InvoiceSummaryKey AND I.ContainerNo = I.ContainerNo AND I.itemkey = B.itemkey AND I.EffectiveDate = B.EffectiveDate),


--SELL_InvoiceDraybaseSummary
DraySellDB AS 
(SELECT DISTINCT InvoiceSummaryKey, ContainerNo, DrayBase_Rate, FSF_Value, FSF_Percent, Draybase_Total, EffectiveDate 
FROM SELL_InvoiceDraybaseSummary WITH (NOLOCK)),

DraySellDBSummary AS 
(SELECT DISTINCT I.InvoiceSummaryKey, I.ContainerNo, MAX(I.EffectiveDate) AS EffectiveDate
FROM DraySellDB AS I 
GROUP BY I.InvoiceSummaryKey, I.ContainerNo),

InvDB AS 
(SELECT DISTINCT I.InvoiceSummaryKey, I.ContainerNo, I.EffectiveDate, B.DrayBase_Rate, B.FSF_Value, B.FSF_Percent, B.Draybase_Total 
FROM DraySellDBSummary AS I 
LEFT JOIN DraySellDB AS B ON I.InvoiceSummaryKey = B.InvoiceSummaryKey AND I.ContainerNo = I.ContainerNo AND I.EffectiveDate = B.EffectiveDate) ,


--SELL_InvoiceBobtailSummary
BobSellDB AS 
(SELECT DISTINCT InvoiceSummaryKey, ContainerNo, BobtailRate, EffectiveDate 
FROM SELL_InvoiceBobtailSummary WITH (NOLOCK)),

BobSellDBSummary AS 
(SELECT DISTINCT I.InvoiceSummaryKey, I.ContainerNo, MAX(I.EffectiveDate) AS EffectiveDate
FROM BobSellDB AS I 
GROUP BY I.InvoiceSummaryKey, I.ContainerNo),

InvBB AS 
(SELECT DISTINCT I.InvoiceSummaryKey, I.ContainerNo, I.EffectiveDate, B.BobtailRate 
FROM BobSellDBSummary AS I 
LEFT JOIN BobSellDB AS B ON I.InvoiceSummaryKey = B.InvoiceSummaryKey AND I.ContainerNo = I.ContainerNo AND I.EffectiveDate = B.EffectiveDate) ,

-- Invoice Contains FSF (Fuel Surchage)
Inv_FSF AS
(SELECT ID.InvoiceKey, 'Exist' AS FSF_Exist
FROM Invoicedetail AS ID WITH (NOLOCK)
LEFT JOIN Item I WITH (NOLOCK) ON ID.ItemKey = I.ItemKey
WHERE I.CostGrp = 7)


SELECT	ID.InvoiceKey, ID.InvoicelineKey, ID.ItemKey, I.ItemID, I.Description, I.CostGrp--, I.InvoiceItemDesc
		, DCI.DriverNonDriverCostDesc AS ItemCostGroup, ID.Container, ID.Qty, ID.UnitPrice, ID.ExtAmt
		, CASE 
				WHEN I.CostGrp = 4 AND Inv_FSF.FSF_Exist = 'Exist' THEN InvDB.DrayBase_Rate
				WHEN I.CostGrp = 4 AND Inv_FSF.FSF_Exist IS NULL THEN InvDB.Draybase_Total
				WHEN I.CostGrp = 7 THEN InvDB.FSF_Value
				WHEN I.CostGrp = 10 THEN InvBB.BobtailRate
				ELSE InvItm.Rate END AS SellDBRate
FROM Invoicedetail AS ID WITH (NOLOCK) 



--SELECT ItemKey, ItemID, Description, CostGrp, DCI.DriverNonDriverCostDesc

LEFT JOIN Item I WITH (NOLOCK) ON ID.ItemKey = I.ItemKey
LEFT JOIN DriverNonDriverCostItems DCI WITH (NOLOCK) ON I.CostGrp = DCI.DriverNonDriverCostKey
LEFT JOIN 
	(SELECT DISTINCT InvoiceKey, InvoiceSummaryKey  FROM SELL_InvoiceSummary WITH (NOLOCK)) AS InvS ON InvS.InvoiceKey = ID.InvoiceKey

LEFT JOIN Inv_FSF ON ID.InvoiceKey = Inv_FSF.InvoiceKey

LEFT JOIN InvItm ON InvS.InvoiceSummaryKey = InvItm.InvoiceSummaryKey AND ID.Container = InvItm.ContainerNo AND ID.ItemKey = InvItm.itemkey

LEFT JOIN InvDB ON InvS.InvoiceSummaryKey = InvDB.InvoiceSummaryKey AND ID.Container = InvDB.ContainerNo --AND ID.ItemKey = InvDB.ItemKey

LEFT JOIN InvBB ON InvS.InvoiceSummaryKey = InvBB.InvoiceSummaryKey AND ID.Container = InvBB.ContainerNo --AND ID.ItemKey = InvBB.ItemKey


