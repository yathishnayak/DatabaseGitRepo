
CREATE proc [dbo].[TMS_Integration_GetScheduleAndActuals_Flexport_BKP20241114] -- TMS_Integration_GetScheduleAndActuals_Flexport 123826, 47958 
(
	@TMS_OrderKey	int,
	@DataKey		int
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	declare @OrderType varchar(20) = '',
			@SiteID	varchar(10) = 'Flexport',
			@Custkey int = 0

	select @OrderType = OT.OrderType, @Custkey = CustKey
	from OrderHeader OH WITH (NOLOCK)
	inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
	where OrderKey = @TMS_OrderKey

	delete from TKT_RouteDataNew where routekey in 
		(select distinct a.routekey 
		from TKT_RouteDataNew  a
		left join routes RT on a.RouteKey = Rt.RouteKey and a.TMS_LegKey = Rt.LegKey
		where a.orderkey = @TMS_OrderKey and Rt.routekey is null)

	exec [UPDATE_TKT_ROUTESDATANEW_ONReverseMapping] @TMS_OrderKey

	select * into #TempData from TempPickupDelivery where 1=0
	
	if(@OrderType = 'Import')
	Begin
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum)
		select *, ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) as StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey,  DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID, 'FROM' as StopType,
			isnull(isnull(RT.PickupDateTo, RT.PickupDateFrom),RT.ActualDeparture) as SchedPickup, 
			CASE WHEN LocationType = 'ER' THEN ISNULL(RT.EmptySetDate, LD.DateCreated)  ELSE RT.ActualDeparture END as ActualPickup,
			null as SchedDelivery, null as ActualDelivery
			from TKT_RouteDataNew DT
			inner join Routes RT WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD WITH (NOLOCK) on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT WITH (NOLOCK)  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR WITH (NOLOCK) ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID =@SiteID
				AND TR.TMS_RouteKey = RT.RouteKey 
			inner join integration_jcb.dbo.Flexpro_StopList SL on TR.StopKey = SL.StopKey and Dt.LocationType = SL.facilityCode
			LEFT JOIN	AuditLogDetail LD WITH (NOLOCK) ON OD.OrderDetailKey = LD.RefKey  AND Comments LIKE '%Container Marked Empty%'
			where  OT.OrderType = 'IMPORT' and isnull(RT.IsDryRun ,0) = 0 and DT.LocationType IN ( 'SF','EP','ER')
			and SD.SiteID = @SiteID --and SL.stopNumber = 1
			and OD.Orderkey = @TMS_OrderKey and TR.DataKey = @DataKey
		) A

		declare @CntImp int = 0
		select @CntImp = count(1) from #TempData
	
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum)
		select *, @CntImp + ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) AS StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID,
			'TO' as StopType, null as SchedPickup, null as ActualPickup,
			isnull(isnull(RT.DeliveryDateTo,RT.DeliveryDateFrom),  RT.ActualArrival) as SchedDelivery, 
			RT.ActualArrival as ActualDelivery
			from TKT_RouteDataNew DT WITH (NOLOCK)
			inner join Routes RT WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD WITH (NOLOCK) on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT WITH (NOLOCK)  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR WITH (NOLOCK) ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID
				AND TR.TMS_RouteKey = RT.RouteKey 
			inner join integration_jcb.dbo.Flexpro_StopList SL WITH (NOLOCK) on TR.StopKey = SL.StopKey and Dt.LocationType = SL.facilityCode
			where OT.OrderType = 'Import' and isnull(RT.IsDryRun ,0) = 0
				and DT.LocationType in ('ST','RT')
			and SD.SiteID = @SiteID --and SL.stopNumber in (2,3)
			and OD.OrderKey = @TMS_OrderKey and TR.DataKey = @DataKey
		) A
		
	END

	if(@OrderType = 'Export')
	Begin
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum)
		select *, ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) as StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID, 'FROM' as StopType,
			isnull(isnull(RT.PickupDateTo,RT.PickupDateFrom),RT.ActualDeparture) as SchedPickup, 
			RT.ActualDeparture as ActualPickup,
			null as SchedDelivery, null as ActualDelivery
			from TKT_RouteDataNew DT WITH (NOLOCK)
			inner join Routes RT WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD WITH (NOLOCK) on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR WITH (NOLOCK) ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID 
				AND TR.TMS_RouteKey = RT.RouteKey
			inner join integration_jcb.dbo.Flexpro_StopList SL WITH (NOLOCK) on TR.StopKey = SL.StopKey and DT.LocationType = SL.facilityCode
			where OT.OrderType = 'EXPORT' and isnull(RT.IsDryRun ,0) = 0
			and DT.LocationType IN ( 'SF','EP')
			and SD.SiteID = @SiteID 
			and OD.Orderkey = @TMS_OrderKey  and TR.DataKey = @DataKey
		) A
	
		declare @CntExp int = 0
		select @cntExp = count(1) from #TempData

		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum)
		select *, @CntExp + ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) AS StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID,
			'TO' as StopType,  null as SchedPickup, null as ActualPickup,
			isnull(isnull(RT.DeliveryDateTo,RT.DeliveryDateFrom),RT.ActualArrival) as SchedDelivery, 
			RT.ActualArrival as ActualDelivery
			from TKT_RouteDataNew DT WITH (NOLOCK)
			inner join Routes RT WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD WITH (NOLOCK) on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT WITH (NOLOCK)  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L WITH (NOLOCK) on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR WITH (NOLOCK) ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID
				AND TR.TMS_RouteKey = RT.RouteKey
			inner join integration_jcb.dbo.Flexpro_StopList SL WITH (NOLOCK) on TR.StopKey = SL.StopKey and Dt.LocationType = SL.facilityCode
			where OT.OrderType = 'Export' and isnull(RT.IsDryRun ,0) = 0
				and DT.LocationType in ('ST','RT')
			and SD.SiteID = @SiteID --and SL.stopNumber =2
			and OD.OrderKey = @TMS_OrderKey  and TR.DataKey = @DataKey
		) A

	End
	
	--select * from #TempData
	
	SELECT top 1 OH.OrderKey, TH.DataKey, Th.SiteID, TMS_OrderKey, WorkOrdernumber, WorKOrderDate, OH.status,
			ContainerData = ( select OD.OrderDetailKey, TC.ContainerKey, OD.ContainerNo, OD.status,
			STOPDATA = (
				SELECT  RouteKey, LegKey, StopKey, TMS_LegKey, TMS_RouteKey,
					SchedPickup, SchedDelivery, ActualPickup, ActualDelivery, StopNum
				FROM #TempData A
				FOR JSON PATH
				)
				from TMS_integration_Container TC WITH (NOLOCK)
				inner join OrderDetail OD WITH (NOLOCK) on TC.TMS_OrderDetailKey = OD.orderDetailKey 
				where TC.DataKey = TH.DataKey and TC.SiteID = TH.SiteID
				FOR JSON PATH
			)
	FROM OrderHeader OH WITH (NOLOCK)
	inner join OrderDetail OD WITH (NOLOCK) on Oh.OrderKey = OD.OrderKey
	inner join TMS_Integration_Header TH WITH (NOLOCK) on OH.OrderKey = TH.TMS_OrderKey 
	inner join TMS_Integration_Container TC WITH (NOLOCK) on TH.DataKey = TC.DataKey and TH.SiteID = Tc.SiteID and TC.TMS_OrderDetailKey = OD.OrderDetailKey
	WHERE OH.OrderKey = @TMS_OrderKey and TH.SiteID = @SiteID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END

