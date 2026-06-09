


CREATE View [dbo].[vVoucherAmt]
as
select VoucherKey, sum(case when RouteKey = 0 then -1 * ExtCost else ExtCost End) as VoucherAmt 
from VoucherDetail  WITH (NOLOCK) 
group by Voucherkey
