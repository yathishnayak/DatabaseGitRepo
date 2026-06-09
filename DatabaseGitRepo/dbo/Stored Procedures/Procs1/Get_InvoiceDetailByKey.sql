
CREATE PROCEDURE [dbo].[Get_InvoiceDetailByKey] -- [Get_InvoiceDetailByKey] 82769
@InvoiceKey  INT=52
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON

	SELECT DISTINCT  
	I.ItemKey, ItemID, ID.[Description],ID.Qty,ID.UnitPrice,ID.ExtAmt,ID.InvoicelineKey,IH.InvoiceKey,IH.CustKey,
	ID.OrderDetailKey	,ltrim(rtrim(IC.ContainerNo)) as Container	, I.InvoiceItemDesc, 
	PB.PriceBasisKey, pb.PriceBasisID, InvoiceCompanyKey, TimeDuration, ISNULL(CI.ChargeCode,'') CustomerChargeCode, 
	ISNULL(CI.ChargeDescription,ID.[Description]) ChargeDescription, CAST(0 AS INT) FreeQty, CAST(0 AS INT) TotalQty,
	CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem) THEN CAST(ISNULL(ShowCustomerItemDesc,0) AS BIT) ELSE CAST(0 AS BIT) END AS ShowCustomerItemDesc,
	CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem) THEN CAST(ISNULL(ShowChargeCode,0) AS BIT) ELSE CAST(0 AS BIT) END AS ShowChargeCode
	FROM 
		dbo.Invoicedetail ID 	
		LEFT JOIN InvoiceContainers IC WITH (NOLOCK) ON IC.InvoiceKey=ID.InvoiceKey and ID.OrderDetailKey  =  IC.OrderDetailsKey
		JOIN dbo.InvoiceHeader IH	ON IH.InvoiceKey = ID.InvoiceKey
		--JOIN  dbo.RouteInvoice RI	ON RI.InvoiceKey = IH.InvoiceKey
		JOIN dbo.Item I				ON I.ItemKey=ID.ItemKey
		LEFT JOIN dbo.ItemPriceBasis PB WITH (NOLOCK) ON I.PriceBasisKey = PB.PriceBasisKey
		LEFT JOIN dbo.CustomerItem CI WITH (NOLOCK) ON ISNULL(CI.MasterItemKey,0)=I.ItemKEy
	WHERE ID.InvoiceKey = @InvoiceKey and ID.OrderDetailKey is not null 
	ORDER BY LTRIM(RTRIM(IC.ContainerNo)), I.ItemID

END
