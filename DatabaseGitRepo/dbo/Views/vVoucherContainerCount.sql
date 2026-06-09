CREATE View [dbo].[vVoucherContainerCount]
as
SELECT VoucherKey, COUNT(distinct OD.ContainerNo) AS ContCount
FROM dbo.Voucherdetail RV WITH (NOLOCK) 
	INNER JOIN Routes RT WITH (NOLOCK) ON RT.RouteKey=RV.RouteKey 
	INNER JOIN dbo.OrderDetail OD	WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailkey
GROUP BY VoucherKey
