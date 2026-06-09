

CREATE View [dbo].[vVoucherOrderCount] -- Select * from vVoucherOrderCount
 
as
SELECT COUNT_BIG(DISTINCT OH.OrderKey) AS OrdCount,VoucherKey 
FROM dbo.RouteVouchers RV WITH (NOLOCK) 
INNER JOIN dbo.Routes RT  WITH (NOLOCK) ON RT.RouteKey=RV.RouteKey 
--INNER JOIN dbo.OrderDetail OD	WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailkey
INNER JOIN dbo.OrderHeader OH	WITH (NOLOCK) ON OH.OrderKey = RT.OrderKey
GROUP BY VoucherKey
