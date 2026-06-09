
-- [Auto_ReturnBaseInfo_shiva_20250424]  176186
CREATE PROCEDURE [dbo].[Auto_ReturnBaseInfo_shiva_20250424] 
--Auto_ReturnBaseInfo 164524
--Auto_ReturnBaseInfo 176186
(
	@InvoiceKey INT
)
AS
BEGIN

	SELECT *
	FROM (SELECT TOP 1000  
		IH.Invoicekey, IH.InvoiceNo, IH.InvoiceDate,OD.OrderDetailKey,OT.OrderType,
		OD.ContainerNo, RT.Routekey, L.LegID, L.FromLocation, L.ToLocation , 
		RT.SourceAddrKey, Rt.DestinationAddrKey, Y.ShortName, 
		--Case when isnull(Y.YardType, '')<>'' then Y.YardType else L.FromLocation end as YardType,
		Case when OT.OrderType = 'Import' and L.ToLocation in ('Consignee','Customer','Shipper') and L.FromLocation = 'Yard'	
			then Y.YardType
			when OT.OrderType = 'Export' and L.FromLocation in ('Consignee','Customer','Shipper') and L.ToLocation = 'Yard'	
			then Y.YardType
			else 'Local'
		end as YardType,
		Y.yardid,
		P.ShippingPortKey, P.ShippingPortID,
		A.City, A.State, A.ZipCode, D.DriverKey, D.driverID, TT.TruckType, 
		L.LegCostType, LT.LegTypeName, RT.IsDryRun, RT.DryRunType AS DryRunTypeKey, DRT.DryRunType, isnull(RT.IsBobtail,0) as IsBobtail,
		RT.LegNo, Rt.ChassisCategoryKey, A.AddrName as LocationName, Address1
	FROM (SELECT DISTINCT InvoiceKey, orderdetailkey, Container FROM InvoiceDetail where InvoiceKey = @InvoiceKey) ID 
	INNER JOIN InvoiceHeader IH WITH (NOLOCK) ON ID.InvoiceKey = IH.InvoiceKey
	INNER JOIN OrderDetail OD WITH (NOLOCK) ON ID.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN Orderheader OH WITH (NOLOCK) ON OD.orderKey = OH.orderKey
	INNER JOIN routes RT WITH (NOLOCK) ON ID.OrderDetailKey = RT.OrderDetailKey --and OD.ContainerNo = ID.Container
	INNER JOIN OrderType OT WITH (NOLOCK) ON OH.orderTypekey = OT.OrderTypeKey
	INNER JOIN Leg L WITH (NOLOCK)  ON RT.LegKey = L.LegKey 
	LEFT JOIN Yard Y WITH (NOLOCK) ON CASE WHEN L.FromLocation  = 'Yard' THEN Rt.SourceAddrKey
		WHEN L.ToLocation = 'Yard' THEN Rt.DestinationAddrKey ELSE 0 END = Y.AddrKey
	LEFT JOIN ShippingPort P WITH (NOLOCK) ON CASE WHEN L.FromLocation  = 'Port' THEN Rt.SourceAddrKey
		WHEN L.ToLocation = 'Port' THEN Rt.DestinationAddrKey ELSE 0 END = P.AddrKey
	LEFT JOIN Address A WITH (NOLOCK) ON 
		CASE 
			WHEN OT.OrderType = 'Import' AND  L.ToLocation  IN ('Shipper','Customer', 'Consignee') THEN Rt.DestinationAddrKey
			WHEN OT.OrderType = 'Export' AND  L.FromLocation  IN ('Shipper','Customer', 'Consignee') THEN Rt.SourceAddrKey
			WHEN OT.OrderType = 'Empty'  AND  L.ToLocation IN ('Port') THEN Rt.DestinationAddrKey
			WHEN L.ToLocation IN ('Shipper','Customer', 'Consignee') THEN Rt.DestinationAddrKey 
			ELSE 0 END = A.AddrKey
	LEFT JOIN Driver D WITH (NOLOCK) ON RT.DriverKey = D.DriverKey
	LEFT JOIN TruckType TT WITH (NOLOCK) ON D.TruckTypeKey = TT.TruckTypeKey
	LEFT JOIN Cost_LegTypes LT WITH (NOLOCK) ON L.LegCostType = LT.LegTypeID
	LEFT JOIN DryRunType DRT WITH (NOLOCK) ON RT.DryRunType = DRT.DryRunTypeKey
	ORDER BY Rt.LegNo ASC ) A

END