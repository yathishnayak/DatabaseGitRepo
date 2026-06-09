
CREATE View vPendingRoutesToVoucher
 
as 
select RT.RouteKey
from dbo.Routes RT WITH (NOLOCK)
LEFT JOIN dbo.VoucherDetail VD WITH (NOLOCK) on Rt.RouteKey = VD.RouteKey
where vd.RouteKey is null