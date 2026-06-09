


CREATE procedure [dbo].[Get_ContainerGlobalSearch_Main] --[Get_ContainerGlobalSearch_Main]

(
	@ContainerNo			varchar(50) = '',
	@ContainerStatusKey		int = 0,
	@OrderNo				Varchar(50) ='',
	@CustomerKey			int,
	@ContainerType			varchar(50) = ''
)
as
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	/*
	Container No, 
	Customer
	Order Type
	Last Free Day
	Status
	Current Location
	Appt Date
	*/

	create table #ContainerData
	(
		OrderdetailKey	int,
		RouteKey		int,
		StatusKey	int,
		ContainerNo  varchar(50)
	)

	insert into #ContainerData (OrderdetailKey)
	select OrderdetailKey
	from OrderDetail WITH (NOLOCK) 


	update A set OrderdetailKey = MaxODKey, RouteKey = B.RouteKey, StatusKey = CStatusKey, ContainerNo = B.ContainerNo
	--select *
	from #ContainerData A
	inner join (
			Select  Rt.OrderDetailKey as MaxODKey , 2 as CStatusKey, Rt.RouteKey, OD.ContainerNo
			from (
					select  max(RT.RouteKey) as MaxRTKey,  ContainerNo ,2 CStatusKey
					from Routes RT  WITH (NOLOCK) 
					inner join OrderDetail OD WITH (NOLOCK)  on OD.OrderDetailKey = RT.OrderDetailKey
					where ActualDeparture is not null and ActualArrival is null
					group by OD.OrderDetailKey, ContainerNo
					) A 
				inner join Routes RT WITH (NOLOCK)  on A.MaxRTKey = Rt.RouteKey
				inner join OrderDetail OD WITH (NOLOCK)  on OD.OrderDetailKey = RT.OrderDetailKey
			) B on A.OrderDetailKey = B.MaxODKey
	

		update A set OrderdetailKey = MaxODKey, RouteKey = B.RouteKey, StatusKey = CStatusKey, ContainerNo = B.ContainerNo
	--select *
	from #ContainerData A
	inner join (
			Select  Rt.OrderDetailKey as MaxODKey , 3 as CStatusKey, Rt.RouteKey, ContainerNo
			from (
					select OD.OrderDetailKey, max(RT.RouteKey) as MaxRTKey, ContainerNo
					from Routes RT WITH (NOLOCK) 
					inner join OrderDetail OD WITH (NOLOCK)  on OD.OrderDetailKey = RT.OrderDetailKey
					where ActualArrival is not null and ActualDeparture is not null
					group by ContainerNo, OD.OrderDetailKey
				) A
				inner join Routes RT WITH (NOLOCK)  on A.MaxRTKey = Rt.RouteKey
				inner join Leg L WITH (NOLOCK)  on Rt.LegKey = L.LegKey
				where L.ToLocation = 'PORT'
			) B on A.OrderDetailKey = B.MaxODKey 
	--where ISNULL(A.OrderdetailKey,0) < b.MaxODKey


		update A set OrderdetailKey = MaxODKey, RouteKey = B.RouteKey, StatusKey = CStatusKey, ContainerNo = B.ContainerNo
	--select *
	from #ContainerData A
	inner join (
		Select  Rt.OrderDetailKey as MaxODKey , 4 as CStatusKey, Rt.RouteKey, ContainerNo
		from (
				select OD.OrderDetailKey, max(RT.RouteKey) as MaxRTKey, ContainerNo
				from Routes RT WITH (NOLOCK) 
				inner join OrderDetail OD WITH (NOLOCK)  on OD.OrderDetailKey = RT.OrderDetailKey
				inner Join Leg L  WITH (NOLOCK) on  RT.LegKey = L.LegKey
				where ActualArrival is not null and ActualDeparture is not null
				group by ContainerNo, OD.OrderDetailKey
			) A
			inner join Routes RT  WITH (NOLOCK) on A.MaxRTKey = Rt.RouteKey
			inner join Leg L  WITH (NOLOCK) on Rt.LegKey = L.LegKey
			where L.ToLocation in ('YARD','Depot','Warehouse')	 
		) B on  A.OrderDetailKey = B.MaxODKey
	--where  ISNULL(A.OrderdetailKey,0) < b.MaxODKey


		update A set OrderdetailKey = MaxODKey, RouteKey = B.RouteKey, StatusKey = CStatusKey, ContainerNo = B.ContainerNo
	--select *
	from #ContainerData A
	inner join (
		Select  Rt.OrderDetailKey as MaxODKey , 5 as CStatusKey, Rt.RouteKey, ContainerNo
		from (
			select OD.OrderDetailKey, max(RT.RouteKey) as MaxRTKey, ContainerNo
			from Routes RT WITH (NOLOCK) 
			inner join OrderDetail OD  WITH (NOLOCK) on OD.OrderDetailKey = RT.OrderDetailKey
			inner Join Leg L  WITH (NOLOCK) on  RT.LegKey = L.LegKey
			where ActualArrival is not null and ActualDeparture is not null
			group by ContainerNo, OD.OrderDetailKey
		) A
		inner join Routes RT WITH (NOLOCK)  on A.MaxRTKey = Rt.RouteKey
		inner join Leg L WITH (NOLOCK)  on Rt.LegKey = L.LegKey
		where L.ToLocation in ('Consignee','Shipper','Customer')
	) B on  A.OrderDetailKey = B.MaxODKey
	--where  ISNULL(A.OrderdetailKey,0) < b.MaxODKey

	update #ContainerData 
	set StatusKey = 1
	where isnull(StatusKey ,0) = 0

	select 
		OH.OrderKey, OH.OrderNo, OD.OrderDetailKey, R.RouteKey, OD.ContainerNo, CS.Description as ContainerSize, OD.Status as OrderDetailStatusKey, ODS.Description as OrderDetailStatus,
		L.LegKey, L.LegID,R.FromLocation, R.ToLocation, R.ActualDeparture, R.ActualArrival,
		D.DriverKey, D.DriverID, isnull(D.FirstName,'') + ' ' + isnull( D.LastName,'') as DriverName,
		A.StatusKey as CurrentLocationKey,
		Case 
		when A.StatusKey = 1 then 'OPEN' 
		when A.StatusKey = 2 then 'IN USE' 
		When A.StatusKey = 3 then 'IN PORT'
		When A.StatusKey = 4 then 'IN YARD' 
		When A.StatusKey = 5 then 'CUSTOMER' 
		End as CurrentLocationStatus,
		C.CustID, C.CustName
	from  
		#ContainerData A
		Left Join [dbo].Routes R WITH (NOLOCK)  on A.RouteKey = R.RouteKey
		left Join [dbo].OrderDetail OD WITH (NOLOCK)  on OD.OrderDetailKey = A.OrderDetailKey
		Left Join [dbo].OrderHeader OH WITH (NOLOCK)  on OH.OrderKey = OD.OrderKey
		left Join [dbo].Leg L WITH (NOLOCK)  on L.LegKey = R.LegKey
		left Join [dbo].Driver D WITH (NOLOCK)  on D. DriverKey = R.DriverKey
		left Join [dbo].ContainerSize CS WITH (NOLOCK)  on CS.ContainerSizeKey = OD.ContainerSizeKey
		left Join [dbo].OrderDetailStatus ODS WITH (NOLOCK)  on ODS.Status = OD.Status
		leFT JOIN DBO.CUSTOMER C WITH (NOLOCK)  ON OH.CustKey = C.CUSTKEY
		where
		(isnull(@ContainerNo,'') = '' OR OD.ContainerNo like '%' + @ContainerNo + '%' ) AND
		(ISNULL(@ContainerStatusKey,0) = 0 OR OD.Status = @ContainerStatusKey) AND
		(ISNULL(@OrderNo,'') = '' OR  OH.OrderNo like '%' + @OrderNo + '%') AND
		(ISNULL(@CustomerKey,0) = 0 or oh.CustKey =- @CustomerKey )
		
END
