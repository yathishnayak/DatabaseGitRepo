CREATE PROCEDURE [dbo].[Get_InvoiceDetail] -- [Get_InvoiceDetail] 361
@InvoiceKey  INT=52
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT 
		I.ItemID
      , ID.[Description]     
      , SUM(ID.[ExtAmt]) AS ExtAmt 
	  , I.InvoiceItemDesc,PriceBasisKey,TimeDuration, ISNULL(CI.ChargeCode,'') CustomerChargeCode, 
	ISNULL(CI.ChargeDescription,ID.[Description]) ChargeDescription, CAST(0 AS INT) FreeQty, CAST(0 AS INT) TotalQty,
	CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS ShowCustomerItemDesc
  FROM [dbo].[Invoicedetail] ID 
		JOIN dbo.InvoiceHeader IH  ON IH.InvoiceKey =  ID.InvoiceKey
		--JOIN  dbo.RouteInvoice RI ON RI.InvoiceKey = IH.InvoiceKey
		JOIN dbo.Item I ON I.Itemkey=ID.ItemKey
		LEFT JOIN dbo.CustomerItem CI WITH (NOLOCK) ON ISNULL(CI.MasterItemKey,0)=I.ItemKEy
  WHERE id.InvoiceKey = @InvoiceKey and OrderDetailKey is not null
  GROUP BY I.ItemID, ID.[Description], I.InvoiceItemDesc,PriceBasisKey,TimeDuration,ChargeCode,ChargeDescription,I.[Description],IH.CustKey
END