
create proc [dbo].[ContainerWithoutChassisReport]
(
	@CSRKey			int = 0,
	@CustKey		int = 0,
	@DriverKey		int = 0,
	@OrderNo		varchar(50) = ''
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	select OD.ContainerNo, OH.OrderNo, OH.OrderDate, OT.OrderType, C.CsrName, ODs.Description as StatusName,
	od.OpenLegs, od.CurrentLegNo, od.TotalLegs, CU.CustID, CU.CustName,
	L.LegID, RT.LegNo,
	RT.PickupDateFrom, Rt.PickupDateTo, Rt.DeliveryDateFrom, RT.DeliveryDateTo,
	D.DriverID, d.FirstName + ' ' + isnull(d.LastName,'') as DriverName
	from Routes RT WITH (NOLOCK) 
	inner join OrderDetail OD WITH (NOLOCK)  on RT.OrderDetailKey = OD.OrderDetailKey and Rt.RouteKey = OD.CurrentRouteKey
	inner join OrderHeader OH WITH (NOLOCK)  on OD.OrderKey = OH.OrderKey
	inner join OrderType OT WITH (NOLOCK)  on OH.OrderTypeKey = OH.OrderTypeKey
	inner join ContainerSize CS WITH (NOLOCK)  on Od.ContainerSizeKey = Cs.ContainerSizeKey
	inner join CSR C WITH (NOLOCK)  on OH.CsrKey = C.CsrKey
	inner join OrderDetailStatus ODS WITH (NOLOCK)  on OD.Status = ODS.Status
	inner join Leg L WITH (NOLOCK)  on RT.LegKey = L.LegKey
	inner join Customer CU WITH (NOLOCK)  on OH.CustKey = CU.CustKey
	left join Driver D  WITH (NOLOCK) on Rt.DriverKey = D.DriverKey
	where RT.ChassisKey is null and
	( isnull(@CSRKey,0) = 0 OR OH.CsrKey = @CSRKey) and
	( ISNULL(@CustKey,0) = 0 OR OH.CustKey = @CustKey ) and
	( isnull(@DriverKey,0) = 0 OR RT.DriverKey = @DriverKey )  and
	( ISNULL(@OrderNo,'') = '' OR OH.OrderNo like '%' + @OrderNo + '' )
END
