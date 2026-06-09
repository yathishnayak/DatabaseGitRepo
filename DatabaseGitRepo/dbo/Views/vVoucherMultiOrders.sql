


CREATE VIEW [dbo].[vVoucherMultiOrders]
 
as
SELECT V.VOucherKey,		
	SUBSTRING( (	SELECT ','+OH.OrderNo AS OrderNo
	FROM dbo.RouteVouchers RV	WITH (NOLOCK) 
		INNER JOIN dbo.Routes RT	WITH (NOLOCK) ON RT.RouteKey=RV.RouteKey AND RV.VoucherKey=V.VoucherKey
		--INNER JOIN dbo.OrderDetail OD	WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailkey
		INNER JOIN dbo.OrderHeader OH	WITH (NOLOCK) ON OH.OrderKey = RT.OrderKey
	FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,2,5000)AS OrdNo
FROM dbo.VoucherHeader V WITH (NOLOCK) 
