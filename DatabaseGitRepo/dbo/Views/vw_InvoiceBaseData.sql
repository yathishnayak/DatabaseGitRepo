

CREATE   VIEW [dbo].[vw_InvoiceBaseData]
AS
/* ============================
   PENDING TO INVOICE
============================ */
SELECT
    OH.OrderKey,
    OD.OrderDetailKey,
    OH.OrderNo,
    OD.ContainerNo,
    9 AS StatusKey,
    'Pending to Invoice' AS StatusName,
    OH.OrderDate,
    OD.CompleteDate AS TerminationDate,
    CU.CustKey,
    CU.CustID,
    CU.CustName,
    CU.IsFactored,
    CU.CustomerCompanyKey AS CustCompanyKey,
    CC.CompanyName AS CustCompanyName,
    NULL AS InvoiceKey,
    NULL AS InvoiceNo,
    NULL AS InvoiceDate,
    0 AS InvoiceAmount,
    0 AS BalanceAmount,
    OH.BillOfLading,
    OH.BrokerRefNo,
    OH.MarketLocationKey,
    ML.MarketLocation,
    OT.OrderTypeKey,
    OT.OrderType,
    CASE WHEN OT.OrderTypeKey = 3 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS DoorToDoor
FROM OrderDetail OD
JOIN OrderHeader OH ON OD.OrderKey = OH.OrderKey
JOIN Customer CU ON OH.CustKey = CU.CustKey
LEFT JOIN CustomerCompany CC ON CU.CustomerCompanyKey = CC.CustomerCompanyKey
LEFT JOIN OrderType OT ON ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) = OT.OrderTypeKey
LEFT JOIN MarketLocation ML ON OH.MarketLocationKey = ML.MarketLocationKey
LEFT JOIN InvoiceContainers IC ON IC.OrderDetailsKey = OD.OrderDetailKey
WHERE
    OD.Status IN (6,10,12,13,14)
    AND IC.OrderDetailsKey IS NULL

UNION ALL

/* ============================
   INVOICED
============================ */
SELECT
    OH.OrderKey,
    0 AS OrderDetailKey,
    OH.OrderNo,
    NULL AS ContainerNo,
    IH.StatusKey,
    INS.Description AS StatusName,
    OH.OrderDate,
    IC.TerminationDate,
    CU.CustKey,
    CU.CustID,
    CU.CustName,
    CU.IsFactored,
    CU.CustomerCompanyKey,
    CC.CompanyName,
    IH.InvoiceKey,
    IH.InvoiceNo,
    IH.InvoiceDate,
    IH.InvoiceAmount,
    ISNULL(VIB.BalanceAmount, IH.InvoiceAmount),
    OH.BillOfLading,
    ISNULL(IH.BrokerRefNo, OH.BrokerRefNo),
    OH.MarketLocationKey,
    ML.MarketLocation,
    OT.OrderTypeKey,
    OT.OrderType,
    CASE WHEN OT.OrderTypeKey = 3 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
FROM InvoiceHeader IH
JOIN OrderHeader OH ON IH.OrderKey = OH.OrderKey
JOIN Customer CU ON IH.CustKey = CU.CustKey
LEFT JOIN CustomerCompany CC ON CU.CustomerCompanyKey = CC.CustomerCompanyKey
LEFT JOIN InvoiceStatus INS ON IH.StatusKey = INS.StatusKey
LEFT JOIN (
    SELECT InvoiceKey, MAX(TerminationDate) TerminationDate
    FROM InvoiceContainers
    GROUP BY InvoiceKey
) IC ON IC.InvoiceKey = IH.InvoiceKey
LEFT JOIN vInvoiceBalanceAmount VIB ON IH.InvoiceKey = VIB.InvoiceKey
LEFT JOIN OrderType OT ON OH.OrderTypeKey = OT.OrderTypeKey
LEFT JOIN MarketLocation ML ON OH.MarketLocationKey = ML.MarketLocationKey
LEFT JOIN ArchivedInvoiceHistory AIH ON AIH.InvoiceKey = IH.InvoiceKey
WHERE
    AIH.InvoiceKey IS NULL;
