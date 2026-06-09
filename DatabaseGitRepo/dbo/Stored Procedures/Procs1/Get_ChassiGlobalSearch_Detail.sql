

CREATE proc [dbo].[Get_ChassiGlobalSearch_Detail] -- Get_ChassiGlobalSearch_Detail 5, 303
(
	@ChassisKey			int = 0,
	@OrderDetailKey		int = 0
)
as
begin
	select  RT.ChassisKey, OH.OrderNo, OH.OrderDate, C.CustID, C.CustName, OD.ContainerNo, 
		RT.ActualArrival as DeliveryDate, RT.ActualDeparture as PickupDate,
		L.LegID, Rt.LegNo, D.DriverID, isnull(D.FirstName,'') + ' ' + isnull(d.LastName,'') as DriverName,
		isnull(A1.AddrName,'') + ' ' + isnull(A1.City,'') + ' ' + A1.ZipCode + ' ' +  isnull(a1.State,'') as SourceLocation, 
		isnull(A2.AddrName,'') + ' ' + isnull(A2.City,'') + ' ' + A2.ZipCode + ' ' +  isnull(A2.State,'') as Destination
	from Routes RT (Nolock)
	inner join OrderDetail OD (Nolock) on RT.OrderDetailKey = OD.OrderDetailKey
	inner join Driver D (Nolock) on RT.DriverKey = D.DriverKey
	inner join OrderHeader OH (Nolock) on OD.OrderKey = OH.OrderKey
	inner join Customer C (Nolock) on OH.CustKey = C.CustKey
	inner join Leg L (Nolock) on RT.LegKey = L.LegKey
	LEft join Address A1 (Nolock) on RT.SourceAddrKey = A1.AddrKey
	LEft join Address A2 (Nolock) on RT.DestinationAddrKey = A2.AddrKey
	where Rt.ChassisKey = @ChassisKey and RT.OrderDetailKey = @OrderDetailKey and
		((Rt.ActualArrival is null and RT.ActualDeparture is not null) OR (Rt.ActualArrival is not null and Rt.ActualDeparture is not null))
	order by RT.ActualDeparture desc
end
