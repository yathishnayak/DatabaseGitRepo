




CREATE View [dbo].[vVoucherContainers]
 
as
SELECT V.VOucherKey,		
	SUBSTRING( (	SELECT ','+OD.ContainerNo AS ContNo
FROM dbo.RouteVouchers RV	 WITH (NOLOCK) 
	INNER JOIN dbo.Routes RT	WITH (NOLOCK) ON RT.RouteKey=RV.RouteKey AND RV.VoucherKey=V.VoucherKey
	INNER JOIN dbo.OrderDetail OD	WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailkey		
FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,2,5000)AS ContNo
FROM dbo.VoucherHeader V  WITH (NOLOCK) 
