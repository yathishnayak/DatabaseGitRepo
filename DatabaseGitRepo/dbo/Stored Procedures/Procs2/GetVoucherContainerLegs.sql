CREATE Proc [dbo].[GetVoucherContainerLegs]
(
	@VoucherKey	int	= 0
)
as
Select *
from vVoucherContainerLegs
where VoucherKey = @VoucherKey