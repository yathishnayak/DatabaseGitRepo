
CREATE proc [dbo].[Get_ChassisGlobalSearch_Items] -- Get_ChassisGlobalSearch_Items 5,
(
	@ChassisKey		int = 0,
	@OrderDetailKey	int	= 0		
)
AS
Begin
	select RT.ChassisKey, OH.OrderNo, OH.OrderDate, OD.ContainerNo, OD.OrderDetailKey,
		RT.ActualArrival as DeliveryDate, RT.ActualDeparture as PickupDate,
		L.LegID, Rt.LegNo, D.DriverID, isnull(D.FirstName,'') + ' ' + isnull(d.LastName,'') as DriverName,
		Vh.VoucherNo, Vh.VoucherDate, I.ItemID, VD.Qty, VD.UnitCost, VD.ExtCost

	from Routes RT  (Nolock)
	inner join OrderDetail OD (Nolock) on RT.OrderDetailKey = OD.OrderDetailKey
	inner join Driver D (Nolock) on RT.DriverKey = D.DriverKey
	inner join OrderHeader OH (Nolock) on OD.OrderKey = OH.OrderKey
	Left  join Leg L (Nolock) on RT.LegKey = L.LegKey
	Left Join VoucherDetail VD (Nolock) on VD.RouteKey = RT.RouteKey
	LEft join VoucherHeader VH (Nolock) on VD.Voucherkey = Vh.VoucherKey
	LEft join Item I (Nolock) on VD.ItemKey = I.ItemKey
	where Rt.ChassisKey = @ChassisKey and OD.OrderDetailKey = @OrderDetailKey
	order by RT.ActualDeparture desc
end
