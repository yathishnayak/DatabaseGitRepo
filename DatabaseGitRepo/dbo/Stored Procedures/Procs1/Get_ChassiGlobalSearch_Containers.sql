

CREATE proc [dbo].[Get_ChassiGlobalSearch_Containers] -- [Get_ChassiGlobalSearch_Containers] 5
(
	@ChassisKey			int = 0
)
as
begin
	SELECT top 50 * FROM (
	select  RT.ChassisKey, OH.OrderNo, OH.OrderDate, C.CustID, C.CustName, OD.ContainerNo, OH.BrokerRefNo, OD.OrderDetailKey,
	cs.Description, RT.ActualArrival as DeliveryDate, RT.ActualDeparture as PickupDate,
	L.LegID, Rt.LegNo,
		isnull(A1.AddrName,'') + ' ' + isnull(A1.City,'') + ' ' + A1.ZipCode + ' ' +  isnull(a1.State,'') as SourceLocation, 
		isnull(A2.AddrName,'') + ' ' + isnull(A2.City,'') + ' ' + A2.ZipCode + ' ' +  isnull(A2.State,'') as Destination,
	 ROW_NUMBER() OVER( PARTITION BY OD.ORDERDETAILKEY ORDER BY OD.ORDERDETAILKEY, RT.ActualDeparture DESC  ) AS ROWNUM 
	from Routes RT (Nolock)
	inner join OrderDetail OD (Nolock) on RT.OrderDetailKey = OD.OrderDetailKey
	inner join OrderHeader OH (Nolock) on OD.OrderKey = OH.OrderKey
	inner join Customer C (Nolock) on OH.CustKey = C.CustKey
	inner join Leg L (Nolock) on RT.LegKey = L.LegKey
	LEft join Address A1 (Nolock) on RT.SourceAddrKey = A1.AddrKey
	LEft join Address A2 (Nolock) on RT.DestinationAddrKey = A2.AddrKey
	inner join ContainerSize CS (nolock) on OD.ContainerSizeKey = CS.ContainerSizeKey
	where Rt.ChassisKey = @ChassisKey and 
		((Rt.ActualArrival is null and RT.ActualDeparture is not null) OR (Rt.ActualArrival is not null and Rt.ActualDeparture is not null))
	
	) A
	WHERE ROWNUM = 1
	order by PickupDate desc
end
