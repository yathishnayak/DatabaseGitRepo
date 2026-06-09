create Procedure [dbo].[Get_DriverVoucherDeductionDetail]
@DriverVoucherKey int 
as
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	Select DDD.DriverVoucherLineKey, DVD.DriverVoucherKey, DDD.ItemKey, I.[Description], DDD.UnitCost, DDD.Qty, DDD.ExtCost,
	DDD.CreateUser, DDD.UpdateUser
	from DriverVoucherDeduction DVD
	Left Join DriverVoucherDeductionDetail DDD on DDD.DriverVoucherKey = DVD.DriverVoucherKey 
	Left Join Driver D on D.DriverKey = DVD.DriverKey
	left Join Item I on I.ItemKey = DDD.ItemKey
	where DVD.DriverVoucherKey = @DriverVoucherKey
	
End
