


CREATE view [dbo].[vVoucherContainerLegs]
as
select OD.OrderDetailKey, ContainerNo, ContainerID, L.LegID, VoucherKey, RV.RouteKey
from RouteVouchers RV WITH (NOLOCK) 
inner join Routes R  WITH (NOLOCK) on RV.RouteKey = R.RouteKey
inner join OrderDetail OD  WITH (NOLOCK) on R.OrderDetailKey = OD.OrderDetailKey
inner join Leg L  WITH (NOLOCK) on R.LegKey = L.LegKey
