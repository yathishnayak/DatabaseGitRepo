


CREATE PROCEDURE [dbo].[Get_ChassisGlobalSearch_Main] -- Get_ChassisGlobalSearch_Main
(
	@ChassisKey		int = 0,
	@ContainerNo	varchar(50) = '',
	@LegKey			int = 0,
	@ContainerStatusKey	int = 0,
	@DriverKey		int =0,
	@ChassisStatusKey	int = 0 --// 0 : All, 1: Open, 2: In Use, 3: In Port, 4: in Yard
)
as
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	create table #chassisData
	(
		ChassisKey	int,
		OrderdetailKey	int,
		RouteKey		int,
		StatusKey	int
	)

	insert into #chassisData (ChassisKey)
	select chassisKey
	from Chassis (nolock)

	update A set OrderdetailKey = MaxODKey, RouteKey = B.RouteKey, StatusKey = CStatusKey
	--select *
	from #chassisData A
	inner join (
		Select A.ChassisKey, Rt.OrderDetailKey as MaxODKey , 2 as CStatusKey, Rt.RouteKey
		from (
			select ChassisKey, max(RouteKey) as MaxRTKey,  2 CStatusKey
			from Routes RT (Nolock)
			inner join Leg L (Nolock) on RT.LegKey = L.LegKey
			where ChassisKey is not null and ActualDeparture is not null and ActualArrival is null
			group by ChassisKey
		) A 
		inner join Routes RT (Nolock) on A.MaxRTKey = Rt.RouteKey
		inner join Leg L (Nolock) on Rt.LegKey = L.LegKey
	) B on A.ChassisKey = B.ChassisKey
	
	update A set OrderdetailKey = MaxODKey, RouteKey = B.RouteKey, StatusKey = CStatusKey
	--select *
	from #chassisData A
	inner join (
		Select A.ChassisKey, Rt.OrderDetailKey as MaxODKey , 3 as CStatusKey, Rt.RouteKey
		from (
			select ChassisKey, max(RouteKey) as MaxRTKey
			from Routes RT (Nolock)
			where ChassisKey is not null and ActualArrival is not null and ActualDeparture is not null
			group by ChassisKey
		) A
		inner join Routes RT (Nolock) on A.MaxRTKey = Rt.RouteKey
		inner join Leg L (Nolock) on Rt.LegKey = L.LegKey
		where L.ToLocation = 'PORT'
	) B on A.ChassisKey = B.ChassisKey 
	where ISNULL(A.OrderdetailKey,0) < b.MaxODKey

	update A set OrderdetailKey = MaxODKey, RouteKey = B.RouteKey, StatusKey = CStatusKey
	--select *
	from #chassisData A
	inner join (
		Select A.ChassisKey, Rt.OrderDetailKey as MaxODKey , 4 as CStatusKey, Rt.RouteKey
		from (
			select ChassisKey, max(RouteKey) as MaxRTKey
			from Routes RT (Nolock)
			where ChassisKey is not null and ActualArrival is not null and ActualDeparture is not null
			group by ChassisKey
		) A
		inner join Routes RT (Nolock) on A.MaxRTKey = Rt.RouteKey
		inner join Leg L (Nolock) on Rt.LegKey = L.LegKey
		where L.ToLocation = 'YARD'
	) B on A.ChassisKey = B.ChassisKey
	where  ISNULL(A.OrderdetailKey,0) < b.MaxODKey

	update #chassisData 
	set StatusKey = 1
	where isnull(StatusKey ,0) = 0
	
	--select * from #chassisData

	select 
		A.Chassiskey,C.chassisNo,C.ChassisType,R.OrderKey,OH.OrderNo,R.OrderDetailKey,OD.ContainerNo, ODS.Description as OrderDetailStatus,
		R.LegKey, L.LegID	,R.FromLocation, R.ToLocation, 
		R.DriverKey, D.DriverID, isnull(D.FirstName,'') + ' ' + isnull( D.LastName,'') as DriverName,
		A.StatusKey as ChassisStatusKey
	from  
		#chassisData A 
		Left join [dbo].Routes R (Nolock) on A.RouteKey = R.RouteKey
		left join [dbo].Chassis C (Nolock) on C.chassisKey = A.ChassisKey
		left Join [dbo].OrderDetail OD (Nolock) on OD.OrderDetailKey = A.OrderDetailKey
		Left Join [dbo].OrderHeader OH on OH.OrderKey = OD.OrderKey
		left Join [dbo].Leg L (Nolock) on L.LegKey = R.LegKey
		left Join [dbo].Driver D (Nolock) on D.DriverKey = R.DriverKey
		LEft join [dbo].OrderDetailStatus ODS (nolock) on OD.status = ODS.Status
	where
		(isnull(@ChassisKey,0) = 0 OR C.chassisKey = @ChassisKey) AND
		(isnull(@ContainerNo,'') = '' OR OD.ContainerNo like '%' + @ContainerNo + '%' ) AND
		(isnull(@LegKey,0) = 0 OR R.LegKey = @LegKey) AND
		(ISNULL(@ContainerStatusKey,0) = 0 OR OD.Status = @ContainerStatusKey) AND
		(ISNULL(@DriverKey,0) = 0 OR R.DriverKey = @DriverKey) 
		--(isnull(@ChassisStatusKey,0) = 0 OR a.StatusKey = @ChassisStatusKey)
END
